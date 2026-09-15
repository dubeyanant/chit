import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/calendar/presentation/calendar_screen.dart';
import '../features/shell/presentation/shell_screen.dart';
import '../features/today/presentation/today_screen.dart';

part 'router.g.dart';

/// The app's destinations, and the one list that says how many there are.
///
/// The tab bar reads this rather than carrying its own copy: a route and its
/// tab are one piece of knowledge, and two lists of two things is how a third
/// destination gets added to one of them and not the other.
///
/// The route's **name** is the enum constant's own `name`, so there is nothing
/// to keep in sync. [label] is separate even though the two happen to match
/// today — one is an identifier and the other is copy on a screen, and they
/// change for different reasons.
enum ChitRoute {
  /// Today, and the app's start.
  today(path: '/', label: 'today'),

  /// The calendar tab.
  calendar(path: '/calendar', label: 'calendar');

  const ChitRoute({required this.path, required this.label});

  /// Where it lives.
  final String path;

  /// What its tab says.
  final String label;
}

/// The router: a shell holding two tabs that keep their own state (ADR-011).
///
/// **Held by Riverpod rather than by a widget.** ADR-001 makes Riverpod the
/// only state mechanism in the app, and a `GoRouter` is state — it owns the
/// navigation stack of every branch. Parking it in a `StatefulWidget` would
/// put the one thing that must outlive a rebuild in the one place that does
/// not, and would keep it out of reach of anything that later needs to
/// redirect on what a provider knows.
///
/// `keepAlive` because it outlives every screen. Disposed with the container,
/// so a test gets a fresh router per `ProviderScope` and two tests cannot leak
/// navigation state into each other.
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final GoRouter router = GoRouter(
    initialLocation: ChitRoute.today.path,
    routes: <RouteBase>[
      StatefulShellRoute(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) => ShellScreen(navigationShell: navigationShell),
        // go_router has no cross-fading container of its own, so this is the
        // extension point it offers for one. See [BranchFade].
        navigatorContainerBuilder: (
          BuildContext context,
          StatefulNavigationShell navigationShell,
          List<Widget> children,
        ) => BranchFade(navigationShell: navigationShell, children: children),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: ChitRoute.today.path,
                name: ChitRoute.today.name,
                builder: (BuildContext context, GoRouterState state) =>
                    const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: ChitRoute.calendar.path,
                name: ChitRoute.calendar.name,
                builder: (BuildContext context, GoRouterState state) =>
                    const CalendarScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
}
