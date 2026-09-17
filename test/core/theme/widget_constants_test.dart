import 'package:chit/core/theme/chit_space.dart';
import 'package:chit/features/calendar/presentation/widgets/month_grid.dart';
import 'package:chit/features/today/application/timeline_provider.dart';
import 'package:chit/features/today/presentation/widgets/timeline.dart';
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

    test(
      "today's ring is a hairline with 2px of paper inside it — ADR-046",
      () {
        // The gap is what puts both edges of the ring on paper; a zero here is
        // the ring back on the wash, and item 12's failure back with it.
        expect(DayTile.ringWidth, 1);
        expect(DayTile.todayRingGap, 2);
        expect(DayTile.selectedScale, 1.06);
      },
    );
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

  group('the timeline (M2 group H, ADR-024)', () {
    test('a chit is the same 7px mark on the strip as in the thread', () {
      // DESIGN-SYSTEM.md §6.3 names one dimension for both, because they are
      // the same mark in two places. Two constants that happen to be equal
      // would drift the first time one of them was tuned.
      expect(Timeline.markSize, ThreadNode.markSize);
      expect(Timeline.markSize, 7);
    });

    test('now is a tick, taller than a mark and thinner than one', () {
      // ADR-036. It has to be findable among a day's worth of marks without
      // becoming a second kind of object — so it beats them on height and
      // loses to them on width, which is what makes it read as a position
      // rather than as a thing sitting on the strip.
      expect(Timeline.nowHeight, greaterThan(Timeline.markSize));
      expect(Timeline.nowStroke, lessThan(Timeline.markSize));
      expect(Timeline.nowHeight, 12);
      expect(Timeline.nowStroke, 1.5);
    });

    test('a day boundary is the same tick, hanging below the line', () {
      // ADR-050. One shape in two places: through the line in `--seal` for
      // what is happening, below it in ink for where a day ended. The
      // difference is position and colour, not size.
      expect(Timeline.boundaryHeight, Timeline.nowHeight);
      expect(Timeline.boundaryStroke, Timeline.nowStroke);
    });

    test('a mark on the line cannot hide a boundary', () {
      // Why it grew from `s1`: a 7px mark reaches half its height below the
      // line, and a 4px boundary under one written near midnight showed half
      // a pixel. What hangs clear of the mark has to be at least a mark's
      // worth, or it is findable only when nothing was written near it.
      expect(
        Timeline.boundaryHeight - Timeline.markSize / 2,
        greaterThanOrEqualTo(Timeline.markSize),
      );
    });

    test('the window is three days, and that is a decision not a setting', () {
      // ADR-024. A different number is a different record, so this is here to
      // make changing it deliberate rather than easy.
      expect(TimelineWindow.maxDays, 3);
    });
  });
}
