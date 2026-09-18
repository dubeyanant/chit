import 'package:flutter/material.dart';

import '../../domain/models/motion_state.dart';

final class MotionIcon extends StatelessWidget {
  const MotionIcon({
    required this.state,
    required this.colour,
    required this.size,
    super.key,
  }) : assert(
         state != MotionState.stationary,
         'stationary is never drawn — ADR-038 filters it before here',
       );

  static const double _viewBox = 14;

  static const double _strokeInViewBox = 1.42;

  final MotionState state;

  final Color colour;

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _label,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _MotionPainter(
            state: state,
            colour: colour,
            strokeWidth: _strokeInViewBox * size / _viewBox,
          ),
        ),
      ),
    );
  }

  String get _label => switch (state) {
    MotionState.stationary => '',
    MotionState.walking => 'Walking',
    MotionState.traveling => 'Travelling',
    MotionState.flying => 'Flying',
  };
}

class _MotionPainter extends CustomPainter {
  const _MotionPainter({
    required this.state,
    required this.colour,
    required this.strokeWidth,
  });

  final MotionState state;
  final Color colour;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / MotionIcon._viewBox;
    final Paint paint = Paint()
      ..color = colour
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth / scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas
      ..save()
      ..scale(scale);

    switch (state) {
      case MotionState.stationary:
        break;
      case MotionState.walking:
        _walking(canvas, paint);
      case MotionState.traveling:
        _traveling(canvas, paint);
      case MotionState.flying:
        _flying(canvas, paint);
    }

    canvas.restore();
  }

  static void _walking(Canvas canvas, Paint paint) {
    canvas
      ..drawCircle(const Offset(8.2, 2.6), 1.3, paint)
      ..drawPath(
        Path()
          ..moveTo(8.2, 5.2)
          ..lineTo(6.9, 8.4)
          ..lineTo(9.1, 12.7),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(6.9, 8.4)
          ..lineTo(4.5, 11.8),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(8, 6.2)
          ..lineTo(5.3, 6.9),
        paint,
      );
  }

  static void _traveling(Canvas canvas, Paint paint) {
    canvas
      ..drawPath(
        Path()
          ..moveTo(2.1, 8.7)
          ..lineTo(2.1, 6.9)
          ..lineTo(3.8, 3.9)
          ..lineTo(10.2, 3.9)
          ..lineTo(11.9, 6.9)
          ..lineTo(11.9, 8.7),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(1.6, 8.7)
          ..lineTo(12.4, 8.7),
        paint,
      )
      ..drawCircle(const Offset(4.5, 9.5), 1.1, paint)
      ..drawCircle(const Offset(9.5, 9.5), 1.1, paint);
  }

  static void _flying(Canvas canvas, Paint paint) {
    canvas
      ..drawPath(
        Path()
          ..moveTo(7, 1.9)
          ..lineTo(7, 12.1),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(1.9, 8)
          ..lineTo(7, 5.2)
          ..lineTo(12.1, 8),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(4.7, 12)
          ..lineTo(7, 10.6)
          ..lineTo(9.3, 12),
        paint,
      );
  }

  @override
  bool shouldRepaint(_MotionPainter oldDelegate) =>
      oldDelegate.state != state ||
      oldDelegate.colour != colour ||
      oldDelegate.strokeWidth != strokeWidth;
}
