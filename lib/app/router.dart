import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/find/find_axis.dart';
import '../features/calendar/presentation/calendar_screen.dart';
import '../features/editor/presentation/editor_screen.dart';
import '../features/find/presentation/axis_screen.dart';
import '../features/find/presentation/find_screen.dart';
import '../features/find/presentation/value_screen.dart';
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

/// find's two deeper screens are **routes under its branch**, not state in the
/// tab (ADR-084): the drill-down is three levels, and go_router already owns
/// what back means. Nested in the branch, so the tab bar stays.
const String findAxisRouteName = 'find-axis';

const String findAxisParameter = 'axis';

const String findValueRouteName = 'find-value';

const String findValueParameter = 'value';

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
                routes: <RouteBase>[
                  GoRoute(
                    path: ':$findAxisParameter',
                    name: findAxisRouteName,
                    builder: (BuildContext context, GoRouterState state) {
                      final FindAxis? axis = FindAxis.ofSlug(
                        state.pathParameters[findAxisParameter]!,
                      );
                      return axis == null
                          ? const FindScreen()
                          : AxisScreen(axis: axis);
                    },
                    routes: <RouteBase>[
                      GoRoute(
                        path: ':$findValueParameter',
                        name: findValueRouteName,
                        builder: (BuildContext context, GoRouterState state) {
                          final FindAxis? axis = FindAxis.ofSlug(
                            state.pathParameters[findAxisParameter]!,
                          );
                          return axis == null
                              ? const FindScreen()
                              : ValueScreen(
                                  axis: axis,
                                  slug:
                                      state.pathParameters[findValueParameter]!,
                                );
                        },
                      ),
                    ],
                  ),
                ],
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
