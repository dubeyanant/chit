import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/motion_state.dart';
import '../models/weather_condition.dart';
import '../motion/motion_ladder.dart';
import 'ambient_signals.dart';
import 'location_service.dart';
import 'weather_service.dart';

part 'ambient_capture.g.dart';

final class AmbientCapture {
  const AmbientCapture({
    required this._weather,
    required this._location,
    this.timeout = defaultTimeout,
  });

  static const Duration defaultTimeout = Duration(seconds: 12);

  final Duration timeout;

  final WeatherService _weather;
  final LocationService _location;

  Future<AmbientReading> read() async {
    final (WeatherCondition? weather, GeoFix? fix) = await (
      _bestEffort(_weather.currentCondition()),
      _bestEffort(_location.currentFix()),
    ).wait;

    return (
      weather: weather,
      lat: fix?.lat,
      lon: fix?.lon,
      motion: _motionOf(fix),
      readAt: null,
    );
  }

  static MotionState? _motionOf(GeoFix? fix) => fix == null
      ? null
      : MotionLadder.from(
          speed: fix.speed,
          speedAccuracy: fix.speedAccuracy,
          altitude: fix.altitude,
        );

  Future<T?> _bestEffort<T>(Future<T?> signal) => signal
      .timeout(timeout, onTimeout: () => null)
      .onError((Object _, StackTrace _) => null);
}

@Riverpod(keepAlive: true)
AmbientCapture ambientCapture(Ref ref) => AmbientCapture(
  weather: ref.watch(weatherServiceProvider),
  location: ref.watch(locationServiceProvider),
);
