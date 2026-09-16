import 'package:chit/domain/models/chit.dart';
import 'package:chit/features/today/presentation/today_screen.dart';
import 'package:chit/features/today/presentation/widgets/day_thread.dart';
import 'package:chit/shared/widgets/ambient_stamp_row.dart';
import 'package:chit/shared/widgets/thread_rail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app.dart';
import '../../support/fake_clock.dart';
import '../../support/fake_repository.dart';

/// Today, end to end — BEHAVIOUR.md §4.1.
///
/// The screen is where M2 stops being parts: a chit typed into the open chit
/// has to come back out of the database and into the thread, stamped with the
/// moment it was **opened** rather than the moment it was saved. Two of the
/// claims here fail silently and are the reason this file is longer than the
/// screen: a re-captured stamp is a perfectly plausible time (ADR-021), and a
/// thread drawn from widget state rather than from the row looks identical
/// until the app is restarted.
void main() {
  /// Wednesday 16 September 2026, 3:42pm.
  final DateTime openedAt = DateTime(2026, 9, 16, 15, 42);

  Future<void> type(WidgetTester tester, String words) async {
    await tester.enterText(find.byType(TextField), words);
    await tester.pumpAndSettle();
  }

  Future<void> write(WidgetTester tester, String words) async {
    await type(tester, words);
    await tester.tap(find.text('Save chit'));
    await tester.pumpAndSettle();
  }

  group('§4.1: the date is a label, not a masthead', () {
    testWidgets('weekday and date set as one line', (
      WidgetTester tester,
    ) async {
      await pumpChitApp(tester, at: openedAt);

      expect(find.text('Wednesday 16 September'), findsOneWidget);
    });

    testWidgets('and it comes off the clock, so it moves with the day', (
      WidgetTester tester,
    ) async {
      await pumpChitApp(tester, at: DateTime(2026, 1, 1, 0, 20));

      expect(find.text('Thursday 1 January'), findsOneWidget);
    });
  });

  group('§4.1: an empty day looks empty', () {
    testWidgets('the note stands where the thread would be', (
      WidgetTester tester,
    ) async {
      await pumpChitApp(tester, at: openedAt);

      expect(find.text('Nothing written yet today.'), findsOneWidget);
    });

    testWidgets('no rail, and no placeholder row', (WidgetTester tester) async {
      // The specification is explicit about this and it is the easy thing to
      // get wrong: a rail with nothing on it is a line down an empty page, and
      // a greyed-out row is a chit that does not exist.
      await pumpChitApp(tester, at: openedAt);

      expect(find.byType(ThreadRail), findsNothing);
      expect(find.byType(ThreadNode), findsNothing);
      expect(find.byType(ChitRow), findsNothing);
    });

    testWidgets('and the count beside earlier is omitted', (
      WidgetTester tester,
    ) async {
      // Not "0 chits". §4.1 leaves it off, because the app counting an empty
      // day for the user is the app keeping a score (README §1).
      await pumpChitApp(tester, at: openedAt);

      expect(find.text('earlier'), findsOneWidget);
      expect(
        find.textContaining(RegExp(r'd+ chits?')),
        findsNothing,
        reason: 'not "0 chits" — the count is left off entirely',
      );
    });
  });

  group('Save writes a chit, and the thread shows it', () {
    testWidgets('type, save, and it is in the thread', (
      WidgetTester tester,
    ) async {
      await pumpChitApp(tester, at: openedAt);
      await write(tester, 'Reorg meeting pushed again. Third time.');

      expect(
        find.text('Reorg meeting pushed again. Third time.'),
        findsOneWidget,
      );
      expect(find.byType(ChitRow), findsOneWidget);
      expect(find.text('Nothing written yet today.'), findsNothing);
      expect(find.text('1 chit'), findsOneWidget);
    });

    testWidgets('a second one joins it, and the count follows', (
      WidgetTester tester,
    ) async {
      await pumpChitApp(tester, at: openedAt);
      await write(tester, 'First.');
      await write(tester, 'Second.');

      expect(find.byType(ChitRow), findsNWidgets(2));
      expect(find.text('2 chits'), findsOneWidget);
    });

    testWidgets('one rail behind them, not one each', (
      WidgetTester tester,
    ) async {
      // README §2: a day reads as one continuous thing. Two rails is two days.
      await pumpChitApp(tester, at: openedAt);
      await write(tester, 'First.');
      await write(tester, 'Second.');

      expect(find.byType(ThreadRail), findsOneWidget);
      expect(find.byType(ThreadNode), findsNWidgets(2));
    });

    testWidgets('§3.6: the thread carries no pin', (WidgetTester tester) async {
      // A pin under every chit is ten identical marks distinguishing nothing.
      // The open chit above is still wearing one, which is the whole contrast:
      // *this is being noted, now*.
      await pumpChitApp(tester, at: openedAt);
      await write(tester, 'Somewhere.');

      expect(find.byType(AmbientStampRow), findsNWidgets(2));
      expect(find.bySemanticsLabel('Location noted'), findsOneWidget);
    });
  });

  group('ADR-021: the row carries the stamp the chit was opened with', () {
    testWidgets('not the moment it was saved', (WidgetTester tester) async {
      // The one that fails silently. A chit opened at 3:42 and saved at 4:10
      // belongs at 3:42 — that is where its mark falls on the timeline and
      // which day it is filed under (ADR-006) — and a re-captured stamp looks
      // exactly as plausible.
      final ChitHarness app = await pumpChitApp(tester, at: openedAt);
      await type(tester, 'Started at a quarter to four.');

      app.clock.moveTo(DateTime(2026, 9, 16, 16, 10));
      await tester.tap(find.text('Save chit'));
      await tester.pumpAndSettle();

      final Chit saved = app.repository.rows.single;
      expect(saved.createdAt, openedAt);
      expect(saved.localDay, 20260916);
      // The thread says 3:42; the chit now open above it says 4:10, which is
      // ADR-026 and the next test.
      expect(find.text('3:42 pm'), findsOneWidget);
    });
  });

  group('ADR-026: saving opens a new chit', () {
    testWidgets('the page is empty again and stamped now', (
      WidgetTester tester,
    ) async {
      final ChitHarness app = await pumpChitApp(tester, at: openedAt);
      await type(tester, 'Done with this one.');

      app.clock.moveTo(DateTime(2026, 9, 16, 16, 10));
      await tester.tap(find.text('Save chit'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expect(find.text('Save chit'), findsNothing);
      expect(
        find.text('4:10 pm'),
        findsOneWidget,
        reason: 'the chit now open was opened at the moment of the save',
      );
    });
  });

  group('the thread is read from the row, not held in the screen', () {
    testWidgets('a restart finds it still there', (WidgetTester tester) async {
      // A thread drawn from widget state looks identical until the app is
      // closed. Pumping a second app over the same repository is the nearest a
      // widget test gets to a restart, and it is enough: the new screen has
      // never seen the typing that produced the chit.
      final FakeClock clock = FakeClock(openedAt);
      final FakeChitRepository repository = FakeChitRepository(clock: clock);

      await pumpChitApp(tester, at: openedAt, repository: repository);
      await write(tester, 'Survives.');

      await pumpChitApp(tester, at: openedAt, repository: repository);

      expect(find.text('Survives.'), findsOneWidget);
      expect(find.text('1 chit'), findsOneWidget);
    });
  });

  group('the चित्त mark closes the day', () {
    testWidgets('it is drawn, and a screen reader never reads it', (
      WidgetTester tester,
    ) async {
      // §4.1: it appears here and beside the wordmark, and nowhere else. The
      // prototype marks it `aria-hidden` — announcing "चित्त" at the end of
      // the day is reading out a full stop.
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpChitApp(tester, at: openedAt);

      // Two: the masthead's, in the shell, and this one.
      expect(find.text('चित्त'), findsNWidgets(2));

      // Walked from the screen's own node rather than from a binding: the root
      // semantics owner hangs off a child pipeline owner now, and the accessor
      // that used to reach it is deprecated. `shell_test.dart` does the same.
      final SemanticsNode root = tester.getSemantics(find.byType(TodayScreen));
      final List<String> labels = <String>[];
      void walk(SemanticsNode node) {
        labels.add(node.label);
        node.visitChildren((SemanticsNode child) {
          walk(child);
          return true;
        });
      }

      walk(root);
      expect(labels.where((String l) => l.contains('चित्त')), isEmpty);
      handle.dispose();
    });
  });
}
