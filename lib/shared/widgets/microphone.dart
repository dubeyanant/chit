import 'package:flutter/material.dart';

import '../../core/extensions.dart';

/// The way in that is not typing — BEHAVIOUR.md §3.2 and §3.4.
///
/// It leads the action row at the full 54px because §4.1 makes it an equal of
/// the field rather than a secondary action, and its target does not shrink
/// when text appears (§6.4).
///
/// *It was drawn in M2 and deliberately not marked up as a control, because
/// §6.4 does not allow one that does nothing.* M5 group D gave it its action,
/// its label and its pressed wash together; **M6 group E moved it here** from
/// the open chit when the editor became the second screen to want it
/// (ARCHITECTURE.md §2). What a tap does is [onRecord]'s — the two screens
/// start the same take and send it to different owners (ADR-065).
final class Microphone extends StatelessWidget {
  /// A microphone whose tap runs [onRecord].
  const Microphone({required this.onRecord, super.key});

  /// 54px — one of the four dimensions DESIGN-SYSTEM.md §6.3 allows off the
  /// scale, and **its target does not shrink when text appears** (§6.4).
  static const double size = 54;

  /// The stroke the icon set holds, in the prototype's 20-unit box.
  static const double _strokeInViewBox = 1.22;

  /// The icon's own box, drawn at 20 of the 54.
  static const double _icon = 20;

  /// Ask, start, raise the sheet — whatever the screen does with a tap.
  final Future<void> Function() onRecord;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      label: 'Record',
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
    );
  }
}

/// The microphone glyph, in the prototype's own 20-unit box.
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
      // <rect x=7.2 y=2.2 width=5.6 height=9.4 rx=2.8/>
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(7.2, 2.2, 5.6, 9.4),
          const Radius.circular(2.8),
        ),
        paint,
      )
      // <path d="M4.4 9.2a5.6 5.6 0 0 0 11.2 0M10 14.8v3"/>
      ..drawPath(
        Path()
          ..moveTo(4.4, 9.2)
          // The cup hangs below the capsule and meets the stem at 14.8, so
          // the semicircle goes left → down → right: counter-clockwise on a
          // screen, which is the SVG's `sweep-flag 0`.
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
