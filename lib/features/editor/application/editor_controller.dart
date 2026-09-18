import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/audio_edit.dart';
import '../../../domain/models/chit.dart';
import '../../../domain/models/editor_state.dart';
import '../../../domain/repositories/chit_repository.dart';
import '../../../domain/services/audio_player.dart';
import '../../../domain/services/audio_recorder.dart';
import '../../composer/application/recording_sink.dart';

part 'editor_controller.g.dart';

/// A saved chit being edited — **ADR-017, ADR-062**.
///
/// **Loaded once, not watched.** The thread and the calendar watch, because
/// two tabs must never disagree (DESIGN-SYSTEM.md §7); the editor is a screen
/// somebody is typing on, and a row re-emitting under a caret is a screen that
/// fights its own user. The only thing that writes this row while the editor
/// is open is the editor.
///
/// **Null means the chit is gone.** The screen leaves rather than drawing
/// nothing — an id can outlive its row across a delete, and a blank screen
/// with a back arrow is a dead end that says nothing about why.
///
/// **Everything done to the recording is staged** (TASKS.md D6): `audio` is
/// an [AudioEdit] that the repository applies at Save and that Cancel throws
/// away. It cannot be otherwise — a chit with neither words nor a take is a
/// row the database refuses — and it is what makes Cancel honest.
///
/// Keyed by id so two chits opened in one session are two states, and
/// auto-disposed so leaving the screen forgets it: unlike the recording
/// controller (ADR-057) nothing here outlives the screen. **Every decision the
/// screen draws is a getter on [EditorState]** (TASKS.md D11), which is what
/// lets ADR-031 hold: there is nothing here a test would need a widget for.
@riverpod
class EditorController extends _$EditorController implements RecordingSink {
  @override
  Future<EditorState?> build(String id) async {
    final Chit? chit = await ref.watch(chitRepositoryProvider).byId(id);
    if (chit == null) return null;
    return EditorState(chit: chit, text: chit.text ?? '');
  }

  EditorState? get _current => state.value;

  void _set(EditorState next) => state = AsyncData<EditorState?>(next);

  /// What the user has typed. Whether it is a *change* is [EditorState.isDirty]'s
  /// to say, not this method's.
  void edit(String text) {
    final EditorState? current = _current;
    if (current == null) return;
    _set(current.copyWith(text: text));
  }

  /// **Remove**, on the editor's pill — staged (D6).
  ///
  /// The recording stops sounding, because the pill that could pause it is
  /// about to go. A replacement that was staged and never saved is a temp file
  /// nobody will move, so it is discarded here; the stored recording is not
  /// touched until Save, which is the whole point of staging.
  ///
  /// What is staged afterwards depends on what was loaded: a chit that had a
  /// recording is now *remove*, a chit that had none is back to *keep* — which
  /// is no change at all, so a take recorded and removed again is not dirty.
  Future<void> removeAudio() async {
    final EditorState? current = _current;
    if (current == null || !current.hasAudio) return;

    await ref.read(audioPlayerProvider).stopIf(current.chit.id);
    if (!ref.mounted) return;

    await _discardStaged(current.audio);
    if (!ref.mounted) return;

    _set(
      current.copyWith(
        audio: current.chit.hasAudio
            ? const AudioEdit.remove()
            : const AudioEdit.keep(),
      ),
    );
  }

  @override
  void microphoneWasRefused() {
    final EditorState? current = _current;
    if (current == null) return;
    _set(current.copyWith(microphoneRefused: true));
  }

  @override
  void recordingStarted() {
    final EditorState? current = _current;
    if (current == null) return;
    _set(current.copyWith(microphoneRefused: false));
  }

  /// **Stop & keep** — the take is staged as a replacement (D6). A take that
  /// wrote nothing is nothing kept.
  @override
  void keepRecording(Recording? take) {
    final EditorState? current = _current;
    if (current == null || take == null) return;
    _set(
      current.copyWith(
        audio: AudioEdit.replace(
          tempPath: take.tempPath,
          duration: take.duration,
        ),
      ),
    );
  }

  @override
  void recordingCancelled() {}

  /// **Save chit** — writes the text and the staged audio edit in one call.
  ///
  /// Does nothing when there is nothing to save. The control is not drawn in
  /// that state, so this is the belt rather than the braces — but `canSave` is
  /// also what the repository would refuse, and refusing here is quieter.
  ///
  /// **A playing recording stops first** when the file under it is about to
  /// move or go — the same reason `ComposerController.save` stops the open
  /// chit's take. Leaving the screen afterwards is the screen's business.
  Future<void> save() async {
    final EditorState? current = _current;
    if (current == null || !current.canSave) return;

    if (current.audio is! KeepAudio) {
      await ref.read(audioPlayerProvider).stopIf(current.chit.id);
      if (!ref.mounted) return;
    }

    await ref
        .read(chitRepositoryProvider)
        .update(id: current.chit.id, text: current.text, audio: current.audio);
  }

  /// **Cancel**, answered *discard* — or the back gesture, the same way.
  ///
  /// The row is untouched by construction; what needs doing is only the temp
  /// file of a replacement that will now never be moved.
  Future<void> abandon() async {
    final EditorState? current = _current;
    if (current == null) return;
    await ref.read(audioPlayerProvider).stopIf(current.chit.id);
    if (!ref.mounted) return;
    await _discardStaged(current.audio);
  }

  Future<void> _discardStaged(AudioEdit audio) async {
    if (audio case ReplaceAudio(:final String tempPath)) {
      await ref.read(chitRepositoryProvider).discardTemp(tempPath);
    }
  }
}
