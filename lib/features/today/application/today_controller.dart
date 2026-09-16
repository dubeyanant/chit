import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/clock.dart';
import '../../../domain/models/chit.dart';
import '../../../domain/repositories/chit_repository.dart';

part 'today_controller.g.dart';

/// The moment Today is drawn for.
///
/// **The clock is read here and nowhere else on this screen.** The date line,
/// the timeline and the thread are three readings of one instant, so a
/// provider rather than a `clock.now()` in each: two reads a millisecond
/// apart are two different answers at midnight, and the screen would show one
/// day above a thread of another.
///
/// **And it re-reads itself at midnight.** Everything on Today is derived from
/// this — which day the thread asks for, which three days the timeline spans
/// (ADR-024), what the date line says — so one invalidation rolls the whole
/// screen over together. Without it a phone left on the table overnight shows
/// yesterday's date above yesterday's thread until something else happens to
/// rebuild it, and the first chit of the new day would land on a strip that
/// has no room for it.
///
/// The timer is a wall-clock wait and is therefore the one thing here a test
/// cannot drive. What a test can drive is the arithmetic, and that is why the
/// boundary is [Chit.startOfLocalDay] rather than a `Duration` added to now:
/// the question *when does this day end* has one answer in one place, and
/// ADR-006 already owns it.
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

/// The local day Today is showing, as `yyyymmdd`.
///
/// ADR-006's one conversion, off [today] so it cannot disagree with the date
/// line above it.
@riverpod
int todayLocalDay(Ref ref) => Chit.localDayOf(ref.watch(todayProvider));

/// Today's chits, newest first — BEHAVIOUR.md §4.1.
///
/// A stream off the repository rather than a fetch, which is what makes
/// DESIGN-SYSTEM.md §7's *the two tabs never disagree* true by construction:
/// saving writes one row and every reader of that row re-emits. Nothing here
/// keeps anything in step, because nothing here has a copy to keep.
@riverpod
Stream<List<Chit>> todayChits(Ref ref) => ref
    .watch(chitRepositoryProvider)
    .watchDay(ref.watch(todayLocalDayProvider));
