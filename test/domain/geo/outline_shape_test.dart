import 'package:chitt/domain/geo/geo_point.dart';
import 'package:chitt/domain/geo/outline_shape.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  OutlineShape square({OutlineLayer layer = OutlineLayer.urban}) =>
      OutlineShape(
        layer: layer,
        points: const <GeoPoint>[
          GeoPoint(0, 0),
          GeoPoint(0, 1),
          GeoPoint(1, 1),
          GeoPoint(1, 0),
        ],
      );

  group('a shape and its bounds', () {
    test('the bounds are the extent of the points', () {
      final GeoBox b = square().bounds;

      expect(b.south, 0);
      expect(b.west, 0);
      expect(b.north, 1);
      expect(b.east, 1);
    });

    test('the points cannot be written to afterwards', () {
      expect(
        () => square().points.add(const GeoPoint(9, 9)),
        throwsUnsupportedError,
      );
    });

    test('one point is not a shape', () {
      expect(
        () => OutlineShape(
          layer: OutlineLayer.coast,
          points: const <GeoPoint>[GeoPoint(0, 0)],
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('what a closed shape contains', () {
    test('the middle is inside and the outside is not', () {
      expect(square().contains(const GeoPoint(0.5, 0.5)), isTrue);
      expect(square().contains(const GeoPoint(0.5, 1.5)), isFalse);
      expect(square().contains(const GeoPoint(-0.5, 0.5)), isFalse);
    });

    test('a point far away is refused on the bounds, without the walk', () {
      expect(square().contains(const GeoPoint(40, 40)), isFalse);
    });

    test('a concave shape does not fill its own notch', () {
      final OutlineShape c = OutlineShape(
        layer: OutlineLayer.urban,
        points: const <GeoPoint>[
          GeoPoint(0, 0),
          GeoPoint(0, 3),
          GeoPoint(1, 3),
          GeoPoint(1, 1),
          GeoPoint(2, 1),
          GeoPoint(2, 3),
          GeoPoint(3, 3),
          GeoPoint(3, 0),
        ],
      );

      expect(c.contains(const GeoPoint(1.5, 0.5)), isTrue);
      expect(c.contains(const GeoPoint(1.5, 2.5)), isFalse);
    });

    test('asking an open line what it contains is a mistake, and says so', () {
      expect(
        () =>
            square(layer: OutlineLayer.coast)
                .contains(const GeoPoint(0.5, 0.5)),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('the layers', () {
    test('two are rings that may be filled and two are lines', () {
      expect(OutlineLayer.urban.closed, isTrue);
      expect(OutlineLayer.lakes.closed, isTrue);
      expect(OutlineLayer.coast.closed, isFalse);
      expect(OutlineLayer.rivers.closed, isFalse);
    });

    test('their order is the order the codec reads them in', () {
      expect(OutlineLayer.values, <OutlineLayer>[
        OutlineLayer.urban,
        OutlineLayer.coast,
        OutlineLayer.lakes,
        OutlineLayer.rivers,
      ]);
    });
  });
}
