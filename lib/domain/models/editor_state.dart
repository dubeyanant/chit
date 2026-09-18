import 'package:freezed_annotation/freezed_annotation.dart';

import 'audio_edit.dart';
import 'chit.dart';

part 'editor_state.freezed.dart';

@freezed
abstract class EditorState with _$EditorState {
  const EditorState._();

  const factory EditorState({
    required Chit chit,

    required String text,

    @Default(AudioEdit.keep()) AudioEdit audio,

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

  bool get isDirty => text.trim() != (chit.text ?? '') || audio is! KeepAudio;

  bool get holdsAnything => text.trim().isNotEmpty || hasAudio;

  bool get canSave => isDirty && holdsAnything;

  bool get shouldPromptOnLeave => isDirty;
}
