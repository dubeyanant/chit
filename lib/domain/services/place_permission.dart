import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'location_service.dart';

part 'place_permission.g.dart';

@Riverpod(keepAlive: true)
class PlacePermission extends _$PlacePermission {
  @override
  bool build() => true;

  Future<bool> ask() async {
    if (!state) return false;

    final LocationPermissionOutcome outcome = await ref
        .read(locationServiceProvider)
        .requestPermission();

    if (!ref.mounted) return false;

    state = switch (outcome) {
      LocationPermissionOutcome.granted => false,
      LocationPermissionOutcome.deniedForever => false,

      LocationPermissionOutcome.denied => true,

      LocationPermissionOutcome.serviceDisabled => true,
    };

    return outcome == LocationPermissionOutcome.granted;
  }
}
