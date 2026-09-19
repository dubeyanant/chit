import 'package:chitta/core/clock.dart';
import 'package:chitta/domain/models/motion_state.dart';
import 'package:chitta/domain/models/weather_condition.dart';
import 'package:chitta/domain/services/ambient_signals.dart';
import 'package:chitta/domain/services/location_service.dart';
import 'package:chitta/domain/services/weather_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';

void main() {
  ProviderContainer containerWith(_CountingLocation location) {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        weatherServiceProvider.overrideWith(
          (Ref ref) => const _Weather(WeatherCondition.raining),
        ),
        locationServiceProvider.overrideWith((Ref ref) => location),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('it holds nothing until something is asked for', () {
    final ProviderContainer container = containerWith(_CountingLocation());

    expect(container.read(ambientSignalsProvider), AmbientSignals.nothing);
    expect(
      container.read(ambientSignalsProvider).weather,
      isNull,
      reason: 'reading it must not trigger a capture',
    );
  });

  test('reading the value never asks the services', () async {
    final _CountingLocation location = _CountingLocation();
    final ProviderContainer container = containerWith(location);

    for (int i = 0; i < 5; i++) {
      container.read(ambientSignalsProvider);
    }
    await Future<void>.delayed(Duration.zero);

    expect(location.fixes, 0);
  });

  test('prime asks once, and what lands is what is held', () async {
    final _CountingLocation location = _CountingLocation();
    final ProviderContainer container = containerWith(location);

    await container.read(ambientSignalsProvider.notifier).prime();

    expect(location.fixes, 1);
    expect(
      container.read(ambientSignalsProvider).weather,
      WeatherCondition.raining,
    );
    expect(container.read(ambientSignalsProvider).lat, 1);
    expect(container.read(ambientSignalsProvider).motion, MotionState.walking);
  });

  test('refresh asks again and replaces what is held', () async {
    final _CountingLocation location = _CountingLocation();
    final ProviderContainer container = containerWith(location);

    await container.read(ambientSignalsProvider.notifier).prime();
    location.fix = null;
    await container.read(ambientSignalsProvider.notifier).refresh();

    expect(location.fixes, 2);
    expect(container.read(ambientSignalsProvider).lat, isNull);
    expect(container.read(ambientSignalsProvider).motion, isNull);
    expect(
      container.read(ambientSignalsProvider).weather,
      WeatherCondition.raining,
      reason: 'the other signal is untouched',
    );
  });

  test(
    'a service that throws leaves it holding nothing, not an error',
    () async {
      final ProviderContainer container = ProviderContainer(
        overrides: [
          weatherServiceProvider.overrideWith((Ref ref) => _ThrowingWeather()),
          locationServiceProvider.overrideWith(
            (Ref ref) => _ThrowingLocation(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(ambientSignalsProvider.notifier).prime(),
        completes,
      );

      final AmbientReading held = container.read(ambientSignalsProvider);
      expect(held.weather, isNull);
      expect(held.lat, isNull);
      expect(held.motion, isNull);
      expect(
        held.readAt,
        isNotNull,
        reason:
            'an empty answer is still an answer — ADR-045 dates it, so a'
            ' save does not keep re-asking a service that has nothing',
      );
    },
  );

  group('coming back to the app — ADR-104', () {
    final DateTime opened = DateTime(2026, 9, 19, 9, 30);

    ({ProviderContainer container, FakeClock clock, _CountingLocation location})
    appOpenedAt(DateTime when) {
      final FakeClock clock = FakeClock(when);
      final _CountingLocation location = _CountingLocation();
      final ProviderContainer container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(clock),
          weatherServiceProvider.overrideWith(
            (Ref ref) => const _Weather(WeatherCondition.raining),
          ),
          locationServiceProvider.overrideWith((Ref ref) => location),
        ],
      );
      addTearDown(container.dispose);
      return (container: container, clock: clock, location: location);
    }

    test('nothing captured means nothing to be stale — no fix', () async {
      final app = appOpenedAt(opened);

      await app.container
          .read(ambientSignalsProvider.notifier)
          .refreshIfShownTooLong();

      expect(
        app.location.fixes,
        0,
        reason: 'a resume before the launch capture must not race it',
      );
    });

    test('a glance away leaves the reading alone', () async {
      final app = appOpenedAt(opened);
      await app.container.read(ambientSignalsProvider.notifier).prime();

      app.clock.moveTo(opened.add(AmbientSignals.shownFor - oneSecond));
      await app.container
          .read(ambientSignalsProvider.notifier)
          .refreshIfShownTooLong();

      expect(app.location.fixes, 1, reason: 'the launch capture, and no more');
    });

    test('a sky left on screen too long is read again', () async {
      final app = appOpenedAt(opened);
      await app.container.read(ambientSignalsProvider.notifier).prime();

      app.clock.moveTo(opened.add(AmbientSignals.shownFor));
      await app.container
          .read(ambientSignalsProvider.notifier)
          .refreshIfShownTooLong();

      expect(app.location.fixes, 2);
    });

    test(
      'a refresh restarts the clock, so two resumes are not two fixes',
      () async {
        final app = appOpenedAt(opened);
        await app.container.read(ambientSignalsProvider.notifier).prime();

        app.clock.moveTo(opened.add(AmbientSignals.shownFor));
        final AmbientSignals signals = app.container.read(
          ambientSignalsProvider.notifier,
        );
        await signals.refreshIfShownTooLong();
        await signals.refreshIfShownTooLong();

        expect(
          app.location.fixes,
          2,
          reason: 'the second resume found it fresh',
        );
      },
    );

    test('a clock that went backwards is not treated as age', () async {
      final app = appOpenedAt(opened);
      await app.container.read(ambientSignalsProvider.notifier).prime();

      app.clock.moveTo(opened.subtract(const Duration(hours: 2)));
      await app.container
          .read(ambientSignalsProvider.notifier)
          .refreshIfShownTooLong();

      expect(app.location.fixes, 1);
    });
  });
}

const Duration oneSecond = Duration(seconds: 1);

final class _Weather implements WeatherService {
  const _Weather(this.condition);

  final WeatherCondition? condition;

  @override
  Future<WeatherCondition?> currentCondition() async => condition;
}

final class _CountingLocation implements LocationService {
  int fixes = 0;

  GeoFix? fix = const GeoFix(lat: 1, lon: 2, speed: 1.4, speedAccuracy: 0.4);

  @override
  Future<GeoFix?> currentFix() async {
    fixes++;
    return fix;
  }

  @override
  Future<GeoFix?> lastKnownFix() async => fix;

  @override
  Future<LocationPermissionOutcome> requestPermission() async =>
      LocationPermissionOutcome.granted;

  @override
  Future<LocationServiceOutcome> requestService() async =>
      LocationServiceOutcome.alreadyOn;
}

final class _ThrowingWeather implements WeatherService {
  @override
  Future<WeatherCondition?> currentCondition() async => throw const _Failure();
}

final class _ThrowingLocation implements LocationService {
  @override
  Future<GeoFix?> currentFix() async => throw const _Failure();

  @override
  Future<GeoFix?> lastKnownFix() async => throw const _Failure();

  @override
  Future<LocationPermissionOutcome> requestPermission() async =>
      throw const _Failure();

  @override
  Future<LocationServiceOutcome> requestService() async =>
      throw const _Failure();
}

final class _Failure implements Exception {
  const _Failure();
}
