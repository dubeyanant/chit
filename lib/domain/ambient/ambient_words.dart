import '../models/motion_state.dart';
import '../models/weather_condition.dart';

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

extension WeatherWord on WeatherCondition {
  String get word => switch (this) {
    WeatherCondition.raining => 'raining',
    WeatherCondition.clear => 'clear',
    WeatherCondition.overcast => 'overcast',
    WeatherCondition.windy => 'windy',
    WeatherCondition.clearNight => 'clear night',
  };
}
