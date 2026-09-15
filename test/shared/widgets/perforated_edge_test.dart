import 'package:chit/core/theme/chit_colors.dart';
import 'package:chit/core/theme/chit_space.dart';
import 'package:chit/shared/widgets/perforated_edge.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/pump.dart';

/// The one claim the design log makes about this widget: **they are holes in
/// the surface beneath, never a dotted border.**
///
/// A dotted border and a row of punched holes look similar in a screenshot and
/// mean opposite things — one is a line drawn along an edge, the other is the
/// pad showing through the paper — so the test watches what the painter
/// actually calls. Circles in the under colour, and *nothing else at all*: no
/// line, no rect, no path. That last half is the half that matters, because a
/// border would pass every check that only looked for the holes.
void main() {
  const ChitColors colors = ChitColors.tokens();
  const ChitSpace space = ChitSpace.tokens();

  /// A strip 80px wide holds ten holes with 4px of margin at each end.
  const double width = 80;
  const int holes = 10;

  Future<void> pumpEdge(WidgetTester tester) =>
      pumpOnPaper(tester, const PerforatedEdge(), width: width);

  group('the figures of DESIGN-SYSTEM.md §6.3', () {
    test('the hole is 1.55px at an 8px pitch', () {
      // §6.3 quotes both, and this is the file it says they become constants
      // in. If either moves, it moves in the document too.
      expect(PerforatedEdge.holeRadius, 1.55);
      expect(PerforatedEdge.pitch, 8);
    });

    test('the strip is s1 tall', () {
      // Spelled as a literal in the widget because the painter needs it at
      // compile time. This is what keeps that literal honest.
      expect(PerforatedEdge.thickness, space.s1);
    });
  });

  group('where the holes fall', () {
    test('they are one pitch apart', () {
      final List<double> centres = PerforatedEdge.holeCentresAcross(width);

      expect(centres, hasLength(holes));
      for (int i = 1; i < centres.length; i++) {
        expect(centres[i] - centres[i - 1], PerforatedEdge.pitch);
      }
    });

    test('whole holes only, and the remainder is split evenly', () {
      // The prototype tiles from the left and lets the right-hand end clip,
      // which leaves a nick at some widths. A torn edge is symmetric.
      final List<double> centres = PerforatedEdge.holeCentresAcross(85);

      expect(centres.first, 85 - centres.last);
    });

    test('a strip too narrow for a hole has none', () {
      expect(PerforatedEdge.holeCentresAcross(4), isEmpty);
    });
  });

  group('holes, not a border', () {
    testWidgets('every hole is a circle in the colour of the pad beneath', (
      WidgetTester tester,
    ) async {
      await pumpEdge(tester);

      expect(
        find.byType(PerforatedEdge),
        paints..circle(
          x: PerforatedEdge.holeCentresAcross(width).first,
          y: PerforatedEdge.thickness / 2,
          radius: PerforatedEdge.holeRadius,
          color: colors.slipUnder,
        ),
      );
      expect(
        find.byType(PerforatedEdge),
        paintsExactlyCountTimes(#drawCircle, holes),
      );
    });

    testWidgets('and nothing else is drawn — no line, no rect, no path', (
      WidgetTester tester,
    ) async {
      // This is the assertion that separates a perforation from a dotted
      // border. Every one of these would be a way of drawing the edge as a
      // line, and the metaphor rests on the edge not being one.
      await pumpEdge(tester);

      for (final Symbol stroke in <Symbol>[
        #drawLine,
        #drawRect,
        #drawRRect,
        #drawPath,
        #drawDRRect,
      ]) {
        expect(
          find.byType(PerforatedEdge),
          paintsExactlyCountTimes(stroke, 0),
          reason: '$stroke would be drawing the edge rather than punching it',
        );
      }
    });
  });
}
