import 'package:freezed_annotation/freezed_annotation.dart';

part 'recording_state.freezed.dart';

@freezed
abstract class RecordingState with _$RecordingState {
  const RecordingState._();

  const factory RecordingState({
    @Default(Duration.zero) Duration elapsed,

    @Default(<double>[]) List<double> levels,
  }) = _RecordingState;
}
