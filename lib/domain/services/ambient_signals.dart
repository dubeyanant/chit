import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/motion_state.dart';
import '../models/weather_condition.dart';
import 'ambient_capture.dart';

part 'ambient_signals.g.dart';

/// A capture's three answers, with no time attached.
///
/// Separate from `AmbientStamp` because a stamp belongs to *a chit* and always
/// has the one field that cannot be missing. This is what the services said,
/// which is a different thing and may be entirely empty.
typedef AmbientReading = ({
  WeatherCondition? weather,
  double? lat,
  double? lon,
  MotionState? motion,
});

/// The three best-effort signals, held for the life of the process —
/// **ADR-042**.
///
/// **They are captured twice and never in between**: once at launch, and again
/// when a chit is saved. There is no timer, no time-to-live, and no refresh
/// when the app returns to the foreground.
///
/// *The app used to ask both services on every chit open*, which meant four
/// taps of **Discard** made four network calls. The record that governed
/// Discard asked for an implementation "as unbothered by that as the fakes
/// are" without saying how; this is how. Nothing is asked unless a chit is
/// actually written.
///
/// **What is held here is the preview; what a saved chit carries is the
/// record.** They are different values on purpose. The stamp on the open chit
/// draws whatever landed at launch, and on a phone that has been open all day
/// that can be hours old. The staleness is confined to the screen: [refresh]
/// runs before a row is written (ADR-040), so no chit is ever *recorded* with
/// a signal from launch.
///
/// **It holds no clock.** The time on a stamp is read where it is used — by
/// the composer for what it shows, and by `save` for what it writes — because
/// a time held here would be the one thing in the app that went stale
/// dangerously rather than harmlessly.
@Riverpod(keepAlive: true)
class AmbientSignals extends _$AmbientSignals {
  /// Nothing, and what the app holds until the launch capture lands.
  ///
  /// A `null` here and a signal that came back empty are the same thing to
  /// every reader, which is ADR-007's whole point: what did not arrive is not
  /// drawn, and nothing asks why.
  static const AmbientReading nothing = (
    weather: null,
    lat: null,
    lon: null,
    motion: null,
  );

  @override
  AmbientReading build() => nothing;

  /// The launch capture. **Fired after the first frame, and never awaited.**
  ///
  /// README §1 — *opening the app costs nothing* — is a startup requirement as
  /// much as a visual one, so this cannot sit in front of a paint. The stamp on
  /// the open chit simply gains a word and a pin when it lands, which is the
  /// behaviour ADR-007 already describes.
  ///
  /// Safe to call more than once; a second call is a [refresh].
  Future<void> prime() => refresh();

  /// Reads both services again and replaces what is held.
  ///
  /// Called by the composer's `save` (ADR-040), so that what goes into the row
  /// is what is true now rather than what was true at launch. Never throws:
  /// the capture underneath turns every failure into a `null` (ADR-007).
  Future<void> refresh() async {
    final AmbientReading reading = await ref
        .read(ambientCaptureProvider)
        .read();

    // The container may be gone — the app closed while a capture was in
    // flight. Writing to a disposed notifier is the one way this could throw,
    // and a signal nobody is waiting for is not worth an error.
    if (!ref.mounted) return;

    state = reading;
  }
}
