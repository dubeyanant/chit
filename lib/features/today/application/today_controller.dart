import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/clock.dart';
import '../../../domain/models/chit.dart';
import '../../../domain/repositories/chit_repository.dart';

part 'today_controller.g.dart';

@riverpod
DateTime today(Ref ref) {
  final DateTime now = ref.watch(clockProvider).now();

  final Timer rollover = Timer(
    Chit.startOfLocalDay(now, offsetDays: 1).difference(now),
    ref.invalidateSelf,
  );
  ref.onDispose(rollover.cancel);

  return now;
}

@riverpod
int todayLocalDay(Ref ref) => Chit.localDayOf(ref.watch(todayProvider));

@riverpod
Stream<List<Chit>> todayChits(Ref ref) => ref
    .watch(chitRepositoryProvider)
    .watchDay(ref.watch(todayLocalDayProvider));
