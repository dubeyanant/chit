import 'package:flutter/foundation.dart';

import 'geo_point.dart';

enum OutlineLayer {
  urban(closed: true),

  coast(closed: false),

  lakes(closed: true),

  rivers(closed: false);

  const OutlineLayer({required this.closed});

  final bool closed;
}

@immutable
final class OutlineShape {
  factory OutlineShape({
    required OutlineLayer layer,
    required List<GeoPoint> points,
  }) {
    assert(points.length >= 2, 'a shape with one point is not a shape');

    double south = points.first.lat;
    double north = south;
    double west = points.first.lon;
    double east = west;

    for (final GeoPoint point in points) {
      if (point.lat < south) south = point.lat;
      if (point.lat > north) north = point.lat;
      if (point.lon < west) west = point.lon;
      if (point.lon > east) east = point.lon;
    }

    return OutlineShape._(
      layer: layer,
      points: List<GeoPoint>.unmodifiable(points),
      bounds: GeoBox(south: south, west: west, north: north, east: east),
    );
  }

  const OutlineShape._({
    required this.layer,
    required this.points,
    required this.bounds,
  });

  final OutlineLayer layer;

  final List<GeoPoint> points;

  final GeoBox bounds;

  bool contains(GeoPoint point) {
    assert(
      layer.closed,
      'an open line has no inside — ${layer.name} is a line',
    );

    if (!bounds.contains(point)) return false;

    bool inside = false;
    for (int i = 0, j = points.length - 1; i < points.length; j = i++) {
      final GeoPoint a = points[i];
      final GeoPoint b = points[j];

      if ((a.lat > point.lat) != (b.lat > point.lat) &&
          point.lon <
              (b.lon - a.lon) * (point.lat - a.lat) / (b.lat - a.lat) + a.lon) {
        inside = !inside;
      }
    }
    return inside;
  }

  @override
  bool operator ==(Object other) =>
      other is OutlineShape &&
      other.layer == layer &&
      other.bounds == bounds &&
      listEquals(other.points, points);

  @override
  int get hashCode => Object.hash(layer, bounds, points.length);

  @override
  String toString() => 'OutlineShape(${layer.name}, ${points.length} points)';
}
