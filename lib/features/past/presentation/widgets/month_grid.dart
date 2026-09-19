import 'package:flutter/material.dart';

import '../../../../core/extensions.dart';
import '../../../../core/haptics.dart';
import '../../../../core/theme/chit_colors.dart';
import '../../../../core/theme/chit_motion.dart';
import '../../application/month_provider.dart';

final class MonthGrid extends StatelessWidget {
  const MonthGrid({
    required this.shape,
    required this.selectedDay,
    required this.onTapDay,
    super.key,
  });

  final MonthShape shape;

  final int? selectedDay;

  final ValueChanged<int> onTapDay;

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
                      style: context.type.pastWeekday,
                    ),
                  ),
              ],
            ),
          ),
        ),

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
                        onTap: () {
                          ChitHaptics.selected();
                          onTapDay(shape.localDayOf(day));
                        },
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

final class DayTile extends StatelessWidget {
  const DayTile({
    required this.day,
    required this.count,
    required this.isToday,
    required this.selected,
    required this.semanticsDate,
    required this.onTap,
    super.key,
  });

  final int day;

  final int count;

  final bool isToday;

  final bool selected;

  final String semanticsDate;

  final VoidCallback onTap;

  static const double todayRingGap = 2;

  static const double ringWidth = 1;

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

    final Widget? numeral = written || isToday
        ? Center(
            child: Text(
              '$day',
              style: isToday && !written
                  ? type.pastDay.copyWith(color: colors.inkFaint)
                  : type.pastDay,
            ),
          )
        : null;

    final Color? frame = selected
        ? colors.ink
        : isToday
        ? colors.seal
        : null;

    final Widget face = isToday
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
