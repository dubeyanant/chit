import 'package:freezed_annotation/freezed_annotation.dart';

part 'audio_edit.freezed.dart';

@freezed
sealed class AudioEdit with _$AudioEdit {
  const factory AudioEdit.keep() = KeepAudio;

  const factory AudioEdit.remove() = RemoveAudio;

  const factory AudioEdit.replace({
    required String tempPath,
    required Duration duration,
  }) = ReplaceAudio;
}
