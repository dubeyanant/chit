import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/weather_condition.dart';

part 'weather_service.g.dart';

/// One condition word for wherever the device is.
///
/// **It takes no position, and that is a decision rather than an omission —
/// ADR-025.** Open-Meteo needs coordinates, so the obvious shape is
/// `conditionAt(lat, lon)`; that shape would make the weather wait on the
/// location fix, and ADR-016 made the fix the *precise* one, which is the slow
/// half. ADR-007 says the two run in parallel. Where an implementation gets a
/// position is its own business — M3's uses the last known fix, which is
/// instant — and `domain` does not need to know that weather is a thing you
/// look up by place.
///
/// **Best-effort, and it never blocks** (ADR-007). Offline, rate-limited and
/// slow are all the same answer: `null`, and a `null` is not drawn.
abstract interface class WeatherService {
  /// The condition now, or `null` if it did not arrive.
  ///
  /// One of the five words BEHAVIOUR.md §3.6 allows, mapped from whatever the
  /// source says by a pure function in `domain/weather` — the mapping is a
  /// product decision and stays on this side of the boundary.
  ///
  /// An implementation should not throw, and `AmbientCapture` does not trust
  /// it not to.
  Future<WeatherCondition?> currentCondition();
}

/// The weather service the app runs on.
///
/// Unimplemented on purpose, for the reason `chitRepositoryProvider` is:
/// `domain` cannot import `data` (ARCHITECTURE.md §1), so the implementation
/// is supplied at the root. M2 supplies a fixed value; M3 supplies
/// `OpenMeteoService` and nothing else changes.
@Riverpod(keepAlive: true)
WeatherService weatherService(Ref ref) => throw UnimplementedError(
  'weatherServiceProvider is overridden at the root — see main.dart',
);
