import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/ambient_stamp.dart';
import '../models/chit.dart';
import '../models/day_summary.dart';

part 'chit_repository.g.dart';

/// Everything the app can do to a chit.
///
/// The interface is in `domain` and the implementation is in `data`, which is
/// the dependency rule of ARCHITECTURE.md §1: a controller talks to this, and
/// Riverpod supplies the real thing at the root. It is what lets a sync layer
/// appear later (ADR-004) without a screen noticing, and what lets a test hand
/// a controller a database that lives in memory.
///
/// Reads are streams because DESIGN-SYSTEM.md §7 requires the two tabs never
/// to disagree. They do not disagree because they are the same query, not
/// because anything keeps them in step.
abstract interface class ChitRepository {
  /// Writes a chit and returns it as it was stored.
  ///
  /// [stamp] carries the moment the chit was opened; it becomes `createdAt`,
  /// and the local day is computed from it once, here, and stored (ADR-006).
  ///
  /// A recording at [audioTempPath] is moved into permanent storage **before**
  /// the row is written, so a failed move never leaves a row pointing at
  /// nothing (DATA-MODEL.md §5).
  ///
  /// Blank [text] is no text: it is stored as `null`, along with its origin.
  /// That is the ordinary shape of BEHAVIOUR.md §3.5 — a recording the engine
  /// could not read, saved with the field left empty — and not an error.
  ///
  /// Throws [ArgumentError] when the result would be no chit at all: neither
  /// words nor a recording, text without an origin, or half a recording.
  Future<Chit> save({
    required AmbientStamp stamp,
    String? text,
    TextOrigin? textOrigin,
    String? audioTempPath,
    Duration? audioDuration,
  });

  /// Changes what a chit says. ADR-014.
  ///
  /// Touches `text`, `textOrigin` and `updatedAt`, and can touch nothing else:
  /// `createdAt`, `localDay` and `audioPath` are not parameters, so an edit
  /// cannot move a chit in the thread, relight a calendar tile, or lose a
  /// recording. Text is what the chit *says* and belongs to the user; audio is
  /// what *was said* and belongs to the moment.
  ///
  /// [text] is required and must not be blank. A chit cannot be emptied from
  /// here — for a typed chit that would break the invariant of README §5, and
  /// for a recorded one no screen offers it. Deleting the chit is how a chit
  /// goes away.
  ///
  /// Throws [StateError] if no chit has that [id].
  Future<void> updateText({
    required String id,
    required String text,
    required TextOrigin textOrigin,
  });

  /// One chit, or null. The editor of M6 opens on this.
  Future<Chit?> byId(String id);

  /// One day's chits, newest first. Today's thread.
  Stream<List<Chit>> watchDay(int localDay);

  /// Every chit between [fromDay] and [toDay], inclusive, oldest first.
  ///
  /// The timeline's three days (ADR-024). It is a second read of rows the
  /// thread already has for one of those days, which is a real cost of that
  /// decision rather than an oversight — DATA-MODEL.md §4 says so. The two
  /// still cannot disagree: both are streams off the same table, so a save
  /// re-emits on both.
  Stream<List<Chit>> watchDayRange({required int fromDay, required int toDay});

  /// How many chits each day between [fromDay] and [toDay] holds, inclusive.
  /// The calendar's density and its month summary, from one query.
  Stream<List<DaySummary>> watchDaySummaries({
    required int fromDay,
    required int toDay,
  });

  /// Everything, newest day first. The archive.
  Stream<List<Chit>> watchArchive({required int limit, int offset = 0});

  /// Deletes recordings that no chit claims. ADR-008.
  ///
  /// Runs once at startup and off the critical path. Nothing waits for it and
  /// nothing fails if it does not finish.
  Future<void> reconcileAudio();
}

/// The repository the app runs on.
///
/// Unimplemented on purpose. `domain` cannot import `data` (ARCHITECTURE.md
/// §1), so the implementation is supplied where the two layers are allowed to
/// meet: the `ProviderScope` at the root, in `main.dart`, and a
/// `ProviderContainer` in a test.
@Riverpod(keepAlive: true)
ChitRepository chitRepository(Ref ref) => throw UnimplementedError(
  'chitRepositoryProvider is overridden at the root — see main.dart',
);
