import 'package:geolocator/geolocator.dart';

import '../../domain/services/location_service.dart';

final class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  static const Duration fixTimeout = Duration(seconds: 10);

  @override
  Future<LocationPermissionOutcome> requestPermission() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return LocationPermissionOutcome.serviceDisabled;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      return _outcomeOf(permission);
    } on Object {
      return LocationPermissionOutcome.denied;
    }
  }

  @override
  Future<GeoFix?> currentFix() async {
    try {
      if (!await _isPermitted()) return null;

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: fixTimeout,
        ),
      );

      return _fixOf(position, withKinematics: true);
    } on Object {
      return lastKnownFix();
    }
  }

  @override
  Future<GeoFix?> lastKnownFix() async {
    try {
      if (!await _isPermitted()) return null;

      final Position? position = await Geolocator.getLastKnownPosition();
      if (position == null) return null;

      return _fixOf(position, withKinematics: false);
    } on Object {
      return null;
    }
  }

  Future<bool> _isPermitted() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;

    final LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  static GeoFix _fixOf(Position position, {required bool withKinematics}) =>
      GeoFix(
        lat: position.latitude,
        lon: position.longitude,
        speed: withKinematics ? position.speed : null,
        speedAccuracy: withKinematics ? position.speedAccuracy : null,
        altitude: withKinematics ? position.altitude : null,
      );

  static LocationPermissionOutcome _outcomeOf(
    LocationPermission permission,
  ) => switch (permission) {
    LocationPermission.always ||
    LocationPermission.whileInUse => LocationPermissionOutcome.granted,
    LocationPermission.denied => LocationPermissionOutcome.denied,
    LocationPermission.deniedForever => LocationPermissionOutcome.deniedForever,

    LocationPermission.unableToDetermine => LocationPermissionOutcome.denied,
  };
}
