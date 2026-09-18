import 'package:flutter/material.dart';

import '../../core/extensions.dart';

final class PerforatedEdge extends StatelessWidget {
  const PerforatedEdge({super.key});

  static const double holeRadius = 1.55;

  static const double pitch = 8;

  static const double thickness = 4;

  static List<double> holeCentresAcross(double width) {
    final int count = width ~/ pitch;
    if (count < 1) return const <double>[];
    final double margin = (width - (count - 1) * pitch) / 2;
    return <double>[for (int i = 0; i < count; i++) margin + i * pitch];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: thickness,
      width: double.infinity,
      child: CustomPaint(
        painter: _PerforationPainter(showsThrough: context.colors.slipUnder),
      ),
    );
  }
}

final class _PerforationPainter extends CustomPainter {
  const _PerforationPainter({required this.showsThrough});

  final Color showsThrough;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = showsThrough;
    final double y = size.height / 2;

    for (final double x in PerforatedEdge.holeCentresAcross(size.width)) {
      canvas.drawCircle(Offset(x, y), PerforatedEdge.holeRadius, paint);
    }
  }

  @override
  bool shouldRepaint(_PerforationPainter oldDelegate) =>
      oldDelegate.showsThrough != showsThrough;
}
