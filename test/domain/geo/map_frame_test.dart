import 'dart:math' as math;

import 'package:chitt/domain/geo/geo_point.dart';
import 'package:chitt/domain/geo/map_frame.dart';
import 'package:chitt/domain/geo/map_projection.dart';
import 'package:chitt/domain/geo/outline_shape.dart';
import 'package:chitt/domain/geo/outline_source.dart';
import 'package:flutter_test/flutter_test.dart';

final class _Shapes implements OutlineSource {
  const _Shapes(this._shapes);

  final List<OutlineShape> _shapes;

  @override
  List<OutlineShape> shapesIn(GeoBox box) =>
      _shapes.where((OutlineShape s) => s.bounds.overlaps(box)).toList();

  @override
  OutlineShape? cityAt(GeoPoint point) {
    for (final OutlineShape s in _shapes) {
      if (s.layer == OutlineLayer.urban && s.contains(point)) return s;
    }
    return null;
  }
}

OutlineShape ring({
  required double lat,
  required double lon,
  required double radius,
  int points = 64,
  OutlineLayer layer = OutlineLayer.urban,
}) => OutlineShape(
  layer: layer,
  points: <GeoPoint>[
    for (int i = 0; i < points; i++)
      GeoPoint(
        lat + radius * math.sin(i * 2 * math.pi / points),
        lon + radius * math.cos(i * 2 * math.pi / points),
      ),
  ],
);

const double width = 393;
const double height = 760;

MapFrame? frame(GeoPoint pin, List<OutlineShape> shapes) => MapFraming.around(
  pin: pin,
  source: _Shapes(shapes),
  width: width,
  height: height,
);

void main() {
  group('framing the city the pin stands in', () {
    test(
      'the city it stands in becomes the host, and it is the filled one',
      () {
        final OutlineShape city = ring(lat: 0, lon: 0, radius: 0.05);
        final MapFrame? f = frame(const GeoPoint(0.01, 0.01), <OutlineShape>[
          city,
        ]);

        expect(f, isNotNull);
        expect(f!.host, same(city));
      },
    );

    test('the span is the city and most of the same again around it', () {
      final MapFrame? f = frame(const GeoPoint(0, 0), <OutlineShape>[
        ring(lat: 0, lon: 0, radius: 0.1),
      ]);

      expect(
        f!.spanKm,
        closeTo(0.2 * kmPerDegree * MapFraming.cityFactor, 0.1),
      );
      expect(f.spanKm, greaterThan(MapFraming.minSpanKm));
    });

    test(
      'a hamlet is opened out to the floor rather than filling the screen',
      () {
        final MapFrame? f = frame(const GeoPoint(0, 0), <OutlineShape>[
          ring(lat: 0, lon: 0, radius: 0.01),
        ]);

        expect(f!.spanKm, MapFraming.minSpanKm);
      },
    );

    test(
      'a city too big for the screen is capped rather than shrunk to fit',
      () {
        final MapFrame? f = frame(const GeoPoint(0, 0), <OutlineShape>[
          ring(lat: 0, lon: 0, radius: 2),
        ]);

        expect(f!.spanKm, MapFraming.maxSpanKm);
      },
    );

    test('out in the country there is no host to fill', () {
      final MapFrame? f = frame(const GeoPoint(0, 0), <OutlineShape>[
        ring(lat: 0.05, lon: 0.05, radius: 0.02),
      ]);

      expect(f, isNotNull);
      expect(f!.host, isNull);
    });
  });

  group('opening up until there is something to look at', () {
    test('a town well off a city-sized screen widens the screen', () {
      final MapFrame? f = frame(const GeoPoint(0, 0), <OutlineShape>[
        ring(lat: 0.36, lon: 0, radius: 0.02),
      ]);

      expect(f, isNotNull);
      expect(f!.spanKm, greaterThan(MapFraming.minSpanKm));
      expect(f.spanKm, lessThanOrEqualTo(MapFraming.maxSpanKm));
    });

    test(
      'a desert draws nothing at all, rather than a pin on a blank screen',
      () {
        expect(frame(const GeoPoint(0, 0), <OutlineShape>[]), isNull);

        expect(
          frame(const GeoPoint(0, 0), <OutlineShape>[
            ring(lat: 40, lon: 40, radius: 1, layer: OutlineLayer.lakes),
          ]),
          isNull,
        );
      },
    );

    test(
      'a handful of points is below the floor and still counts as nothing',
      () {
        expect(
          frame(const GeoPoint(0, 0), <OutlineShape>[
            ring(
              lat: 0,
              lon: 0.01,
              radius: 0.01,
              points: 4,
              layer: OutlineLayer.lakes,
            ),
          ]),
          isNull,
        );
      },
    );
  });

  group('keeping the pin clear of find\'s column', () {
    test(
      'a pin at the eastern edge of a big city is moved back into the clear',
      () {
        final MapFrame? f = frame(const GeoPoint(0, 0.38), <OutlineShape>[
          ring(lat: 0, lon: 0, radius: 0.4),
        ]);

        final MapProjection p = f!.projection(width: width, height: height);

        expect(
          p.xOf(f.pin.lon),
          lessThanOrEqualTo(MapFraming.pinMaxX * width + 0.001),
        );
        expect(
          p.xOf(f.pin.lon),
          greaterThanOrEqualTo(MapFraming.pinMinX * width - 0.001),
        );
      },
    );

    test('wherever it lands, it lands inside the safe area', () {
      for (final double lon in <double>[-0.4, -0.2, 0, 0.2, 0.4]) {
        for (final double lat in <double>[-0.4, 0, 0.4]) {
          final MapFrame? f = frame(GeoPoint(lat, lon), <OutlineShape>[
            ring(lat: 0, lon: 0, radius: 0.6),
          ]);
          final MapProjection p = f!.projection(width: width, height: height);
          final double x = p.xOf(f.pin.lon);
          final double y = p.yOf(f.pin.lat);

          expect(x, greaterThanOrEqualTo(MapFraming.pinMinX * width - 0.001));
          expect(x, lessThanOrEqualTo(MapFraming.pinMaxX * width + 0.001));
          expect(y, greaterThanOrEqualTo(MapFraming.pinMinY * height - 0.001));
          expect(y, lessThanOrEqualTo(MapFraming.pinMaxY * height + 0.001));
        }
      }
    });

    test('a pin already in the clear does not move the camera', () {
      final OutlineShape city = ring(lat: 0, lon: 0, radius: 0.4);
      final MapFrame? f = frame(const GeoPoint(0.05, -0.05), <OutlineShape>[
        city,
      ]);

      expect(f!.centre, city.bounds.centre);
    });
  });
}
