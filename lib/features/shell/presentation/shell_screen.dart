import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/extensions.dart';
import '../../../core/theme/chit_motion.dart';
import '../../../shared/widgets/focus_ring.dart';
import '../../../shared/widgets/wordmark.dart';

class ShellScreen extends StatelessWidget {
  const ShellScreen({required this.navigationShell, super.key});

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

class _Masthead extends StatelessWidget {
  const _Masthead();

  @override
  Widget build(BuildContext context) {
    final space = context.space;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: space.gutter,
        vertical: space.s3,
      ),
      child: const Align(alignment: Alignment.centerLeft, child: Wordmark()),
    );
  }
}

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
            for (final ChitRoute route in ChitRoute.values)
              Expanded(
                child: _Tab(
                  label: route.label,
                  selected: navigationShell.currentIndex == route.index,
                  onTap: () => _goToBranch(route.index),
                ),
              ),
          ],
        ),
      ),
    );
  }

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

      child: FocusRing(
        onActivate: onTap,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,

          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: space.minTouchTarget),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
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
      ),
    );
  }
}

class BranchFade extends StatelessWidget {
  const BranchFade({
    required this.navigationShell,
    required this.children,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

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
