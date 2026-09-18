import 'package:freezed_annotation/freezed_annotation.dart';

import '../prompts.dart';
import 'ambient_stamp.dart';

part 'composer_state.freezed.dart';

@freezed
abstract class ComposerState with _$ComposerState {
  const ComposerState._();

  const factory ComposerState({
    required AmbientStamp stamp,

    @Default('') String text,

    @Default(false) bool showPrompt,

    String? audioTempPath,

    Duration? audioDuration,

    @Default(false) bool isRecording,

    @Default(false) bool microphoneRefused,
  }) = _ComposerState;

  bool get canSave => text.trim().isNotEmpty || audioTempPath != null;

  String get prompt => Prompts.forStamp(stamp);

  bool get hasAudio => audioTempPath != null;
}
