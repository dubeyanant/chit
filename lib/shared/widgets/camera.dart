import 'package:flutter/material.dart';

import '../../core/extensions.dart';
import 'focus_ring.dart';
import 'microphone.dart';

final class Camera extends StatelessWidget {
  const Camera({required this.onPhoto, this.label = 'Add a photo', super.key});

  static const double _strokeInViewBox = 1.22;

  static const double _icon = 20;

  final Future<void> Function() onPhoto;

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      label: label,
      child: FocusRing(
        onActivate: onPhoto,
        child: GestureDetector(
          onTap: onPhoto,
          child: SizedBox.square(
            dimension: Microphone.size,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: colors.hair),
                borderRadius: BorderRadius.circular(context.space.radius),
              ),
              child: Center(
                child: CustomPaint(
                  size: const Size.square(Camera._icon),
                  painter: _CameraPainter(
                    colour: colors.inkMuted,
                    strokeWidth: Camera._strokeInViewBox,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CameraPainter extends CustomPainter {
  const _CameraPainter({required this.colour, required this.strokeWidth});

  final Color colour;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = colour
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas
      ..drawPath(
        Path()
          ..moveTo(7.6, 5.0)
          ..lineTo(8.8, 3.0)
          ..lineTo(11.2, 3.0)
          ..lineTo(12.4, 5.0),
        paint,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(2.6, 5.0, 14.8, 12.0),
          const Radius.circular(2.4),
        ),
        paint,
      )
      ..drawCircle(const Offset(10, 11.2), 3.4, paint);
  }

  @override
  bool shouldRepaint(_CameraPainter oldDelegate) =>
      oldDelegate.colour != colour || oldDelegate.strokeWidth != strokeWidth;
}
