import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/calendar/presentation/calendar_screen.dart';
import '../features/shell/presentation/shell_screen.dart';
import '../features/today/presentation/today_screen.dart';

/// Where the two tabs live. Spelled once so nothing navigates by string.
abstract final class ChitRoutes {
  const ChitRoutes._();

  /// Today, and the app's start.
  static const String today = '/';

  /// The calendar tab.
  static const String calendar = '/calendar';
}

/// The router: a shell holding two tabs that keep their own state (ADR-011).
///
/// Built per app instance rather than held as a top-level `final`, so that a
/// test gets a fresh one and two tests cannot leak navigation state into each
/// other.
GoRouter buildChitRouter() {
  return GoRouter(
    initialLocation: ChitRoutes.today,
    routes: <RouteBase>[
      StatefulShellRoute(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) => ShellScreen(navigationShell: navigationShell),
        navigatorContainerBuilder: (
          BuildContext context,
          StatefulNavigationShell navigationShell,
          List<Widget> children,
        ) => BranchFade(navigationShell: navigationShell, children: children),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: ChitRoutes.today,
                builder: (BuildContext context, GoRouterState state) =>
                    const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: ChitRoutes.calendar,
                builder: (BuildContext context, GoRouterState state) =>
                    const CalendarScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
