import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions.dart';
import '../../../core/theme/chit_motion.dart';

/// The frame both tabs sit inside: the masthead above, the tab bar below.
///
/// Neither moves when the tab changes. The masthead is app-level chrome rather
/// than part of Today, which is how the prototype has it and what keeps the
/// wordmark from sliding about as somebody switches back and forth.
///
/// **There is no settings control.** The prototype draws a gear beside the
/// wordmark and gives it nothing to do; v1 has no settings screen anywhere in
/// BEHAVIOUR.md §3 or §4, and §6.4 does not allow a control that does nothing.
/// It arrives when there is something behind it.
class ShellScreen extends StatelessWidget {
  /// The shell go_router hands in, holding both branches and the current one.
  const ShellScreen({required this.navigationShell, super.key});

  /// Both tab branches, and which is showing.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const _Masthead(),
            Expanded(child: navigationShell),
            _TabBar(navigationShell: navigationShell),
          ],
        ),
      ),
    );
  }
}

/// "chit चित्त", in the page gutter, above both tabs.
class _Masthead extends StatelessWidget {
  const _Masthead();

  @override
  Widget build(BuildContext context) {
    final space = context.space;
    return Padding(
      // The prototype fixes this row at 42px. Here the height comes from the
      // wordmark plus a step of the scale, which lands within a pixel and a
      // half of it without inventing a dimension — DESIGN-SYSTEM.md §6.3.
      padding: EdgeInsets.symmetric(
        horizontal: space.gutter,
        vertical: space.s3,
      ),
      child: const Align(alignment: Alignment.centerLeft, child: _Wordmark()),
    );
  }
}

/// "chit" in Newsreader, चित्त in Noto Serif Devanagari.
///
/// Baseline-aligned. The two are one mark — the Sanskrit is not a subtitle —
/// so they share a baseline rather than a centre line.
///
/// The gap is `s2`. The prototype sets 7px; every gap in this app comes off
/// the 4px scale (DESIGN-SYSTEM.md §6.3), and a 1px departure on a
/// baseline-aligned pair is not a departure anybody can see.
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    return Semantics(
      header: true,
      label: 'chit',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Text('chit', style: type.wordmark),
          SizedBox(width: context.space.s2),
          Text('चित्त', style: type.devanagariMark),
        ],
      ),
    );
  }
}

/// The two tabs. DESIGN-SYSTEM.md §6.2 sets them in the serif, because they
/// are words rather than labels.
class _TabBar extends StatelessWidget {
  const _TabBar({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.paper,
        border: Border(top: BorderSide(color: colors.hair)),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: space.s3, bottom: space.s2),
        child: Row(
          children: <Widget>[
            for (final (int index, String label) in <(int, String)>[
              (0, 'today'),
              (1, 'calendar'),
            ])
              Expanded(
                child: _Tab(
                  label: label,
                  selected: navigationShell.currentIndex == index,
                  onTap: () => _goToBranch(index),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Tapping the tab you are already on returns that branch to its root.
  /// That is go_router's `initialLocation` flag and it is what a person
  /// expects from a tab bar.
  void _goToBranch(int index) => navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final motion = context.motion;

    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        // The prototype's tab measures 43.5px, half a pixel under the floor
        // §6.4 sets with no exceptions. Sizing it to the target rather than to
        // its contents is the whole fix, and it costs half a pixel of bar.
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: space.minTouchTarget),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // The pip is ink, not the accent: a tab you are already looking
              // at is not a thing that is happening (ADR-022).
              AnimatedContainer(
                duration: motion.fade(ChitPace.routine),
                curve: motion.curve,
                width: space.s1,
                height: space.s1,
                decoration: BoxDecoration(
                  color: selected ? colors.ink : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(height: space.s2),
              AnimatedDefaultTextStyle(
                duration: motion.fade(ChitPace.routine),
                curve: motion.curve,
                style: context.type.tabLabel.copyWith(
                  color: selected ? colors.ink : colors.inkFaint,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Both branches, stacked, with the one you are not looking at faded out.
///
/// ADR-011 asks that returning to a tab cost a fade and **not a rebuild**:
/// Today is opened many times a day, and re-running its entrance would turn
/// that into waiting. Keeping both branches in the tree is what preserves each
/// tab's scroll position and navigation stack; the opacity is what makes the
/// change legible.
///
/// This is why the route is a plain [StatefulShellRoute] with a container
/// builder rather than `StatefulShellRoute.indexedStack` — an `IndexedStack`
/// swaps instantly, and there is nowhere in it to put 220ms.
class BranchFade extends StatelessWidget {
  /// Stacks [children], showing the branch [navigationShell] currently holds.
  const BranchFade({
    required this.navigationShell,
    required this.children,
    super.key,
  });

  /// Which branch is current.
  final StatefulNavigationShell navigationShell;

  /// One navigator per branch, in branch order.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final motion = context.motion;

    return Stack(
      children: <Widget>[
        for (final (int index, Widget branch) in children.indexed)
          AnimatedOpacity(
            opacity: index == navigationShell.currentIndex ? 1 : 0,
            duration: motion.fade(ChitPace.routine),
            curve: motion.curve,
            // A branch that is invisible must also be untouchable, and it
            // must be out of the semantics tree — a screen reader on Today
            // should not find the calendar underneath it.
            child: ExcludeSemantics(
              excluding: index != navigationShell.currentIndex,
              child: IgnorePointer(
                ignoring: index != navigationShell.currentIndex,
                child: branch,
              ),
            ),
          ),
      ],
    );
  }
}
