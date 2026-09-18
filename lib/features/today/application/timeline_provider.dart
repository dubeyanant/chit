import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/clock.dart';
import '../../../domain/models/chit.dart';
import '../../../domain/repositories/chit_repository.dart';
import 'today_controller.dart';

part 'timeline_provider.g.dart';

@immutable
final class TimelineWindow {
  const TimelineWindow._({
    required this.start,
    required this.end,
    required this.dayCount,
  });

  factory TimelineWindow.around(DateTime now) => TimelineWindow._(
    start: Chit.startOfLocalDay(now, offsetDays: -(maxDays - 1)),
    end: Chit.startOfLocalDay(now, offsetDays: 1),
    dayCount: maxDays,
  );

  static const int maxDays = 3;

  final DateTime start;

  final DateTime end;

  final int dayCount;

  TimelineWindow trimmedTo(DateTime? earliest) {
    final DateTime today = Chit.startOfLocalDay(end, offsetDays: -1);

    final DateTime from = switch (earliest) {
      null => today,

      final DateTime oldest when oldest.isBefore(start) => start,
      final DateTime oldest => Chit.startOfLocalDay(oldest),
    };

    if (from == start) return this;

    int days = 1;
    for (
      DateTime day = Chit.startOfLocalDay(from, offsetDays: 1);
      day.isBefore(end);
      day = Chit.startOfLocalDay(day, offsetDays: 1)
    ) {
      days++;
    }

    return TimelineWindow._(start: from, end: end, dayCount: days);
  }

  int get fromDay => Chit.localDayOf(start);

  int get toDay =>
      Chit.localDayOf(end.subtract(const Duration(microseconds: 1)));

  Duration get span => end.difference(start);

  double? fractionOf(DateTime instant) {
    if (instant.isBefore(start) || !instant.isBefore(end)) return null;
    return instant.difference(start).inMicroseconds / span.inMicroseconds;
  }

  List<DateTime> get dayBoundaries => <DateTime>[
    for (int day = 1; day < dayCount; day++)
      Chit.startOfLocalDay(start, offsetDays: day),
  ];

  int dayAt(double fraction) {
    final DateTime at = start.add(
      Duration(microseconds: (span.inMicroseconds * fraction).round()),
    );

    int day = 0;
    for (
      DateTime edge = Chit.startOfLocalDay(start, offsetDays: 1);
      !edge.isAfter(at) && edge.isBefore(end);
      edge = Chit.startOfLocalDay(edge, offsetDays: 1)
    ) {
      day++;
    }
    return day;
  }

  @override
  bool operator ==(Object other) =>
      other is TimelineWindow && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'TimelineWindow($start → $end, $dayCount days)';
}

@riverpod
TimelineWindow timelineQueryWindow(Ref ref) =>
    TimelineWindow.around(ref.watch(todayProvider));

@riverpod
DateTime timelineNow(Ref ref) {
  ref.watch(todayProvider);
  ref.watch(timelineChitsProvider);
  return ref.watch(clockProvider).now();
}

@riverpod
Stream<List<Chit>> timelineChits(Ref ref) {
  final TimelineWindow window = ref.watch(timelineQueryWindowProvider);
  return ref
      .watch(chitRepositoryProvider)
      .watchDayRange(fromDay: window.fromDay, toDay: window.toDay);
}

@riverpod
TimelineWindow timelineWindow(Ref ref) {
  final TimelineWindow query = ref.watch(timelineQueryWindowProvider);

  final DateTime? earliest = switch (ref.watch(timelineChitsProvider)) {
    AsyncData<List<Chit>>(value: [final Chit oldest, ...]) => oldest.createdAt,
    _ => null,
  };

  return query.trimmedTo(earliest);
}
