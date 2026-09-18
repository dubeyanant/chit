import '../models/ambient_stamp.dart';
import '../models/motion_state.dart';
import '../models/weather_condition.dart';

sealed class AmbientFact {
  const AmbientFact._();

  static AmbientFact? of(AmbientStamp stamp) {
    final MotionState? motion = stamp.motion;
    final WeatherCondition? weather = stamp.weather;

    for (final AmbientFact candidate in <AmbientFact>[
      if (motion == MotionState.flying) const MotionFact(MotionState.flying),
      if (motion == MotionState.traveling)
        const MotionFact(MotionState.traveling),
      if (weather == WeatherCondition.raining)
        const WeatherFact(WeatherCondition.raining),
      if (weather == WeatherCondition.windy)
        const WeatherFact(WeatherCondition.windy),
      if (motion == MotionState.walking) const MotionFact(MotionState.walking),
      if (weather == WeatherCondition.overcast)
        const WeatherFact(WeatherCondition.overcast),
      if (weather == WeatherCondition.clear)
        const WeatherFact(WeatherCondition.clear),
      if (weather == WeatherCondition.clearNight)
        const WeatherFact(WeatherCondition.clearNight),
    ]) {
      return candidate;
    }

    return null;
  }
}

final class MotionFact extends AmbientFact {
  const MotionFact(this.state) : super._();

  final MotionState state;

  @override
  bool operator ==(Object other) => other is MotionFact && other.state == state;

  @override
  int get hashCode => state.hashCode;

  @override
  String toString() => 'MotionFact(${state.name})';
}

final class WeatherFact extends AmbientFact {
  const WeatherFact(this.condition) : super._();

  final WeatherCondition condition;

  @override
  bool operator ==(Object other) =>
      other is WeatherFact && other.condition == condition;

  @override
  int get hashCode => condition.hashCode;

  @override
  String toString() => 'WeatherFact(${condition.name})';
}
