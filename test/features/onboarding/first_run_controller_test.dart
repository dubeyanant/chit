import 'package:chit/domain/models/weather_condition.dart';
import 'package:chit/domain/services/ambient_signals.dart';
import 'package:chit/domain/services/first_run_store.dart';
import 'package:chit/domain/services/location_service.dart';
import 'package:chit/domain/services/weather_service.dart';
import 'package:chit/features/onboarding/application/first_run_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// ADR-041, and the promise inside it: **the app asks once.**
///
/// That is the claim worth testing, because it is the one a future change
/// breaks silently — an app that re-asks on every launch is annoying rather
/// than broken, and nothing crashes. ADR-016 forbids it in words; this is the
/// same rule in a form that fails a build.
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
      // Being *shown* does not settle it; being *answered* does. This is what
      // stops a crash on the first-run screen from silently skipping the ask.
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
      // The capture is skipped at startup on a fresh install, because asking
      // before the screen explains itself is how a system dialog appears over
      // a blank page (ADR-041). This is where it happens instead.
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
      // A refusal is not a failure state and there is no second screen
      // apologising for it: the app runs with fewer signals (ADR-007).
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
      // The reason the control exists. A quiet option that still raises a
      // system prompt is a dark pattern wearing a polite label.
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
    // The whole of ADR-016's no-nagging rule, as one assertion: a second
    // launch reads the store the first launch wrote, and finds nothing owed.
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

/// The store, in memory. Counts writes so that "asked once" is checkable.
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

/// Counts both of the things it can be asked, because both counts are claims.
///
/// **It refuses the fix when it refused the permission**, which is CLAUDE.md
/// §4.1's Liskov rule: a fake that granted nothing and then answered anyway
/// would let a bug through that the real geolocator never would.
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
}

final class _Weather implements WeatherService {
  const _Weather();

  @override
  Future<WeatherCondition?> currentCondition() async =>
      WeatherCondition.raining;
}
