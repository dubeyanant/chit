import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/extensions.dart';
import '../../../domain/models/chit.dart';
import '../../../shared/widgets/day_thread.dart';
import '../../../shared/widgets/heading_row.dart';
import '../../../shared/widgets/staggered_entrance.dart';
import '../../composer/presentation/open_chit.dart';
import '../application/today_controller.dart';
import 'widgets/timeline.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final space = context.space;

    final AsyncValue<List<Chit>> chits = ref.watch(todayChitsProvider);

    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            space.gutter,
            space.s3,
            space.gutter,
            space.s8,
          ),
          sliver: SliverToBoxAdapter(
            child: StaggeredEntrance(
              children: <Widget>[
                const _DateLine(),

                Unstaggered(
                  child: Padding(
                    padding: EdgeInsets.only(top: space.s5),
                    child: const Timeline(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: space.s5),
                  child: const OpenChit(),
                ),

                ...switch (chits) {
                  AsyncData<List<Chit>>(:final List<Chit> value) => <Widget>[
                    _EarlierHeading(count: value.length),
                    if (value.isEmpty) const _EmptyNote(key: ValueKey('none')),

                    DayThread(key: const ValueKey('thread'), chits: value),
                  ],
                  _ => const <Widget>[],
                },
                const _ClosingMark(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DateLine extends ConsumerWidget {
  const _DateLine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime today = ref.watch(todayProvider);
    final type = context.type;

    return HeadingRow(
      child: Semantics(
        header: true,
        child: Text.rich(
          TextSpan(
            children: <InlineSpan>[
              TextSpan(
                text: '${DateFormat('EEEE').format(today)} ',
                style: type.weekday,
              ),
              TextSpan(text: DateFormat('d MMMM').format(today)),
            ],
          ),
          style: type.date,
        ),
      ),
    );
  }
}

class _EarlierHeading extends StatelessWidget {
  const _EarlierHeading({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final space = context.space;
    final type = context.type;

    return Padding(
      padding: EdgeInsets.only(top: space.s6, bottom: space.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text('earlier', style: type.sectionLabel),
          SizedBox(width: space.s3),
          Expanded(
            child: SizedBox(
              height: 1,
              child: ColoredBox(color: context.colors.hair),
            ),
          ),
          if (count > 0) ...<Widget>[
            SizedBox(width: space.s3),
            Text(
              count == 1 ? '1 chit' : '$count chits',
              style: type.sectionCount,
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyNote extends StatelessWidget {
  const _EmptyNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: context.space.s4),
      child: Text('Nothing written yet today.', style: context.type.emptyNote),
    );
  }
}

class _ClosingMark extends StatelessWidget {
  const _ClosingMark();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: context.space.s7),
      child: ExcludeSemantics(
        child: Center(child: Text('चित्त', style: context.type.closingMark)),
      ),
    );
  }
}
