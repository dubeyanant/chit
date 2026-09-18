import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/clock.dart';
import '../models/motion_state.dart';
import '../models/weather_condition.dart';
import 'ambient_capture.dart';

part 'ambient_signals.g.dart';

typedef AmbientReading = ({
  WeatherCondition? weather,
  double? lat,
  double? lon,
  MotionState? motion,
  DateTime? readAt,
});

extension AmbientReadingFreshness on AmbientReading {
  bool isFreshAt(DateTime now) {
    final DateTime? at = readAt;
    if (at == null) return false;

    final Duration age = now.difference(at);
    return !age.isNegative && age < AmbientSignals.freshFor;
  }
}

@Riverpod(keepAlive: true)
class AmbientSignals extends _$AmbientSignals {
  static const AmbientReading nothing = (
    weather: null,
    lat: null,
    lon: null,
    motion: null,
    readAt: null,
  );

  static const Duration freshFor = Duration(minutes: 1);

  @override
  AmbientReading build() => nothing;

  Future<void> prime() => refresh();

  Future<void> refresh() async {
    final AmbientReading reading = await ref
        .read(ambientCaptureProvider)
        .read();

    if (!ref.mounted) return;

    state = (
      weather: reading.weather,
      lat: reading.lat,
      lon: reading.lon,
      motion: reading.motion,
      readAt: ref.read(clockProvider).now(),
    );
  }
}
