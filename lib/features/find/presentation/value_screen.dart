import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions.dart';
import '../../../domain/find/find_axis.dart';
import '../../../shared/day_group.dart';
import '../../../shared/widgets/day_group_view.dart';
import '../../today/application/today_controller.dart';
import '../application/find_providers.dart';

/// Every chit carrying one value, read the way every other day is read.
class ValueScreen extends ConsumerWidget {
  const ValueScreen({required this.axis, required this.slug, super.key});

  final FindAxis axis;

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final space = context.space;
    final int today = ref.watch(todayLocalDayProvider);
    final List<DayGroup>? days = ref.watch(chitsOfValueProvider(axis, slug));

    if (days == null) return const SizedBox.shrink();

    final String word = axis == FindAxis.topics ? '#$slug' : slug;

    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: EdgeInsets.fromLTRB(space.gutter, space.s5, space.gutter, 0),
          sliver: SliverToBoxAdapter(
            child: Align(
              alignment: Alignment.centerRight,
              child: Semantics(
                header: true,
                child: Text(word, style: context.type.date),
              ),
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
            child: days.isEmpty
                ? Padding(
                    padding: EdgeInsets.only(top: space.s6),
                    child: Text(
                      'Nothing written like that.',
                      style: context.type.emptyNote,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
