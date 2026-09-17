import 'package:flutter/material.dart';

import '../../../../core/extensions.dart';
import '../../application/month_provider.dart';

/// *September 2026*, and the chevrons — the head of the calendar.
///
/// The name is set at the date line's size and weight, because DESIGN-SYSTEM.md
/// §6.2 makes the two the same kind of thing: a label for what is below, not a
/// masthead. The year sits beside it in `--ink-faint`, the way the weekday
/// sits beside the date.
///
/// **A chevron is drawn only when it has somewhere to go** — ADR-047. Each
/// one lands on the nearest month with something written in it, so a month
/// nobody can write in is never shown; with nothing earlier, and at the
/// current month, that side is simply empty. *v6 draws both and disables
/// one*, and so did this bar for one commit, until the first device pass saw
/// an empty August with a dead chevron beside it. A control offering nothing
/// is what §6.4 refuses, and a faint one is that with a claim about
/// legibility on top.
final class MonthBar extends StatelessWidget {
  /// The bar for [month].
  const MonthBar({
    required this.month,
    required this.onPrevious,
    required this.onNext,
    super.key,
  });

  /// Which month is showing.
  final YearMonth month;

  /// To the nearest earlier written month. Null draws no chevron.
  final VoidCallback? onPrevious;

  /// To the nearest later written month, or the current one. Null draws no
  /// chevron.
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    final colors = context.colors;

    return Row(
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
        if (onPrevious case final VoidCallback go)
          _Chevron(pointsLeft: true, label: 'Previous month', onTap: go),
        if (onNext case final VoidCallback go)
          _Chevron(pointsLeft: false, label: 'Next month', onTap: go),
      ],
    );
  }
}

/// One chevron at the 44px floor. v6's is a 36px button; §6.4 makes no
/// exceptions, and sizing it to the target costs eight pixels of bar.
class _Chevron extends StatelessWidget {
  const _Chevron({
    required this.pointsLeft,
    required this.label,
    required this.onTap,
  });

  final bool pointsLeft;
  final String label;
  final VoidCallback onTap;

  /// v6 draws the glyph at 17px inside its 18-unit box.
  static const double _glyphSize = 17;

  @override
  Widget build(BuildContext context) {
    final space = context.space;

    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox.square(
          dimension: space.minTouchTarget,
          child: Center(
            child: CustomPaint(
              size: const Size.square(_glyphSize),
              painter: _ChevronPainter(
                color: context.colors.inkFaint,
                pointsLeft: pointsLeft,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// v6's chevron: `M11 4 6 9l5 5` in an 18-unit box at a 1.3 stroke, round
/// caps and joins.
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
