import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/staggered_entrance.dart';
import '../../today/application/today_controller.dart';
import '../application/archive_provider.dart';
import '../application/month_provider.dart';
import 'widgets/archive_day.dart';
import 'widgets/month_bar.dart';
import 'widgets/month_grid.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  static const double _pageAhead = 600;

  static const int entranceDays = StaggeredEntrance.cap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final space = context.space;

    final MonthShape? shape = ref.watch(drawnMonthProvider);
    final List<ArchiveDay>? days = ref.watch(archiveDaysProvider);
    final int? selected = ref.watch(selectedDayProvider);
    final int today = ref.watch(todayLocalDayProvider);
    final MonthNeighbours neighbours = ref.watch(monthNeighboursProvider);

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        _maybePage(ref, notification);
        return false;
      },
      child: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              space.gutter,
              space.s5,
              space.gutter,
              0,
            ),
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
                              : ref
                                    .read(visibleMonthProvider.notifier)
                                    .previous,
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
              sliver: SliverToBoxAdapter(
                child: StaggeredEntrance(
                  key: ValueKey<int?>(selected),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (final ArchiveDay day in days.take(
                      CalendarScreen.entranceDays,
                    ))
                      Padding(
                        padding: EdgeInsets.only(top: space.s6),
                        child: ArchiveDayGroup(day: day, today: today),
                      ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: space.gutter),
              sliver: SliverList.builder(
                itemCount: days.length <= CalendarScreen.entranceDays
                    ? 0
                    : days.length - CalendarScreen.entranceDays,
                itemBuilder: (BuildContext context, int index) {
                  final ArchiveDay day =
                      days[index + CalendarScreen.entranceDays];
                  return Padding(
                    key: ValueKey<int>(day.localDay),
                    padding: EdgeInsets.only(top: space.s6),
                    child: ArchiveDayGroup(day: day, today: today),
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
      ),
    );
  }

  void _maybePage(WidgetRef ref, ScrollNotification notification) {
    if (notification.metrics.extentAfter > _pageAhead) return;
    if (ref.read(selectedDayProvider) != null) return;

    final List<ArchiveDay>? days = ref.read(archiveDaysProvider);
    if (days == null) return;

    final int loaded = days.fold(
      0,
      (int n, ArchiveDay day) => n + day.chits.length,
    );
    if (loaded < ref.read(archiveLimitProvider)) return;

    ref.read(archivePagesProvider.notifier).more();
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
