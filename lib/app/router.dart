import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/calendar/presentation/calendar_screen.dart';
import '../features/editor/presentation/editor_screen.dart';
import '../features/find/presentation/find_screen.dart';
import '../features/onboarding/application/first_run_controller.dart';
import '../features/onboarding/presentation/first_run_screen.dart';
import '../features/shell/presentation/shell_screen.dart';
import '../features/today/presentation/today_screen.dart';

part 'router.g.dart';

enum ChitRoute {
  today(path: '/', label: 'today'),

  calendar(path: '/calendar', label: 'calendar'),

  find(path: '/find', label: 'find');

  const ChitRoute({required this.path, required this.label});

  final String path;

  final String label;
}

const String firstRunPath = '/welcome';

const String editorRouteName = 'editor';

const String editorIdParameter = 'id';

const String editorPath = '/chit/:$editorIdParameter';

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final ValueNotifier<bool> firstRunOwed = ValueNotifier<bool>(
    ref.read(firstRunControllerProvider),
  );
  ref.listen(firstRunControllerProvider, (bool? _, bool owed) {
    firstRunOwed.value = owed;
  });
  ref.onDispose(firstRunOwed.dispose);

  final GoRouter router = GoRouter(
    initialLocation: ChitRoute.today.path,
    refreshListenable: firstRunOwed,

    redirect: (BuildContext context, GoRouterState state) {
      final bool owed = firstRunOwed.value;
      final bool atFirstRun = state.matchedLocation == firstRunPath;

      if (owed && !atFirstRun) return firstRunPath;
      if (!owed && atFirstRun) return ChitRoute.today.path;

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: firstRunPath,
        builder: (BuildContext context, GoRouterState state) =>
            const FirstRunScreen(),
      ),
      GoRoute(
        path: editorPath,
        name: editorRouteName,
        builder: (BuildContext context, GoRouterState state) =>
            EditorScreen(id: state.pathParameters[editorIdParameter]!),
      ),
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
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: ChitRoute.find.path,
                name: ChitRoute.find.name,
                builder: (BuildContext context, GoRouterState state) =>
                    const FindScreen(),
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
