import 'package:chit/app/router.dart';
import 'package:chit/features/calendar/presentation/calendar_screen.dart';
import 'package:chit/features/shell/presentation/shell_screen.dart';
import 'package:chit/features/today/presentation/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app.dart';

/// The shell of ADR-011, and the claim it was chosen for.
///
/// `go_router` with a stateful shell is more machinery than two tabs need
/// today, and the reason it is here anyway is one sentence in
/// DESIGN-SYSTEM.md §6.3: *returning to a tab costs a 200ms fade and nothing
/// more.* A tab bar that rebuilds its screen looks identical in a screenshot
/// and is wrong in the hand, so the claim is worth a test rather than a
/// comment.
const String _calendarPlaceholder = 'The calendar arrives in M4.';

/// Every label in the semantics tree as it is actually built.
Set<String> _labelsIn(WidgetTester tester) {
  final Set<String> labels = <String>{};

  void visit(SemanticsNode node) {
    if (node.label.isNotEmpty) labels.add(node.label);
    node.visitChildren((SemanticsNode child) {
      visit(child);
      return true;
    });
  }

  // Walked from the shell's own node rather than from a binding: the root
  // semantics owner hangs off a child pipeline owner now, and the accessor
  // that used to reach it is deprecated. Starting at a widget avoids it.
  visit(tester.getSemantics(find.byType(ShellScreen)));
  return labels;
}

void main() {
  // Through the shared helper rather than a bare `ProviderScope`: Today
  // builds the open chit now, and the open chit asks for an ambient stamp
  // from two services that `domain` declares and deliberately leaves
  // unimplemented (ARCHITECTURE.md §3). Nothing in this file is about them —
  // they are simply what the app needs to boot.
  Future<void> pumpApp(WidgetTester tester) => pumpChitApp(tester);

  /// The `Semantics` the tab bar puts round a tab, rather than one of the
  /// several the framework wraps a `Text` in on the way down.
  Semantics tabSemantics(WidgetTester tester, String label) => tester
      .widgetList<Semantics>(
        find.ancestor(of: find.text(label), matching: find.byType(Semantics)),
      )
      .firstWhere((Semantics s) => s.properties.selected != null);

  Future<void> tapTab(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  group('the two tabs', () {
    testWidgets('the app opens on Today', (WidgetTester tester) async {
      await pumpApp(tester);

      expect(find.byType(TodayScreen), findsOneWidget);
      expect(find.text('today'), findsOneWidget);
      expect(find.text('calendar'), findsOneWidget);
    });

    testWidgets('the masthead belongs to the shell, not to a tab', (
      WidgetTester tester,
    ) async {
      // It is above both tabs, so it does not move when they change. If it
      // lived on Today it would appear and disappear with the tab.
      await pumpApp(tester);
      expect(find.text('chit'), findsOneWidget);

      await tapTab(tester, 'calendar');
      expect(find.text('chit'), findsOneWidget);
    });

    testWidgets('there is no settings control', (WidgetTester tester) async {
      // The prototype draws a gear with nothing behind it. DESIGN-SYSTEM.md
      // §6.4: a control that does nothing is not marked up as a control.
      await pumpApp(tester);

      final Iterable<Semantics> controls = tester
          .widgetList<Semantics>(find.byType(Semantics))
          .where((Semantics s) => s.properties.label == 'Settings');
      expect(controls, isEmpty);
    });
  });

  group('ADR-011: returning to a tab costs a fade, not a rebuild', () {
    testWidgets('Today is never torn down when the calendar is shown', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);
      final Element today = tester.element(find.byType(TodayScreen));

      await tapTab(tester, 'calendar');

      expect(
        find.byType(CalendarScreen),
        findsOneWidget,
        reason: 'the calendar is showing',
      );
      expect(
        find.byType(TodayScreen),
        findsOneWidget,
        reason: 'and Today is still in the tree behind it',
      );
      expect(
        tester.element(find.byType(TodayScreen)),
        same(today),
        reason: 'the same element, so nothing was rebuilt',
      );
    });

    testWidgets('and it is the same element again on the way back', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);
      final Element today = tester.element(find.byType(TodayScreen));

      await tapTab(tester, 'calendar');
      await tapTab(tester, 'today');

      expect(tester.element(find.byType(TodayScreen)), same(today));
    });

    testWidgets('the tab you are not on is untouchable and unreadable', (
      WidgetTester tester,
    ) async {
      // Both branches stay in the tree once both have been visited, which is
      // the point — but a screen reader on Today must not then find the
      // calendar underneath it, and a tap must not reach it either.
      //
      // A branch is built lazily, so the calendar is not in the tree at all
      // until it is first shown. That is why this goes there and comes back
      // rather than asserting at launch.
      await pumpApp(tester);
      expect(find.byType(CalendarScreen), findsNothing);

      await tapTab(tester, 'calendar');
      await tapTab(tester, 'today');

      // Something above the hidden branch refuses pointers. Which widget does
      // it is the framework's business — several of its own sit in this chain
      // — so the assertion is that the branch is gated, not that it is gated
      // by a particular one.
      expect(
        tester
            .widgetList<IgnorePointer>(
              find.ancestor(
                of: find.byType(CalendarScreen),
                matching: find.byType(IgnorePointer),
              ),
            )
            .any((IgnorePointer gate) => gate.ignoring),
        isTrue,
        reason: 'the branch behind the current one takes no taps',
      );

      // And a screen reader on Today does not find it at all. Walked over the
      // real semantics tree rather than asked of the widget that produces it:
      // `find.bySemanticsLabel` reads each widget's own configuration, so it
      // still finds text that an ancestor has excluded, which is the opposite
      // of the thing being checked.
      final SemanticsHandle semantics = tester.ensureSemantics();
      // Disposed in the body rather than in a tear-down: the framework checks
      // for live handles before tear-downs run.
      await tester.pumpAndSettle();

      expect(
        _labelsIn(tester),
        isNot(contains(_calendarPlaceholder)),
        reason: 'the hidden branch is out of the semantics tree',
      );

      await tapTab(tester, 'calendar');
      expect(
        _labelsIn(tester),
        contains(_calendarPlaceholder),
        reason: 'and back in it when it is the tab you are on',
      );

      semantics.dispose();
    });

    testWidgets('the fade is the house pace, and it is a fade', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);

      final AnimatedOpacity todayFade = tester.widget<AnimatedOpacity>(
        find
            .ancestor(
              of: find.byType(TodayScreen),
              matching: find.byType(AnimatedOpacity),
            )
            .first,
      );
      expect(todayFade.opacity, 1);
      expect(todayFade.duration, const Duration(milliseconds: 220));
    });
  });

  group('the tab bar', () {
    testWidgets('the selected tab is marked selected, not just coloured', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);

      expect(tabSemantics(tester, 'today').properties.selected, isTrue);
      expect(tabSemantics(tester, 'calendar').properties.selected, isFalse);

      await tapTab(tester, 'calendar');

      expect(tabSemantics(tester, 'today').properties.selected, isFalse);
      expect(tabSemantics(tester, 'calendar').properties.selected, isTrue);
    });

    testWidgets('there is a tab for every route, and no others', (
      WidgetTester tester,
    ) async {
      // The bar is built from ChitRoute.values rather than from a list of its
      // own, so this is what that buys: a destination cannot be added to the
      // router and quietly miss its tab.
      await pumpApp(tester);

      for (final ChitRoute route in ChitRoute.values) {
        expect(
          find.text(route.label),
          findsOneWidget,
          reason: '${route.name} has a tab',
        );
      }
      expect(find.byType(InkWell), findsNWidgets(ChitRoute.values.length));
    });

    testWidgets('every tab clears the 44px touch target of §6.4', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);

      for (final String label in <String>['today', 'calendar']) {
        final Size size = tester.getSize(
          find
              .ancestor(of: find.text(label), matching: find.byType(InkWell))
              .first,
        );
        expect(
          size.height,
          greaterThanOrEqualTo(44),
          reason: '$label is ${size.height}px tall',
        );
      }
    });
  });
}
