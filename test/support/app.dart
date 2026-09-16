import 'package:chit/app/chit_app.dart';
import 'package:chit/core/clock.dart';
import 'package:chit/domain/models/weather_condition.dart';
import 'package:chit/domain/repositories/chit_repository.dart';
import 'package:chit/domain/services/location_service.dart';
import 'package:chit/domain/services/weather_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_clock.dart';
import 'fake_repository.dart';

/// The whole app, with the root overridden the way `main.dart` overrides it.
///
/// **Any test that pumps `ChitApp` has to come through here.** Today builds
/// the open chit and the thread, so it asks for an ambient stamp and for a
/// repository — and all three are declared in `domain` and left unimplemented
/// on purpose (ARCHITECTURE.md §3), so a bare `ProviderScope` does not boot
/// the app, it throws `UnimplementedError` from inside a widget build. That is
/// the seam working as designed, and this is the one place a test states the
/// other half of it.
///
/// The repository is [FakeChitRepository] rather than Drift in memory, and the
/// reason is in that file: real I/O never completes inside a `testWidgets`
/// body. CLAUDE.md §4.2 carries the rule and this exception to it.
Future<ChitHarness> pumpChitApp(
  WidgetTester tester, {
  DateTime? at,
  WeatherService weather = const FakeWeather(WeatherCondition.raining),
  LocationService location = const FakeLocation((lat: 51.4769, lon: -0.0005)),
  FakeChitRepository? repository,
}) async {
  final FakeClock clock = FakeClock(at ?? DateTime(2026, 9, 16, 15, 42));
  final FakeChitRepository chits =
      repository ?? FakeChitRepository(clock: clock);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        clockProvider.overrideWithValue(clock),
        chitRepositoryProvider.overrideWithValue(chits),
        weatherServiceProvider.overrideWithValue(weather),
        locationServiceProvider.overrideWithValue(location),
      ],
      child: const ChitApp(),
    ),
  );
  await tester.pumpAndSettle();

  return ChitHarness(clock: clock, repository: chits);
}

/// What a test needs to reach behind the app it just pumped.
///
/// The clock, because the things worth asserting about a stamp are *when* it
/// was taken and how many times the clock was asked (ADR-021). The repository,
/// because *"it is still there after a restart"* is a claim about the row
/// rather than about the widget that drew it — pump a second app over the same
/// repository and the thread has to fill itself from it.
final class ChitHarness {
  /// The harness for one pumped app.
  const ChitHarness({required this.clock, required this.repository});

  /// The clock the app is running on. Move it to move the app's idea of now.
  final FakeClock clock;

  /// What the app has written, and what it reads back.
  final FakeChitRepository repository;
}

/// A [WeatherService] that answers one condition, or nothing.
final class FakeWeather implements WeatherService {
  /// Answers [condition] — `null` for the ordinary offline outcome.
  const FakeWeather(this.condition);

  /// What it says.
  final WeatherCondition? condition;

  @override
  Future<WeatherCondition?> currentCondition() async => condition;
}

/// A [LocationService] that answers one fix, or nothing.
final class FakeLocation implements LocationService {
  /// Answers [fix] — `null` for a refused permission.
  const FakeLocation(this.fix);

  /// Where it says the device is.
  final GeoFix? fix;

  @override
  Future<GeoFix?> currentFix() async => fix;
}
