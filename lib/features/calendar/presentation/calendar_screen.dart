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

/// The month grid, the month summary and the archive — BEHAVIOUR.md §4.2.
///
/// One flow, like Today: the month bar, the grid, the summary, then every day
/// with something in it, newest first. Tapping a tile narrows the archive to
/// that day; the same tile again, or **Show every day**, widens it back.
///
/// **Nothing is drawn until the queries first answer, and after that the last
/// answer holds while the next is in flight** (ADR-049). A grid with no
/// numbers and *Nothing written this month* under it, shown while the real
/// month is in flight, is a wrong answer rather than a slow one — the same
/// reading of ADR-007 the thread takes. A blank where the grid was a frame
/// ago is a flicker, which the handset saw on every change of month.
///
/// There is no closing mark here. BEHAVIOUR.md §4.1 puts चित्त at the foot of
/// Today alone; *v5 repeated it at the foot of the calendar too*, which turned
/// a full stop into a page decoration.
class CalendarScreen extends ConsumerWidget {
  /// Creates the calendar tab.
  const CalendarScreen({super.key});

  /// How close to the end of the archive the reader gets before the next
  /// page is asked for. Roughly a screen, so the join is never seen.
  static const double _pageAhead = 600;

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
              space.s8,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // **Two entrances, not one** (§6.3). The month arrives once
                  // and stays; the archive below it arrives again whenever a
                  // tapped date rebuilds it, which is what explains why the
                  // list changed. One entrance over both would re-run the
                  // grid under the finger that just tapped it.
                  if (shape != null)
                    StaggeredEntrance(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        MonthBar(
                          month: shape.month,
                          // A chevron exists only where there is a month to go
                          // to — ADR-047.
                          onPrevious: neighbours.previous == null
                              ? null
                              : ref
                                    .read(visibleMonthProvider.notifier)
                                    .previous,
                          onNext: neighbours.next == null
                              ? null
                              : ref.read(visibleMonthProvider.notifier).next,
                        ),
                        // v6: the bar's padding is s5 above and s4 below.
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
                  if (days != null)
                    StaggeredEntrance(
                      // The filter is the key, so selecting a day and clearing
                      // it both replay; paging in more days does not.
                      key: ValueKey<int?>(selected),
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        for (final ArchiveDay day in days)
                          Padding(
                            padding: EdgeInsets.only(top: space.s6),
                            child: ArchiveDayGroup(day: day, today: today),
                          ),
                        // Only a filtered day can be empty — a tile with
                        // nothing in it takes no tap — but a chit can go
                        // between the tap and the query one day, and the line
                        // is v6's.
                        if (days.isEmpty && selected != null)
                          const _EmptyNote(),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Asks for another page when the reader nears the end of a full one.
  ///
  /// The only state paging needs is a count, and it lives in
  /// `archivePagesProvider`; this is the one place that decides *when*. It
  /// asks nothing while a day is selected — that archive is one day and is
  /// not paged — and nothing while the last page came back short, because a
  /// short page is the end.
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

/// *22 chits over eleven days*, under a hairline.
///
/// **No legend.** v6 removed it (BEHAVIOUR.md §4.2): four swatches explaining
/// that more ink means more writing is a caption on something nobody
/// misreads, and this line says the same thing in words a person would use.
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

/// *"Nothing written that day."* — the archive's line, in the voice of
/// Today's *"Nothing written yet today."*
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
