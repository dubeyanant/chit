import 'package:flutter/foundation.dart';

import 'geo_point.dart';

/// The four things the atlas holds — ADR-089.
///
/// Order is the order they are drawn in and the order they are stored in, and
/// the two must agree: the codec reads layers positionally.
enum OutlineLayer {
  /// Built-up areas. The one the pin stands in is drawn filled; the rest are
  /// outlines, which is what makes a city read as the subject.
  urban(closed: true),

  /// Coastline, and the strongest line on the screen.
  coast(closed: false),

  lakes(closed: true),

  rivers(closed: false);

  const OutlineLayer({required this.closed});

  /// Whether the shape is a ring that may be filled, or an open line.
  final bool closed;
}

/// One shape read out of the atlas.
@immutable
final class OutlineShape {
  /// [bounds] is computed once here rather than on demand: framing asks for it
  /// in a loop over every shape near the pin, and walking the points each time
  /// is the whole cost of drawing done twice for nothing.
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

  /// Whether [point] falls inside this shape, by ray casting.
  ///
  /// Only meaningful for a [OutlineLayer.closed] layer; an open line has no
  /// inside, and asking is a mistake worth catching in development.
  bool contains(GeoPoint point) {
    assert(layer.closed, 'an open line has no inside — ${layer.name} is a line');

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

  /// **By value, not by identity.** A shape wider than one cell of the atlas is
  /// filed in each cell it touches and decoded separately from each, so the
  /// city handed back by `cityAt` is a different object from the one that comes
  /// out of `shapesIn` — and a painter that told them apart by identity would
  /// draw the host city twice, once as itself and once as its own neighbour.
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
