import 'package:freezed_annotation/freezed_annotation.dart';

part 'recording_state.freezed.dart';

/// What the recording sheet currently holds — BEHAVIOUR.md §3.4.
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

    /// The most recent input levels, 0 to 1, oldest first (ADR-052, D4).
    ///
    /// **A short rolling window, not the whole take** — one bar per reading,
    /// the newest at the right, so the wave draws the shape of what was just
    /// said rather than one loudness split twenty ways. It holds
    /// `RecordingController.levelWindow` readings and is empty until the first
    /// one lands.
    ///
    /// *ADR-054 originally kept a single number, on the reading that v6's wave
    /// is twenty bars each bobbing on its own loop. It is a buffer because the
    /// bars are drawn from the microphone instead.*
    @Default(<double>[]) List<double> levels,
  }) = _RecordingState;
}
