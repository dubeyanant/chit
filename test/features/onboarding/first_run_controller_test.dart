import 'package:chit/domain/models/weather_condition.dart';
import 'package:chit/domain/services/ambient_signals.dart';
import 'package:chit/domain/services/first_run_store.dart';
import 'package:chit/domain/services/location_service.dart';
import 'package:chit/domain/services/weather_service.dart';
import 'package:chit/features/onboarding/application/first_run_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _Store store;
  late _Location location;

  ProviderContainer containerOf() {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        firstRunStoreProvider.overrideWithValue(store),
        locationServiceProvider.overrideWithValue(location),
        weatherServiceProvider.overrideWithValue(const _Weather()),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    store = _Store();
    location = _Location();
  });

  group('whether the screen is owed at all', () {
    test('a fresh install owes it', () {
      expect(containerOf().read(firstRunControllerProvider), isTrue);
    });

    test('an install that has seen it does not', () {
      store.hasRunBefore = true;

      expect(containerOf().read(firstRunControllerProvider), isFalse);
    });

    test('it is owed again after neither button — nothing is implicit', () {
      final ProviderContainer container = containerOf();
      container.read(firstRunControllerProvider);

      expect(store.completions, 0);
      expect(container.read(firstRunControllerProvider), isTrue);
    });
  });

  group('Allow', () {
    test('raises the dialog once, and lets the app in', () async {
      final ProviderContainer container = containerOf();

      await container.read(firstRunControllerProvider.notifier).allow();

      expect(location.requests, 1);
      expect(container.read(firstRunControllerProvider), isFalse);
      expect(store.hasRunBefore, isTrue);
    });

    test(
      'a grant does not settle it — there is nothing left to settle',
      () async {
        final ProviderContainer container = containerOf();

        await container.read(firstRunControllerProvider.notifier).allow();

        expect(store.permissionSettled, isFalse);
      },
    );

    test('a grant primes the launch capture', () async {
      final ProviderContainer container = containerOf();

      await container.read(firstRunControllerProvider.notifier).allow();
      await Future<void>.delayed(Duration.zero);

      expect(location.fixes, 1);
      expect(
        container.read(ambientSignalsProvider).weather,
        WeatherCondition.raining,
      );
    });

    test('every refusal settles it, and none of them is an error', () async {
      for (final LocationPermissionOutcome outcome
          in <LocationPermissionOutcome>[
            LocationPermissionOutcome.denied,
            LocationPermissionOutcome.deniedForever,
            LocationPermissionOutcome.serviceDisabled,
          ]) {
        store = _Store();
        location = _Location()..outcome = outcome;
        final ProviderContainer container = containerOf();

        await expectLater(
          container.read(firstRunControllerProvider.notifier).allow(),
          completes,
          reason: '$outcome',
        );

        expect(store.permissionSettled, isTrue, reason: '$outcome');
        expect(container.read(firstRunControllerProvider), isFalse);
      }
    });

    test('a refusal does not prime the capture', () async {
      location.outcome = LocationPermissionOutcome.deniedForever;
      final ProviderContainer container = containerOf();

      await container.read(firstRunControllerProvider.notifier).allow();
      await Future<void>.delayed(Duration.zero);

      expect(location.fixes, 0, reason: 'nothing to ask, so nothing is asked');
    });
  });

  group('Not now', () {
    test('never raises the dialog', () async {
      final ProviderContainer container = containerOf();

      await container.read(firstRunControllerProvider.notifier).notNow();

      expect(location.requests, 0);
      expect(container.read(firstRunControllerProvider), isFalse);
    });

    test('settles it, so the app never asks again', () async {
      await containerOf().read(firstRunControllerProvider.notifier).notNow();

      expect(store.permissionSettled, isTrue);
      expect(store.hasRunBefore, isTrue);
    });
  });

  test('the screen is never owed twice, whichever button ended it', () async {
    for (final bool viaAllow in <bool>[true, false]) {
      store = _Store();
      location = _Location()..outcome = LocationPermissionOutcome.deniedForever;

      final FirstRunController first = containerOf().read(
        firstRunControllerProvider.notifier,
      );
      await (viaAllow ? first.allow() : first.notNow());

      expect(
        containerOf().read(firstRunControllerProvider),
        isFalse,
        reason: viaAllow ? 'after Allow' : 'after Not now',
      );
    }
  });
}

final class _Store implements FirstRunStore {
  @override
  bool hasRunBefore = false;

  @override
  bool permissionSettled = false;

  int completions = 0;

  @override
  Future<void> complete({required bool permissionSettled}) async {
    completions++;
    hasRunBefore = true;
    if (permissionSettled) this.permissionSettled = true;
  }
}

final class _Location implements LocationService {
  int requests = 0;
  int fixes = 0;
  LocationPermissionOutcome outcome = LocationPermissionOutcome.granted;

  @override
  Future<LocationPermissionOutcome> requestPermission() async {
    requests++;
    return outcome;
  }

  @override
  Future<GeoFix?> currentFix() async {
    fixes++;
    return outcome == LocationPermissionOutcome.granted
        ? const GeoFix(lat: 1, lon: 2)
        : null;
  }

  @override
  Future<GeoFix?> lastKnownFix() => currentFix();
}

final class _Weather implements WeatherService {
  const _Weather();

  @override
  Future<WeatherCondition?> currentCondition() async =>
      WeatherCondition.raining;
}
