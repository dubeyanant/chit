import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions.dart';
import '../../../shared/day_group.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/day_group_view.dart';
import '../../../shared/widgets/staggered_entrance.dart';
import '../../today/application/today_controller.dart';
import '../application/archive_provider.dart';
import '../application/month_provider.dart';
import 'widgets/month_bar.dart';
import 'widgets/month_grid.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final space = context.space;

    final MonthShape? shape = ref.watch(drawnMonthProvider);
    final List<DayGroup>? days = ref.watch(archiveDaysProvider);
    final int? selected = ref.watch(selectedDayProvider);
    final int today = ref.watch(todayLocalDayProvider);
    final MonthNeighbours neighbours = ref.watch(monthNeighboursProvider);

    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: EdgeInsets.fromLTRB(space.gutter, space.s3, space.gutter, 0),
          sliver: SliverToBoxAdapter(
            child: shape == null
                ? const SizedBox.shrink()
                : StaggeredEntrance(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      MonthBar(
                        month: shape.month,

                        onPrevious: neighbours.previous == null
                            ? null
                            : ref.read(visibleMonthProvider.notifier).previous,
                        onNext: neighbours.next == null
                            ? null
                            : ref.read(visibleMonthProvider.notifier).next,
                      ),

                      Padding(
                        padding: EdgeInsets.only(top: space.s4),
                        child: MonthGrid(
                          shape: shape,
                          selectedDay: selected,
                          onTapDay: ref
                              .read(selectedDayProvider.notifier)
                              .toggle,
                        ),
                      ),
                      _MonthSummary(shape: shape),
                    ],
                  ),
          ),
        ),

        if (days != null) ...<Widget>[
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: space.gutter),
            sliver: SliverList.builder(
              itemCount: days.length,
              itemBuilder: (BuildContext context, int index) {
                final DayGroup day = days[index];
                return Padding(
                  key: ValueKey<int>(day.localDay),
                  padding: EdgeInsets.only(top: space.s6),
                  child: DayGroupView(day: day, today: today),
                );
              },
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              space.gutter,
              0,
              space.gutter,
              space.s8,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (days.isEmpty && selected != null) const _EmptyNote(),
                  if (selected != null)
                    Padding(
                      padding: EdgeInsets.only(top: space.s4),
                      child: Center(
                        child: QuietButton(
                          label: 'Show every day',
                          onPressed: ref
                              .read(selectedDayProvider.notifier)
                              .clear,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _MonthSummary extends StatelessWidget {
  const _MonthSummary({required this.shape});

  final MonthShape shape;

  @override
  Widget build(BuildContext context) {
    final space = context.space;
    final type = context.type;
    final (String strong, String rest) = shape.summary;

    return Padding(
      padding: EdgeInsets.only(top: space.s5),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.colors.hair)),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: space.s3),
          child: Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(text: strong, style: type.monthSummaryStrong),
                TextSpan(text: rest),
              ],
            ),
            style: type.monthSummary,
          ),
        ),
      ),
    );
  }
}

class _EmptyNote extends StatelessWidget {
  const _EmptyNote();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: context.space.s6),
      child: Text('Nothing written that day.', style: context.type.emptyNote),
    );
  }
}
