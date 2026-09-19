import 'package:geolocator/geolocator.dart';

import '../../domain/services/location_service.dart';

final class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  static const Duration fixTimeout = Duration(seconds: 10);

  static const Duration servicePromptTimeout = Duration(seconds: 60);

  @override
  Future<LocationPermissionOutcome> requestPermission() async {
    try {
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
  Future<LocationServiceOutcome> requestService() async {
    try {
      if (!await _isGranted()) return LocationServiceOutcome.notPermitted;

      if (await Geolocator.isLocationServiceEnabled()) {
        return LocationServiceOutcome.alreadyOn;
      }

      await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: servicePromptTimeout,
        ),
      );

      return LocationServiceOutcome.turnedOn;
    } on LocationServiceDisabledException {
      return LocationServiceOutcome.refused;
    } on Object {
      return await _isEnabled()
          ? LocationServiceOutcome.turnedOn
          : LocationServiceOutcome.refused;
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

  Future<bool> _isPermitted() async => await _isEnabled() && await _isGranted();

  Future<bool> _isEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } on Object {
      return false;
    }
  }

  Future<bool> _isGranted() async {
    final LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  static GeoFix _fixOf(Position position, {required bool withKinematics}) =>
      GeoFix(
        lat: position.latitude,
        lon: position.longitude,
        speed: withKinematics && position.hasSpeed ? position.speed : null,
        speedAccuracy: withKinematics && position.hasSpeedAccuracy
            ? position.speedAccuracy
            : null,
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
