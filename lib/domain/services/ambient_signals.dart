import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/clock.dart';
import '../models/motion_state.dart';
import '../models/weather_condition.dart';
import 'ambient_capture.dart';

part 'ambient_signals.g.dart';

/// What the services said, and when they said it.
///
/// Separate from `AmbientStamp` because a stamp belongs to *a chit* and always
/// has the one field that cannot be missing. This is what the services
/// answered, which is a different thing and may be entirely empty.
///
/// `readAt` is **when the capture came back**, not when a chit was opened or
/// saved. It exists so that a save can tell whether what it is holding is
/// worth writing unchanged — ADR-045.
typedef AmbientReading = ({
  WeatherCondition? weather,
  double? lat,
  double? lon,
  MotionState? motion,
  DateTime? readAt,
});

/// Whether a held reading is recent enough to write into a row as it stands.
extension AmbientReadingFreshness on AmbientReading {
  /// `true` when this was read less than [AmbientSignals.freshFor] ago.
  ///
  /// A reading that never arrived is never fresh: `null` is not a value that
  /// was true five minutes ago, it is the absence of one.
  bool isFreshAt(DateTime now) {
    final DateTime? at = readAt;
    if (at == null) return false;

    final Duration age = now.difference(at);
    return !age.isNegative && age < AmbientSignals.freshFor;
  }
}

/// The three best-effort signals, held for the life of the process —
/// **ADR-042**, as amended by **ADR-045**.
///
/// **Captured at launch, and at a save that is holding something stale.** Once
/// after the first frame, and again when a chit is saved more than
/// `freshFor` after the last reading came back. There is no timer, no refresh
/// on resume, and no capture at all on a chit that is merely opened.
///
/// *The app used to ask both services on every chit open*, which meant four
/// taps of the open chit's **Discard** — itself gone since ADR-060 — made four
/// network calls. *And then it asked on every
/// save*, which meant a burst of chits in one sitting paid for a GPS fix each.
/// Neither is true now: a save inside the window writes what is already in
/// hand.
///
/// **What is held here is the preview; what a saved chit carries is the
/// record.** They can differ, and the staleness lives on the screen rather
/// than in the data.
///
/// **It holds a clock, and only to timestamp itself.** `readAt` is what makes
/// ADR-045's window checkable; no chit ever takes its time from here, because
/// a chit is stamped where it is saved (ADR-040).
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
    readAt: null,
  );

  /// **Five minutes.** Inside this, a save writes what is held rather than
  /// asking again — ADR-045.
  ///
  /// Long enough that a burst of chits in one sitting costs one capture, short
  /// enough that a chit written after a walk does not carry the weather from
  /// where the walk began. Weather barely moves in five minutes; a *place*
  /// can, which is what sets the ceiling rather than the floor.
  static const Duration freshFor = Duration(minutes: 5);

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
  /// Called after a save, always — a save inside [freshFor] skips the *patch*
  /// to the row, not the refresh (ADR-045). What the next chit previews should
  /// be the freshest thing the app knows, and this is the only thing that
  /// keeps it so.
  ///
  /// Never throws: the capture underneath turns every failure into a `null`
  /// (ADR-007). A capture that came back empty is still stamped `readAt` — it
  /// is a reading, and *nothing* is what it read.
  Future<void> refresh() async {
    final AmbientReading reading = await ref
        .read(ambientCaptureProvider)
        .read();

    // The container may be gone — the app closed while a capture was in
    // flight. Writing to a disposed notifier is the one way this could throw,
    // and a signal nobody is waiting for is not worth an error.
    if (!ref.mounted) return;

    state = (
      weather: reading.weather,
      lat: reading.lat,
      lon: reading.lon,
      motion: reading.motion,
      readAt: ref.read(clockProvider).now(),
    );
  }
}
