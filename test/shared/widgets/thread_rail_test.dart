import 'package:chit/core/theme/chit_colors.dart';
import 'package:chit/core/theme/chit_space.dart';
import 'package:chit/shared/widgets/thread_rail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/pump.dart';

/// The rail a day hangs off, and the mark each chit hangs by.
///
/// README §2 asks the thread to read as *one continuous thing*, which is the
/// whole reason there is a rail rather than a mark beside each row. So the
/// tests here are about continuity: one line, unbroken, with the node drawn
/// over it in paper.
void main() {
  const ChitColors colors = ChitColors.tokens();
  const ChitSpace space = ChitSpace.tokens();

  /// The line itself — the only thing [ThreadRail] draws.
  Finder rail() => find.descendant(
    of: find.byType(ThreadRail),
    matching: find.byType(ColoredBox),
  );

  group('the rail', () {
    testWidgets('is a hairline, in the colour every other rule is', (
      WidgetTester tester,
    ) async {
      await pumpOnPaper(
        tester,
        const ThreadRail(child: SizedBox(height: 200, width: 200)),
      );

      expect(tester.widget<ColoredBox>(rail()).color, colors.hair);
      expect(tester.getSize(rail()).width, ThreadRail.thickness);
      expect(ThreadRail.thickness, 1);
    });

    testWidgets('starts and stops inside the thread, not at its edges', (
      WidgetTester tester,
    ) async {
      // A rail that reached the first and last pixel would read as a border
      // down the side of the screen.
      await pumpOnPaper(
        tester,
        const ThreadRail(child: SizedBox(height: 200, width: 200)),
      );

      final Offset top = tester.getTopLeft(rail());
      final Offset thread = tester.getTopLeft(find.byType(ThreadRail));

      expect(top.dy - thread.dy, space.s3);
      expect(tester.getSize(rail()).height, 200 - 2 * space.s3);
    });

    testWidgets('is one line, not one per chit', (WidgetTester tester) async {
      await pumpOnPaper(
        tester,
        const ThreadRail(
          child: Column(
            children: <Widget>[
              SizedBox(height: 60, width: 200),
              SizedBox(height: 60, width: 200),
              SizedBox(height: 60, width: 200),
            ],
          ),
        ),
      );

      expect(rail(), findsOneWidget);
    });
  });

  group('the node', () {
    /// Its layers, outermost first.
    List<Color?> layers(WidgetTester tester) => tester
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(ThreadNode),
            matching: find.byType(DecoratedBox),
          ),
        )
        .map((DecoratedBox box) => (box.decoration as BoxDecoration).color)
        .toList();

    testWidgets('is a halo of paper with the mark over it, in that order', (
      WidgetTester tester,
    ) async {
      // The halo is drawn rather than left blank: paper laid over the line.
      // It is what makes a chit read as hanging *off* the rail instead of as
      // an item in a list that happens to have a line beside it. And the mark
      // is ink, not the accent — a chit already written is a record, and the
      // accent marks what is live (ADR-022).
      await pumpOnPaper(tester, const ThreadNode());

      expect(layers(tester), <Color>[colors.paper, colors.inkFaint]);
    });

    testWidgets('is the 7px mark of §6.3, inside a 15px halo', (
      WidgetTester tester,
    ) async {
      await pumpOnPaper(tester, const ThreadNode());

      expect(ThreadNode.markSize, 7);
      expect(
        tester.getSize(
          find
              .descendant(
                of: find.byType(ThreadNode),
                matching: find.byType(SizedBox),
              )
              .last,
        ),
        const Size(ThreadNode.markSize, ThreadNode.markSize),
      );
      expect(
        tester.getSize(find.byType(ThreadNode)),
        const Size(ThreadNode.size, ThreadNode.size),
      );
    });

    test('the halo is one step of the scale', () {
      // Spelled as a literal in the widget so that [ThreadNode.size] is usable
      // before there is a BuildContext to read the scale from. This is what
      // keeps the literal honest.
      expect(ThreadNode.halo, space.s1);
      expect(ThreadNode.size, ThreadNode.markSize + 2 * space.s1);
    });
  });

  test('the rail comes out of the middle of the mark', () {
    // The prototype puts the node 2px to the left of the rail — a leftover
    // from when it was offset by the page gutter rather than by the thread's
    // own inset. Centring them is what "hanging off a rail" means, and it is
    // also what keeps the rail's position derived from the 7px mark rather
    // than being a fifth off-scale dimension of its own.
    expect(ThreadRail.centre, ThreadNode.markSize / 2);
    expect(ThreadRail.centre, 3.5);
  });

  testWidgets('a chit\'s words sit s5 from the rail', (
    WidgetTester tester,
  ) async {
    await pumpOnPaper(tester, const ThreadNode());

    expect(
      ThreadRail.contentInset(tester.element(find.byType(ThreadNode))),
      space.s5,
    );
  });
}
