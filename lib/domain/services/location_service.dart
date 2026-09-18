import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_service.g.dart';

@immutable
final class GeoFix {
  const GeoFix({
    required this.lat,
    required this.lon,
    this.speed,
    this.speedAccuracy,
    this.altitude,
  });

  final double lat;

  final double lon;

  final double? speed;

  final double? speedAccuracy;

  final double? altitude;

  @override
  bool operator ==(Object other) =>
      other is GeoFix &&
      other.lat == lat &&
      other.lon == lon &&
      other.speed == speed &&
      other.speedAccuracy == speedAccuracy &&
      other.altitude == altitude;

  @override
  int get hashCode => Object.hash(lat, lon, speed, speedAccuracy, altitude);

  @override
  String toString() =>
      'GeoFix($lat, $lon, speed: $speed ±$speedAccuracy, altitude: $altitude)';
}

enum LocationPermissionOutcome {
  granted,

  denied,

  deniedForever,

  serviceDisabled,
}

abstract interface class LocationService {
  Future<GeoFix?> currentFix();

  Future<LocationPermissionOutcome> requestPermission();

  Future<GeoFix?> lastKnownFix();
}

@Riverpod(keepAlive: true)
LocationService locationService(Ref ref) => throw UnimplementedError(
  'locationServiceProvider is overridden at the root — see main.dart',
);
