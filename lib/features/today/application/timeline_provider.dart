import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/clock.dart';
import '../../../domain/models/chit.dart';
import '../../../domain/repositories/chit_repository.dart';
import 'today_controller.dart';

part 'timeline_provider.g.dart';

/// Where each chit falls on the timeline's three-day window (ADR-024).
///
/// Midnight to midnight, today and the two days before it, proportional to
/// real time. *This file was `day_arc_provider.dart` and the strip was the day
/// arc, running 5am to midnight over one day; ADR-024 says why it is not.*
///
/// Everything a position depends on is in [TimelineWindow], which is a plain
/// value with no Flutter and no Riverpod in it. That is deliberate and it is
/// ADR-031 applied at the point it bites: the arithmetic here is the only part
/// of the timeline a test can hold, so it is kept where a test can reach it
/// without building anything.
@immutable
final class TimelineWindow {
  const TimelineWindow._({
    required this.start,
    required this.end,
    required this.dayCount,
  });

  /// The widest window as of [now] — the local day [now] falls in, and the two
  /// before it.
  ///
  /// This is what the **query** asks for. What is **drawn** may be narrower:
  /// see [trimmedTo].
  ///
  /// Both ends come from [Chit.startOfLocalDay], so they are **whole local
  /// days** rather than multiples of 24 hours. A window built by subtracting
  /// `Duration(days: 2)` would start at 23:00 or 01:00 of the right day across
  /// a daylight saving change, and every position in it would be an hour out.
  factory TimelineWindow.around(DateTime now) => TimelineWindow._(
    start: Chit.startOfLocalDay(now, offsetDays: -(maxDays - 1)),
    end: Chit.startOfLocalDay(now, offsetDays: 1),
    dayCount: maxDays,
  );

  /// The most days the window ever spans. Three — ADR-024.
  ///
  /// *The smallest window in which "yesterday was quiet and today is not" is
  /// visible at a glance, and the largest that still reads as one glance.* It
  /// is a constant rather than a setting because a different number is a
  /// different decision, and that means a new record.
  static const int maxDays = 3;

  /// Midnight at the start of the window's first day.
  final DateTime start;

  /// Midnight at the **end** of the window's last day, which is the next local
  /// midnight from now. Exclusive: an instant exactly here is tomorrow.
  final DateTime end;

  /// How many whole local days the window spans — one, two or [maxDays].
  ///
  /// Counted rather than divided, because a daylight saving change makes one
  /// of those days 23 or 25 hours long and `end.difference(start).inDays`
  /// would answer 2 for a three-day window.
  final int dayCount;

  /// This window with **leading empty days dropped** — ADR-035.
  ///
  /// [earliest] is the oldest chit in the window, or null when there are none.
  /// The result begins at the start of that chit's day; with no chits at all it
  /// is today alone. It can only ever narrow: a chit older than [start] is not
  /// in this window and does not widen it.
  ///
  /// Only the **leading** days go. A quiet day between two days that have
  /// something is still drawn, and still reads as quiet — which is the half of
  /// ADR-024's argument this keeps.
  TimelineWindow trimmedTo(DateTime? earliest) {
    final DateTime today = Chit.startOfLocalDay(end, offsetDays: -1);

    final DateTime from = switch (earliest) {
      null => today,
      // A chit older than this window is not in it, and does not widen it.
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

  /// The window's first day, as `yyyymmdd` — the low bound of the query.
  int get fromDay => Chit.localDayOf(start);

  /// The window's last day, as `yyyymmdd` — the high bound of the query.
  ///
  /// Taken from just inside [end] rather than from [end] itself, which is
  /// already tomorrow.
  int get toDay =>
      Chit.localDayOf(end.subtract(const Duration(microseconds: 1)));

  /// How long the window actually is.
  ///
  /// A daylight saving change makes one of its days 23 or 25 hours long.
  /// Positions are measured against this rather than against a nominal 24 per
  /// day, so a short day takes up proportionally less of the strip — which is
  /// what *proportional to real time* means.
  Duration get span => end.difference(start);

  /// Where [instant] falls across the window, from 0.0 at [start] to 1.0 at
  /// [end] — or **null when it falls outside**.
  ///
  /// Null rather than a clamp, and that is the whole point of ADR-024. The day
  /// arc clamped, so a chit written at 00:20 and one written at 5:00 landed on
  /// the same pixel and the strip said something untrue about both. A mark
  /// that cannot be placed honestly is not drawn — which is ADR-007's rule
  /// about a signal that did not arrive, applied to one that does not fit.
  double? fractionOf(DateTime instant) {
    if (instant.isBefore(start) || !instant.isBefore(end)) return null;
    return instant.difference(start).inMicroseconds / span.inMicroseconds;
  }

  /// The midnights **inside** the window — where one day ends and the next
  /// begins. One fewer than [dayCount], and none at all on a one-day window.
  ///
  /// [start] and [end] are not here: they are the strip's own ends, and a mark
  /// on top of an end is a mark saying what the edge already says.
  /// BEHAVIOUR.md §4.1 draws each of these as a tick hanging below the line,
  /// unlabelled — *someone who sees two of them is looking at three days and
  /// will know it without being told.*
  List<DateTime> get dayBoundaries => <DateTime>[
    for (int day = 1; day < dayCount; day++)
      Chit.startOfLocalDay(start, offsetDays: day),
  ];

  /// Which day of the window [fraction] falls in, counting from 0 at [start].
  ///
  /// What the haptic on the strip is keyed to (ADR-034) — a scroll that crosses
  /// a boundary is a scroll whose answer here has changed.
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

/// The three days the timeline **asks the database for**.
///
/// Off [todayProvider] rather than off the clock, so the strip, the date line
/// above it and the thread below it are three readings of one instant. It
/// therefore slides on its own when the day does: `todayProvider` re-reads the
/// clock at midnight and everything derived from it follows (ADR-033).
///
/// This is always [TimelineWindow.maxDays] wide. What gets **drawn** is
/// [timelineWindowProvider], which can be narrower — and which cannot be the
/// query window, because it depends on the answer.
@riverpod
TimelineWindow timelineQueryWindow(Ref ref) =>
    TimelineWindow.around(ref.watch(todayProvider));

/// Where the tick at now is drawn — **re-read on every save** (ADR-066).
///
/// The strip is static by design (§4.1: nothing on it moves), and
/// [todayProvider] is read once per screen and again at midnight (ADR-033) —
/// so a chit saved twenty minutes after launch used to land *ahead* of the
/// tick at now, which then read as a mark in the future. This re-reads the
/// clock whenever the rows under the strip change, which is exactly when §4.1
/// says the strip may change: on a save, and on the day turning.
///
/// **A second clock read on the screen, and the one exception to
/// ARCHITECTURE.md §3's one-read rule.** It cannot disagree with the date line
/// about *which day* — the window it is drawn into still comes off
/// [todayProvider] — only about the minute, which is the point. At the instant
/// after midnight, before the rollover timer fires, it falls outside the window
/// and the tick is simply not drawn for those milliseconds.
@riverpod
DateTime timelineNow(Ref ref) {
  ref.watch(todayProvider);
  ref.watch(timelineChitsProvider);
  return ref.watch(clockProvider).now();
}

/// Every chit in the query window, oldest first — the timeline's marks.
///
/// A second stream over rows the thread already has for one of the three days.
/// ADR-024 lists that as a cost; what it is not is a second source of truth,
/// because both are streams off the same table and a save re-emits on both.
@riverpod
Stream<List<Chit>> timelineChits(Ref ref) {
  final TimelineWindow window = ref.watch(timelineQueryWindowProvider);
  return ref
      .watch(chitRepositoryProvider)
      .watchDayRange(fromDay: window.fromDay, toDay: window.toDay);
}

/// The window the strip actually draws — ADR-035.
///
/// The query window with its leading empty days dropped, so a strip never
/// opens on a stretch of days that were never written in. On a first run it is
/// today alone and does not scroll at all; it grows backwards as there is
/// something back there to grow into.
///
/// While the query is in flight there are no chits and this is today, which is
/// the narrowest honest answer — the same reading of ADR-007 the thread takes.
@riverpod
TimelineWindow timelineWindow(Ref ref) {
  final TimelineWindow query = ref.watch(timelineQueryWindowProvider);

  // Oldest first, so the first row is the earliest thing in the window.
  final DateTime? earliest = switch (ref.watch(timelineChitsProvider)) {
    AsyncData<List<Chit>>(value: [final Chit oldest, ...]) => oldest.createdAt,
    _ => null,
  };

  return query.trimmedTo(earliest);
}
