import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'geo_point.dart';
import 'map_projection.dart';
import 'outline_shape.dart';
import 'outline_source.dart';

/// Where the map sits, and which shape is the subject of it.
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

  /// The chit's own fix — drawn as the one bright mark on the screen.
  final GeoPoint pin;

  /// The built-up area the pin stands in, drawn filled while its neighbours are
  /// left as outlines. **Null out in the country**, where there is nothing to
  /// fill and the pin stands on open ground.
  final OutlineShape? host;

  MapProjection projection({required double width, required double height}) =>
      MapProjection(
        centre: centre,
        spanKm: spanKm,
        width: width,
        height: height,
      );

  /// What a painter asks to decide whether anything moved.
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

/// How the map frames itself around one fix — ADR-089.
///
/// The rule in one line: **frame the city the pin stands in, open up until the
/// viewport has something in it, then move the camera so the pin clears find's
/// column.** All three steps are arithmetic, which is why none of them needs a
/// screen to be checked (CLAUDE.md §4.2).
final class MapFraming {
  const MapFraming._();

  /// The host city, and most of the same again around it — so that a metro and
  /// a market town both sit on the screen at about the same size, and the fill
  /// reads as *the* subject either way.
  ///
  /// **1.8 and not 3, read off a handset**: at 3 every city bigger than about
  /// fifty kilometres hit the cap, so Mumbai drew at the full span and sat in a
  /// third of the screen with the rest given to sea.
  static const double cityFactor = 1.8;

  /// Tight enough that a small town is not lost, wide enough that a metro's
  /// neighbours and its coast come with it.
  static const double minSpanKm = 24;
  static const double maxSpanKm = 110;

  /// What an empty viewport opens by before it looks again.
  static const double widenBy = 1.5;

  /// Points in view below which there is nothing worth drawing. A desert has no
  /// coast, no river and no town, and **a lone pin on an empty screen reads as
  /// a defect rather than as a fact** — so nothing is drawn at all (ADR-007).
  static const int inkFloor = 40;

  /// Where the pin may land, in fractions of the viewport. It has to clear
  /// find's column, which is flush right and runs to the bottom (ADR-084).
  static const double pinMinX = 0.18;
  static const double pinMaxX = 0.60;
  static const double pinMinY = 0.14;
  static const double pinMaxY = 0.68;

  /// The frame for [pin], or **null when there is nothing worth drawing**.
  static MapFrame? around({
    required GeoPoint pin,
    required OutlineSource source,
    required double width,
    required double height,
  }) {
    final OutlineShape? host = source.cityAt(pin);

    GeoPoint centre = host?.bounds.centre ?? pin;

    // Clamped here and not only in the widening below: a metro wider than the
    // cap never enters that loop, and an unclamped span would frame Delhi at a
    // thousand kilometres — the city filling the screen, which is the failure
    // the cap exists to stop.
    final double spanForCity = _spanForCity(host, width: width, height: height);
    double spanKm = spanForCity.clamp(minSpanKm, maxSpanKm);

    // Open up until the viewport holds something. A town twelve kilometres away
    // is off a city-sized screen, and the answer is a wider screen rather than
    // a blank one.
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

    // The taller of the two is compared against the viewport's shape, so a city
    // that is long north-to-south still fits a portrait screen.
    final double acrossKm = bounds.lonSpan * lonScale * kmPerDegree;
    final double downKm = bounds.latSpan * kmPerDegree * width / height;

    return math.max(acrossKm, downKm) * cityFactor;
  }

  /// How much there is to look at, counted honestly.
  ///
  /// **Counting only the points inside the viewport gets two cases wrong**, and
  /// both of them draw a blank screen over something there was plenty to see:
  /// standing in the middle of a city wider than the screen, where the fill
  /// covers everything and not one of its corners is in view; and a coastline
  /// crossing the middle with both of its ends off the edges.
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

    // The city being stood in is drawn filled, so it is ink whether or not any
    // of its outline is on the screen.
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

  /// Whether the run between two points puts anything on the screen.
  ///
  /// The segment's own extent against the viewport — which says yes a little
  /// more often than a true intersection would, on segments that are short
  /// enough for the difference not to matter.
  static bool _crosses(GeoPoint a, GeoPoint b, GeoBox bounds) => GeoBox(
    south: math.min(a.lat, b.lat),
    west: math.min(a.lon, b.lon),
    north: math.max(a.lat, b.lat),
    east: math.max(a.lon, b.lon),
  ).overlaps(bounds);

  /// Slide the camera the least distance that puts the pin in the clear.
  ///
  /// The viewport moves with it, so what is in view is not quite what [_inkIn]
  /// counted — by less than a third of a screen, and the floor has margin in it.
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

    return GeoPoint(
      at.latOf(height / 2 + dy),
      at.lonOf(width / 2 + dx),
    );
  }
}
