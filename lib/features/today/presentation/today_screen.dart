import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/extensions.dart';
import '../../../domain/models/chit.dart';
import '../../../shared/widgets/day_thread.dart';
import '../../../shared/widgets/staggered_entrance.dart';
import '../../composer/presentation/open_chit.dart';
import '../application/today_controller.dart';
import 'widgets/timeline.dart';

/// The home screen: the date, the timeline, the open chit, the thread.
///
/// The whole of BEHAVIOUR.md §4.1's page, as of M2 group H.
///
/// The masthead is not here: it belongs to the shell, above both tabs, so that
/// it does not move when somebody switches between them.
///
/// **It is one `SliverToBoxAdapter` holding a `Column`, and not a list of
/// slivers.** The page is one flow — a header, a strip, a slip and a thread —
/// rather than a list of things, and building it as slivers bought nothing:
/// the open chit is always there and the thread is a day's worth of rows. It
/// also keeps semantics reachable, which a `SliverList` does not.
class TodayScreen extends ConsumerWidget {
  /// Creates Today.
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final space = context.space;

    // One stream, watched once. The heading's count and the thread below it
    // are two readings of the same list, so they cannot disagree about how
    // many chits the day holds.
    final AsyncValue<List<Chit>> chits = ref.watch(todayChitsProvider);

    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            space.gutter,
            space.s4,
            space.gutter,
            space.s8,
          ),
          sliver: SliverToBoxAdapter(
            // **The page arrives a block at a time on its first build**, and
            // then this is a `Column` (§6.3). Each child carries the gap above
            // it rather than sitting beside a `SizedBox`, because a spacer in
            // the list would take a turn in the stagger.
            child: StaggeredEntrance(
              children: <Widget>[
                const _DateLine(),
                // The timeline sits directly under the date, and its own line
                // is what divides the header from the content — which is why
                // neither the date above nor the slip below draws a rule.
                // v6 tightened both of these gaps from 32 to 24 (§6.3).
                //
                // **It arrives by scrolling to now and by nothing else**
                // (ADR-070): the strip is the one block the page entrance
                // draws straight through, because a widget cannot fade, rise
                // and scroll at once and still look like one thing.
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
                // The thread has nothing to say until the first frame the
                // database answers on, and that frame is the one after this.
                // Drawing "Nothing written yet today." while a day's chits are
                // in flight would be a wrong answer rather than a slow one —
                // ADR-007's rule about undrawn signals applied to a query.
                ...switch (chits) {
                  AsyncData<List<Chit>>(:final List<Chit> value) => <Widget>[
                    _EarlierHeading(count: value.length),
                    if (value.isEmpty)
                      const _EmptyNote()
                    else
                      DayThread(chits: value),
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

/// "Sunday 13 September" — one line, 26px.
///
/// DESIGN-SYSTEM.md §6.2: **the date is a label, not a masthead.** The weekday
/// is the same size and weight as the date beside it and differs only in being
/// italic and faint, so the two set as one phrase. *v5 stacked an italic
/// weekday over a 38px date*, which made what-day-it-is the largest thing on a
/// screen whose subject is the blank slip underneath.
class _DateLine extends ConsumerWidget {
  const _DateLine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // One read of the clock for the whole screen — `todayProvider`, so the
    // date and the thread below it cannot land on different days.
    final DateTime today = ref.watch(todayProvider);
    final type = context.type;

    return Semantics(
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
    );
  }
}

/// "earlier ─────────────── 2 chits".
///
/// The rule between the word and the count is what separates the open chit
/// from the day behind it; no other divider is needed, and none is drawn.
class _EarlierHeading extends StatelessWidget {
  const _EarlierHeading({required this.count});

  /// How many chits the day holds. **Nothing is shown when it is zero** —
  /// BEHAVIOUR.md §4.1 omits the count on an empty day rather than printing
  /// "0 chits", which would be the app counting for the user.
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

/// *"Nothing written yet today."* — BEHAVIOUR.md §4.1.
///
/// The whole of the empty state. No rail, no placeholder row, no illustration
/// and no invitation: an empty day looks empty, and the thing that invites is
/// the open chit above it.
class _EmptyNote extends StatelessWidget {
  const _EmptyNote();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: context.space.s4),
      child: Text('Nothing written yet today.', style: context.type.emptyNote),
    );
  }
}

/// चित्त, closing the day.
///
/// BEHAVIOUR.md §4.1: it appears here and beside the wordmark, and nowhere
/// else. *v5 repeated it at the foot of the calendar too*, which turned a
/// closing mark into a page decoration.
///
/// It is **decoration and carries no semantics**, the way the prototype marks
/// it `aria-hidden`: a screen reader announcing "चित्त" at the end of the day
/// is reading out a full stop.
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
