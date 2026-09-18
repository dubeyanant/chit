import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/clock.dart';
import '../../../domain/models/ambient_stamp.dart';
import '../../../domain/models/chit.dart';
import '../../../domain/models/composer_state.dart';
import '../../../domain/repositories/chit_repository.dart';
import '../../../domain/services/ambient_signals.dart';
import '../../../domain/services/audio_player.dart';
import '../../../domain/services/audio_recorder.dart';

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
/// Discard — itself gone since ADR-060 — made four network calls.* Capture now
/// happens twice in the life of
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
  /// The prompt goes with the first character and the five seconds start
  /// again the moment the field is empty (BEHAVIOUR.md §3.3) — including when
  /// it is emptied a character at a time, which is a user who has stopped
  /// rather than one who is typing.
  void edit(String text) {
    final bool blank = text.trim().isEmpty;

    state = state.copyWith(text: text, showPrompt: false);

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
  /// and that a second record used to contain, cannot happen at all now. The
  /// cost is that the stamp on the slip is a **preview**: it shows when the
  /// chit was opened, and a chit sat on for twenty minutes lands in the thread
  /// carrying a later time.
  ///
  /// **The row is written first, and corrected after only if it is stale**
  /// (ADR-042, ADR-045). Nothing about a save waits on a network call: the
  /// insert goes out with whatever `AmbientSignals` is holding. If that reading
  /// is less than `AmbientSignals.freshFor` old it is already right and the row
  /// is left alone — a burst of chits in one sitting costs one capture, not one
  /// each. Only a stale reading is patched, and since §3.6 draws nothing for a
  /// `null` even that is usually invisible.
  ///
  /// Saving then opens a new chit through `_openChit()`, which since ADR-060
  /// is the only way a chit comes into existence.
  ///
  /// Does nothing when there is nothing to save. The control is not drawn in
  /// that state, so this is the belt rather than the braces — but `canSave` is
  /// also what the repository would refuse, and refusing here is quieter.
  Future<void> save() async {
    final ComposerState chit = state;
    if (!chit.canSave) return;

    // **The take stops sounding before it moves.** Save hands the file to
    // `AudioStore`, which renames it out of the cache, and the pill playing it
    // is gone from the screen a frame later — a player left running would go
    // on playing a recording nothing on screen could stop.
    if (chit.hasAudio) {
      await ref.read(audioPlayerProvider).stopIf(Playback.openChit);
      if (!ref.mounted) return;
    }

    final DateTime now = ref.read(clockProvider).now();
    final AmbientReading held = ref.read(ambientSignalsProvider);
    final bool fresh = held.isFreshAt(now);

    final Chit saved = await ref
        .read(chitRepositoryProvider)
        .save(
          stamp: AmbientStamp(
            capturedAt: now,
            weather: held.weather,
            lat: held.lat,
            lon: held.lon,
            motion: held.motion,
          ),
          text: chit.text,
          audioTempPath: chit.audioTempPath,
          audioDuration: chit.audioDuration,
        );

    // **Inside the window, nothing is asked at all** — ADR-045. What was
    // written was read less than `freshFor` ago, so it is both what the row
    // should say and what the next chit should preview. Refreshing anyway
    // would cost exactly what this decision exists to stop paying: a GPS fix
    // and a network call for every chit in a sitting.
    //
    // Outside it, deliberately not awaited — the chit is already in the
    // thread, and this is the half of ADR-042 that must never be in front of
    // the user.
    if (!fresh) unawaited(_refreshAmbience(saved.id));

    if (!ref.mounted) return;
    state = _openChit();
  }

  /// The stamp the preview is drawn from: **the clock now**, and the ambience
  /// in hand.
  ///
  /// The reading may be empty — at launch, before the first capture has landed,
  /// or on an install where location was refused. That is the ordinary ADR-007
  /// outcome and the slip simply shows a time.
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

  /// Reads the services again and corrects the row — **only when the reading
  /// the row was written from had gone stale** (ADR-045).
  ///
  /// It does two jobs at once and that is the point: the fresh answer both
  /// patches the row and becomes what the next chit previews, so one capture
  /// serves the record and the screen.
  ///
  /// **`createdAt` is never touched** — moving it would
  /// move the chit in the thread and on the strip, and across a midnight it
  /// would move it to another day. `updatedAt` does not move either, because
  /// ADR-014 reserves that for a change to the *text*.
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

  /// The sheet is up — BEHAVIOUR.md §3.4.
  ///
  /// The prompt goes: it offers something to write about, and somebody who is
  /// speaking has already found one.
  ///
  /// **A refusal that has since been granted stops being said.** This is one
  /// of the two places the note clears now that Discard is gone (ADR-060); the
  /// other is [save], which opens a fresh chit. Getting as far as the sheet
  /// means permission was given, so a line saying it was withheld is stale.
  void recordingStarted() {
    _cancelPrompt();
    state = state.copyWith(
      isRecording: true,
      showPrompt: false,
      microphoneRefused: false,
    );
  }

  /// The sheet was dismissed without keeping anything — nothing is attached
  /// and the field is untouched.
  ///
  /// The five seconds start again on a chit that is still empty, because that
  /// is a chit nothing has happened to.
  void recordingCancelled() {
    state = state.copyWith(isRecording: false);
    if (!state.canSave) _armPrompt();
  }

  /// Permission was withheld — TASKS.md D2.
  ///
  /// The sheet does not open and the microphone does not move. It is the
  /// controller that records this rather than the widget so that the rule has
  /// a test at all (ADR-031).
  void microphoneWasRefused() =>
      state = state.copyWith(isRecording: false, microphoneRefused: true);

  /// **Stop & keep** — BEHAVIOUR.md §3.4, ARCHITECTURE.md §4.4.
  ///
  /// The recording is attached and **the field is left exactly as it was**: a
  /// chit can hold words, a recording, or both, and which of the two came
  /// first is not something the chit records.
  ///
  /// [recording] is nullable because a take that wrote nothing is nothing —
  /// the platform refused, or produced no file. That closes the sheet and
  /// changes nothing else.
  void keepRecording(Recording? recording) {
    final ComposerState chit = state;
    if (recording == null) {
      state = chit.copyWith(isRecording: false);
      return;
    }

    // The prompt is spent: it offers something to write about, and somebody
    // who has just recorded has found one.
    _cancelPrompt();

    state = chit.copyWith(
      audioTempPath: recording.tempPath,
      audioDuration: recording.duration,
      isRecording: false,
      showPrompt: false,
    );
  }

  /// **Remove**, on the audio pill — ADR-060.
  ///
  /// *This is what is left of the open chit's Discard*, which cleared the
  /// whole chit and is gone: the words can be cleared by selecting them, so
  /// dropping the take was the only thing it uniquely did, and the pill is
  /// where the take is. (The recording sheet's Discard is a different control
  /// and stays — ADR-055.) The field is not touched here: a recording is not
  /// words, and removing one is not an edit to anything written.
  ///
  /// The take goes for good (ADR-008). The screen is cleared first and the
  /// file deleted after: nothing about a disk write should be in front of
  /// somebody who has just removed a recording.
  ///
  /// **The five seconds start again on a chit this empties**, because a chit
  /// nothing is left in is a chit nothing has happened to (BEHAVIOUR.md §3.3).
  Future<void> removeTake() async {
    final String? take = state.audioTempPath;
    if (take == null) return;

    state = state.copyWith(audioTempPath: null, audioDuration: null);
    if (!state.canSave) _armPrompt();

    await ref.read(audioPlayerProvider).stopIf(Playback.openChit);
    await ref.read(chitRepositoryProvider).discardTemp(take);
  }
}
