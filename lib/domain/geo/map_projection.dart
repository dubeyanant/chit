import 'dart:math' as math;

import 'geo_point.dart';

/// Kilometres to a degree of latitude.
const double kmPerDegree = 111.32;

/// Where a point on the earth lands on the screen.
///
/// **Equirectangular, longitude scaled by the cosine of the centre's latitude**
/// (ADR-089). Across the tens of kilometres find draws, this and Web Mercator
/// differ by less than the error in the fix being drawn, and this one is
/// arithmetic a test can check by hand.
final class MapProjection {
  MapProjection({
    required this.centre,
    required this.spanKm,
    required this.width,
    required this.height,
  }) : assert(spanKm > 0, 'a viewport with no width shows nothing'),
       assert(width > 0 && height > 0, 'a viewport with no size shows nothing'),
       pixelsPerKm = width / spanKm,
       // At the poles the cosine goes to zero and every longitude is the same
       // place. Nothing stops a fix from being taken there, so the scale has a
       // floor rather than an assert: a map that is wrong at Longyearbyen beats
       // one that divides by zero.
       _lonScale = math.max(math.cos(centre.lat * math.pi / 180), 0.01);

  /// What sits at the middle of the viewport.
  final GeoPoint centre;

  /// How wide the viewport is on the ground.
  final double spanKm;

  final double width;

  final double height;

  final double pixelsPerKm;

  final double _lonScale;

  double xOf(double lon) =>
      width / 2 + (lon - centre.lon) * _lonScale * kmPerDegree * pixelsPerKm;

  double yOf(double lat) =>
      height / 2 - (lat - centre.lat) * kmPerDegree * pixelsPerKm;

  /// The inverse, which is what the framing rule shifts the camera with.
  double lonOf(double x) =>
      centre.lon + (x - width / 2) / (_lonScale * kmPerDegree * pixelsPerKm);

  double latOf(double y) =>
      centre.lat - (y - height / 2) / (kmPerDegree * pixelsPerKm);

  /// What the viewport covers.
  GeoBox get bounds {
    final double halfLon = spanKm / 2 / (_lonScale * kmPerDegree);
    final double halfLat = spanKm * height / width / 2 / kmPerDegree;

    return GeoBox(
      south: centre.lat - halfLat,
      west: centre.lon - halfLon,
      north: centre.lat + halfLat,
      east: centre.lon + halfLon,
    );
  }
}
