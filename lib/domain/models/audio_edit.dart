import 'package:freezed_annotation/freezed_annotation.dart';

part 'audio_edit.freezed.dart';

/// What an edit does to a chit's recording — **ADR-063**, TASKS.md D5, D6.
///
/// A sealed union rather than two nullable parameters, so that *leave it
/// alone*, *take it away* and *put this one there instead* cannot be confused
/// for one another, and a switch over them is exhaustive (CLAUDE.md §4.1). The
/// editor stages one of these until Save; `ChitRepository.update` applies it
/// in the same write as the text.
@freezed
sealed class AudioEdit with _$AudioEdit {
  /// The recording stays as it is. The default, and what a text-only edit
  /// sends.
  const factory AudioEdit.keep() = KeepAudio;

  /// The recording goes. Refused by the repository if the chit would be left
  /// with nothing — README §5's invariant, and the reason the editor withholds
  /// Save in that state rather than letting this throw.
  const factory AudioEdit.remove() = RemoveAudio;

  /// The recording at [tempPath], [duration] long, takes the old one's place.
  const factory AudioEdit.replace({
    required String tempPath,
    required Duration duration,
  }) = ReplaceAudio;
}
