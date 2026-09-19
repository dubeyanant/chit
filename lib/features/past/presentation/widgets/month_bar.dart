import 'package:flutter/material.dart';

import '../../../../core/extensions.dart';
import '../../../../shared/widgets/focus_ring.dart';
import '../../../../shared/widgets/heading_row.dart';
import '../../application/month_provider.dart';

final class MonthBar extends StatelessWidget {
  const MonthBar({
    required this.month,
    required this.onPrevious,
    required this.onNext,
    super.key,
  });

  final YearMonth month;

  final VoidCallback? onPrevious;

  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    final colors = context.colors;

    final double overhang =
        (context.space.minTouchTarget - Chevron.glyphSize) / 2;

    return HeadingRow(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Semantics(
              header: true,
              child: Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    TextSpan(text: '${month.name} '),
                    TextSpan(
                      text: '${month.year}',
                      style: type.date.copyWith(color: colors.inkFaint),
                    ),
                  ],
                ),
                style: type.date,
              ),
            ),
          ),

          Transform.translate(
            offset: Offset(overhang, 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Chevron(
                  pointsLeft: true,
                  label: 'Previous month',
                  onTap: onPrevious,
                ),
                Chevron(pointsLeft: false, label: 'Next month', onTap: onNext),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final class Chevron extends StatelessWidget {
  const Chevron({
    required this.pointsLeft,
    required this.label,
    required this.onTap,
    super.key,
  });

  final bool pointsLeft;

  final String label;

  final VoidCallback? onTap;

  static const double glyphSize = 17;

  @override
  Widget build(BuildContext context) {
    final space = context.space;
    final colors = context.colors;
    final VoidCallback? go = onTap;

    final Widget glyph = SizedBox.square(
      dimension: space.minTouchTarget,
      child: Center(
        child: CustomPaint(
          size: const Size.square(glyphSize),
          painter: _ChevronPainter(
            color: go == null ? colors.inkDisabled : colors.inkFaint,
            pointsLeft: pointsLeft,
          ),
        ),
      ),
    );

    if (go == null) {
      return Semantics(
        button: true,
        enabled: false,
        label: label,
        child: glyph,
      );
    }

    return Semantics(
      button: true,
      label: label,
      child: FocusRing(
        onActivate: go,
        child: GestureDetector(
          onTap: go,
          behavior: HitTestBehavior.opaque,
          child: glyph,
        ),
      ),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter({required this.color, required this.pointsLeft});

  final Color color;
  final bool pointsLeft;

  static const double _viewBox = 18;
  static const double _strokeInViewBox = 1.3;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / _viewBox;
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeInViewBox
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.scale(scale);
    final Path path = pointsLeft
        ? (Path()
            ..moveTo(11, 4)
            ..lineTo(6, 9)
            ..lineTo(11, 14))
        : (Path()
            ..moveTo(7, 4)
            ..lineTo(12, 9)
            ..lineTo(7, 14));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ChevronPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.pointsLeft != pointsLeft;
}
