import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/ambient_stamp.dart';
import '../../../domain/models/chit.dart';
import '../../../domain/models/composer_state.dart';
import '../../../domain/services/ambient_capture.dart';

part 'composer_controller.g.dart';

/// The open chit's state.
///
/// **Synchronous by construction.** ADR-007 says nothing about ambient capture
/// may delay the composer, so `build` does not wait for anything: it takes the
/// instant half of the stamp from [AmbientCapture.open] and hands the slow half
/// to [AmbientCapture.settle], which lands whenever it lands. A
/// `FutureOr<ComposerState> build()` would give the open chit a loading state,
/// and a loading state is a spinner whether or not one is drawn.
///
/// **The stamp is captured once and held** (ADR-021). Nothing in here re-reads
/// the clock, and `save()` in group G must pass `state.stamp` rather than
/// capturing again — that is the whole decision, and it fails silently if it is
/// got wrong, because a re-captured stamp is still a perfectly plausible time.
///
/// The five-second prompt's timer belongs here too, not in the widget
/// (ARCHITECTURE.md §4.3). It arrives with TASKS.md group F.
@riverpod
class ComposerController extends _$ComposerController {
  @override
  ComposerState build() => _openChit();

  /// A blank chit, stamped now, with its slow signals on the way.
  ComposerState _openChit() {
    final AmbientCapture capture = ref.read(ambientCaptureProvider);
    final AmbientStamp opened = capture.open();

    // Deliberately not awaited: this is the *point* of ADR-007. The chit is
    // on screen with its time before either service has been asked anything.
    unawaited(_settle(capture, opened));

    return ComposerState(stamp: opened);
  }

  /// Puts the weather and the fix onto the stamp, if they arrive.
  Future<void> _settle(AmbientCapture capture, AmbientStamp opened) async {
    final AmbientStamp settled = await capture.settle(opened);

    // The chit this started for may be gone — discarded, saved, or the screen
    // disposed — in which case the answer is stale and belongs to nothing. The
    // identity check is on `capturedAt`, which is the one field that cannot
    // change under a chit and is different for every chit that follows it.
    if (!ref.mounted) return;
    if (state.stamp.capturedAt != opened.capturedAt) return;

    state = state.copyWith(stamp: settled);
  }

  /// What the user has typed.
  ///
  /// [TextOrigin.typed] the moment there is anything, and `null` again when
  /// the field is emptied — a chit with no words has no provenance for them,
  /// which is the pairing README §5's invariant is about. The transcript
  /// origins of BEHAVIOUR.md §3.4 arrive with the recogniser in M5.
  void edit(String text) {
    state = state.copyWith(
      text: text,
      textOrigin: text.trim().isEmpty ? null : TextOrigin.typed,
    );
  }

  /// **Discard** — BEHAVIOUR.md §3.1.
  ///
  /// Opens a fresh chit rather than emptying this one, which means a **new
  /// stamp**: ADR-026. Discarding at 3:42 and writing at 4:10 must not file
  /// the chit at 3:42.
  void discard() => state = _openChit();
}
