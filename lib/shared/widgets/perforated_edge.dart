import 'package:flutter/material.dart';

import '../../core/extensions.dart';

/// The tear edge along the top of a chit.
///
/// **Holes in the colour of the surface beneath, not a dotted border.** The
/// design log is emphatic and the whole metaphor rests on it: a chit is torn
/// from a pad, so what is left behind is the pad showing through. A dotted
/// border is a line drawn *along* an edge and says nothing about what is under
/// it; these are holes, and what shows through them is `--slip-under`.
///
/// The strip straddles the slip's top border rather than sitting below it —
/// the holes are punched *through* the edge, so they cut the hairline.
///
/// `Slip` draws one of these across its own top, so nothing normally has to
/// place one by hand. `shared/widgets/slip.dart` is the caller.
final class PerforatedEdge extends StatelessWidget {
  /// A row of holes, as wide as the space it is given.
  const PerforatedEdge({super.key});

  /// **1.55px**, and it is the *radius* — DESIGN-SYSTEM.md §6.3 quotes the
  /// figure as the prototype's CSS writes it, and that gradient stop is a
  /// distance from the centre.
  ///
  /// It was 1.2px in v5. In a colour four points off the slip, at that size,
  /// the holes were invisible at arm's length — a detail nobody sees is a
  /// detail not worth drawing.
  ///
  /// §6.3 says this figure becomes a constant here when M2 writes the widget,
  /// rather than a token in `ChitSpace`, because it is one widget's geometry
  /// and a token nothing reads is a token nobody checks.
  static const double holeRadius = 1.55;

  /// **8px** between hole centres. 6px in v5, and it moved for the same
  /// reason [holeRadius] did.
  static const double pitch = 8;

  /// The strip's height. Holes are centred across it, so a hole's centre sits
  /// [thickness] / 2 below the top of the slip's border.
  ///
  /// This is `s1`, and it is spelled here rather than read from `ChitSpace`
  /// because the painter needs it as a compile-time constant. The test in
  /// `test/shared/widgets/perforated_edge_test.dart` is what keeps the two
  /// agreeing.
  static const double thickness = 4;

  /// Where the holes fall across a strip [width] wide.
  ///
  /// Whole holes only, at [pitch] spacing, with the remainder split evenly at
  /// both ends. The prototype tiles a background image from the left and lets
  /// the right-hand end clip, which leaves a nick on some widths; a torn edge
  /// is symmetric or it is not a torn edge.
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

/// Punches the holes. Nothing here draws a line, and that is the point.
final class _PerforationPainter extends CustomPainter {
  const _PerforationPainter({required this.showsThrough});

  /// The surface under the slip — what a hole reveals.
  final Color showsThrough;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = showsThrough;
    final double y = size.height / 2;

    for (final double x in PerforatedEdge.holeCentresAcross(size.width)) {
      // The prototype's gradient feathers from 1.55px to 1.8px, which is CSS
      // antialiasing a circle by hand. Flutter gives that for free.
      canvas.drawCircle(Offset(x, y), PerforatedEdge.holeRadius, paint);
    }
  }

  @override
  bool shouldRepaint(_PerforationPainter oldDelegate) =>
      oldDelegate.showsThrough != showsThrough;
}
