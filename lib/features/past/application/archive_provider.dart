import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/chit.dart';
import '../../../domain/repositories/chit_repository.dart';
import '../../../shared/day_group.dart';
import 'month_provider.dart';

part 'archive_provider.g.dart';

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
  List<DayGroup>? build() => switch (ref.watch(archiveChitsProvider)) {
    AsyncData<List<Chit>>(:final List<Chit> value) => groupByDay(value),
    _ => stateOrNull,
  };
}
