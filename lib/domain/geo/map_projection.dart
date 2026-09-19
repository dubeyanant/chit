import 'dart:math' as math;

import 'geo_point.dart';

const double kmPerDegree = 111.32;

final class MapProjection {
  MapProjection({
    required this.centre,
    required this.spanKm,
    required this.width,
    required this.height,
  }) : assert(spanKm > 0, 'a viewport with no width shows nothing'),
       assert(width > 0 && height > 0, 'a viewport with no size shows nothing'),
       pixelsPerKm = width / spanKm,

       _lonScale = math.max(math.cos(centre.lat * math.pi / 180), 0.01);

  final GeoPoint centre;

  final double spanKm;

  final double width;

  final double height;

  final double pixelsPerKm;

  final double _lonScale;

  double xOf(double lon) =>
      width / 2 + (lon - centre.lon) * _lonScale * kmPerDegree * pixelsPerKm;

  double yOf(double lat) =>
      height / 2 - (lat - centre.lat) * kmPerDegree * pixelsPerKm;

  double lonOf(double x) =>
      centre.lon + (x - width / 2) / (_lonScale * kmPerDegree * pixelsPerKm);

  double latOf(double y) =>
      centre.lat - (y - height / 2) / (kmPerDegree * pixelsPerKm);

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
