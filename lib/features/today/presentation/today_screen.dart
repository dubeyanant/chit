import 'package:flutter/material.dart';

import '../../../core/extensions.dart';

/// The home screen: the date, the timeline, the open chit, the thread.
///
/// **Group B built the page and nothing on it.** The date line and the thread
/// arrive with group G, the open chit with E, and the timeline with H —
/// TASKS.md. What is here is the scroll view they all go into, so that each of
/// those groups adds a widget rather than also rearranging the page.
///
/// The masthead is not here: it belongs to the shell, above both tabs, so that
/// it does not move when somebody switches between them.
class TodayScreen extends StatelessWidget {
  /// Creates Today.
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final space = context.space;

    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            space.gutter,
            space.s4,
            space.gutter,
            space.s8,
          ),
          sliver: const SliverToBoxAdapter(child: SizedBox.shrink()),
        ),
      ],
    );
  }
}
