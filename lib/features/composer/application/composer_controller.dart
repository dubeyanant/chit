import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/clock.dart';
import '../../../domain/models/ambient_stamp.dart';
import '../../../domain/models/chit.dart';
import '../../../domain/models/composer_state.dart';
import '../../../domain/repositories/chit_repository.dart';
import '../../../domain/services/ambient_signals.dart';

part 'composer_controller.g.dart';

/// The open chit's state.
///
/// **Synchronous by construction.** ADR-007 says nothing about ambient capture
/// may delay the composer, so `build` does not wait for anything: it shows the
/// time at once and whatever ambience the app is already holding. A
/// `FutureOr<ComposerState> build()` would give the open chit a loading state,
/// and a loading state is a spinner whether or not one is drawn.
///
/// **This screen captures nothing** (ADR-042). *It used to drive an
/// `open()`/`settle()` pair on every chit open, which meant four taps of
/// Discard made four network calls.* Capture now happens twice in the life of
/// the app — at launch and at save — and what the slip draws is whatever
/// `AmbientSignals` is holding.
///
/// **The stamp on screen is a preview** (ADR-040). The row is stamped when
/// [save] runs, from a fresh clock read and a fresh capture, so a chit sat on
/// for twenty minutes lands in the thread carrying a later time than the slip
/// showed.
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

    // Watched, not read: when the launch capture lands (ADR-042) the open
    // chit's stamp gains its word and its pin without anything here asking.
    // That is the same arrival ADR-007 always described — what changed is that
    // the capture is the app's rather than this chit's.
    ref.watch(ambientSignalsProvider);

    return _openChit();
  }

  /// A blank chit, showing the time now and whatever ambience has landed.
  ///
  /// **This is a preview, not the record** (ADR-040, ADR-042). Nothing is
  /// captured here and nothing is written; [save] reads both the clock and the
  /// services again. The time shown is the moment the chit opened, and it does
  /// not tick — a stamp that updated itself would be an ambient loop, which
  /// ADR-027 and §6.4 have already ruled out.
  ComposerState _openChit() {
    _armPrompt();
    return ComposerState(stamp: _stampNow());
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

  /// **Save chit** — BEHAVIOUR.md §3.1. The only thing that inserts.
  ///
  /// **The chit is stamped here, not when it was opened — ADR-040.** The clock
  /// is read at this moment and becomes the row's `createdAt`, which decides
  /// where the chit falls in the thread, where its mark lands on the timeline,
  /// and which day it belongs to (ADR-006). *This reverses ADR-021, which
  /// stamped a chit when it opened.* The gain is that a chit is always filed on
  /// the day it was actually saved — the wrong-day case that ADR-021 created,
  /// and that a second record used to contain, cannot happen at all now. The cost is that the stamp on the slip
  /// is a **preview**: it shows when the chit was opened, and a chit sat on for
  /// twenty minutes lands in the thread carrying a later time.
  ///
  /// **The row is written first and the ambience is patched in after**
  /// (ADR-042). Nothing about a save waits on a network call: the insert goes
  /// out with whatever `AmbientSignals` is holding, a fresh read is started
  /// beside it, and the row is corrected when it lands. Since §3.6 draws
  /// nothing for a `null`, that correction is usually invisible — at worst a
  /// word appears in the thread a beat after the chit does.
  ///
  /// Saving then opens a new chit, the way [discard] does: the same
  /// `_openChit()`, so there is one way for a chit to come into existence.
  ///
  /// Does nothing when there is nothing to save. The control is not drawn in
  /// that state, so this is the belt rather than the braces — but `canSave` is
  /// also what the repository would refuse, and refusing here is quieter.
  Future<void> save() async {
    final ComposerState chit = state;
    if (!chit.canSave) return;

    final Chit saved = await ref
        .read(chitRepositoryProvider)
        .save(
          stamp: _stampNow(),
          text: chit.text,
          textOrigin: chit.textOrigin,
          audioTempPath: chit.audioTempPath,
          audioDuration: chit.audioDuration,
        );

    // Deliberately not awaited — the chit is already in the thread, and this
    // is the half of ADR-042 that must never be in front of the user.
    unawaited(_refreshAmbience(saved.id));

    if (!ref.mounted) return;
    state = _openChit();
  }

  /// The stamp a row is written with: **the clock now**, and the ambience in
  /// hand.
  ///
  /// The reading may be empty — at launch, before the first capture has landed,
  /// or on an install where location was refused. That is the ordinary ADR-007
  /// outcome and the row simply carries a time.
  AmbientStamp _stampNow() {
    final AmbientReading held = ref.read(ambientSignalsProvider);

    return AmbientStamp(
      capturedAt: ref.read(clockProvider).now(),
      weather: held.weather,
      lat: held.lat,
      lon: held.lon,
      motion: held.motion,
    );
  }

  /// Reads the services again and corrects the row that was just written.
  ///
  /// **`createdAt` is never touched** — moving it would move the chit in the
  /// thread and on the strip, and across a midnight it would move it to
  /// another day. Only the three best-effort fields change, and `updatedAt`
  /// does not move either: ADR-014 reserves that for a change to the *text*,
  /// and a signal arriving late is not an edit anybody made.
  Future<void> _refreshAmbience(String id) async {
    await ref.read(ambientSignalsProvider.notifier).refresh();

    if (!ref.mounted) return;
    final AmbientReading fresh = ref.read(ambientSignalsProvider);

    await ref
        .read(chitRepositoryProvider)
        .updateAmbient(
          id: id,
          weather: fresh.weather,
          lat: fresh.lat,
          lon: fresh.lon,
          motion: fresh.motion,
        );
  }

  /// **Discard** — BEHAVIOUR.md §3.1.
  ///
  /// Opens a fresh chit rather than emptying this one, so the slip's preview
  /// reads the moment it was discarded rather than a time that has passed.
  /// *Under ADR-021 this was load-bearing enough to have a record of its own,
  /// because the shown stamp was the one that got written. Under ADR-040 it is
  /// honesty about a preview — a smaller claim, and still the right behaviour.*
  void discard() => state = _openChit();
}
