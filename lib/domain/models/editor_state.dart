import 'package:freezed_annotation/freezed_annotation.dart';

import 'audio_edit.dart';
import 'chit.dart';
import 'photo_edit.dart';

part 'editor_state.freezed.dart';

@freezed
abstract class EditorState with _$EditorState {
  const EditorState._();

  const factory EditorState({
    required Chit chit,

    required String text,

    @Default(AudioEdit.keep()) AudioEdit audio,

    @Default(PhotoEdit.keep()) PhotoEdit photo,

    @Default(false) bool microphoneRefused,
  }) = _EditorState;

  bool get hasAudio => switch (audio) {
    KeepAudio() => chit.hasAudio,
    RemoveAudio() => false,
    ReplaceAudio() => true,
  };

  String? get audioPath => switch (audio) {
    KeepAudio() => chit.audioPath,
    RemoveAudio() => null,
    ReplaceAudio(:final String tempPath) => tempPath,
  };

  Duration? get audioDuration => switch (audio) {
    KeepAudio() => chit.audioDuration,
    RemoveAudio() => null,
    ReplaceAudio(:final Duration duration) => duration,
  };

  bool get hasPhoto => switch (photo) {
    KeepPhoto() => chit.hasPhoto,
    RemovePhoto() => false,
    ReplacePhoto() => true,
  };

  String? get photoPath => switch (photo) {
    KeepPhoto() => chit.photoPath,
    RemovePhoto() => null,
    ReplacePhoto(:final String tempPath) => tempPath,
  };

  bool get isDirty =>
      text.trim() != (chit.text ?? '') ||
      audio is! KeepAudio ||
      photo is! KeepPhoto;

  bool get holdsAnything => text.trim().isNotEmpty || hasAudio || hasPhoto;

  bool get canSave => isDirty && holdsAnything;

  bool get shouldPromptOnLeave => isDirty;
}
