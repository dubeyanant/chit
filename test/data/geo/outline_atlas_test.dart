import 'dart:io';
import 'dart:typed_data';

import 'package:chitta/data/geo/asset_outline_atlas.dart';
import 'package:chitta/data/geo/outline_atlas.dart';
import 'package:chitta/domain/geo/geo_point.dart';
import 'package:chitta/domain/geo/map_frame.dart';
import 'package:chitta/domain/geo/map_projection.dart';
import 'package:chitta/domain/geo/outline_shape.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The asset the app ships, read off disk rather than out of the bundle: the
  // decoding is what is under test, and a bundle needs a binding.
  final Uint8List bytes = File(outlineAtlasAsset).readAsBytesSync();
  final OutlineAtlas atlas = OutlineAtlas.decode(bytes);

  _framing(atlas);

  group('the file the app ships', () {
    test('it is there, and it is not empty', () {
      expect(bytes.lengthInBytes, greaterThan(100000));
      expect(atlas.cellCount, greaterThan(1000));
      expect(atlas.cellDeg, 2);
    });

    test('something that is not an atlas is refused, not misread', () {
      expect(
        () => OutlineAtlas.decode(Uint8List.fromList(<int>[1, 2, 3, 4, 5, 6, 7, 8, 9])),
        throwsA(isA<FormatException>()),
      );
    });

    test('a file from a later format is refused rather than guessed at', () {
      final Uint8List future = Uint8List.fromList(bytes);
      future[4] = 99;

      expect(() => OutlineAtlas.decode(future), throwsA(isA<FormatException>()));
    });
  });

  group('finding the city somebody is standing in', () {
    test('a fix in a city comes back with that city, whole', () {
      // Bandra, Mumbai.
      final OutlineShape? city = atlas.cityAt(const GeoPoint(19.076, 72.8777));

      expect(city, isNotNull);
      expect(city!.layer, OutlineLayer.urban);
      expect(city.contains(const GeoPoint(19.076, 72.8777)), isTrue);
      // Whole, not clipped to its cell: a shape cut at the grid could not fill.
      expect(city.points.length, greaterThan(10));
    });

    test('it works away from India too, which is the point of bundling it', () {
      for (final GeoPoint fix in const <GeoPoint>[
        GeoPoint(51.5072, -0.1276), // London
        GeoPoint(-23.5505, -46.6333), // São Paulo
        GeoPoint(35.6762, 139.6503), // Tokyo
      ]) {
        expect(atlas.cityAt(fix), isNotNull, reason: '$fix should be in a city');
      }
    });

    test('the middle of an ocean is in no city', () {
      expect(atlas.cityAt(const GeoPoint(0, -140)), isNull);
    });
  });

  group('reading what is near a point', () {
    test('a city box comes back with something to draw', () {
      final List<OutlineShape> near = atlas.shapesIn(
        const GeoBox(south: 18.8, west: 72.6, north: 19.4, east: 73.2),
      );

      expect(near, isNotEmpty);
      expect(
        near.map((OutlineShape s) => s.layer).toSet(),
        contains(OutlineLayer.urban),
      );
    });

    test('a shape filed in two cells is only handed back once', () {
      // A box wide enough to span cells. Twice over is visibly darker than
      // once, so the duplicate has to go before it reaches a painter.
      final List<OutlineShape> near = atlas.shapesIn(
        const GeoBox(south: 17, west: 71, north: 23, east: 77),
      );

      final Set<String> keys = near
          .map(
            (OutlineShape s) =>
                '${s.layer.index}:${s.points.length}:'
                '${s.points.first.lat}:${s.points.first.lon}',
          )
          .toSet();

      expect(keys.length, near.length);
    });

    test('everything handed back actually meets the box', () {
      const GeoBox box = GeoBox(south: 12.7, west: 77.3, north: 13.2, east: 77.9);

      for (final OutlineShape s in atlas.shapesIn(box)) {
        expect(s.bounds.overlaps(box), isTrue);
      }
    });

    test('empty ocean reads as empty, not as a crash', () {
      expect(
        atlas.shapesIn(const GeoBox(south: -20, west: -140, north: -19, east: -139)),
        isEmpty,
      );
    });
  });
}

// The rule and the real file together — the domain tests stand shapes in front
// of MapFraming by hand, and this is the one place the two meet.
void _framing(OutlineAtlas atlas) {
  group('framing against the file the app ships', () {
    const double width = 393;
    const double height = 760;

    MapFrame? frameAt(double lat, double lon) => MapFraming.around(
      pin: GeoPoint(lat, lon),
      source: atlas,
      width: width,
      height: height,
    );

    test('three cities each get a frame, a host and a sane span', () {
      const Map<String, GeoPoint> cities = <String, GeoPoint>{
        'Mumbai': GeoPoint(19.076, 72.8777),
        'Bangalore': GeoPoint(12.9716, 77.5946),
        'Pune': GeoPoint(18.5204, 73.8567),
      };

      cities.forEach((String name, GeoPoint fix) {
        final MapFrame? f = frameAt(fix.lat, fix.lon);

        expect(f, isNotNull, reason: '$name should frame');
        expect(f!.host, isNotNull, reason: '$name should have a city to fill');
        expect(f.spanKm, greaterThanOrEqualTo(MapFraming.minSpanKm));
        expect(f.spanKm, lessThanOrEqualTo(MapFraming.maxSpanKm));
      });
    });

    test('the pin always lands clear of the column', () {
      for (final GeoPoint fix in const <GeoPoint>[
        GeoPoint(19.076, 72.8777),
        GeoPoint(12.9716, 77.5946),
        GeoPoint(51.5072, -0.1276),
        GeoPoint(35.6762, 139.6503),
      ]) {
        final MapFrame f = frameAt(fix.lat, fix.lon)!;
        final MapProjection p = f.projection(width: width, height: height);

        expect(p.xOf(f.pin.lon), lessThanOrEqualTo(MapFraming.pinMaxX * width + 0.01));
        expect(p.yOf(f.pin.lat), lessThanOrEqualTo(MapFraming.pinMaxY * height + 0.01));
      }
    });

    test('the open ocean draws nothing at all', () {
      expect(frameAt(0, -140), isNull);
    });
  });
}
