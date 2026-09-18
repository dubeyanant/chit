import 'package:freezed_annotation/freezed_annotation.dart';

import 'audio_edit.dart';
import 'chit.dart';

part 'editor_state.freezed.dart';

/// A saved chit being edited — BEHAVIOUR.md §4.5, ADR-017.
///
/// [chit] is the row **as it was loaded** and never changes while the screen
/// is open; [text] and [audio] are what the user has done to it since. Every
/// rule the editor's controls turn on is a getter over those three, so it can
/// be tested without a screen (ADR-031): whether Save shows,
/// whether leaving asks, whether the chit would still be a chit.
@freezed
abstract class EditorState with _$EditorState {
  /// Lets this class carry getters. Freezed requires it.
  const EditorState._();

  /// An editor open on [chit].
  const factory EditorState({
    /// The row when the editor opened. The baseline every *dirty* is measured
    /// against, and the source of everything the edit may not touch — the
    /// stamp, the day, the id.
    required Chit chit,

    /// The field's live content.
    required String text,

    /// What has been done to the recording, **staged until Save**.
    @Default(AudioEdit.keep()) AudioEdit audio,

    /// Whether the microphone has been refused on this screen — the same
    /// line as the open chit's (ADR-056), cleared by a later tap that gets as
    /// far as recording.
    @Default(false) bool microphoneRefused,
  }) = _EditorState;

  /// Whether the chit will hold a recording if this edit is saved.
  bool get hasAudio => switch (audio) {
    KeepAudio() => chit.hasAudio,
    RemoveAudio() => false,
    ReplaceAudio() => true,
  };

  /// What the pill plays: the stored recording, or the staged replacement —
  /// relative for the first, absolute for the second (ADR-008). Null when
  /// there is nothing to play.
  String? get audioPath => switch (audio) {
    KeepAudio() => chit.audioPath,
    RemoveAudio() => null,
    ReplaceAudio(:final String tempPath) => tempPath,
  };

  /// How long what the pill plays runs. Null with [audioPath].
  Duration? get audioDuration => switch (audio) {
    KeepAudio() => chit.audioDuration,
    RemoveAudio() => null,
    ReplaceAudio(:final Duration duration) => duration,
  };

  /// Whether saving would write anything different from what was loaded.
  ///
  /// **Differs from what was loaded, not was typed in.** Typing a character
  /// and deleting it again is not a change, and neither is a trailing space
  /// the save would trim — a prompt that fires on those is a prompt people
  /// learn to dismiss. The stored text is already trimmed, so comparing the
  /// trimmed field to it is comparing what *would* be saved to what *was*.
  bool get isDirty => text.trim() != (chit.text ?? '') || audio is! KeepAudio;

  /// Whether the chit would still be a chit — README §5's invariant, applied
  /// to what Save would write. False once a removal leaves nothing behind.
  bool get holdsAnything => text.trim().isNotEmpty || hasAudio;

  /// Whether **Save chit** is offered: something has changed, and what
  /// it would write is a chit. Cancel arrives with it and *Delete this chit*
  /// is there regardless, so an emptied chit is left with exactly those two.
  bool get canSave => isDirty && holdsAnything;

  /// Whether leaving raises the keep-or-discard prompt (ADR-017). It is
  /// [isDirty] under a name that says what it is for: the prompt guards a
  /// change, not a Save that happens to be unavailable.
  bool get shouldPromptOnLeave => isDirty;
}
