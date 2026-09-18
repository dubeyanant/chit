import 'package:flutter/material.dart';

import '../../core/extensions.dart';
import 'focus_ring.dart';

final class Microphone extends StatelessWidget {
  const Microphone({required this.onRecord, super.key});

  static const double size = 54;

  static const double _strokeInViewBox = 1.22;

  static const double _icon = 20;

  final Future<void> Function() onRecord;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      label: 'Record',
      child: FocusRing(
        onActivate: onRecord,
        child: GestureDetector(
          onTap: onRecord,
          child: SizedBox.square(
            dimension: Microphone.size,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: colors.hair),
                borderRadius: BorderRadius.circular(context.space.radius),
              ),
              child: Center(
                child: CustomPaint(
                  size: const Size.square(Microphone._icon),
                  painter: _MicrophonePainter(
                    colour: colors.inkMuted,
                    strokeWidth: Microphone._strokeInViewBox,
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

class _MicrophonePainter extends CustomPainter {
  const _MicrophonePainter({required this.colour, required this.strokeWidth});

  final Color colour;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = colour
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(7.2, 2.2, 5.6, 9.4),
          const Radius.circular(2.8),
        ),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(4.4, 9.2)
          ..arcToPoint(
            const Offset(15.6, 9.2),
            radius: const Radius.circular(5.6),
            clockwise: false,
          )
          ..moveTo(10, 14.8)
          ..lineTo(10, 17.8),
        paint,
      );
  }

  @override
  bool shouldRepaint(_MicrophonePainter oldDelegate) =>
      oldDelegate.colour != colour || oldDelegate.strokeWidth != strokeWidth;
}
