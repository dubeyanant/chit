import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions.dart';
import '../../../domain/ambient/ambient_words.dart';
import '../../../domain/models/chit_filter.dart';
import '../../../domain/models/motion_state.dart';
import '../../../domain/models/weather_condition.dart';
import '../../../domain/tags/chit_tags.dart';
import '../../../shared/day_group.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/day_group_view.dart';
import '../../../shared/widgets/heading_row.dart';
import '../../today/application/today_controller.dart';
import '../application/find_providers.dart';
import 'widgets/filter_row.dart';

/// The third tab — four rows of words, and the chits they leave behind.
class FindScreen extends ConsumerWidget {
  const FindScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final space = context.space;

    final FindFacets facets = ref.watch(facetsProvider);
    final ChitFilter filter = ref.watch(filterProvider);
    final List<DayGroup> days = ref.watch(foundProvider);
    final int today = ref.watch(todayLocalDayProvider);

    final int count = <int>[
      for (final DayGroup day in days) day.chits.length,
    ].fold(0, (int a, int b) => a + b);

    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: EdgeInsets.fromLTRB(space.gutter, space.s5, space.gutter, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // The same minTouchTarget row the other two tabs open with, so
                // the heading does not move when a tab changes — §6.3.
                HeadingRow(
                  child: _Summary(
                    count: count,
                    narrowed: !filter.isEmpty,
                    anything: !facets.isEmpty,
                  ),
                ),
                SizedBox(height: space.s4),
                if (!facets.isEmpty)
                  _Filters(facets: facets, filter: filter),
              ],
            ),
          ),
        ),

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
          padding: EdgeInsets.fromLTRB(space.gutter, 0, space.gutter, space.s8),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: filter.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: EdgeInsets.only(top: space.s6),
                      child: QuietButton(
                        label: 'Show everything',
                        onPressed: ref.read(filterProvider.notifier).clear,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

/// What is on the screen, said the way the month summary says it (§4.2).
class _Summary extends StatelessWidget {
  const _Summary({
    required this.count,
    required this.narrowed,
    required this.anything,
  });

  final int count;

  final bool narrowed;

  final bool anything;

  @override
  Widget build(BuildContext context) {
    final type = context.type;

    if (!anything) {
      return Text('Nothing written yet.', style: type.monthSummary);
    }

    if (!narrowed) {
      return Text('Everything written.', style: type.monthSummary);
    }

    if (count == 0) {
      return Text('Nothing written like that.', style: type.monthSummary);
    }

    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(
            text: count == 1 ? '1 chit' : '$count chits',
            style: type.monthSummaryStrong,
          ),
          const TextSpan(text: ' like that'),
        ],
      ),
      style: type.monthSummary,
    );
  }
}

class _Filters extends ConsumerWidget {
  const _Filters({required this.facets, required this.filter});

  final FindFacets facets;

  final ChitFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Filter notifier = ref.read(filterProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        FilterRow(
          label: 'weather',
          words: <Widget>[
            for (final WeatherCondition it in facets.weather)
              FilterWord(
                key: ValueKey<String>('weather:${it.name}'),
                word: it.word,
                chosen: filter.weather.contains(it),
                onTap: () => notifier.toggleWeather(it),
              ),
          ],
        ),

        FilterRow(
          label: 'motion',
          words: <Widget>[
            for (final MotionState it in facets.motion)
              FilterWord(
                key: ValueKey<String>('motion:${it.name}'),
                word: it.word,
                chosen: filter.motion.contains(it),
                onTap: () => notifier.toggleMotion(it),
              ),
          ],
        ),

        FilterRow(
          label: 'people',
          words: <Widget>[
            for (final TagSpan it in facets.people)
              FilterWord(
                key: ValueKey<String>(it.key),
                word: it.label,
                chosen: filter.people.contains(it.key),
                onTap: () => notifier.togglePerson(it.key),
              ),
          ],
        ),

        FilterRow(
          label: 'topics',
          words: <Widget>[
            for (final TagSpan it in facets.topics)
              FilterWord(
                key: ValueKey<String>(it.key),
                word: '#${it.label}',
                chosen: filter.topics.contains(it.key),
                onTap: () => notifier.toggleTopic(it.key),
              ),
          ],
        ),
      ],
    );
  }
}
