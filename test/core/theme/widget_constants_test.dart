import 'package:chit/core/theme/chit_space.dart';
import 'package:chit/shared/widgets/perforated_edge.dart';
import 'package:chit/shared/widgets/thread_rail.dart';
import 'package:flutter_test/flutter_test.dart';

/// The handful of dimensions that are spelled as compile-time constants in a
/// widget instead of being read from `ChitSpace`, and the rule that keeps them
/// honest: **a constant that duplicates a step of the scale still equals it.**
///
/// DESIGN-SYSTEM.md §6.3 allows a *dimension* off the scale when it is a
/// property of one component and named in `ChitSpace`; it does not allow a
/// dimension to quietly stop matching the step it was copied from. Two of these
/// are `s1` written out by hand — the painter and the layout caller both need
/// them before there is a `BuildContext` to read the scale from — and a nudge
/// to `s1` that left them behind would be invisible.
///
/// These claims had a home in the widget suite until ADR-031 removed it. They
/// come back here because none of them ever needed a widget: `ChitSpace.tokens`
/// is a const constructor and these are const fields, so it is arithmetic.
void main() {
  const ChitSpace space = ChitSpace.tokens();

  group('a constant copied off the scale still matches it', () {
    test('the perforated strip is s1 tall', () {
      expect(PerforatedEdge.thickness, space.s1);
    });

    test("the thread node's halo is s1", () {
      expect(ThreadNode.halo, space.s1);
    });

    test('the holes are pitched at s2', () {
      expect(PerforatedEdge.pitch, space.s2);
    });
  });

  group('the figures read off v6, which are nobody else\'s to change', () {
    test('holes are 1.55px at an 8px pitch', () {
      // At v5's 1.2px they were invisible at arm's length, which is the same as
      // not drawing them — DESIGN-LOG.md, and the reason the figure is exact.
      expect(PerforatedEdge.holeRadius, 1.55);
      expect(PerforatedEdge.pitch, 8);
    });

    test('the mark is 7px and the rail is a hairline', () {
      expect(ThreadNode.markSize, 7);
      expect(ThreadRail.thickness, 1);
    });
  });

  test('the rail is derived from the mark, never set beside it', () {
    // The prototype puts the node 2px to the left of the rail. Deriving the
    // centre is what stops the two drifting apart — §6.3 carries the departure,
    // and this is the assertion that makes the derivation load-bearing rather
    // than incidental.
    expect(ThreadRail.centre, ThreadNode.markSize / 2);
  });

  test('a node occupies its mark plus a halo on both sides', () {
    expect(ThreadNode.size, ThreadNode.markSize + 2 * ThreadNode.halo);
  });
}
