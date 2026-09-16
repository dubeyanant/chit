import 'package:flutter/material.dart';

import '../../domain/models/motion_state.dart';

/// The mark BEHAVIOUR.md §3.6 draws for a motion state — **ADR-039**.
///
/// **Motion is an icon where weather is a word.** A condition is recorded as a
/// word because "raining" is a feeling; a motion state is a fact about the
/// phone, and every word for it — *in transit*, *in vehicle*, *active* —
/// reads like a fitness tracker. So it is drawn instead, and the row keeps one
/// word at most.
///
/// It takes the pin's own 14-unit box and the pin's own 1.42 stroke, so the
/// stamp has one drawing weight rather than two. The paths are the ones in
/// `design/chit-app-v6.html`, which is where they were designed.
///
/// **Drawn as strokes rather than as outlines.** A plane's wings and a
/// figure's limbs are a unit and a half wide, and an outline of either closes
/// into a blob under a 1.22px stroke at 12px — the size this actually renders
/// at. Three lines that suggest a plane survive the size; a traced silhouette
/// does not.
final class MotionIcon extends StatelessWidget {
  /// The mark for [state], at [size], in [colour].
  ///
  /// [MotionState.stationary] draws nothing — §3.6 has no mark for it, and
  /// `AmbientFact` never offers one. The assert is where a caller that went
  /// round the ladder finds out.
  const MotionIcon({
    required this.state,
    required this.colour,
    required this.size,
    super.key,
  }) : assert(
         state != MotionState.stationary,
         'stationary is never drawn — ADR-038 filters it before here',
       );

  /// The box the prototype's paths are written in.
  static const double _viewBox = 14;

  /// The stroke the icon set holds, in those same units. At 12px it draws at
  /// about 1.22px, which is what every other icon in the app measures.
  static const double _strokeInViewBox = 1.42;

  /// What the phone was doing.
  final MotionState state;

  /// The ink. The stamp passes its **own** colour rather than the pin's
  /// `--ink-faint`: this icon stands in for a word, so it weighs what that
  /// word weighed — brighter on the open chit, quieter in the thread.
  final Color colour;

  /// The side of the square it draws in. `s3`, as the pin is given.
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

  /// What a screen reader says.
  ///
  /// §6.4 asks for it: the icon is the whole of the fact, so with nothing read
  /// out there is simply one fewer thing on the chit. Exhaustive with no
  /// `default:` — CLAUDE.md §4.1.
  String get _label => switch (state) {
    MotionState.stationary => '',
    MotionState.walking => 'Walking',
    MotionState.traveling => 'Travelling',
    MotionState.flying => 'Flying',
  };
}

/// Draws one of the three marks, scaled from the prototype's 14-unit box.
///
/// One painter rather than three, because the scaling is one piece of
/// knowledge and the shapes differ only in their paths — CLAUDE.md §4.1's DRY
/// rule is about knowledge, and this is the knowledge.
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

  /// Head, torso into a stride, trailing leg, trailing arm.
  static void _walking(Canvas canvas, Paint paint) {
    // <circle cx=8.2 cy=2.6 r=1.3/>
    // M8.2 5.2 6.9 8.4l2.2 4.3   M6.9 8.4 4.5 11.8   M8 6.2 5.3 6.9
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

  /// A car from the side: cabin and bonnet over a sill, on two wheels.
  static void _traveling(Canvas canvas, Paint paint) {
    // M2.1 8.7V6.9l1.7-3h6.4l1.7 3v1.8   M1.6 8.7h10.8
    // <circle cx=4.5 cy=9.5 r=1.1/> <circle cx=9.5 cy=9.5 r=1.1/>
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

  /// A plane from above: fuselage, swept wing, tailplane. Three lines.
  static void _flying(Canvas canvas, Paint paint) {
    // M7 1.9v10.2   M1.9 8 7 5.2l5.1 2.8   M4.7 12 7 10.6l2.3 1.4
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
