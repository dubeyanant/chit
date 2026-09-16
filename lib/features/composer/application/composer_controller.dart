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
/// **The five-second prompt's timer lives here, not in the widget**
/// (ARCHITECTURE.md §4.3), so that a rebuild does not restart it. A field that
/// is laid out again — a keyboard arriving, the action row growing by two
/// controls — has not been idle for any less time than it was a frame ago.
@riverpod
class ComposerController extends _$ComposerController {
  /// How long the field waits before it offers the prompt — BEHAVIOUR.md §3.3.
  ///
  /// **A product rule, not an animation.** It is not in the pace table, it
  /// does not move under reduced motion, and it never changes: a prompt shown
  /// immediately is an instruction and a prompt shown after a pause is an
  /// offer. People who know what they want to say never see it.
  static const Duration idle = Duration(seconds: 5);

  Timer? _idle;

  @override
  ComposerState build() {
    ref.onDispose(_cancelPrompt);
    return _openChit();
  }

  /// A blank chit, stamped now, with its slow signals on the way.
  ComposerState _openChit() {
    final AmbientCapture capture = ref.read(ambientCaptureProvider);
    final AmbientStamp opened = capture.open();

    // Deliberately not awaited: this is the *point* of ADR-007. The chit is
    // on screen with its time before either service has been asked anything.
    unawaited(_settle(capture, opened));

    _armPrompt();
    return ComposerState(stamp: opened);
  }

  /// Starts the five seconds again — at open, and whenever the field goes back
  /// to empty.
  ///
  /// **M5:** BEHAVIOUR.md §3.5's note occupies this same space and says more
  /// than the prompt would, so a chit whose transcription failed gets the note
  /// and no prompt. The branch belongs here, with `sttFailed`, when the note
  /// is drawn.
  void _armPrompt() {
    _idle?.cancel();
    _idle = Timer(idle, () {
      if (!ref.mounted) return;
      state = state.copyWith(showPrompt: true);
    });
  }

  void _cancelPrompt() {
    _idle?.cancel();
    _idle = null;
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
  ///
  /// The prompt goes with the first character and the five seconds start
  /// again the moment the field is empty (BEHAVIOUR.md §3.3) — including when
  /// it is emptied a character at a time, which is a user who has stopped
  /// rather than one who is typing.
  void edit(String text) {
    final bool blank = text.trim().isEmpty;

    state = state.copyWith(
      text: text,
      textOrigin: blank ? null : TextOrigin.typed,
      showPrompt: false,
    );

    if (blank) {
      _armPrompt();
    } else {
      _cancelPrompt();
    }
  }

  /// **Discard** — BEHAVIOUR.md §3.1.
  ///
  /// Opens a fresh chit rather than emptying this one, which means a **new
  /// stamp**: ADR-026. Discarding at 3:42 and writing at 4:10 must not file
  /// the chit at 3:42.
  void discard() => state = _openChit();
}
