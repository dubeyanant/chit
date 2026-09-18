import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/models/weather_condition.dart';
import '../../domain/services/location_service.dart';
import '../../domain/services/weather_service.dart';
import '../../domain/weather/wmo_mapping.dart';

final class OpenMeteoService implements WeatherService {
  const OpenMeteoService({required this._location, required this._client});

  static const String host = 'api.open-meteo.com';

  static const String path = '/v1/forecast';

  static const Duration timeout = Duration(seconds: 5);

  final LocationService _location;
  final http.Client _client;

  @override
  Future<WeatherCondition?> currentCondition() async {
    try {
      final GeoFix? fix = await _location.lastKnownFix();

      if (fix == null) return null;

      final http.Response response = await _client
          .get(_uriFor(fix))
          .timeout(timeout);

      if (response.statusCode != 200) return null;

      return _conditionOf(response.body);
    } on Object {
      return null;
    }
  }

  static Uri _uriFor(GeoFix fix) => Uri.https(host, path, <String, String>{
    'latitude': fix.lat.toStringAsFixed(4),
    'longitude': fix.lon.toStringAsFixed(4),
    'current': 'weather_code,wind_speed_10m,is_day,precipitation,cloud_cover',
    'wind_speed_unit': 'ms',
  });

  static WeatherCondition? _conditionOf(String body) {
    final Object? decoded = jsonDecode(body);
    if (decoded is! Map<String, Object?>) return null;

    final Object? current = decoded['current'];
    if (current is! Map<String, Object?>) return null;

    return WmoMapping.from(
      code: _intOf(current['weather_code']),
      isDay: switch (_intOf(current['is_day'])) {
        1 => true,
        0 => false,

        _ => null,
      },
      windSpeed: _doubleOf(current['wind_speed_10m']),
      precipitation: _doubleOf(current['precipitation']),
      cloudCover: _doubleOf(current['cloud_cover']),
    );
  }

  static int? _intOf(Object? value) => switch (value) {
    final int i => i,
    final double d => d.round(),
    _ => null,
  };

  static double? _doubleOf(Object? value) => switch (value) {
    final double d => d,
    final int i => i.toDouble(),
    _ => null,
  };
}
