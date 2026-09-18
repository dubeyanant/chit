import 'package:chit/features/today/application/timeline_provider.dart';
import 'package:flutter_test/flutter_test.dart';

/// The arithmetic the timeline rests on — ADR-024.
///
/// `TimelineWindow` is a plain value on purpose, and this file is why: under
/// ADR-031 the strip itself is a device check, so everything that can be
/// decided by counting has to be reachable without building a widget. What is
/// tested here is where a mark lands and which three days are on screen; what
/// it *looks* like when fifteen of them crowd into one strip is a person's job
/// and `docs/OPEN-QUESTIONS.md` carries it.
void main() {
  /// Wednesday 16 September 2026, 3:42pm — the afternoon the docs are written
  /// around.
  final DateTime afternoon = DateTime(2026, 9, 16, 15, 42);

  group(
    'the window is three whole local days, ending at the next midnight',
    () {
      test('starts two midnights back and ends at the next one', () {
        final TimelineWindow window = TimelineWindow.around(afternoon);

        expect(window.start, DateTime(2026, 9, 14));
        expect(window.end, DateTime(2026, 9, 17));
      });

      test('spans exactly three days', () {
        expect(TimelineWindow.maxDays, 3);
        expect(TimelineWindow.around(afternoon).span, const Duration(days: 3));
      });

      test('the query bounds are the first and last day, inclusive', () {
        final TimelineWindow window = TimelineWindow.around(afternoon);

        expect(window.fromDay, 20260914);
        // Today, and *not* tomorrow: `end` is already the next day, so a naive
        // `localDayOf(end)` would widen the query by a day and put tomorrow's
        // chits on a strip with nowhere to draw them.
        expect(window.toDay, 20260916);
      });

      test(
        'a moment one minute into a day still spans the two days before it',
        () {
          // The five hours ADR-006 works hardest to protect. Nothing about the
          // window is special here, which is the point.
          final TimelineWindow window = TimelineWindow.around(
            DateTime(2026, 9, 16, 0, 1),
          );

          expect(window.start, DateTime(2026, 9, 14));
          expect(window.end, DateTime(2026, 9, 17));
        },
      );

      test('it counts days rather than 24-hour blocks, across a month', () {
        final TimelineWindow window = TimelineWindow.around(
          DateTime(2026, 10, 1, 9),
        );

        expect(window.start, DateTime(2026, 9, 29));
        expect(window.fromDay, 20260929);
        expect(window.toDay, 20261001);
      });

      test('and across a year', () {
        final TimelineWindow window = TimelineWindow.around(
          DateTime(2027, 1, 1, 9),
        );

        expect(window.start, DateTime(2026, 12, 30));
        expect(window.fromDay, 20261230);
        expect(window.toDay, 20270101);
      });
    },
  );

  group('a mark lands where its time actually falls', () {
    final TimelineWindow window = TimelineWindow.around(afternoon);

    test('the first instant of the window is the left edge', () {
      expect(window.fractionOf(DateTime(2026, 9, 14)), 0);
    });

    test('a midpoint is the middle', () {
      // Noon on the middle day — halfway through 72 hours.
      expect(window.fractionOf(DateTime(2026, 9, 15, 12)), closeTo(0.5, 1e-9));
    });

    test('the last instant of the window is just short of the right edge', () {
      final double? fraction = window.fractionOf(
        DateTime(2026, 9, 17).subtract(const Duration(microseconds: 1)),
      );

      expect(fraction, isNotNull);
      expect(fraction!, lessThan(1));
      expect(fraction, closeTo(1, 1e-6));
    });

    test('four chits in an hour are four positions, not one', () {
      // §4.1: *four chits in an hour look like a burst, because they are one.*
      // Evenly spaced dots would be the same picture whatever the times were.
      final List<double> positions = <double>[
        for (final int minute in <int>[0, 15, 30, 45])
          window.fractionOf(DateTime(2026, 9, 16, 11, minute))!,
      ];

      expect(positions.toSet(), hasLength(4));
      expect(positions, orderedEquals(<double>[...positions]..sort()));
    });

    test('an hour is the same width wherever it falls', () {
      double hourAt(DateTime start) =>
          window.fractionOf(start.add(const Duration(hours: 1)))! -
          window.fractionOf(start)!;

      expect(
        hourAt(DateTime(2026, 9, 14, 3)),
        closeTo(hourAt(DateTime(2026, 9, 16, 14)), 1e-9),
      );
      // One hour in seventy-two.
      expect(hourAt(DateTime(2026, 9, 15, 9)), closeTo(1 / 72, 1e-9));
    });
  });

  group('what will not fit is not drawn', () {
    final TimelineWindow window = TimelineWindow.around(afternoon);

    test('before the window is null, not zero', () {
      expect(
        window.fractionOf(
          DateTime(2026, 9, 14).subtract(const Duration(microseconds: 1)),
        ),
        isNull,
      );
    });

    test('the far end is exclusive — an instant at `end` is tomorrow', () {
      expect(window.fractionOf(DateTime(2026, 9, 17)), isNull);
    });

    test('the small hours are not the left edge — this is the day arc bug, '
        'and it is what ADR-024 was written about', () {
      // The arc ran 5am to midnight and clamped, so a chit written at 00:20
      // and one written at 5:00 landed on the same pixel. Both are honest
      // positions now, and they are different ones.
      final double? small = window.fractionOf(DateTime(2026, 9, 16, 0, 20));
      final double? five = window.fractionOf(DateTime(2026, 9, 16, 5));

      expect(small, isNotNull);
      expect(five, isNotNull);
      expect(small, lessThan(five!));
      expect(small, greaterThan(window.fractionOf(DateTime(2026, 9, 16))!));
    });
  });

  group('the day boundaries', () {
    final TimelineWindow window = TimelineWindow.around(afternoon);

    test('are the two midnights inside the window, and not its own ends', () {
      expect(window.dayBoundaries, <DateTime>[
        DateTime(2026, 9, 15),
        DateTime(2026, 9, 16),
      ]);
    });

    test('fall a third and two thirds of the way across', () {
      final List<double> positions = <double>[
        for (final DateTime boundary in window.dayBoundaries)
          window.fractionOf(boundary)!,
      ];

      expect(positions[0], closeTo(1 / 3, 1e-9));
      expect(positions[1], closeTo(2 / 3, 1e-9));
    });

    test('there is one fewer of them than there are days', () {
      // Two marks for three days. §4.1: *someone who sees two of them is
      // looking at three days and will know it without being told.*
      expect(window.dayBoundaries, hasLength(window.dayCount - 1));
    });
  });

  group('leading empty days are not drawn — ADR-035', () {
    final TimelineWindow query = TimelineWindow.around(afternoon);

    test('nothing written at all is today alone, and does not scroll', () {
      final TimelineWindow drawn = query.trimmedTo(null);

      expect(drawn.dayCount, 1);
      expect(drawn.start, DateTime(2026, 9, 16));
      expect(drawn.end, DateTime(2026, 9, 17));
      // One day is one screen (ADR-032), so one day is a strip with nowhere
      // to go — which is the whole point: a first run opens on today.
      expect(drawn.dayBoundaries, isEmpty);
    });

    test('the oldest chit decides where the strip starts', () {
      final TimelineWindow drawn = query.trimmedTo(DateTime(2026, 9, 15, 11));

      expect(drawn.dayCount, 2);
      expect(drawn.start, DateTime(2026, 9, 15));
      expect(drawn.dayBoundaries, <DateTime>[DateTime(2026, 9, 16)]);
    });

    test('a chit on the first day leaves the window as it was', () {
      final TimelineWindow drawn = query.trimmedTo(DateTime(2026, 9, 14, 23));

      expect(drawn, query);
      expect(drawn.dayCount, TimelineWindow.maxDays);
    });

    test('it only ever narrows — an older chit cannot widen it', () {
      // Nothing outside the window is in the query that produced it, but the
      // window is the thing that decides what *can* be drawn, and it must not
      // be talked into drawing a fourth day.
      final TimelineWindow drawn = query.trimmedTo(DateTime(2026, 9, 1, 12));

      expect(drawn, query);
      expect(drawn.start, DateTime(2026, 9, 14));
    });

    test('a quiet day between two busy ones is still drawn', () {
      // The half of ADR-024's argument this keeps: *yesterday was quiet and
      // today is not* is still visible, as long as there is something older
      // than yesterday to anchor it.
      final TimelineWindow drawn = query.trimmedTo(DateTime(2026, 9, 14, 9));

      expect(drawn.dayCount, 3);
      expect(
        drawn.fractionOf(DateTime(2026, 9, 15, 12)),
        closeTo(0.5, 1e-9),
        reason: 'the empty middle day still occupies its third of the strip',
      );
    });

    test('a narrower window re-spreads what is on it', () {
      // Positions are a fraction of the window, so trimming is not a crop —
      // two days of marks spread across the whole strip rather than bunching
      // into the right-hand two thirds of it.
      final DateTime noon = DateTime(2026, 9, 16, 12);

      expect(query.fractionOf(noon), closeTo(5 / 6, 1e-9));
      expect(
        query.trimmedTo(DateTime(2026, 9, 16, 1)).fractionOf(noon),
        closeTo(0.5, 1e-9),
      );
    });
  });

  group('which day the reader is looking at — ADR-034', () {
    final TimelineWindow window = TimelineWindow.around(afternoon);

    test('each third of a three-day strip is its own day', () {
      expect(window.dayAt(0), 0);
      expect(window.dayAt(0.2), 0);
      expect(window.dayAt(0.5), 1);
      expect(window.dayAt(0.9), 2);
      expect(window.dayAt(1), 2);
    });

    test('the answer changes exactly at a boundary', () {
      // The haptic fires on a change here, so a boundary that answered the
      // same on both sides would be a day that passed in silence.
      final double edge = window.fractionOf(DateTime(2026, 9, 15))!;

      expect(window.dayAt(edge - 1e-6), 0);
      expect(window.dayAt(edge), 1);
    });

    test('a one-day window has one answer, so nothing can be crossed', () {
      final TimelineWindow today = window.trimmedTo(null);

      expect(today.dayAt(0), 0);
      expect(today.dayAt(1), 0);
    });
  });

  group('the window slides when the local day does', () {
    test('a minute either side of midnight is two different windows', () {
      final TimelineWindow before = TimelineWindow.around(
        DateTime(2026, 9, 16, 23, 59),
      );
      final TimelineWindow after = TimelineWindow.around(
        DateTime(2026, 9, 17, 0, 1),
      );

      expect(before, isNot(after));
      expect(before.start, DateTime(2026, 9, 14));
      expect(after.start, DateTime(2026, 9, 15));
      expect(after.toDay, 20260917);
    });

    test('the oldest day falls off the far end as it slides', () {
      final DateTime oldChit = DateTime(2026, 9, 14, 23);

      expect(
        TimelineWindow.around(DateTime(2026, 9, 16, 23, 59))
            .fractionOf(oldChit),
        isNotNull,
      );
      // Still on screen at 23:59, gone a minute later. A chit does not move
      // (ADR-006); the window moves under it (ADR-024).
      expect(
        TimelineWindow.around(DateTime(2026, 9, 17, 0, 1)).fractionOf(oldChit),
        isNull,
      );
    });

    test('a window does not slide while the day does not', () {
      expect(
        TimelineWindow.around(DateTime(2026, 9, 16, 0, 1)),
        TimelineWindow.around(DateTime(2026, 9, 16, 23, 59)),
      );
    });
  });
}
