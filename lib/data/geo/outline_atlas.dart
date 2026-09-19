import 'dart:typed_data';

import '../../domain/geo/geo_point.dart';
import '../../domain/geo/outline_shape.dart';
import '../../domain/geo/outline_source.dart';

final class OutlineAtlas implements OutlineSource {
  OutlineAtlas._(this._bytes, this._index, this.cellDeg);

  factory OutlineAtlas.decode(Uint8List bytes) {
    final ByteData data = ByteData.sublistView(bytes);

    final bool magic =
        bytes.length > _headerBytes &&
        bytes[0] == 0x43 &&
        bytes[1] == 0x48 &&
        bytes[2] == 0x54 &&
        bytes[3] == 0x4F;
    if (!magic) {
      throw const FormatException('not an outline atlas: bad magic');
    }

    final int version = bytes[4];
    if (version != _version) {
      throw FormatException(
        'outline atlas version $version, expected $_version',
      );
    }

    final int cellDeg = bytes[5];
    final int cells = data.getUint16(6, Endian.little);

    final Map<int, _Cell> index = <int, _Cell>{};
    for (int i = 0; i < cells; i++) {
      final int at = _headerBytes + i * _indexBytes;
      index[data.getUint16(at, Endian.little)] = _Cell(
        offset: data.getUint32(at + 2, Endian.little),
        length: data.getUint32(at + 6, Endian.little),
      );
    }

    return OutlineAtlas._(bytes, index, cellDeg);
  }

  static const int _version = 1;
  static const int _headerBytes = 8;
  static const int _indexBytes = 10;

  final int cellDeg;

  final Uint8List _bytes;
  final Map<int, _Cell> _index;
  final Map<int, List<OutlineShape>> _decoded = <int, List<OutlineShape>>{};

  int get cellCount => _index.length;

  @override
  List<OutlineShape> shapesIn(GeoBox box) {
    final List<OutlineShape> found = <OutlineShape>[];

    final Set<String> seen = <String>{};

    for (final int key in _keysFor(box)) {
      for (final OutlineShape shape in _cell(key)) {
        if (!shape.bounds.overlaps(box)) continue;
        final GeoPoint first = shape.points.first;
        if (seen.add(
          '${shape.layer.index}:${shape.points.length}:${first.lat}:${first.lon}',
        )) {
          found.add(shape);
        }
      }
    }
    return found;
  }

  @override
  OutlineShape? cityAt(GeoPoint point) {
    for (final OutlineShape shape in _cell(_keyOf(point.lat, point.lon))) {
      if (shape.layer == OutlineLayer.urban && shape.contains(point)) {
        return shape;
      }
    }
    return null;
  }

  int _keyOf(double lat, double lon) {
    final int latIndex = _clamp((lat + 90) ~/ cellDeg, 180 ~/ cellDeg - 1);
    final int lonIndex = _clamp((lon + 180) ~/ cellDeg, 360 ~/ cellDeg - 1);
    return latIndex * (360 ~/ cellDeg) + lonIndex;
  }

  static int _clamp(int value, int last) =>
      value < 0 ? 0 : (value > last ? last : value);

  Iterable<int> _keysFor(GeoBox box) sync* {
    final int lonCells = 360 ~/ cellDeg;
    final int south = _clamp((box.south + 90) ~/ cellDeg, 180 ~/ cellDeg - 1);
    final int north = _clamp((box.north + 90) ~/ cellDeg, 180 ~/ cellDeg - 1);
    final int west = _clamp((box.west + 180) ~/ cellDeg, lonCells - 1);
    final int east = _clamp((box.east + 180) ~/ cellDeg, lonCells - 1);

    for (int lat = south; lat <= north; lat++) {
      for (int lon = west; lon <= east; lon++) {
        yield lat * lonCells + lon;
      }
    }
  }

  List<OutlineShape> _cell(int key) {
    final List<OutlineShape>? already = _decoded[key];
    if (already != null) return already;

    final _Cell? at = _index[key];
    if (at == null) return _decoded[key] = const <OutlineShape>[];

    final _Reader read = _Reader(_bytes, at.offset);
    final List<OutlineShape> shapes = <OutlineShape>[];

    for (final OutlineLayer layer in OutlineLayer.values) {
      final int count = read.unsigned();
      for (int s = 0; s < count; s++) {
        final int points = read.unsigned();
        final List<GeoPoint> ring = <GeoPoint>[];

        int lat = 0;
        int lon = 0;
        for (int p = 0; p < points; p++) {
          lat += read.signed();
          lon += read.signed();
          ring.add(GeoPoint(lat / 1000, lon / 1000));
        }
        if (ring.length >= 2) {
          shapes.add(OutlineShape(layer: layer, points: ring));
        }
      }
    }
    return _decoded[key] = List<OutlineShape>.unmodifiable(shapes);
  }
}

final class _Cell {
  const _Cell({required this.offset, required this.length});

  final int offset;
  final int length;
}

final class _Reader {
  _Reader(this._bytes, this._at);

  final Uint8List _bytes;
  int _at;

  int unsigned() {
    int result = 0;
    int shift = 0;
    int byte;
    do {
      byte = _bytes[_at++];
      result |= (byte & 0x7f) << shift;
      shift += 7;
    } while ((byte & 0x80) != 0);
    return result;
  }

  int signed() {
    final int raw = unsigned();
    return (raw & 1) == 1 ? -((raw + 1) >> 1) : raw >> 1;
  }
}
