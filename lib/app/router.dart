import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/find/find_axis.dart';
import '../features/editor/presentation/editor_screen.dart';
import '../features/find/presentation/axis_screen.dart';
import '../features/find/presentation/find_screen.dart';
import '../features/find/presentation/value_screen.dart';
import '../features/past/presentation/past_screen.dart';
import '../features/shell/presentation/shell_screen.dart';
import '../features/today/presentation/today_screen.dart';

part 'router.g.dart';

enum ChitRoute {
  today(path: '/', label: 'today'),

  past(path: '/past', label: 'past'),

  find(path: '/find', label: 'find');

  const ChitRoute({required this.path, required this.label});

  final String path;

  final String label;

  static List<ChitRoute> drawnWhen({required bool tagged}) => <ChitRoute>[
    for (final ChitRoute route in ChitRoute.values)
      if (route != ChitRoute.find || tagged) route,
  ];
}

const String editorRouteName = 'editor';

const String editorIdParameter = 'id';

const String editorPath = '/chit/:$editorIdParameter';

const String findAxisRouteName = 'find-axis';

const String findAxisParameter = 'axis';

const String findValueRouteName = 'find-value';

const String findValueParameter = 'value';

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final GoRouter router = GoRouter(
    initialLocation: ChitRoute.today.path,

    routes: <RouteBase>[
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
                path: ChitRoute.past.path,
                name: ChitRoute.past.name,
                builder: (BuildContext context, GoRouterState state) =>
                    const PastScreen(),
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
