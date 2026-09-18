import 'package:chitta/core/theme/chit_space.dart';
import 'package:chitta/features/calendar/presentation/widgets/month_grid.dart';
import 'package:chitta/features/today/application/timeline_provider.dart';
import 'package:chitta/features/today/presentation/widgets/timeline.dart';
import 'package:chitta/shared/widgets/focus_ring.dart';
import 'package:chitta/shared/widgets/microphone.dart';
import 'package:chitta/shared/widgets/perforated_edge.dart';
import 'package:chitta/shared/widgets/thread_rail.dart';
import 'package:flutter_test/flutter_test.dart';

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
        expect(DayTile.ringWidth, 1);
        expect(DayTile.todayRingGap, 2);
        expect(DayTile.selectedScale, 1.06);
      },
    );
  });

  test('the rail is derived from the mark, never set beside it', () {
    expect(ThreadRail.centre, ThreadNode.markSize / 2);
  });

  test('a node occupies its mark plus a halo on both sides', () {
    expect(ThreadNode.size, ThreadNode.markSize + 2 * ThreadNode.halo);
  });

  group('the timeline (M2 group H, ADR-024)', () {
    test('a chit is the same 7px mark on the strip as in the thread', () {
      expect(Timeline.markSize, ThreadNode.markSize);
      expect(Timeline.markSize, 7);
    });

    test('now is a tick, taller than a mark and thinner than one', () {
      expect(Timeline.nowHeight, greaterThan(Timeline.markSize));
      expect(Timeline.nowStroke, lessThan(Timeline.markSize));
      expect(Timeline.nowHeight, 12);
      expect(Timeline.nowStroke, 1.5);
    });

    test('a day boundary is the same tick, hanging below the line', () {
      expect(Timeline.boundaryHeight, Timeline.nowHeight);
      expect(Timeline.boundaryStroke, Timeline.nowStroke);
    });

    test('a mark on the line cannot hide a boundary', () {
      expect(
        Timeline.boundaryHeight - Timeline.markSize / 2,
        greaterThanOrEqualTo(Timeline.markSize),
      );
    });

    test('the window is three days, and that is a decision not a setting', () {
      expect(TimelineWindow.maxDays, 3);
    });
  });

  group('the accessibility floors that are numbers', () {
    test('44px, with no exceptions — §6.4', () {
      expect(space.minTouchTarget, 44);
    });

    test('the microphone is larger and does not shrink for text', () {
      expect(Microphone.size, 54);
      expect(Microphone.size, greaterThan(space.minTouchTarget));
    });

    test('a control padded by s4 clears the floor on its own', () {
      expect(2 * space.s4, greaterThanOrEqualTo(32.0));
    });

    test(
      'a pill does not reach the floor on its padding, so it is held to it',
      () {
        expect(2 * space.s3 + 18, lessThan(space.minTouchTarget));
        expect(2 * space.s3 + 18, 42);
      },
    );

    test('the focus ring is the app\x27s one stroke', () {
      expect(FocusRing.thickness, Timeline.nowStroke);
    });
  });
}
