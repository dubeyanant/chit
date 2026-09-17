import 'package:flutter/material.dart';

import '../../../../core/extensions.dart';
import '../../../../core/theme/chit_colors.dart';
import '../../../../core/theme/chit_motion.dart';
import '../../application/month_provider.dart';

/// The weekday row and the month's tiles — BEHAVIOUR.md §4.2.
///
/// A date carries a number only when something was written that day, and the
/// tile's density scales with how much: four steps of **ink**, so the month
/// reads as the shape of what was written rather than as a grid to be scanned.
/// Today always keeps its number, whatever it holds, and is ringed in
/// `--seal` — the one thing on this screen that is *happening* (ADR-022).
///
/// **Seven columns, no spacing between them, and the gap lives inside each
/// cell.** The whole cell is the tap target, so on a handset narrow enough
/// that seven 44px targets and six gaps cannot both fit in the gutter, the
/// target still clears §6.4's floor — the visual tile is what shrinks, not
/// what a finger can hit. The gap between neighbours is `s1` (v6 draws 5px;
/// DESIGN-SYSTEM.md §6.3 keeps every gap on the scale).
///
/// Built as rows rather than as a `GridView`: a month is at most six rows of
/// seven, and a scrolling widget inside a scrolling page is a thing to explain.
final class MonthGrid extends StatelessWidget {
  /// The grid for [shape].
  const MonthGrid({
    required this.shape,
    required this.selectedDay,
    required this.onTapDay,
    super.key,
  });

  /// The month as the arithmetic has it.
  final MonthShape shape;

  /// The selected `yyyymmdd`, or null.
  final int? selectedDay;

  /// A tap on a day that holds something, as `yyyymmdd`.
  final ValueChanged<int> onTapDay;

  /// Sunday first, single letters, as v6 has them. Decoration for a sighted
  /// reader; a screen reader gets the full date on each tile instead.
  static const List<String> _weekdays = <String>[
    'S',
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
  ];

  @override
  Widget build(BuildContext context) {
    final space = context.space;

    return Column(
      children: <Widget>[
        ExcludeSemantics(
          child: Padding(
            padding: EdgeInsets.only(bottom: space.s2),
            child: Row(
              children: <Widget>[
                for (final String letter in _weekdays)
                  Expanded(
                    child: Text(
                      letter,
                      textAlign: TextAlign.center,
                      style: context.type.calendarWeekday,
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Only the weeks between the first and the last with something in
        // them — the arithmetic decides which (ADR-047), and a cell is either
        // a day or nothing.
        for (final List<int?> row in shape.rows)
          Row(
            children: <Widget>[
              for (final int? cell in row)
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: switch (cell) {
                      null => const SizedBox.shrink(),
                      final int day => DayTile(
                        day: day,
                        count: shape.countOf(day),
                        isToday: day == shape.todayDay,
                        selected: shape.localDayOf(day) == selectedDay,
                        semanticsDate: '$day ${shape.month.name}',
                        onTap: () => onTapDay(shape.localDayOf(day)),
                      ),
                    },
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

/// One day of the month.
///
/// A tile is **a field of ink**, which is why it takes `tileRadius` rather
/// than the paper radius everything else has (§6.3). Its wash is one of
/// [ChitColors.densitySteps] by count, and the numeral over it is `--ink` at
/// every step — 12.66:1 down to 5.99:1, so it never has to change colour to
/// stay legible.
///
/// **Today is ringed on paper — ADR-046.** The ring sits at the tile's edge
/// and the wash is inset from it by [todayRingGap], so both edges of the ring
/// meet `--paper` whatever density today carries. On the tile itself `--seal`
/// measured 2.61:1 against three chits and 1.88:1 against four, under §6.4's
/// 3:1 for a component; on paper it is 4.56:1 every day. The gap is what
/// makes today a different *shape* from every other day as well as a
/// different colour, which §6.4 asks for outright.
///
/// A selected tile is framed in `--ink` and lifted by six percent — a tile
/// being asked about is not a thing that is happening, so it is not the
/// accent. Under reduced motion it is framed and not lifted.
final class DayTile extends StatelessWidget {
  /// A tile for [day] of the month holding [count] chits.
  const DayTile({
    required this.day,
    required this.count,
    required this.isToday,
    required this.selected,
    required this.semanticsDate,
    required this.onTap,
    super.key,
  });

  /// The day of the month, one to thirty-one.
  final int day;

  /// How many chits the day holds. Zero draws no number and takes no tap.
  final int count;

  /// Whether this is today: always numbered, and ringed.
  final bool isToday;

  /// Whether the archive is filtered to this day.
  final bool selected;

  /// *17 September*, for the screen reader's label.
  final String semanticsDate;

  /// A tap, offered only when [count] is above zero.
  final VoidCallback onTap;

  /// **2px** of paper between today's ring and its wash — ADR-046.
  ///
  /// A property of this one component rather than a gap between two, so it
  /// is a dimension in §6.3's sense and sits off the scale by design. Wide
  /// enough to read as paper at arm's length; narrow enough that the ring
  /// still frames the tile rather than floating around it.
  static const double todayRingGap = 2;

  /// A hairline, like every border in the app.
  static const double ringWidth = 1;

  /// How much a selected tile lifts — v6's `scale(1.06)`.
  static const double selectedScale = 1.06;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final motion = context.motion;
    final type = context.type;

    final bool written = count > 0;
    final int step = MonthShape.densityStep(count);
    final Color? wash = written
        ? colors.inkWash(
            colors.paper,
            opacity: ChitColors.densitySteps[step - 1],
          )
        : null;

    // Today with nothing in it keeps its number, in the quieter ink: it is
    // there to be findable, not to claim something was written.
    final Widget? numeral = written || isToday
        ? Center(
            child: Text(
              '$day',
              style: isToday && !written
                  ? type.calendarDay.copyWith(color: colors.inkFaint)
                  : type.calendarDay,
            ),
          )
        : null;

    final Color? frame = selected
        ? colors.ink
        : isToday
        ? colors.seal
        : null;

    final Widget face = isToday
        // The ring, a strip of paper, then the wash — ADR-046.
        ? DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: frame!, width: ringWidth),
              borderRadius: BorderRadius.circular(space.tileRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(ringWidth + todayRingGap),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: wash,
                  borderRadius: BorderRadius.circular(space.radius),
                ),
                child: numeral,
              ),
            ),
          )
        : DecoratedBox(
            decoration: BoxDecoration(
              color: wash,
              border: frame == null
                  ? null
                  : Border.all(color: frame, width: ringWidth),
              borderRadius: BorderRadius.circular(space.tileRadius),
            ),
            child: numeral,
          );

    // The gap between neighbours is `s1`, half of it on each side of every
    // cell, so the cell — and the tap — is the full seventh of the row.
    final Widget tile = Padding(
      padding: EdgeInsets.all(space.s1 / 2),
      child: AnimatedScale(
        scale: selected && !motion.reduceMotion ? selectedScale : 1,
        duration: motion.travel(ChitPace.routine),
        curve: motion.curve,
        child: face,
      ),
    );

    if (!written) {
      // A day with nothing in it is not a control. Today's bare tile is
      // still announced, because the ring means something.
      return isToday
          ? Semantics(label: '$semanticsDate, today', child: tile)
          : ExcludeSemantics(child: tile);
    }

    return Semantics(
      button: true,
      selected: selected,
      label:
          '$semanticsDate${isToday ? ', today' : ''} — '
          '${count == 1 ? '1 chit' : '$count chits'}',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: tile,
      ),
    );
  }
}
