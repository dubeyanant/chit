import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/audio_edit.dart';
import '../../../domain/models/chit.dart';
import '../../../domain/models/editor_state.dart';
import '../../../domain/models/photo_edit.dart';
import '../../../domain/repositories/chit_repository.dart';
import '../../../domain/services/audio_player.dart';
import '../../../domain/services/audio_recorder.dart';
import '../../../domain/services/photo_source.dart';
import '../../composer/application/recording_sink.dart';

part 'editor_controller.g.dart';

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

  void edit(String text) {
    final EditorState? current = _current;
    if (current == null) return;
    _set(current.copyWith(text: text));
  }

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

  Future<void> replacePhoto(PhotoOrigin from) async {
    final EditorState? current = _current;
    if (current == null) return;

    final String? shot = await ref.read(photoSourceProvider).take(from);
    if (shot == null || !ref.mounted) return;

    await _discardStagedPhoto(_current?.photo);
    if (!ref.mounted) return;

    final EditorState? now = _current;
    if (now == null) return;
    _set(now.copyWith(photo: PhotoEdit.replace(tempPath: shot)));
  }

  Future<void> removePhoto() async {
    final EditorState? current = _current;
    if (current == null || !current.hasPhoto) return;

    await _discardStagedPhoto(current.photo);
    if (!ref.mounted) return;

    final EditorState? now = _current;
    if (now == null) return;

    _set(
      now.copyWith(
        photo: now.chit.hasPhoto
            ? const PhotoEdit.remove()
            : const PhotoEdit.keep(),
      ),
    );
  }

  Future<void> save() async {
    final EditorState? current = _current;
    if (current == null || !current.canSave) return;

    if (current.audio is! KeepAudio) {
      await ref.read(audioPlayerProvider).stopIf(current.chit.id);
      if (!ref.mounted) return;
    }

    await ref
        .read(chitRepositoryProvider)
        .update(
          id: current.chit.id,
          text: current.text,
          audio: current.audio,
          photo: current.photo,
        );
  }

  Future<void> abandon() async {
    final EditorState? current = _current;
    if (current == null) return;
    await ref.read(audioPlayerProvider).stopIf(current.chit.id);
    if (!ref.mounted) return;
    await _discardStaged(current.audio);
    if (!ref.mounted) return;
    await _discardStagedPhoto(current.photo);
  }

  Future<void> delete() async {
    final EditorState? current = _current;
    if (current == null) return;

    await abandon();
    if (!ref.mounted) return;

    await ref.read(chitRepositoryProvider).delete(current.chit.id);
  }

  Future<void> _discardStaged(AudioEdit audio) async {
    if (audio case ReplaceAudio(:final String tempPath)) {
      await ref.read(chitRepositoryProvider).discardTemp(tempPath);
    }
  }

  Future<void> _discardStagedPhoto(PhotoEdit? photo) async {
    if (photo case ReplacePhoto(:final String tempPath)) {
      await ref.read(chitRepositoryProvider).discardTemp(tempPath);
    }
  }
}
