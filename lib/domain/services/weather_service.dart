import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/weather_condition.dart';

part 'weather_service.g.dart';

abstract interface class WeatherService {
  Future<WeatherCondition?> currentCondition();
}

@Riverpod(keepAlive: true)
WeatherService weatherService(Ref ref) => throw UnimplementedError(
  'weatherServiceProvider is overridden at the root — see main.dart',
);
