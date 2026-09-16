import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/calendar/presentation/calendar_screen.dart';
import '../features/onboarding/application/first_run_controller.dart';
import '../features/onboarding/presentation/first_run_screen.dart';
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

/// Where the first-run screen lives — **ADR-041**.
///
/// **Not a [ChitRoute].** That enum is the list the tab bar is built from, so
/// a third constant there would be a third tab. This is a destination the app
/// passes through exactly once and never returns to, which is a different kind
/// of thing and belongs outside the shell.
const String firstRunPath = '/welcome';

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
///
/// **This function must run exactly once.** Everything it depends on is read
/// with `ref.read` or `ref.listen`, never `ref.watch` — a watch here would
/// rebuild the provider, and rebuilding it constructs a second `GoRouter` that
/// starts with empty navigation stacks. Anything that needs to change the
/// router's behaviour later goes through a listenable, as the first-run gate
/// below does.
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  // **The first-run gate, as a listenable rather than a watch** — ADR-041.
  //
  // `ref.watch` cannot be used inside `redirect`: that callback runs on every
  // navigation, long after this provider finished building, and a `watch` from
  // there is reaching for a `Ref` that is no longer building. It would also be
  // the wrong shape even if it worked — re-running this function builds a *new*
  // `GoRouter`, which throws away every branch's navigation stack.
  //
  // So the value is read once, kept in a `ValueNotifier`, and handed to
  // go_router's own `refreshListenable`. `ref.listen` keeps it current. One
  // router for the life of the app, and redirects re-run when the gate flips.
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
    // A fresh install is sent to the first-run screen and everything afterwards
    // is sent away from it, so the screen cannot be reached twice and Today
    // cannot be reached before it.
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
