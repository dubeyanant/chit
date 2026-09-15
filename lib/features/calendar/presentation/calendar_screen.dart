import 'package:flutter/material.dart';

import '../../../core/extensions.dart';

/// The month grid, the month summary and the archive.
///
/// **Arrives in M4.** M2 gives the tab something to land on so that the shell
/// can be built and switched between; BUILD-PLAN.md M2 calls the Calendar tab
/// a placeholder and this is it.
///
/// The line below is scaffolding, not copy. It exists because a blank screen
/// and a broken screen look identical, and M4 deletes it along with this
/// comment.
class CalendarScreen extends StatelessWidget {
  /// Creates the calendar tab.
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final space = context.space;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: space.gutter),
      child: Center(
        child: Text(
          'The calendar arrives in M4.',
          style: context.type.monthSummary,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
