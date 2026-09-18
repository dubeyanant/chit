import 'package:flutter/foundation.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/chit.dart';
import '../../../domain/repositories/chit_repository.dart';
import '../../../shared/day_label.dart';
import 'month_provider.dart';

part 'archive_provider.g.dart';

@immutable
final class ArchiveDay {
  const ArchiveDay({required this.localDay, required this.chits});

  final int localDay;

  final List<Chit> chits;

  String label({required int today}) =>
      dayLabel(localDay: localDay, today: today);

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

@riverpod
class SelectedDay extends _$SelectedDay {
  @override
  int? build() {
    ref.watch(visibleMonthProvider);
    return null;
  }

  void toggle(int localDay) => state = state == localDay ? null : localDay;

  void clear() => state = null;
}

@riverpod
Stream<List<Chit>> archiveChits(Ref ref) {
  final ChitRepository repo = ref.watch(chitRepositoryProvider);
  final int? selected = ref.watch(selectedDayProvider);

  if (selected != null) return repo.watchDay(selected);

  final YearMonth month = ref.watch(visibleMonthProvider);
  return repo.watchArchive(fromDay: month.firstDay, toDay: month.lastDay);
}

@riverpod
class ArchiveDays extends _$ArchiveDays {
  @override
  List<ArchiveDay>? build() => switch (ref.watch(archiveChitsProvider)) {
    AsyncData<List<Chit>>(:final List<Chit> value) => groupByDay(value),
    _ => stateOrNull,
  };
}
