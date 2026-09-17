import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/chit.dart';
import '../../../domain/repositories/chit_repository.dart';
import 'month_provider.dart';

part 'archive_provider.g.dart';

/// One day of the archive: its `yyyymmdd` and its chits, newest first.
@immutable
final class ArchiveDay {
  /// The chits of [localDay].
  const ArchiveDay({required this.localDay, required this.chits});

  /// Which day, as the row stores it (ADR-006).
  final int localDay;

  /// Newest first — the order the repository hands them over in, and the
  /// order the thread draws.
  final List<Chit> chits;

  /// *Today*, *Yesterday*, then *Friday 11 September* — with the year only
  /// when it is not the one [today] is in, because a journal is read close
  /// to when it was written and a year on every heading would be the app
  /// counting for the reader.
  String label({required int today}) {
    if (localDay == today) return 'Today';

    final DateTime date = Chit.dateOf(localDay);
    final DateTime now = Chit.dateOf(today);
    if (date == Chit.startOfLocalDay(now, offsetDays: -1)) return 'Yesterday';

    final String dayAndMonth = DateFormat('EEEE d MMMM').format(date);
    return date.year == now.year ? dayAndMonth : '$dayAndMonth ${date.year}';
  }

  @override
  bool operator ==(Object other) =>
      other is ArchiveDay &&
      other.localDay == localDay &&
      listEquals(other.chits, chits);

  @override
  int get hashCode => Object.hash(localDay, Object.hashAll(chits));

  @override
  String toString() => 'ArchiveDay($localDay, ${chits.length} chits)';
}

/// [chits] grouped by the day they were written, in the order they arrived.
///
/// The repository returns the archive newest day first and newest chit first
/// within it (DATA-MODEL.md §4), so the groups come out in that order too.
/// Nothing is sorted here: sorting twice is how two orders disagree.
List<ArchiveDay> groupByDay(List<Chit> chits) {
  final List<ArchiveDay> days = <ArchiveDay>[];
  int? current;
  List<Chit> bucket = <Chit>[];

  for (final Chit chit in chits) {
    if (chit.localDay != current) {
      if (current != null) {
        days.add(ArchiveDay(localDay: current, chits: bucket));
      }
      current = chit.localDay;
      bucket = <Chit>[];
    }
    bucket.add(chit);
  }
  if (current != null) days.add(ArchiveDay(localDay: current, chits: bucket));

  return days;
}

/// The day the archive is filtered to, or null for every day.
///
/// Tapping a tile selects it and tapping it again clears it — BEHAVIOUR.md
/// §4.2. **It resets when the month changes**, by watching the month rather
/// than by anybody remembering to clear it: a selection is a tile on the grid
/// being shown, and once that grid is another month's there is no tile for it
/// to be.
@riverpod
class SelectedDay extends _$SelectedDay {
  @override
  int? build() {
    ref.watch(visibleMonthProvider);
    return null;
  }

  /// Selects [localDay], or clears the selection if it already was.
  void toggle(int localDay) => state = state == localDay ? null : localDay;

  /// **Show every day.**
  void clear() => state = null;
}

/// How many pages of the archive have been asked for.
///
/// The archive is paged (DATA-MODEL.md §4) and this is the only state paging
/// needs: the screen asks for one more as the reader nears the end, and the
/// query widens. It never narrows again while the tab is open, which is what
/// a reader scrolling back up expects.
@riverpod
class ArchivePages extends _$ArchivePages {
  /// Chits per page. Forty is a couple of weeks of ordinary use, and the
  /// query is cheap enough that the number is about how far a reader has to
  /// scroll before the next one is asked for, not about load.
  static const int pageSize = 40;

  @override
  int build() => 1;

  /// One more page.
  void more() => state = state + 1;
}

/// How many chits the archive is currently asking for.
@riverpod
int archiveLimit(Ref ref) =>
    ArchivePages.pageSize * ref.watch(archivePagesProvider);

/// The archive's chits: every day, paged — or one day, when one is selected.
///
/// Two queries behind one reading, and the selection decides which. A
/// filtered archive is `watchDay`, the same query Today's thread runs, because
/// *one day's chits, newest first* is one question however it was asked.
@riverpod
Stream<List<Chit>> archiveChits(Ref ref) {
  final ChitRepository repo = ref.watch(chitRepositoryProvider);
  final int? selected = ref.watch(selectedDayProvider);

  if (selected != null) return repo.watchDay(selected);
  return repo.watchArchive(limit: ref.watch(archiveLimitProvider));
}

/// The archive grouped into days, newest first — null until the query has
/// first answered, and after that **the last answer, held while the next is
/// in flight** (ADR-049), for the reasons [drawnMonthProvider] gives.
///
/// Three things swap the query under this — selecting a tile, clearing it,
/// and changing the month, which clears it — and each of them blanked the
/// archive for the frames the new query took until the hold was added.
@riverpod
class ArchiveDays extends _$ArchiveDays {
  @override
  List<ArchiveDay>? build() => switch (ref.watch(archiveChitsProvider)) {
    AsyncData<List<Chit>>(:final List<Chit> value) => groupByDay(value),
    _ => stateOrNull,
  };
}
