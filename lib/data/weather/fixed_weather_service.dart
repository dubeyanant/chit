import '../../domain/models/weather_condition.dart';
import '../../domain/services/weather_service.dart';

/// One condition, always, and no network at all. **M2 only.**
///
/// It exists so that M2's composer can be built and judged against
/// `design/chit-app-v6.html` — which draws `raining` — before M3 writes
/// `OpenMeteoService`. Group D of TASKS.md put the interface in place first
/// precisely so that M3 is a swap at the root and nothing above it moves.
///
/// **M3 deletes this file.** It is not a fallback, not an offline mode and not
/// a test double: the honest answer when the real service cannot say is
/// `null`, and ADR-007 already has that covered.
final class FixedWeatherService implements WeatherService {
  /// Always answers [condition].
  const FixedWeatherService({this.condition = WeatherCondition.raining});

  /// What it says. Defaults to the prototype's word.
  final WeatherCondition? condition;

  @override
  Future<WeatherCondition?> currentCondition() async => condition;
}
