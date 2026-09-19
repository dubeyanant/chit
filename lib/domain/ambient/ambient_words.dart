import '../models/motion_state.dart';
import '../models/weather_condition.dart';

/// The word a motion is said in — BEHAVIOUR.md §3.6.
///
/// One list, because §3.6 requires the same words and case wherever they
/// appear: the stamp on a chit and the row find narrows by are the same
/// vocabulary, and two copies of it would drift.
extension MotionWord on MotionState {
  String get word {
    assert(
      this != MotionState.stationary,
      'stationary is never drawn — ADR-038 filters it before here',
    );

    return switch (this) {
      MotionState.stationary => '',
      MotionState.walking => 'walking',
      MotionState.traveling => 'travelling',
      MotionState.flying => 'flying',
    };
  }
}

/// The word a sky is said in — BEHAVIOUR.md §3.6.
extension WeatherWord on WeatherCondition {
  String get word => switch (this) {
    WeatherCondition.raining => 'raining',
    WeatherCondition.clear => 'clear',
    WeatherCondition.overcast => 'overcast',
    WeatherCondition.windy => 'windy',
    WeatherCondition.clearNight => 'clear night',
  };
}
