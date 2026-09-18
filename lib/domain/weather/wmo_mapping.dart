import '../models/weather_condition.dart';

abstract final class WmoMapping {
  static const double windyFloor = 7;

  static const double rainFloor = 0.1;

  static const double overcastFloor = 60;

  static WeatherCondition? from({
    required int? code,
    required bool? isDay,
    required double? windSpeed,
    double? precipitation,
    double? cloudCover,
  }) {
    final bool? falling = _falls(precipitation, code: code);
    if (falling ?? false) return WeatherCondition.raining;

    if (windSpeed != null && !windSpeed.isNaN && windSpeed >= windyFloor) {
      return WeatherCondition.windy;
    }

    if (code != null && _closed.contains(code)) {
      return WeatherCondition.overcast;
    }

    if (falling == null) return null;

    final bool? shut = _isShut(cloudCover, code: code);
    if (shut == null) return null;
    if (shut) return WeatherCondition.overcast;

    if (isDay == null) return null;
    return isDay ? WeatherCondition.clear : WeatherCondition.clearNight;
  }

  static bool? _isShut(double? cloudCover, {required int? code}) {
    if (cloudCover != null && !cloudCover.isNaN) {
      return cloudCover >= overcastFloor;
    }
    if (code == null) return null;
    if (_cloudy.contains(code)) return true;
    if (_open.contains(code)) return false;
    return null;
  }

  static bool? _falls(double? precipitation, {required int? code}) {
    if (precipitation != null && !precipitation.isNaN) {
      return precipitation >= rainFloor;
    }
    if (code == null) return null;
    return _falling.contains(code);
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

  static const Set<int> _closed = <int>{45, 48, 71, 73, 75, 77, 85, 86};

  static const Set<int> _cloudy = <int>{3};

  static const Set<int> _open = <int>{0, 1, 2};

  static Set<int> get known => <int>{
    ..._falling,
    ..._closed,
    ..._cloudy,
    ..._open,
  };
}
