import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/day_summary.dart';
import '../../../domain/repositories/chit_repository.dart';
import '../../today/application/today_controller.dart';

part 'month_provider.g.dart';

/// A year and a month, and nothing else — which month the calendar is showing.
///
/// Plain rather than a `DateTime` at the first of the month, because a
/// `DateTime` carries a time zone and a time of day and neither is a property
/// of a month. Everything the grid asks about one — where it starts, how long
/// it is, what its bounds are as `yyyymmdd` — is answered here.
@immutable
final class YearMonth {
  /// The month numbered [month] of [year].
  const YearMonth(this.year, this.month)
    : assert(month >= 1 && month <= 12, 'a month is 1 to 12');

  /// The month [when] falls in.
  factory YearMonth.of(DateTime when) => YearMonth(when.year, when.month);

  /// The month a `yyyymm` names.
  factory YearMonth.fromCode(int code) => YearMonth(code ~/ 100, code % 100);

  /// Four digits.
  final int year;

  /// One to twelve.
  final int month;

  /// The month before, across a year boundary if it comes to that.
  YearMonth get previous =>
      month == 1 ? YearMonth(year - 1, 12) : YearMonth(year, month - 1);

  /// The month after.
  YearMonth get next =>
      month == 12 ? YearMonth(year + 1, 1) : YearMonth(year, month + 1);

  /// Twenty-eight to thirty-one. Day zero of the next month is the last day
  /// of this one, which is the one place `DateTime` does the calendar for us.
  int get daysInMonth => DateTime(year, month + 1, 0).day;

  /// The first of the month as `yyyymmdd` — the low bound of the query.
  int get firstDay => year * 10000 + month * 100 + 1;

  /// The last of the month as `yyyymmdd` — the high bound of the query.
  int get lastDay => year * 10000 + month * 100 + daysInMonth;

  /// Whether [localDay] falls inside this month.
  bool contains(int localDay) => localDay >= firstDay && localDay <= lastDay;

  /// Whether this month ends before [other] begins.
  bool isBefore(YearMonth other) =>
      year < other.year || (year == other.year && month < other.month);

  /// This month as `yyyymm` — the form `watchWrittenMonths` answers in.
  int get code => year * 100 + month;

  /// The nearest month before this one with something written in it, or null
  /// when there is none — where the previous chevron goes (ADR-047).
  ///
  /// [written] is every written month as `yyyymm`, in any order.
  YearMonth? previousWrittenIn(Iterable<int> written) {
    int? best;
    for (final int candidate in written) {
      if (candidate < code && (best == null || candidate > best)) {
        best = candidate;
      }
    }
    return best == null ? null : YearMonth.fromCode(best);
  }

  /// The nearest month after this one worth landing on, or null when this is
  /// [current] — where the next chevron goes (ADR-047).
  ///
  /// The current month always counts as written, whatever it holds: it is
  /// where the next chit goes, and the way back to it must not depend on
  /// whether one has been written yet today.
  YearMonth? nextWrittenIn(
    Iterable<int> written, {
    required YearMonth current,
  }) {
    if (!isBefore(current)) return null;

    int best = current.code;
    for (final int candidate in written) {
      if (candidate > code && candidate < best) best = candidate;
    }
    return YearMonth.fromCode(best);
  }

  /// *September*, on its own. The year is drawn beside it in a quieter ink,
  /// so the two are separate strings rather than one.
  String get name => DateFormat('MMMM').format(DateTime(year, month));

  @override
  bool operator ==(Object other) =>
      other is YearMonth && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() => 'YearMonth($year-${month.toString().padLeft(2, '0')})';
}

/// One month as the grid draws it — BEHAVIOUR.md §4.2.
///
/// Everything about a month that a test can hold without a widget, which is
/// ADR-031 applied where it bites. The grid is left with layout and taps and
/// nothing to be wrong about: where the first tile sits, how many tiles there
/// are, which one is today, what each carries and how dark it is are all
/// answered here from a list of [DaySummary] rows and one reading of the day.
///
/// **The current month is drawn up to today and stops.** A month drawn to its
/// end is a fortnight of empty tiles standing for days that have not happened,
/// which reads as a fortnight of days with nothing written in them. A past
/// month draws in full, and a future one draws nothing — the calendar never
/// navigates there, and this is the arithmetic saying so as well.
@immutable
final class MonthShape {
  /// The shape of [month] on the day [today], given the [summaries] the
  /// repository returned for it.
  ///
  /// A summary outside the month is ignored rather than trusted: the query is
  /// bounded already, and a row that somehow was not should not put a number
  /// on a tile that has no day.
  MonthShape({
    required this.month,
    required DateTime today,
    required List<DaySummary> summaries,
  }) : todayDay = YearMonth.of(today) == month ? today.day : null,
       lastDrawnDay = _lastDrawnDay(month, today),
       _counts = <int, int>{
         for (final DaySummary summary in summaries)
           if (month.contains(summary.localDay))
             summary.localDay % 100: summary.count,
       };

  /// Which month this is.
  final YearMonth month;

  /// Today's day of the month, or null when today is not in this month.
  ///
  /// Today always keeps its number and is ringed whatever it holds, so the
  /// grid needs to know which tile it is even when the count is zero.
  final int? todayDay;

  /// The last day of the month that gets a tile: today's for the current
  /// month, the month's own last day for a past one, and zero for a month
  /// that has not started.
  final int lastDrawnDay;

  final Map<int, int> _counts;

  /// The four density steps, faintest first. **The numeral never changes
  /// colour** across them — ADR-022 is what made that possible.
  static const int steps = 4;

  /// Whether this is the month today falls in — the one the calendar opens
  /// on, and the one the next chevron cannot go past.
  bool get isCurrentMonth => todayDay != null;

  /// How many empty cells precede the first, **Sunday first** as v6 draws it.
  ///
  /// `DateTime.weekday` runs Monday 1 to Sunday 7, so modulo seven turns
  /// Sunday into 0 and leaves the rest a day along.
  int get leadingBlanks => DateTime(month.year, month.month, 1).weekday % 7;

  /// Seven cells across.
  static const int columns = 7;

  /// The rows the grid draws, each seven cells of a day number or null —
  /// **only the weeks with something in them** (ADR-048).
  ///
  /// A week counts as having something in it when a day of it was written
  /// in, or is today. Every other week is left out, wherever it falls in the
  /// month. *For one commit a quiet week between two written ones was kept
  /// and read as quiet* (ADR-047), and the second seeded pass, looking at an
  /// August with a bare row across its middle, asked for it to go. Within a
  /// drawn row, every day of the month up to [lastDrawnDay] has a cell,
  /// numbered or bare, so a tile's column still says its weekday.
  ///
  /// Empty for a month with nothing in it and no today, which the chevrons
  /// never land on.
  List<List<int?>> get rows {
    int rowOf(int day) => (leadingBlanks + day - 1) ~/ columns;

    // A set literal keeps insertion order, and the days ascend, so the rows
    // come out in order without a sort.
    final Set<int> drawn = <int>{
      for (int day = 1; day <= lastDrawnDay; day++)
        if (countOf(day) > 0 || day == todayDay) rowOf(day),
    };

    return <List<int?>>[
      for (final int row in drawn)
        <int?>[
          for (int col = 0; col < columns; col++)
            switch (row * columns + col - leadingBlanks + 1) {
              final int day when day >= 1 && day <= lastDrawnDay => day,
              _ => null,
            },
        ],
    ];
  }

  /// How many chits [day] holds. Zero for a day with nothing written, which
  /// is how a tile knows to carry no number.
  int countOf(int day) => _counts[day] ?? 0;

  /// The `yyyymmdd` of [day] in this month — what a tap on it selects.
  int localDayOf(int day) => month.year * 10000 + month.month * 100 + day;

  /// Every chit in the month.
  int get total => _counts.values.fold(0, (int sum, int n) => sum + n);

  /// How many days have something written in them.
  int get daysWritten => _counts.length;

  /// Which of the four steps a day with [count] chits is drawn at, one to
  /// four — or zero for a day with nothing, which is not a step but the
  /// absence of one.
  ///
  /// One chit, two, three, four or more: the scale of BEHAVIOUR.md §4.2. It
  /// is here rather than in the query because it is a design scale, not a
  /// fact about the data (DATA-MODEL.md §4).
  static int densityStep(int count) => count <= 0 ? 0 : count.clamp(1, steps);

  /// The month summary in two halves — *22 chits* and *over eleven days* —
  /// because the first is set upright and strong and the rest italic.
  ///
  /// An empty month reads *Nothing written this month*, split the same way.
  (String strong, String rest) get summary {
    if (total == 0) return ('Nothing written', ' this month');

    final String chits = total == 1 ? '1 chit' : '$total chits';
    final String days = daysWritten == 1
        ? 'one day'
        : '${countInWords(daysWritten)} days';
    return (chits, ' over $days');
  }

  /// *eleven*, for a count of days. Anything past thirty-one — which one
  /// month cannot produce — falls back to digits rather than to a wrong word.
  static String countInWords(int n) =>
      n >= 0 && n < _words.length ? _words[n] : '$n';

  static const List<String> _words = <String>[
    'no',
    'one',
    'two',
    'three',
    'four',
    'five',
    'six',
    'seven',
    'eight',
    'nine',
    'ten',
    'eleven',
    'twelve',
    'thirteen',
    'fourteen',
    'fifteen',
    'sixteen',
    'seventeen',
    'eighteen',
    'nineteen',
    'twenty',
    'twenty-one',
    'twenty-two',
    'twenty-three',
    'twenty-four',
    'twenty-five',
    'twenty-six',
    'twenty-seven',
    'twenty-eight',
    'twenty-nine',
    'thirty',
    'thirty-one',
  ];

  static int _lastDrawnDay(YearMonth month, DateTime today) {
    final YearMonth current = YearMonth.of(today);
    if (month == current) return today.day;
    if (month.isBefore(current)) return month.daysInMonth;
    return 0;
  }

  @override
  bool operator ==(Object other) =>
      other is MonthShape &&
      other.month == month &&
      other.todayDay == todayDay &&
      other.lastDrawnDay == lastDrawnDay &&
      mapEquals(other._counts, _counts);

  @override
  int get hashCode => Object.hash(
    month,
    todayDay,
    lastDrawnDay,
    Object.hashAllUnordered(
      _counts.entries.map((MapEntry<int, int> e) => (e.key, e.value)),
    ),
  );

  @override
  String toString() =>
      'MonthShape($month, today: $todayDay, drawn to $lastDrawnDay, $_counts)';
}

/// Every month with a chit in it, as `yyyymm`, oldest first — what the
/// chevrons step through (ADR-047).
@riverpod
Stream<List<int>> writtenMonths(Ref ref) =>
    ref.watch(chitRepositoryProvider).watchWrittenMonths();

/// Where the chevrons go from the visible month: the nearest written month
/// either side, or null where there is none — and then no chevron is drawn.
///
/// The current month is always a destination whatever it holds, because it is
/// where the next chit goes. Null on both sides until the query has answered,
/// which draws no chevrons for a frame rather than two that go nowhere.
typedef MonthNeighbours = ({YearMonth? previous, YearMonth? next});

/// The two chevrons' destinations for the visible month.
@riverpod
MonthNeighbours monthNeighbours(Ref ref) {
  final YearMonth month = ref.watch(visibleMonthProvider);
  final YearMonth current = YearMonth.of(ref.watch(todayProvider));
  final List<int>? written = ref.watch(writtenMonthsProvider).value;
  if (written == null) return (previous: null, next: null);

  return (
    previous: month.previousWrittenIn(written),
    next: month.nextWrittenIn(written, current: current),
  );
}

/// Which month the calendar is showing, and the two chevrons.
///
/// It opens on the month today falls in, and **re-reads that at midnight**
/// with everything else — off [todayProvider], so on the first of a month a
/// phone left open rolls the calendar over with the date line (ADR-033).
/// That also returns a reader who had gone back a few months to the current
/// one, which is what they would want on a new day anyway.
///
/// **A chevron only ever lands on a month with something in it** — ADR-047.
/// [previous] goes to the nearest written month before this one and [next] to
/// the nearest after, or back to the current month, which counts whatever it
/// holds. Neither does anything when there is nowhere to go; the bar draws no
/// chevron for that side, so a month nobody can write in is never shown.
/// *They stepped one calendar month at a time for one commit*, and the first
/// device pass found an empty August with a dead chevron beside it.
@riverpod
class VisibleMonth extends _$VisibleMonth {
  @override
  YearMonth build() => YearMonth.of(ref.watch(todayProvider));

  // Both read the written months directly rather than [monthNeighboursProvider],
  // which watches this notifier: a read from here back into it is a cycle,
  // and Riverpod says so. The arithmetic is on YearMonth either way.

  /// The nearest earlier month with something in it, if there is one.
  void previous() {
    final YearMonth? target = state.previousWrittenIn(_written);
    if (target != null) state = target;
  }

  /// The nearest later month with something in it, or the current month.
  void next() {
    final YearMonth? target = state.nextWrittenIn(
      _written,
      current: YearMonth.of(ref.read(todayProvider)),
    );
    if (target != null) state = target;
  }

  /// Nothing until the query has answered, which makes both moves no-ops.
  List<int> get _written => ref.read(writtenMonthsProvider).value ?? const [];
}

/// How many chits each day of the visible month holds — one query for the
/// grid's density and the summary under it (DATA-MODEL.md §4).
///
/// A stream, so a save on Today reaches the tile and the total without either
/// being told: both are readings of this, and this re-emits on the write.
/// That is the milestone's statement of done and it is true by construction
/// rather than by anything keeping the two tabs in step.
@riverpod
Stream<List<DaySummary>> monthSummaries(Ref ref) {
  final YearMonth month = ref.watch(visibleMonthProvider);
  return ref
      .watch(chitRepositoryProvider)
      .watchDaySummaries(fromDay: month.firstDay, toDay: month.lastDay);
}

/// The month the grid draws: the visible month once its query has answered,
/// and **the last month that answered until then** — ADR-049. Null only
/// before the first answer.
///
/// Null rather than an empty shape at first, for the reason Today's thread
/// waits for its first frame: an empty month drawn while the real one is in
/// flight is *Nothing written this month* said about a month that was written
/// in, which is a wrong answer rather than a slow one.
///
/// **And the last answer rather than null after that.** *For one commit this
/// went back to null on every change of month*, and the handset saw it as a
/// flicker: the bar, the grid and the summary vanished for the frames the
/// query took and came back, and the archive under them jumped up and down
/// with them. The month that was true a moment ago, under its own name, is a
/// slow answer; a blank is a wrong one. The bar takes its name from this and
/// not from [visibleMonthProvider], so the name and the grid change together.
@riverpod
class DrawnMonth extends _$DrawnMonth {
  @override
  MonthShape? build() {
    final List<DaySummary>? summaries = switch (ref.watch(
      monthSummariesProvider,
    )) {
      AsyncData<List<DaySummary>>(:final List<DaySummary> value) => value,
      _ => null,
    };
    if (summaries == null) return stateOrNull;

    return MonthShape(
      month: ref.watch(visibleMonthProvider),
      today: ref.watch(todayProvider),
      summaries: summaries,
    );
  }
}
