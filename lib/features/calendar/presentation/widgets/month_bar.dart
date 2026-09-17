import 'package:flutter/material.dart';

import '../../../../core/extensions.dart';
import '../../application/month_provider.dart';

/// *September 2026*, and the two chevrons — the head of the calendar.
///
/// The name is set at the date line's size and weight, because DESIGN-SYSTEM.md
/// §6.2 makes the two the same kind of thing: a label for what is below, not a
/// masthead. The year sits beside it in `--ink-faint`, the way the weekday
/// sits beside the date.
///
/// **The next chevron is disabled at the current month** rather than hidden.
/// A control that vanishes shifts the one beside it, and v6 draws both and
/// disables one for the same reason. It is drawn at a third of its strength
/// and carries no tap; §6.4's contrast floor does not reach a control that is
/// not offering anything.
final class MonthBar extends StatelessWidget {
  /// The bar for [month].
  const MonthBar({
    required this.month,
    required this.canGoForward,
    required this.onPrevious,
    required this.onNext,
    super.key,
  });

  /// Which month is showing.
  final YearMonth month;

  /// False at the current month, where there is nothing further to show.
  final bool canGoForward;

  /// One month back.
  final VoidCallback onPrevious;

  /// One month forward.
  final VoidCallback onNext;

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
        _Chevron(
          direction: TextDirection.rtl,
          label: 'Previous month',
          onTap: onPrevious,
        ),
        _Chevron(
          direction: TextDirection.ltr,
          label: 'Next month',
          onTap: canGoForward ? onNext : null,
        ),
      ],
    );
  }
}

/// One chevron at the 44px floor. v6's is a 36px button; §6.4 makes no
/// exceptions, and sizing it to the target costs eight pixels of bar.
class _Chevron extends StatelessWidget {
  const _Chevron({
    required this.direction,
    required this.label,
    required this.onTap,
  });

  /// [TextDirection.rtl] points left, [TextDirection.ltr] right.
  final TextDirection direction;
  final String label;

  /// Null disables it.
  final VoidCallback? onTap;

  /// v6 draws the glyph at 17px inside its 18-unit box.
  static const double _glyphSize = 17;

  /// How faint a disabled chevron is drawn — v6's `opacity: .3`.
  static const double _disabledStrength = 0.3;

  @override
  Widget build(BuildContext context) {
    final space = context.space;
    final colors = context.colors;
    final bool enabled = onTap != null;

    return Semantics(
      button: true,
      enabled: enabled,
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
                color: enabled
                    ? colors.inkFaint
                    : colors.inkFaint.withValues(alpha: _disabledStrength),
                pointsLeft: direction == TextDirection.rtl,
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
