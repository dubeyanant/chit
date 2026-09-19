import 'package:chitta/domain/geo/geo_point.dart';
import 'package:chitta/domain/geo/map_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('projecting a point onto the screen', () {
    MapProjection at(GeoPoint centre) => MapProjection(
      centre: centre,
      spanKm: kmPerDegree,
      width: 100,
      height: 200,
    );

    test('the centre lands in the middle', () {
      final MapProjection p = at(const GeoPoint(0, 0));

      expect(p.xOf(0), closeTo(50, 1e-9));
      expect(p.yOf(0), closeTo(100, 1e-9));
    });

    test('a degree east is a screen width, and north is up', () {
      final MapProjection p = at(const GeoPoint(0, 0));

      expect(p.xOf(1), closeTo(150, 1e-9));
      expect(p.xOf(-1), closeTo(-50, 1e-9));

      expect(p.yOf(1), closeTo(0, 1e-9));
      expect(p.yOf(-1), closeTo(200, 1e-9));
    });

    test('longitude narrows with latitude, which is the whole projection', () {
      final double atEquator = at(const GeoPoint(0, 0)).xOf(1);
      final double atSixty = at(const GeoPoint(60, 0)).xOf(1);

      expect(atSixty - 50, closeTo((atEquator - 50) / 2, 1e-6));
    });

    test('the inverse gets back what the forward put there', () {
      final MapProjection p = at(const GeoPoint(18.52, 73.85));

      for (final double lon in <double>[73.0, 73.85, 74.6]) {
        expect(p.lonOf(p.xOf(lon)), closeTo(lon, 1e-9));
      }
      for (final double lat in <double>[18.0, 18.52, 19.1]) {
        expect(p.latOf(p.yOf(lat)), closeTo(lat, 1e-9));
      }
    });

    test('the bounds are the viewport, and taller than wide when it is', () {
      final GeoBox box = at(const GeoPoint(0, 0)).bounds;

      expect(box.lonSpan, closeTo(1, 1e-9));

      expect(box.latSpan, closeTo(2, 1e-9));
      expect(box.centre.lat, closeTo(0, 1e-9));
      expect(box.centre.lon, closeTo(0, 1e-9));
    });

    test('a fix at the pole is drawn wrong rather than not at all', () {
      final MapProjection p = at(const GeoPoint(90, 0));

      expect(p.xOf(10).isFinite, isTrue);
      expect(p.bounds.lonSpan.isFinite, isTrue);
    });
  });
}
