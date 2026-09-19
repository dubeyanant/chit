import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'location_service.dart';

part 'place_permission.g.dart';

enum PlaceAccess { unasked, granted, refused, refusedForever }

typedef PlaceAsk = ({PlaceAccess access, bool service});

extension PlaceAccessAsking on PlaceAccess {
  bool get worthAsking =>
      this == PlaceAccess.unasked || this == PlaceAccess.refused;
}

@Riverpod(keepAlive: true)
class PlacePermission extends _$PlacePermission {
  @override
  PlaceAsk build() => (access: PlaceAccess.unasked, service: true);

  Future<bool> ask() async {
    final LocationService location = ref.read(locationServiceProvider);
    bool won = false;

    if (state.access.worthAsking) {
      final LocationPermissionOutcome outcome = await location
          .requestPermission();

      if (!ref.mounted) return false;

      won = outcome == LocationPermissionOutcome.granted;
      state = (access: _accessOf(outcome), service: state.service);
    }

    if (state.access != PlaceAccess.granted || !state.service) return won;

    final LocationServiceOutcome outcome = await location.requestService();

    if (!ref.mounted) return false;

    return switch (outcome) {
      LocationServiceOutcome.alreadyOn => won,
      LocationServiceOutcome.turnedOn => true,
      LocationServiceOutcome.notPermitted => won,

      LocationServiceOutcome.refused => _rest(won),
    };
  }

  bool _rest(bool won) {
    state = (access: state.access, service: false);
    return won;
  }

  static PlaceAccess _accessOf(LocationPermissionOutcome outcome) =>
      switch (outcome) {
        LocationPermissionOutcome.granted => PlaceAccess.granted,
        LocationPermissionOutcome.denied => PlaceAccess.refused,
        LocationPermissionOutcome.deniedForever => PlaceAccess.refusedForever,
      };
}
