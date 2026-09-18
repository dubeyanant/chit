import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/day_summary.dart';
import '../../../domain/repositories/chit_repository.dart';
import '../../today/application/today_controller.dart';

part 'month_provider.g.dart';

@immutable
final class YearMonth {
  const YearMonth(this.year, this.month)
    : assert(month >= 1 && month <= 12, 'a month is 1 to 12');

  factory YearMonth.of(DateTime when) => YearMonth(when.year, when.month);

  factory YearMonth.fromCode(int code) => YearMonth(code ~/ 100, code % 100);

  final int year;

  final int month;

  YearMonth get previous =>
      month == 1 ? YearMonth(year - 1, 12) : YearMonth(year, month - 1);

  YearMonth get next =>
      month == 12 ? YearMonth(year + 1, 1) : YearMonth(year, month + 1);

  int get daysInMonth => DateTime(year, month + 1, 0).day;

  int get firstDay => year * 10000 + month * 100 + 1;

  int get lastDay => year * 10000 + month * 100 + daysInMonth;

  bool contains(int localDay) => localDay >= firstDay && localDay <= lastDay;

  bool isBefore(YearMonth other) =>
      year < other.year || (year == other.year && month < other.month);

  int get code => year * 100 + month;

  YearMonth? previousWrittenIn(Iterable<int> written) {
    int? best;
    for (final int candidate in written) {
      if (candidate < code && (best == null || candidate > best)) {
        best = candidate;
      }
    }
    return best == null ? null : YearMonth.fromCode(best);
  }

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

  String get name => DateFormat('MMMM').format(DateTime(year, month));

  @override
  bool operator ==(Object other) =>
      other is YearMonth && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() => 'YearMonth($year-${month.toString().padLeft(2, '0')})';
}

@immutable
final class MonthShape {
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

  final YearMonth month;

  final int? todayDay;

  final int lastDrawnDay;

  final Map<int, int> _counts;

  static const int steps = 4;

  bool get isCurrentMonth => todayDay != null;

  int get leadingBlanks => DateTime(month.year, month.month, 1).weekday % 7;

  static const int columns = 7;

  List<List<int?>> get rows {
    int rowOf(int day) => (leadingBlanks + day - 1) ~/ columns;

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

  int countOf(int day) => _counts[day] ?? 0;

  int localDayOf(int day) => month.year * 10000 + month.month * 100 + day;

  int get total => _counts.values.fold(0, (int sum, int n) => sum + n);

  int get daysWritten => _counts.length;

  static int densityStep(int count) => count <= 0 ? 0 : count.clamp(1, steps);

  (String strong, String rest) get summary {
    if (total == 0) return ('Nothing written', ' this month');

    final String chits = total == 1 ? '1 chit' : '$total chits';
    final String days = daysWritten == 1
        ? 'one day'
        : '${countInWords(daysWritten)} days';
    return (chits, ' over $days');
  }

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

@riverpod
Stream<List<int>> writtenMonths(Ref ref) =>
    ref.watch(chitRepositoryProvider).watchWrittenMonths();

typedef MonthNeighbours = ({YearMonth? previous, YearMonth? next});

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

@riverpod
class VisibleMonth extends _$VisibleMonth {
  @override
  YearMonth build() => YearMonth.of(ref.watch(todayProvider));

  void previous() {
    final YearMonth? target = state.previousWrittenIn(_written);
    if (target != null) state = target;
  }

  void next() {
    final YearMonth? target = state.nextWrittenIn(
      _written,
      current: YearMonth.of(ref.read(todayProvider)),
    );
    if (target != null) state = target;
  }

  List<int> get _written => ref.read(writtenMonthsProvider).value ?? const [];
}

@riverpod
Stream<List<DaySummary>> monthSummaries(Ref ref) {
  final YearMonth month = ref.watch(visibleMonthProvider);
  return ref
      .watch(chitRepositoryProvider)
      .watchDaySummaries(fromDay: month.firstDay, toDay: month.lastDay);
}

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
