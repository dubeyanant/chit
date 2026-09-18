import 'package:freezed_annotation/freezed_annotation.dart';

import '../services/speech_recognizer.dart';

part 'recording_state.freezed.dart';

/// What the recording sheet currently holds — BEHAVIOUR.md §3.4.
///
/// **The pending transcript lives here and never in `ComposerState.text`**
/// (TASKS.md D6). The field is written once, at Stop & keep, and the
/// recogniser never touches it again — which is what makes §3.4.1's promise
/// that the field remains the user's true by construction rather than by
/// discipline.
///
/// It is not a row and it does not outlive the sheet: `cancel` and Stop & keep
/// both leave it back at [RecordingState.new].
@freezed
abstract class RecordingState with _$RecordingState {
  /// Lets this class carry getters. Freezed requires it.
  const RecordingState._();

  /// A take in progress.
  const factory RecordingState({
    /// How long it has run, off the clock (ADR-012, ADR-052). The sheet draws
    /// this in tabular figures; the kept take's length is the recorder's own
    /// measurement, not this.
    @Default(Duration.zero) Duration elapsed,

    /// The input level, 0 to 1 (ADR-052, TASKS.md D4).
    ///
    /// **One number, not a history.** The prototype's waveform is twenty bars
    /// with fixed heights, each bobbing on its own loop, so what it needs from
    /// here is the current loudness and nothing else — keeping a rolling
    /// buffer would be state nobody reads.
    @Default(0) double level,

    /// What has been heard, split where §3.4 draws it.
    @Default(Transcript.nothing) Transcript transcript,

    /// Whether the recogniser stopped before the take did.
    ///
    /// It has no note and no icon: §3.5 is stated once, at Stop & keep, on the
    /// open chit. What this is for is [transcript] having stopped growing for
    /// a reason, and for Stop & keep knowing there is nothing left to wait on.
    @Default(false) bool recognitionGaveUp,
  }) = _RecordingState;
}
