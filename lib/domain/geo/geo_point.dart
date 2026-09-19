import 'package:flutter/foundation.dart';

/// A point on the earth, in degrees.
@immutable
final class GeoPoint {
  const GeoPoint(this.lat, this.lon);

  final double lat;

  final double lon;

  @override
  bool operator ==(Object other) =>
      other is GeoPoint && other.lat == lat && other.lon == lon;

  @override
  int get hashCode => Object.hash(lat, lon);

  @override
  String toString() => 'GeoPoint($lat, $lon)';
}

/// A rectangle of the earth.
///
/// **Longitude does not wrap.** The atlas is cut on a grid that does not wrap
/// either, and the widest view find draws is a degree or two across, so a box
/// spanning the antimeridian is a state this app cannot reach.
@immutable
final class GeoBox {
  const GeoBox({
    required this.south,
    required this.west,
    required this.north,
    required this.east,
  });

  final double south;

  final double west;

  final double north;

  final double east;

  bool contains(GeoPoint point) =>
      point.lat >= south &&
      point.lat <= north &&
      point.lon >= west &&
      point.lon <= east;

  bool overlaps(GeoBox other) =>
      other.east >= west &&
      other.west <= east &&
      other.north >= south &&
      other.south <= north;

  GeoPoint get centre => GeoPoint((south + north) / 2, (west + east) / 2);

  double get latSpan => north - south;

  double get lonSpan => east - west;

  @override
  bool operator ==(Object other) =>
      other is GeoBox &&
      other.south == south &&
      other.west == west &&
      other.north == north &&
      other.east == east;

  @override
  int get hashCode => Object.hash(south, west, north, east);

  @override
  String toString() => 'GeoBox($south, $west → $north, $east)';
}
