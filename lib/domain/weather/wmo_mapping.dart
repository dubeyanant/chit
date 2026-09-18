import '../models/weather_condition.dart';

abstract final class WmoMapping {
  static const double windyFloor = 7;

  static WeatherCondition? from({
    required int? code,
    required bool? isDay,
    required double? windSpeed,
  }) {
    if (code != null && _falling.contains(code)) {
      return WeatherCondition.raining;
    }

    if (windSpeed != null && !windSpeed.isNaN && windSpeed >= windyFloor) {
      return WeatherCondition.windy;
    }

    if (code == null) return null;
    if (_closed.contains(code)) return WeatherCondition.overcast;

    if (_open.contains(code)) {
      if (isDay == null) return null;
      return isDay ? WeatherCondition.clear : WeatherCondition.clearNight;
    }

    return null;
  }

  static const Set<int> _falling = <int>{
    51,
    53,
    55,
    56,
    57,
    61,
    63,
    65,
    66,
    67,
    80,
    81,
    82,
    95,
    96,
    99,
  };

  static const Set<int> _closed = <int>{3, 45, 48, 71, 73, 75, 77, 85, 86};

  static const Set<int> _open = <int>{0, 1, 2};

  static Set<int> get known => <int>{..._falling, ..._closed, ..._open};
}
