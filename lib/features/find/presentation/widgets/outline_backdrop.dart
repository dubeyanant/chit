import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions.dart';
import '../../../../core/theme/chit_colors.dart';
import '../../../../domain/geo/geo_point.dart';
import '../../../../domain/geo/map_frame.dart';
import '../../../../domain/geo/map_projection.dart';
import '../../../../domain/geo/outline_shape.dart';
import '../../../../domain/geo/outline_source.dart';
import '../../application/find_map_provider.dart';

final class OutlineBackdrop extends ConsumerWidget {
  const OutlineBackdrop({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GeoPoint? pin = ref.watch(latestFixProvider);
    if (pin == null) return const SizedBox.shrink();

    final OutlineSource? source = switch (ref.watch(outlineSourceProvider)) {
      AsyncData<OutlineSource>(:final OutlineSource value) => value,
      _ => null,
    };
    if (source == null) return const SizedBox.shrink();

    return IgnorePointer(
      child: RepaintBoundary(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints box) {
            final MapFrame? frame = MapFraming.around(
              pin: pin,
              source: source,
              width: box.maxWidth,
              height: box.maxHeight,
            );
            if (frame == null) return const SizedBox.shrink();

            return CustomPaint(
              size: Size(box.maxWidth, box.maxHeight),
              painter: _OutlinePainter(
                frame: frame,
                source: source,
                colors: context.colors,
              ),
            );
          },
        ),
      ),
    );
  }
}

final class _OutlinePainter extends CustomPainter {
  const _OutlinePainter({
    required this.frame,
    required this.source,
    required this.colors,
  });

  static const double _thin = 0.8;
  static const double _line = 1;
  static const double _host = 1.2;

  static const double _pinRadius = 3;
  static const double _pinDisc = 7;

  final MapFrame frame;
  final OutlineSource source;
  final ChitColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final MapProjection at = frame.projection(
      width: size.width,
      height: size.height,
    );

    final List<OutlineShape> shapes = source.shapesIn(at.bounds);

    _draw(canvas, at, shapes, OutlineLayer.rivers, ChitColors.mapLine, _thin);
    _draw(canvas, at, shapes, OutlineLayer.lakes, ChitColors.mapWater, _line);
    _draw(canvas, at, shapes, OutlineLayer.coast, ChitColors.mapWater, _line);
    _draw(
      canvas,
      at,
      shapes,
      OutlineLayer.urban,
      ChitColors.mapLine,
      _line,
      except: frame.host,
    );

    final OutlineShape? host = frame.host;
    if (host != null) {
      final Path path = _pathOf(host, at);
      canvas.drawPath(path, _fill(ChitColors.mapFill));
      canvas.drawPath(path, _stroke(ChitColors.mapHost, _host));
    }

    final Offset pin = Offset(at.xOf(frame.pin.lon), at.yOf(frame.pin.lat));
    canvas.drawCircle(pin, _pinDisc, Paint()..color = colors.paper);
    canvas.drawCircle(pin, _pinRadius, _fill(ChitColors.mapPin));
  }

  void _draw(
    Canvas canvas,
    MapProjection at,
    List<OutlineShape> shapes,
    OutlineLayer layer,
    double wash,
    double width, {
    OutlineShape? except,
  }) {
    final Paint paint = _stroke(wash, width);

    for (final OutlineShape shape in shapes) {
      if (shape.layer != layer || shape == except) continue;
      canvas.drawPath(_pathOf(shape, at), paint);
    }
  }

  Path _pathOf(OutlineShape shape, MapProjection at) {
    final Path path = Path();

    for (int i = 0; i < shape.points.length; i++) {
      final GeoPoint point = shape.points[i];
      final double x = at.xOf(point.lon);
      final double y = at.yOf(point.lat);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    if (shape.layer.closed) path.close();

    return path;
  }

  Paint _fill(double wash) =>
      Paint()..color = colors.inkWash(colors.paper, opacity: wash);

  Paint _stroke(double wash, double width) => _fill(wash)
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeJoin = StrokeJoin.round;

  @override
  bool shouldRepaint(covariant _OutlinePainter old) =>
      old.frame != frame || old.colors != colors;
}
