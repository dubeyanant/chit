import 'package:chit/domain/models/chit.dart';
import 'package:chit/domain/models/day_summary.dart';
import 'package:chit/features/calendar/application/archive_provider.dart';
import 'package:chit/features/calendar/application/month_provider.dart';
import 'package:flutter_test/flutter_test.dart';

/// The arithmetic the month grid rests on — BEHAVIOUR.md §4.2, with no widget
/// anywhere near it (ADR-031).
///
/// Where the first tile sits, where the last one is, which one is today, how
/// dark each is and what the summary says are all answered by [MonthShape]
/// from a list of counts and one reading of the day. The grid draws the
/// answer; this is what makes the answer right.
void main() {
  /// Thursday 17 September 2026, 3pm.
  final DateTime today = DateTime(2026, 9, 17, 15);
  const YearMonth september = YearMonth(2026, 9);

  DaySummary day(int localDay, int count) =>
      DaySummary(localDay: localDay, count: count);

  MonthShape shape(YearMonth month, [List<DaySummary> rows = const []]) =>
      MonthShape(month: month, today: today, summaries: rows);

  group('YearMonth', () {
    test('steps across a year boundary in both directions', () {
      expect(const YearMonth(2026, 1).previous, const YearMonth(2025, 12));
      expect(const YearMonth(2025, 12).next, const YearMonth(2026, 1));
      expect(september.previous, const YearMonth(2026, 8));
      expect(september.next, const YearMonth(2026, 10));
    });

    test('knows how long it is, February included', () {
      expect(september.daysInMonth, 30);
      expect(const YearMonth(2026, 2).daysInMonth, 28);
      expect(const YearMonth(2028, 2).daysInMonth, 29);
      expect(const YearMonth(2026, 12).daysInMonth, 31);
    });

    test('its bounds are the query the repository is asked for', () {
      expect(september.firstDay, 20260901);
      expect(september.lastDay, 20260930);
      expect(september.contains(20260901), isTrue);
      expect(september.contains(20260930), isTrue);
      expect(september.contains(20260831), isFalse);
      expect(september.contains(20261001), isFalse);
    });

    test('orders', () {
      expect(const YearMonth(2026, 8).isBefore(september), isTrue);
      expect(september.isBefore(september), isFalse);
      expect(
        const YearMonth(2025, 12).isBefore(const YearMonth(2026, 1)),
        isTrue,
      );
    });

    test('names itself, without the year', () {
      expect(september.name, 'September');
      expect(const YearMonth(2026, 1).name, 'January');
    });

    test('is a value', () {
      expect(const YearMonth(2026, 9), september);
      expect(YearMonth.of(today), september);
      expect(const YearMonth(2026, 9).hashCode, september.hashCode);
    });
  });

  group('the chevrons land only on written months — ADR-047', () {
    // yyyymm, in no particular order, as the query would answer.
    const List<int> written = <int>[202604, 202607, 202509, 202609];

    test('previous is the nearest written month before', () {
      expect(september.previousWrittenIn(written), const YearMonth(2026, 7));
      expect(
        const YearMonth(2026, 7).previousWrittenIn(written),
        const YearMonth(2026, 4),
      );
      expect(
        const YearMonth(2026, 4).previousWrittenIn(written),
        const YearMonth(2025, 9),
      );
    });

    test('previous is null at the floor', () {
      expect(const YearMonth(2025, 9).previousWrittenIn(written), isNull);
      expect(september.previousWrittenIn(const <int>[]), isNull);
    });

    test('next is the nearest written month after', () {
      expect(
        const YearMonth(2025, 9).nextWrittenIn(written, current: september),
        const YearMonth(2026, 4),
      );
      expect(
        const YearMonth(2026, 4).nextWrittenIn(written, current: september),
        const YearMonth(2026, 7),
      );
    });

    test(
      'next lands on the current month whether or not it was written in',
      () {
        const List<int> withoutSeptember = <int>[202604, 202607];
        expect(
          const YearMonth(
            2026,
            7,
          ).nextWrittenIn(withoutSeptember, current: september),
          september,
        );
      },
    );

    test('next is null at the current month', () {
      expect(september.nextWrittenIn(written, current: september), isNull);
    });

    test('code round-trips', () {
      expect(september.code, 202609);
      expect(YearMonth.fromCode(202609), september);
      expect(YearMonth.fromCode(202512), const YearMonth(2025, 12));
    });
  });

  group('quiet weeks at either end are not drawn — ADR-047', () {
    List<int?> rowOf(MonthShape s, int index) => s.rows[index];

    test('a fresh install draws only the week today is in', () {
      // September 2026 starts on a Tuesday; the 17th is in the third week.
      final MonthShape s = shape(september);
      expect(s.rows, hasLength(1));
      expect(rowOf(s, 0), <int?>[13, 14, 15, 16, 17, null, null]);
    });

    test('from the first written week to today', () {
      final MonthShape s = shape(september, <DaySummary>[day(20260908, 1)]);
      expect(s.rows, hasLength(2));
      expect(rowOf(s, 0), <int?>[6, 7, 8, 9, 10, 11, 12]);
      expect(rowOf(s, 1), <int?>[13, 14, 15, 16, 17, null, null]);
    });

    test('a quiet week between two written ones stays, and reads as quiet', () {
      final MonthShape s = shape(september, <DaySummary>[day(20260901, 1)]);
      expect(s.rows, hasLength(3));
      expect(rowOf(s, 0), <int?>[null, null, 1, 2, 3, 4, 5]);
      expect(rowOf(s, 1), <int?>[6, 7, 8, 9, 10, 11, 12]);
      expect(rowOf(s, 2), <int?>[13, 14, 15, 16, 17, null, null]);
    });

    test('a past month trims both ends', () {
      // August 2026 starts on a Saturday. Writes on the 20th and the 25th
      // fall in its fourth and fifth weeks; the first three and the last go.
      final MonthShape s = shape(const YearMonth(2026, 8), <DaySummary>[
        day(20260820, 2),
        day(20260825, 1),
      ]);
      expect(s.rows, hasLength(2));
      expect(rowOf(s, 0), <int?>[16, 17, 18, 19, 20, 21, 22]);
      expect(rowOf(s, 1), <int?>[23, 24, 25, 26, 27, 28, 29]);
    });

    test('a past month with one write is one week', () {
      final MonthShape s = shape(const YearMonth(2026, 8), <DaySummary>[
        day(20260831, 1),
      ]);
      expect(s.rows, <List<int?>>[
        <int?>[30, 31, null, null, null, null, null],
      ]);
    });

    test('a month with nothing in it and no today draws nothing', () {
      expect(shape(const YearMonth(2026, 8)).rows, isEmpty);
      expect(shape(const YearMonth(2026, 10)).rows, isEmpty);
    });

    test('the seeded September is three weeks, the first one full', () {
      final MonthShape s = shape(september, <DaySummary>[
        day(20260916, 5),
        day(20260915, 5),
        day(20260913, 1),
        day(20260911, 2),
        day(20260908, 1),
        day(20260905, 3),
      ]);
      expect(s.rows, hasLength(3));
      expect(rowOf(s, 0), <int?>[null, null, 1, 2, 3, 4, 5]);
    });
  });

  group('the current month is drawn up to today and stops', () {
    test('today is the last tile', () {
      final MonthShape s = shape(september);
      expect(s.lastDrawnDay, 17);
      expect(s.todayDay, 17);
      expect(s.isCurrentMonth, isTrue);
    });

    test('a past month draws in full and has no today', () {
      final MonthShape s = shape(const YearMonth(2026, 8));
      expect(s.lastDrawnDay, 31);
      expect(s.todayDay, isNull);
      expect(s.isCurrentMonth, isFalse);
    });

    test('a future month draws nothing at all', () {
      final MonthShape s = shape(const YearMonth(2026, 10));
      expect(s.lastDrawnDay, 0);
      expect(s.todayDay, isNull);
    });

    test('on the first of a month, one tile', () {
      final MonthShape s = MonthShape(
        month: const YearMonth(2026, 10),
        today: DateTime(2026, 10, 1, 8),
        summaries: const <DaySummary>[],
      );
      expect(s.lastDrawnDay, 1);
      expect(s.todayDay, 1);
    });
  });

  group('the grid starts on a Sunday, as v6 draws it', () {
    test('September 2026 begins on a Tuesday — two blanks', () {
      // v6's FIRST_DOW for the same month.
      expect(shape(september).leadingBlanks, 2);
    });

    test('a month beginning on a Sunday has none', () {
      expect(shape(const YearMonth(2026, 11)).leadingBlanks, 0);
      expect(DateTime(2026, 11, 1).weekday, DateTime.sunday);
    });

    test('a month beginning on a Saturday has six', () {
      expect(shape(const YearMonth(2026, 8)).leadingBlanks, 6);
      expect(DateTime(2026, 8, 1).weekday, DateTime.saturday);
    });
  });

  group('counts', () {
    test('a day with nothing written has no row and counts zero', () {
      final MonthShape s = shape(september, <DaySummary>[day(20260905, 3)]);
      expect(s.countOf(5), 3);
      expect(s.countOf(6), 0);
    });

    test('a row outside the month is ignored, not drawn on a wrong tile', () {
      final MonthShape s = shape(september, <DaySummary>[
        day(20260831, 2),
        day(20260905, 1),
        day(20261005, 4),
      ]);
      expect(s.total, 1);
      expect(s.daysWritten, 1);
      expect(s.countOf(31), 0);
      expect(s.countOf(5), 1);
    });

    test('a tap on a tile selects that day as the row stores it', () {
      expect(shape(september).localDayOf(5), 20260905);
      expect(shape(const YearMonth(2025, 12)).localDayOf(31), 20251231);
    });
  });

  group('density is four steps, and the numeral never flips', () {
    test('one, two, three, four or more', () {
      expect(MonthShape.densityStep(0), 0);
      expect(MonthShape.densityStep(1), 1);
      expect(MonthShape.densityStep(2), 2);
      expect(MonthShape.densityStep(3), 3);
      expect(MonthShape.densityStep(4), 4);
      expect(MonthShape.densityStep(5), 4);
      expect(MonthShape.densityStep(40), 4);
    });

    test('there are exactly four', () {
      expect(MonthShape.steps, 4);
    });
  });

  group('the summary', () {
    test('22 chits over eleven days', () {
      final MonthShape s = shape(september, <DaySummary>[
        for (int d = 1; d <= 11; d++) day(20260900 + d, 2),
      ]);
      expect(s.summary, ('22 chits', ' over eleven days'));
    });

    test('one chit on one day is singular twice', () {
      final MonthShape s = shape(september, <DaySummary>[day(20260905, 1)]);
      expect(s.summary, ('1 chit', ' over one day'));
    });

    test('three chits on one day', () {
      final MonthShape s = shape(september, <DaySummary>[day(20260905, 3)]);
      expect(s.summary, ('3 chits', ' over one day'));
    });

    test('an empty month says so', () {
      expect(shape(september).summary, ('Nothing written', ' this month'));
    });

    test('the seeded September reads as TASKS.md group F expects', () {
      // Yesterday and the day before at five, a three, a two, and two
      // singles — DATA-MODEL.md §7.
      final MonthShape s = shape(september, <DaySummary>[
        day(20260916, 5),
        day(20260915, 5),
        day(20260913, 1),
        day(20260911, 2),
        day(20260908, 1),
        day(20260905, 3),
      ]);
      expect(s.summary, ('17 chits', ' over six days'));
    });

    test('counts in words run to thirty-one and then give up honestly', () {
      expect(MonthShape.countInWords(1), 'one');
      expect(MonthShape.countInWords(21), 'twenty-one');
      expect(MonthShape.countInWords(31), 'thirty-one');
      expect(MonthShape.countInWords(32), '32');
    });
  });

  group('the archive labels a day', () {
    const int todayDay = 20260917;

    ArchiveDay on(int localDay) =>
        ArchiveDay(localDay: localDay, chits: const []);

    test('Today and Yesterday by name', () {
      expect(on(20260917).label(today: todayDay), 'Today');
      expect(on(20260916).label(today: todayDay), 'Yesterday');
    });

    test('Yesterday across a month boundary', () {
      expect(on(20260831).label(today: 20260901), 'Yesterday');
    });

    test('then the weekday and the date, in the voice of the date line', () {
      expect(on(20260911).label(today: todayDay), 'Friday 11 September');
      expect(on(20260915).label(today: todayDay), 'Tuesday 15 September');
    });

    test('with the year only when it is not this one', () {
      expect(on(20251231).label(today: todayDay), 'Wednesday 31 December 2025');
    });
  });

  group('grouping by day', () {
    Chit chit(String id, DateTime at) => Chit(
      id: id,
      createdAt: at,
      localDay: Chit.localDayOf(at),
      updatedAt: at,
      text: id,
      textOrigin: TextOrigin.typed,
    );

    test('keeps the order it was given and splits on the day', () {
      final Chit a = chit('a', DateTime(2026, 9, 16, 21));
      final Chit b = chit('b', DateTime(2026, 9, 16, 9));
      final Chit c = chit('c', DateTime(2026, 9, 15, 23));
      final Chit d = chit('d', DateTime(2026, 9, 11, 8));

      expect(groupByDay(<Chit>[a, b, c, d]), <ArchiveDay>[
        ArchiveDay(localDay: 20260916, chits: <Chit>[a, b]),
        ArchiveDay(localDay: 20260915, chits: <Chit>[c]),
        ArchiveDay(localDay: 20260911, chits: <Chit>[d]),
      ]);
    });

    test('nothing groups into nothing', () {
      expect(groupByDay(const <Chit>[]), isEmpty);
    });
  });

  test('Chit.dateOf is the inverse of Chit.localDayOf', () {
    for (final DateTime when in <DateTime>[
      DateTime(2026, 9, 17, 15, 42),
      DateTime(2026, 1, 1),
      DateTime(2025, 12, 31, 23, 59),
      DateTime(2028, 2, 29, 12),
    ]) {
      expect(Chit.dateOf(Chit.localDayOf(when)), Chit.startOfLocalDay(when));
    }
  });
}
