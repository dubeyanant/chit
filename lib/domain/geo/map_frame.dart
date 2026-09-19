import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'geo_point.dart';
import 'map_projection.dart';
import 'outline_shape.dart';
import 'outline_source.dart';

@immutable
final class MapFrame {
  const MapFrame({
    required this.centre,
    required this.spanKm,
    required this.pin,
    required this.host,
  });

  final GeoPoint centre;

  final double spanKm;

  final GeoPoint pin;

  final OutlineShape? host;

  MapProjection projection({required double width, required double height}) =>
      MapProjection(
        centre: centre,
        spanKm: spanKm,
        width: width,
        height: height,
      );

  @override
  bool operator ==(Object other) =>
      other is MapFrame &&
      other.centre == centre &&
      other.spanKm == spanKm &&
      other.pin == pin &&
      other.host == host;

  @override
  int get hashCode => Object.hash(centre, spanKm, pin, host);

  @override
  String toString() =>
      'MapFrame($centre, ${spanKm.toStringAsFixed(1)}km, '
      'host: ${host == null ? 'none' : 'yes'})';
}

final class MapFraming {
  const MapFraming._();

  static const double cityFactor = 1.8;

  static const double minSpanKm = 24;
  static const double maxSpanKm = 110;

  static const double widenBy = 1.5;

  static const int inkFloor = 40;

  static const double pinMinX = 0.18;
  static const double pinMaxX = 0.60;
  static const double pinMinY = 0.14;
  static const double pinMaxY = 0.68;

  static MapFrame? around({
    required GeoPoint pin,
    required OutlineSource source,
    required double width,
    required double height,
  }) {
    final OutlineShape? host = source.cityAt(pin);

    GeoPoint centre = host?.bounds.centre ?? pin;

    final double spanForCity = _spanForCity(host, width: width, height: height);
    double spanKm = spanForCity.clamp(minSpanKm, maxSpanKm);

    while (_inkIn(source, host, centre, spanKm, width, height) < inkFloor) {
      if (spanKm >= maxSpanKm) return null;
      spanKm = math.min(spanKm * widenBy, maxSpanKm);
    }

    centre = _shiftForPin(
      pin: pin,
      centre: centre,
      spanKm: spanKm,
      width: width,
      height: height,
    );

    return MapFrame(centre: centre, spanKm: spanKm, pin: pin, host: host);
  }

  static double _spanForCity(
    OutlineShape? host, {
    required double width,
    required double height,
  }) {
    if (host == null) return minSpanKm;

    final GeoBox bounds = host.bounds;
    final double lonScale = math.max(
      math.cos(bounds.centre.lat * math.pi / 180),
      0.01,
    );

    final double acrossKm = bounds.lonSpan * lonScale * kmPerDegree;
    final double downKm = bounds.latSpan * kmPerDegree * width / height;

    return math.max(acrossKm, downKm) * cityFactor;
  }

  static int _inkIn(
    OutlineSource source,
    OutlineShape? host,
    GeoPoint centre,
    double spanKm,
    double width,
    double height,
  ) {
    final GeoBox bounds = MapProjection(
      centre: centre,
      spanKm: spanKm,
      width: width,
      height: height,
    ).bounds;

    if (host != null && host.bounds.overlaps(bounds)) return inkFloor;

    int seen = 0;
    for (final OutlineShape shape in source.shapesIn(bounds)) {
      GeoPoint? previous;
      for (final GeoPoint point in shape.points) {
        final bool draws =
            bounds.contains(point) ||
            (previous != null && _crosses(previous, point, bounds));

        if (draws && ++seen >= inkFloor) return seen;
        previous = point;
      }
    }
    return seen;
  }

  static bool _crosses(GeoPoint a, GeoPoint b, GeoBox bounds) => GeoBox(
    south: math.min(a.lat, b.lat),
    west: math.min(a.lon, b.lon),
    north: math.max(a.lat, b.lat),
    east: math.max(a.lon, b.lon),
  ).overlaps(bounds);

  static GeoPoint _shiftForPin({
    required GeoPoint pin,
    required GeoPoint centre,
    required double spanKm,
    required double width,
    required double height,
  }) {
    final MapProjection at = MapProjection(
      centre: centre,
      spanKm: spanKm,
      width: width,
      height: height,
    );

    final double x = at.xOf(pin.lon);
    final double y = at.yOf(pin.lat);

    final double dx = switch (x) {
      _ when x < pinMinX * width => x - pinMinX * width,
      _ when x > pinMaxX * width => x - pinMaxX * width,
      _ => 0,
    };
    final double dy = switch (y) {
      _ when y < pinMinY * height => y - pinMinY * height,
      _ when y > pinMaxY * height => y - pinMaxY * height,
      _ => 0,
    };

    if (dx == 0 && dy == 0) return centre;

    return GeoPoint(at.latOf(height / 2 + dy), at.lonOf(width / 2 + dx));
  }
}
