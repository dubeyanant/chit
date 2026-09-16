import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/clock.dart';
import '../../../domain/models/chit.dart';
import '../../../domain/repositories/chit_repository.dart';

part 'today_controller.g.dart';

/// The moment Today is drawn for.
///
/// **The clock is read here and nowhere else on this screen.** The date line
/// and the thread are two readings of one instant, so a provider rather than a
/// `clock.now()` in each: two reads a millisecond apart are two different
/// answers at midnight, and the screen would show one day above a thread of
/// another. It also keeps the read count honest, which is what ADR-021's test
/// counts.
@riverpod
DateTime today(Ref ref) => ref.watch(clockProvider).now();

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
