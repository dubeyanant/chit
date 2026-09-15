import 'package:chit/core/theme/chit_colors.dart';
import 'package:chit/core/theme/chit_space.dart';
import 'package:chit/shared/widgets/perforated_edge.dart';
import 'package:chit/shared/widgets/slip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/pump.dart';

/// A chit surface: the slip, the tear edge, and the pad behind it.
///
/// The claim worth testing is that they are one object. BEHAVIOUR.md §4.1 has
/// the open chit resting on *a visible second slip, offset behind it — a pad
/// you tear from*, and the perforation is what says it was torn. A slip that
/// can be built without either is a rectangle.
void main() {
  const ChitColors colors = ChitColors.tokens();
  const ChitSpace space = ChitSpace.tokens();

  const Key inked = Key('written');
  const Widget written = SizedBox(key: inked, height: 60);

  /// The decorated box the slip draws in [colour].
  BoxDecoration surfaceIn(WidgetTester tester, Color colour) => tester
      .widgetList<DecoratedBox>(
        find.descendant(
          of: find.byType(Slip),
          matching: find.byType(DecoratedBox),
        ),
      )
      .map((DecoratedBox box) => box.decoration as BoxDecoration)
      .firstWhere((BoxDecoration d) => d.color == colour);

  testWidgets('a slip is torn from something — it carries the edge', (
    WidgetTester tester,
  ) async {
    await pumpOnPaper(tester, const Slip(child: written));

    expect(find.byType(PerforatedEdge), findsOneWidget);
  });

  testWidgets('and rests on a pad, in the colour a hole reveals', (
    WidgetTester tester,
  ) async {
    // The pad and what shows through the perforation are the same token.
    // That is what makes the holes read as a tear rather than as decoration.
    await pumpOnPaper(tester, const Slip(child: written));

    expect(surfaceIn(tester, colors.slipUnder).color, colors.slipUnder);
    expect(surfaceIn(tester, colors.slip).color, colors.slip);
  });

  testWidgets('the pad shows at the right and bottom, one step off', (
    WidgetTester tester,
  ) async {
    // The prototype offsets it 5px across and 6px down; both snap to s1,
    // because an offset between two surfaces is a relationship and
    // DESIGN-SYSTEM.md §6.3 keeps those on the scale.
    await pumpOnPaper(tester, const Slip(child: written));

    final Size whole = tester.getSize(find.byType(Slip));
    final Size slip = tester.getSize(
      find
          .descendant(of: find.byType(Slip), matching: find.byType(Stack))
          .first,
    );

    expect(whole.width - slip.width, space.s1);
    expect(whole.height - slip.height, space.s1);
  });

  testWidgets('it reserves that room rather than overflowing into what '
      'follows it', (WidgetTester tester) async {
    // A slip that painted its pad outside its own box would put it over the
    // next thing on the page, and a Stack is the only reason that would not
    // show up as an error.
    await pumpOnPaper(
      tester,
      const Column(
        children: <Widget>[
          Slip(child: written),
          SizedBox(height: 60),
        ],
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('hairlines carry the structure and the shadow only seats it', (
    WidgetTester tester,
  ) async {
    await pumpOnPaper(tester, const Slip(child: written));
    final BoxDecoration slip = surfaceIn(tester, colors.slip);

    expect(slip.border, Border.all(color: colors.hair));
    expect(slip.boxShadow, Slip.shadow);
    expect(
      Slip.shadow,
      hasLength(1),
      reason: 'DESIGN-SYSTEM.md §6.3: one faint shadow, and only one',
    );
  });

  testWidgets('paper has cut edges — 2px, like everything else', (
    WidgetTester tester,
  ) async {
    await pumpOnPaper(tester, const Slip(child: written));

    expect(
      surfaceIn(tester, colors.slip).borderRadius,
      BorderRadius.circular(space.radius),
    );
  });

  testWidgets('what is written on it is inset by s4', (
    WidgetTester tester,
  ) async {
    await pumpOnPaper(tester, const Slip(child: written));

    final Offset slip = tester.getTopLeft(
      find
          .descendant(of: find.byType(Slip), matching: find.byType(Stack))
          .first,
    );
    final Offset content = tester.getTopLeft(find.byKey(inked));

    expect(content - slip, Offset(space.s4, space.s4));
  });
}
