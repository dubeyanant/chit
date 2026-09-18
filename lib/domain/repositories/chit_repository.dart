import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/ambient_stamp.dart';
import '../models/audio_edit.dart';
import '../models/chit.dart';
import '../models/day_summary.dart';
import '../models/motion_state.dart';
import '../models/weather_condition.dart';

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
    String? audioTempPath,
    Duration? audioDuration,
  });

  /// Edits a chit: what it says, and what it holds. ADR-014, ADR-063.
  ///
  /// **One write.** The text and the [audio] edit land in the same statement,
  /// so a Save that changes both cannot be half-applied, and README §5's
  /// invariant is asserted once, here, before anything touches the disk.
  /// *Until M6 this was `updateText`, whose guarantee was that an edit could
  /// not reach the recording; the recording is editable now, and the guarantee
  /// that survives is the one about the stamp.*
  ///
  /// Touches `text`, `audioPath`, `audioDuration` and `updatedAt`, and can
  /// touch nothing else: `createdAt`, `localDay` and the three ambient fields
  /// are not parameters, so an edit cannot move a chit in the thread, relight
  /// a calendar tile, or change the moment it was written under. `updatedAt`
  /// moves on any edit, text or audio.
  ///
  /// Blank [text] is no text, stored as `null`, exactly as [save] stores it.
  /// A [ReplaceAudio] moves its file into place **before** the row is written
  /// and a [RemoveAudio] deletes the old file **after**, for the reason
  /// DATA-MODEL.md §5 gives: a row pointing at nothing is a corruption, a file
  /// nobody points at is an orphan the sweep collects.
  ///
  /// Throws [ArgumentError] if the result would be no chit at all — no words
  /// and no recording — and throws it before any file has moved. Throws
  /// [StateError] if no chit has that [id].
  Future<void> update({
    required String id,
    required String? text,
    AudioEdit audio = const AudioEdit.keep(),
  });

  /// Deletes a chit — the row and its recording together. ADR-063, and the
  /// close of open item 9.
  ///
  /// The row goes first and the file after, so that at no point does a row
  /// point at nothing. A recording that fails to delete is an orphan, and
  /// [reconcileAudio] collects it at the next launch.
  ///
  /// **Does nothing if no chit has that [id]**: deleting twice, or deleting
  /// what a race already removed, is the outcome the caller wanted.
  Future<void> delete(String id);

  /// Corrects a chit's ambience after the row was written — **ADR-042**.
  ///
  /// A save writes immediately and re-reads the services behind it, so that
  /// nothing about saving waits on a network call (ADR-040). This is where the
  /// fresh answer lands, a moment later.
  ///
  /// **Touches the three ambient fields and nothing else.** `createdAt` and
  /// `localDay` are not parameters, so a late signal cannot move a chit in the
  /// thread, move its mark on the timeline, or move it to another day.
  /// **`updatedAt` does not move either** — ADR-014 reserves that for an
  /// edit, and a signal arriving two seconds late is not an edit anybody
  /// made. That distinction is the whole reason this is a separate method
  /// rather than an argument to [update].
  ///
  /// Every parameter is nullable and a `null` is written as `null`: this is the
  /// whole reading replacing the whole reading, not a partial patch. A capture
  /// that came back with nothing legitimately clears a value that the launch
  /// capture had — the user walked indoors, and the pin should go.
  ///
  /// **Does nothing if no chit has that [id]**, rather than throwing. Unlike
  /// [update], nobody is waiting on this and no screen can report it; a row
  /// deleted between the write and the patch is an ordinary race, not a fault.
  Future<void> updateAmbient({
    required String id,
    required WeatherCondition? weather,
    required double? lat,
    required double? lon,
    required MotionState? motion,
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

  /// Every month with at least one chit in it, as `yyyymm`, oldest first.
  /// The calendar's chevrons step through these and nothing else (ADR-047).
  Stream<List<int>> watchWrittenMonths();

  /// Everything, newest day first. The archive.
  Stream<List<Chit>> watchArchive({required int limit, int offset = 0});

  /// Deletes a take that was never saved — the recording sheet's **Discard**,
  /// and **Remove** on the open chit's pill (BEHAVIOUR.md §3.2, ADR-060).
  ///
  /// The counterpart of [save]'s `audioTempPath`: one door takes a temp file
  /// in, this one lets it go, and both go through the single thing ADR-008
  /// says may move a recording. A composer that deleted the file itself would
  /// be a second owner of its lifetime — and `features` cannot reach the
  /// store anyway (ARCHITECTURE.md §1).
  ///
  /// A file that has already gone is not a failure.
  Future<void> discardTemp(String tempPath);

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
