import 'package:freezed_annotation/freezed_annotation.dart';

import '../prompts.dart';
import 'ambient_stamp.dart';

part 'composer_state.freezed.dart';

/// What the open chit currently holds — ARCHITECTURE.md §4.1.
///
/// **There is no mode.** BEHAVIOUR.md §3.2 makes the composer one surface — a
/// live field with a microphone beside it — so this is a record of what the
/// chit *holds*, not a union of which way in the user picked. The five-panel
/// state machine an earlier version of the architecture described went with
/// the modes.
///
/// It is never a row. BEHAVIOUR.md §3.1: opening the app six times leaves
/// nothing behind, so this lives in `ComposerController` and nowhere else
/// until **Save chit** inserts.
///
/// **The stamp here is a preview** (ADR-040). It is what the slip draws — the
/// time the chit opened, and whatever ambience the app is holding — and it is
/// not what gets written: `save` reads the clock and the services again, and
/// the row carries that. *It used to be the value that became `createdAt`,
/// which is why nothing in the controller re-read it.*
@freezed
abstract class ComposerState with _$ComposerState {
  /// Lets this class carry getters. Freezed requires it.
  const ComposerState._();

  /// A chit opened with [stamp] and holding whatever the user has put in it.
  const factory ComposerState({
    /// Captured when the chit opened. Weather and location may arrive a moment
    /// later (ADR-007); [AmbientStamp.capturedAt] does not move when they do.
    required AmbientStamp stamp,

    /// The field's live content, and the user's throughout.
    @Default('') String text,

    /// Whether the five-second prompt is being offered — BEHAVIOUR.md §3.3.
    ///
    /// It is state rather than a widget's own business because the five
    /// seconds have to survive a rebuild: a timer in the widget restarts
    /// every time the field is laid out again (ARCHITECTURE.md §4.3).
    @Default(false) bool showPrompt,

    /// Set once a recording is kept, and cleared only by Discard. **M5.**
    String? audioTempPath,

    /// How long that recording runs. **M5.**
    Duration? audioDuration,

    /// Whether the recording sheet is up. **M5.**
    @Default(false) bool isRecording,

    /// Whether the microphone has been refused — TASKS.md D2. **M5.**
    ///
    /// Set the first time permission is withheld and cleared only by Discard.
    /// The microphone stays where it is and stays tappable: ADR-041 spends the
    /// app's one dialog on location, so the only way back is the OS, and a
    /// control that greys out reads as broken where one that explains reads as
    /// refused.
    @Default(false) bool microphoneRefused,
  }) = _ComposerState;

  /// Whether there is anything to save, and therefore anything to discard.
  ///
  /// This is the whole of BEHAVIOUR.md §3.1 and §4.1: **Discard** and **Save
  /// chit** appear when it is true, and an untouched chit shows neither,
  /// because there is nothing to save and nothing to discard.
  ///
  /// Whitespace is nothing. A field holding three spaces is an empty field,
  /// and README §5's invariant would refuse the row anyway — better to refuse
  /// to offer the button than to offer one that throws.
  bool get canSave => text.trim().isNotEmpty || audioTempPath != null;

  /// The words the five-second prompt offers — BEHAVIOUR.md §3.3, ADR-029.
  ///
  /// Derived from [stamp] rather than stored, so there is one answer and it
  /// cannot drift from the moment it is about. It changes once, if the weather
  /// settles (ADR-007) before the five seconds are up.
  String get prompt => Prompts.forStamp(stamp);

  /// Whether a recording has been kept. **M5.**
  ///
  /// BEHAVIOUR.md §3.2: a chit holds one recording, so once this is true the
  /// microphone retires rather than greying out — a control that retires reads
  /// as finished and a disabled one reads as broken.
  bool get hasAudio => audioTempPath != null;
}
