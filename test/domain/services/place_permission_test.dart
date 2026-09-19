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

  PlacePermission askerOf(_Location location) =>
      containerOf(location).read(placePermissionProvider.notifier);

  group('the OS decides how many times somebody is asked — ADR-094', () {
    test('an install starts out worth asking, both ways', () {
      expect(containerOf(_Location()).read(placePermissionProvider), (
        access: PlaceAccess.unasked,
        service: true,
      ));
    });

    test('a refusal leaves it worth asking, the OS having one left', () async {
      final _Location location = _Location(
        outcomes: <LocationPermissionOutcome>[LocationPermissionOutcome.denied],
      );
      final ProviderContainer container = containerOf(location);

      await container.read(placePermissionProvider.notifier).ask();

      expect(
        container.read(placePermissionProvider).access,
        PlaceAccess.refused,
      );
      expect(location.asks, 1);
    });

    test('a second refusal is final, and nothing asks again', () async {
      final _Location location = _Location(
        outcomes: <LocationPermissionOutcome>[
          LocationPermissionOutcome.denied,
          LocationPermissionOutcome.deniedForever,
        ],
      );
      final ProviderContainer container = containerOf(location);
      final PlacePermission permission = container.read(
        placePermissionProvider.notifier,
      );

      await permission.ask();
      await permission.ask();

      expect(
        container.read(placePermissionProvider).access,
        PlaceAccess.refusedForever,
      );
      expect(location.asks, 2);

      await permission.ask();
      await permission.ask();

      expect(location.asks, 2, reason: 'it kept asking after the final no');
    });

    test('a grant settles it too, and is not asked for twice', () async {
      final _Location location = _Location(
        outcomes: <LocationPermissionOutcome>[
          LocationPermissionOutcome.granted,
        ],
        services: <LocationServiceOutcome>[LocationServiceOutcome.alreadyOn],
      );
      final ProviderContainer container = containerOf(location);
      final PlacePermission permission = container.read(
        placePermissionProvider.notifier,
      );

      await permission.ask();
      await permission.ask();

      expect(
        container.read(placePermissionProvider).access,
        PlaceAccess.granted,
      );
      expect(location.asks, 1);
    });

    test('a grant is reported back, so a caller can act on it', () async {
      final _Location location = _Location(
        outcomes: <LocationPermissionOutcome>[
          LocationPermissionOutcome.granted,
        ],
        services: <LocationServiceOutcome>[LocationServiceOutcome.alreadyOn],
      );
      final PlacePermission permission = askerOf(location);

      expect(await permission.ask(), isTrue);
      expect(await permission.ask(), isFalse, reason: 'it was not this ask');
    });

    test('a refusal is not', () async {
      final _Location location = _Location(
        outcomes: <LocationPermissionOutcome>[
          LocationPermissionOutcome.denied,
          LocationPermissionOutcome.deniedForever,
        ],
      );
      final PlacePermission permission = askerOf(location);

      expect(await permission.ask(), isFalse);
      expect(await permission.ask(), isFalse);
    });

    test('asking for permission takes no reading — §3.6.3, not ours', () async {
      final _Location location = _Location(
        outcomes: <LocationPermissionOutcome>[
          LocationPermissionOutcome.granted,
        ],
        services: <LocationServiceOutcome>[LocationServiceOutcome.alreadyOn],
      );

      await askerOf(location).ask();

      expect(
        location.fixes,
        0,
        reason: 'a second owner for the capture rule, and a race with it',
      );
    });
  });

  group('the switch is offered once a run — ADR-102', () {
    test('a refused permission is never followed by the switch', () async {
      final _Location location = _Location(
        outcomes: <LocationPermissionOutcome>[LocationPermissionOutcome.denied],
        services: <LocationServiceOutcome>[LocationServiceOutcome.turnedOn],
      );

      await askerOf(location).ask();

      expect(location.prompts, 0, reason: 'nothing to switch on for');
    });

    test('a granted permission goes on to the switch', () async {
      final _Location location = _Location(
        outcomes: <LocationPermissionOutcome>[
          LocationPermissionOutcome.granted,
        ],
        services: <LocationServiceOutcome>[LocationServiceOutcome.alreadyOn],
      );

      expect(await askerOf(location).ask(), isTrue);
      expect(location.prompts, 1);
    });

    test('a switch turned on is won, even when the grant was older', () async {
      final _Location location = _Location(
        outcomes: <LocationPermissionOutcome>[
          LocationPermissionOutcome.granted,
        ],
        services: <LocationServiceOutcome>[
          LocationServiceOutcome.alreadyOn,
          LocationServiceOutcome.turnedOn,
        ],
      );
      final PlacePermission permission = askerOf(location);

      await permission.ask();

      expect(
        await permission.ask(),
        isTrue,
        reason: 'the second save won the switch, not the permission',
      );
    });

    test('a refused switch is not offered again this run', () async {
      final _Location location = _Location(
        outcomes: <LocationPermissionOutcome>[
          LocationPermissionOutcome.granted,
        ],
        services: <LocationServiceOutcome>[LocationServiceOutcome.refused],
      );
      final ProviderContainer container = containerOf(location);
      final PlacePermission permission = container.read(
        placePermissionProvider.notifier,
      );

      expect(
        await permission.ask(),
        isTrue,
        reason: 'the permission was won on that ask, the switch was not',
      );
      expect(container.read(placePermissionProvider).service, isFalse);

      await permission.ask();
      await permission.ask();

      expect(location.prompts, 1, reason: 'it kept offering after the no');
    });

    test('a switch the OS will not offer leaves the run open', () async {
      final _Location location = _Location(
        outcomes: <LocationPermissionOutcome>[
          LocationPermissionOutcome.granted,
        ],
        services: <LocationServiceOutcome>[LocationServiceOutcome.notPermitted],
      );
      final ProviderContainer container = containerOf(location);

      await container.read(placePermissionProvider.notifier).ask();

      expect(
        container.read(placePermissionProvider).service,
        isTrue,
        reason: 'nobody refused anything, so nothing is spent',
      );
    });
  });
}

final class _Location implements LocationService {
  _Location({
    List<LocationPermissionOutcome>? outcomes,
    List<LocationServiceOutcome>? services,
  }) : _outcomes = outcomes ?? <LocationPermissionOutcome>[],
       _services = services ?? <LocationServiceOutcome>[];

  final List<LocationPermissionOutcome> _outcomes;
  final List<LocationServiceOutcome> _services;

  int asks = 0;
  int prompts = 0;
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
  Future<LocationServiceOutcome> requestService() async {
    if (_services.isEmpty) {
      throw StateError('offered the switch with no outcome to give');
    }

    final int at = prompts < _services.length ? prompts : _services.length - 1;
    prompts++;
    return _services[at];
  }

  @override
  Future<GeoFix?> currentFix() async {
    fixes++;
    return const GeoFix(lat: 19.07, lon: 72.87);
  }

  @override
  Future<GeoFix?> lastKnownFix() async => null;
}
