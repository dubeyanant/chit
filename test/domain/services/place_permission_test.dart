import 'package:chitta/domain/services/location_service.dart';
import 'package:chitta/domain/services/place_permission.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ProviderContainer containerOf(_Location location) {
    final ProviderContainer container = ProviderContainer(
      overrides: [locationServiceProvider.overrideWithValue(location)],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('the OS decides how many times somebody is asked — ADR-094', () {
    test('an install starts out worth asking', () {
      expect(
        containerOf(_Location(<LocationPermissionOutcome>[]))
            .read(placePermissionProvider),
        isTrue,
      );
    });

    test('a refusal leaves it worth asking, the OS having one left', () async {
      final _Location location = _Location(<LocationPermissionOutcome>[
        LocationPermissionOutcome.denied,
      ]);
      final ProviderContainer container = containerOf(location);

      await container.read(placePermissionProvider.notifier).ask();

      expect(container.read(placePermissionProvider), isTrue);
      expect(location.asks, 1);
    });

    test('a second refusal is final, and nothing asks again', () async {
      final _Location location = _Location(<LocationPermissionOutcome>[
        LocationPermissionOutcome.denied,
        LocationPermissionOutcome.deniedForever,
      ]);
      final ProviderContainer container = containerOf(location);
      final PlacePermission permission = container.read(
        placePermissionProvider.notifier,
      );

      await permission.ask();
      await permission.ask();

      expect(container.read(placePermissionProvider), isFalse);
      expect(location.asks, 2);

      await permission.ask();
      await permission.ask();

      expect(location.asks, 2, reason: 'it kept asking after the final no');
    });

    test('a grant settles it too, and is not asked for twice', () async {
      final _Location location = _Location(<LocationPermissionOutcome>[
        LocationPermissionOutcome.granted,
      ]);
      final ProviderContainer container = containerOf(location);
      final PlacePermission permission = container.read(
        placePermissionProvider.notifier,
      );

      await permission.ask();
      await permission.ask();

      expect(container.read(placePermissionProvider), isFalse);
      expect(location.asks, 1);
    });

    test(
      'a disabled service is the setting, not the answer — keep asking',
      () async {
        final _Location location = _Location(<LocationPermissionOutcome>[
          LocationPermissionOutcome.serviceDisabled,
          LocationPermissionOutcome.granted,
        ]);
        final ProviderContainer container = containerOf(location);
        final PlacePermission permission = container.read(
          placePermissionProvider.notifier,
        );

        await permission.ask();
        expect(container.read(placePermissionProvider), isTrue);

        await permission.ask();
        expect(container.read(placePermissionProvider), isFalse);
        expect(location.asks, 2);
      },
    );

    test('a grant is reported back, so a caller can act on it', () async {
      final _Location location = _Location(<LocationPermissionOutcome>[
        LocationPermissionOutcome.granted,
      ]);
      final ProviderContainer container = containerOf(location);
      final PlacePermission permission = container.read(
        placePermissionProvider.notifier,
      );

      expect(await permission.ask(), isTrue);
      expect(await permission.ask(), isFalse, reason: 'it was not this ask');
    });

    test('a refusal is not', () async {
      final _Location location = _Location(<LocationPermissionOutcome>[
        LocationPermissionOutcome.denied,
        LocationPermissionOutcome.deniedForever,
        LocationPermissionOutcome.serviceDisabled,
      ]);
      final ProviderContainer container = containerOf(location);
      final PlacePermission permission = container.read(
        placePermissionProvider.notifier,
      );

      expect(await permission.ask(), isFalse);
      expect(await permission.ask(), isFalse);
    });

    test('asking takes no reading — that is §3.6.3, and it is not ours', () {
      final _Location location = _Location(<LocationPermissionOutcome>[
        LocationPermissionOutcome.granted,
      ]);
      final ProviderContainer container = containerOf(location);

      return container.read(placePermissionProvider.notifier).ask().then((
        bool _,
      ) {
        expect(
          location.fixes,
          0,
          reason: 'a second owner for the capture rule, and a race with it',
        );
      });
    });
  });
}

final class _Location implements LocationService {
  _Location(this._outcomes);

  final List<LocationPermissionOutcome> _outcomes;

  int asks = 0;
  int fixes = 0;

  @override
  Future<LocationPermissionOutcome> requestPermission() async {
    if (_outcomes.isEmpty) {
      throw StateError('asked with no outcome to give');
    }

    final int at = asks < _outcomes.length ? asks : _outcomes.length - 1;
    asks++;
    return _outcomes[at];
  }

  @override
  Future<GeoFix?> currentFix() async {
    fixes++;
    return const GeoFix(lat: 19.07, lon: 72.87);
  }

  @override
  Future<GeoFix?> lastKnownFix() async => null;
}
