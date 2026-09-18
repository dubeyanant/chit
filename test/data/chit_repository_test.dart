import 'dart:async';
import 'dart:io';

import 'package:chit/data/audio/audio_store.dart';
import 'package:chit/data/db/app_database.dart';
import 'package:chit/data/repositories/chit_repository_impl.dart';
import 'package:chit/domain/models/ambient_stamp.dart';
import 'package:chit/domain/models/chit.dart';
import 'package:chit/domain/models/day_summary.dart';
import 'package:chit/domain/models/motion_state.dart';
import 'package:chit/domain/models/weather_condition.dart';
import 'package:chit/domain/repositories/chit_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../support/fake_clock.dart';

/// The data spine, against a database in memory and a filesystem in a
/// temporary directory. M1's statement of done is this file, and every query
/// added since lands here too — `watchDayRange` arrived with M2 group H.
///
/// The third of the three places the invariant of README §5 is held
/// (DATA-MODEL.md §2). The other two — the asserts on [Chit] and the check
/// constraints on the table — are tested beside the things they belong to.
/// What is tested here is that the repository refuses an illegal chit before
/// either of them has to, with an error that says what was wrong.
void main() {
  late Directory root;
  late Directory documents;
  late Directory cache;
  late AppDatabase db;
  late FakeClock clock;
  late ChitRepository repo;

  /// 15 September 2026, 9:30am — the stamp on a chit opened then.
  final DateTime morning = DateTime(2026, 9, 15, 9, 30);

  setUp(() async {
    root = await Directory.systemTemp.createTemp('chit-repo-test');
    documents = await Directory(p.join(root.path, 'documents')).create();
    cache = await Directory(p.join(root.path, 'cache')).create();
    db = AppDatabase(NativeDatabase.memory());
    clock = FakeClock(morning);
    repo = ChitRepositoryImpl(
      dao: db.chitDao,
      audio: AudioStore(Future<Directory>.value(documents)),
      clock: clock,
    );
  });

  tearDown(() async {
    await db.close();
    if (root.existsSync()) await root.delete(recursive: true);
  });

  Future<String> aRecording([String name = 'recording']) async {
    final File file = File(p.join(cache.path, '$name.m4a'));
    await file.writeAsString('pretend this is aac');
    return file.path;
  }

  AmbientStamp stampAt(DateTime when) => AmbientStamp(capturedAt: when);

  File audioFileOf(Chit chit) =>
      File(p.join(documents.path, 'audio', '${chit.id}.m4a'));

  group('the four legal shapes round-trip', () {
    test('typed', () async {
      final Chit saved = await repo.save(
        stamp: stampAt(morning),
        text: 'Train 20 late.',
      );

      final Chit? read = await repo.byId(saved.id);
      expect(read, saved);
      expect(read!.text, 'Train 20 late.');
      expect(read.hasAudio, isFalse);
    });

    test('words and a recording', () async {
      final Chit saved = await repo.save(
        stamp: stampAt(morning),
        text: 'Train 20 late.',
        audioTempPath: await aRecording(),
        audioDuration: const Duration(seconds: 9),
      );

      final Chit? read = await repo.byId(saved.id);
      expect(read, saved);
      expect(read!.hasText, isTrue);
      expect(read.hasAudio, isTrue);
      expect(read.audioDuration, const Duration(seconds: 9));
    });

    test('a recording added to a chit that had words', () async {
      final Chit saved = await repo.save(
        stamp: stampAt(morning),
        text: 'Train 20 late.',
        audioTempPath: await aRecording(),
        audioDuration: const Duration(seconds: 9),
      );

      final Chit read = (await repo.byId(saved.id))!;
      expect(read.hasAudio, isTrue);
    });

    test('a recording with no words is a chit — README §5', () async {
      final Chit saved = await repo.save(
        stamp: stampAt(morning),
        audioTempPath: await aRecording(),
        audioDuration: const Duration(seconds: 9),
      );

      final Chit read = (await repo.byId(saved.id))!;
      expect(read.text, isNull);
      expect(read.hasAudio, isTrue);
    });

    test('the whole ambient stamp comes back as it went in', () async {
      final Chit saved = await repo.save(
        stamp: AmbientStamp(
          capturedAt: morning,
          weather: WeatherCondition.raining,
          lat: 19.0760,
          lon: 72.8777,
          motion: MotionState.traveling,
        ),
        text: 'Train 20 late.',
      );

      final AmbientStamp stamp = (await repo.byId(saved.id))!.stamp;
      expect(stamp.capturedAt, morning);
      expect(stamp.weather, WeatherCondition.raining);
      expect(stamp.lat, closeTo(19.0760, 1e-9));
      expect(stamp.lon, closeTo(72.8777, 1e-9));
      expect(stamp.motion, MotionState.traveling);
    });

    test('every motion state survives the round trip', () async {
      // The column is a `textEnum`, so a state renamed in Dart silently stops
      // matching the rows already written with the old name. This is what
      // would notice.
      for (final MotionState motion in MotionState.values) {
        final Chit saved = await repo.save(
          stamp: AmbientStamp(capturedAt: morning, motion: motion),
          text: 'Train 20 late.',
        );

        expect(
          (await repo.byId(saved.id))!.motion,
          motion,
          reason: motion.name,
        );
      }
    });

    test('a signal that never arrived is null, not a placeholder', () async {
      final Chit saved = await repo.save(
        stamp: stampAt(morning),
        text: 'Train 20 late.',
      );

      final Chit read = (await repo.byId(saved.id))!;
      expect(read.weather, isNull);
      expect(read.motion, isNull);
      expect(read.stamp.hasLocation, isFalse);
    });

    test('a chit that was never saved is not there', () async {
      expect(await repo.byId('no-such-chit'), isNull);
    });
  });

  group('what it refuses', () {
    test('a chit with neither words nor a recording', () {
      expect(
        () => repo.save(stamp: stampAt(morning)),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('a field of nothing but spaces, with no recording', () {
      expect(
        () => repo.save(stamp: stampAt(morning), text: '   \n  '),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('a recording with no length', () async {
      final String temp = await aRecording();
      expect(
        () => repo.save(stamp: stampAt(morning), audioTempPath: temp),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('a length with no recording', () {
      expect(
        () => repo.save(
          stamp: stampAt(morning),
          audioDuration: const Duration(seconds: 9),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('a refusal writes nothing', () async {
      await expectLater(
        repo.save(stamp: stampAt(morning)),
        throwsA(isA<ArgumentError>()),
      );

      expect(await db.select(db.chits).get(), isEmpty);
    });
  });

  group('blank text beside a recording is §3.5, not an error', () {
    test('an empty field is stored as no text at all', () async {
      final Chit saved = await repo.save(
        stamp: stampAt(morning),
        text: '   ',
        audioTempPath: await aRecording(),
        audioDuration: const Duration(seconds: 9),
      );

      // Nothing partial, approximate or placeholder is written — and a
      // provenance for words that do not exist is exactly that.
      expect(saved.text, isNull);
      expect(saved.hasAudio, isTrue);
      expect((await repo.byId(saved.id))!.text, isNull);
    });
  });

  group('the text that is stored', () {
    test('is trimmed: the edges of a slip are not content', () async {
      final Chit saved = await repo.save(
        stamp: stampAt(morning),
        text: '  Train 20 late.\n',
      );

      expect(saved.text, 'Train 20 late.');
      expect((await repo.byId(saved.id))!.text, 'Train 20 late.');
    });
  });

  group('the local day (ADR-006)', () {
    test('is computed from the stamp, once, and stored', () async {
      final Chit saved = await repo.save(
        stamp: stampAt(morning),
        text: 'Train 20 late.',
      );

      expect(saved.localDay, 20260915);
      expect((await repo.byId(saved.id))!.localDay, 20260915);
    });

    test('a minute either side of midnight is two different days', () async {
      final Chit before = await repo.save(
        stamp: stampAt(DateTime(2026, 9, 14, 23, 59)),
        text: 'Still the 14th.',
      );
      final Chit after = await repo.save(
        stamp: stampAt(DateTime(2026, 9, 15, 0, 1)),
        text: 'Now the 15th.',
      );

      expect(before.localDay, 20260914);
      expect(after.localDay, 20260915);
      expect(await repo.watchDay(20260914).first, <Chit>[before]);
      expect(await repo.watchDay(20260915).first, <Chit>[after]);
    });

    test('a chit written at 00:20 stays on that day after the device moves '
        'timezone', () async {
      // The device's wall clock said 00:20 on the 15th. As an instant that is
      // still the 14th for a device far enough west — so a day derived from
      // `createdAt` at read time would quietly move this chit to the previous
      // morning the first time its owner flew anywhere.
      final Chit saved = await repo.save(
        stamp: stampAt(DateTime(2026, 9, 15, 0, 20)),
        text: 'Late one.',
      );

      final DateTime elsewhere = saved.createdAt.subtract(
        const Duration(hours: 6),
      );

      expect(
        Chit.localDayOf(elsewhere),
        20260914,
        reason: 'what a read-time derivation would say on a westward device',
      );
      expect(
        (await repo.byId(saved.id))!.localDay,
        20260915,
        reason: 'what the row says, and goes on saying',
      );
    });

    test('an edit does not move it', () async {
      final Chit saved = await repo.save(
        stamp: stampAt(DateTime(2026, 9, 15, 0, 20)),
        text: 'Late one.',
      );

      clock.moveTo(DateTime(2026, 9, 16, 8, 0));
      await repo.updateText(id: saved.id, text: 'Late one, corrected.');

      // A typo found the next morning is the same typo. Correcting it must not
      // relight a calendar tile (ADR-014).
      expect((await repo.byId(saved.id))!.localDay, 20260915);
    });
  });

  group('audio (ADR-008)', () {
    test(
      'the recording is moved into place and the row points at it',
      () async {
        final String temp = await aRecording();

        final Chit saved = await repo.save(
          stamp: stampAt(morning),
          audioTempPath: temp,
          audioDuration: const Duration(seconds: 9),
        );

        expect(File(temp).existsSync(), isFalse, reason: 'moved, not copied');
        expect(saved.audioPath, 'audio/${saved.id}.m4a');
        expect(audioFileOf(saved).existsSync(), isTrue);
      },
    );

    test('the stored path is relative', () async {
      final Chit saved = await repo.save(
        stamp: stampAt(morning),
        audioTempPath: await aRecording(),
        audioDuration: const Duration(seconds: 9),
      );

      expect(p.isAbsolute(saved.audioPath!), isFalse);
    });

    test(
      'reconciling deletes what no chit claims and keeps what one does',
      () async {
        final Chit saved = await repo.save(
          stamp: stampAt(morning),
          audioTempPath: await aRecording('kept'),
          audioDuration: const Duration(seconds: 9),
        );
        final File orphan = File(p.join(documents.path, 'audio', 'orphan.m4a'));
        await orphan.writeAsString('nobody owns this');

        await repo.reconcileAudio();

        expect(orphan.existsSync(), isFalse);
        expect(audioFileOf(saved).existsSync(), isTrue);
      },
    );
  });

  group('updateAmbient (ADR-042)', () {
    late Chit original;

    setUp(() async {
      original = await repo.save(
        stamp: AmbientStamp(
          capturedAt: morning,
          weather: WeatherCondition.raining,
          lat: 19.0760,
          lon: 72.8777,
          motion: MotionState.stationary,
        ),
        text: 'Train 20 late.',
      );
      clock.moveTo(DateTime(2026, 9, 16, 8, 0));
    });

    test('touches the ambient fields — and nothing else', () async {
      await repo.updateAmbient(
        id: original.id,
        weather: WeatherCondition.clear,
        lat: 1.5,
        lon: 2.5,
        motion: MotionState.walking,
      );

      final Chit patched = (await repo.byId(original.id))!;

      expect(patched.weather, WeatherCondition.clear);
      expect(patched.lat, closeTo(1.5, 1e-9));
      expect(patched.lon, closeTo(2.5, 1e-9));
      expect(patched.motion, MotionState.walking);

      // Everything else, field by field rather than by comparing a copyWith:
      // a field dropped from the model would pass that comparison happily.
      expect(patched.id, original.id);
      expect(patched.text, original.text);
      expect(patched.audioPath, original.audioPath);
      expect(patched.audioDuration, original.audioDuration);
    });

    test('createdAt and localDay never move', () async {
      // The claim that matters most. `createdAt` decides where the chit sits
      // in the thread and where its mark falls on the strip, and `localDay`
      // decides which day it belongs to — a late signal moving either would
      // move a chit that the user is already looking at, and across a midnight
      // it would move it to another day (ADR-006).
      await repo.updateAmbient(
        id: original.id,
        weather: null,
        lat: null,
        lon: null,
        motion: null,
      );

      final Chit patched = (await repo.byId(original.id))!;

      expect(patched.createdAt, original.createdAt);
      expect(patched.localDay, original.localDay);
    });

    test(
      'updatedAt does not move — ADR-014 reserves it for the text',
      () async {
        // The clock has moved on by an hour in setUp, so an implementation that
        // stamped this the way `updateText` does would be caught here. A signal
        // arriving late is not an edit anybody made, and an edit is the user's act.
        await repo.updateAmbient(
          id: original.id,
          weather: WeatherCondition.clear,
          lat: null,
          lon: null,
          motion: null,
        );

        expect((await repo.byId(original.id))!.updatedAt, original.updatedAt);
      },
    );

    test(
      'a null clears what was there — the whole reading replaces it',
      () async {
        // Not a partial patch. A capture that came back empty legitimately
        // clears what the launch capture had put there: the user walked indoors
        // and the pin should go, rather than a stale coordinate persisting
        // because `null` was read as "no opinion".
        await repo.updateAmbient(
          id: original.id,
          weather: null,
          lat: null,
          lon: null,
          motion: null,
        );

        final Chit patched = (await repo.byId(original.id))!;

        expect(patched.weather, isNull);
        expect(patched.lat, isNull);
        expect(patched.lon, isNull);
        expect(patched.motion, isNull);
        expect(patched.stamp.hasLocation, isFalse);
      },
    );

    test('an unknown id is silent, where updateText throws', () async {
      // Nobody is waiting on this and no screen could report it: a row deleted
      // between the write and the patch is an ordinary race (ADR-042). The
      // contrast with `updateText` is deliberate and is the reason these are
      // two methods.
      await expectLater(
        repo.updateAmbient(
          id: 'no-such-chit',
          weather: WeatherCondition.clear,
          lat: null,
          lon: null,
          motion: null,
        ),
        completes,
      );
    });
  });

  group('updateText (ADR-014)', () {
    late Chit original;

    setUp(() async {
      original = await repo.save(
        stamp: AmbientStamp(
          capturedAt: morning,
          weather: WeatherCondition.raining,
          lat: 19.0760,
          lon: 72.8777,
        ),
        text: 'Trane 20 late.',
        audioTempPath: await aRecording(),
        audioDuration: const Duration(seconds: 9),
      );
      clock.moveTo(DateTime(2026, 9, 16, 8, 0));
    });

    test('touches text, textOrigin and updatedAt — and nothing else', () async {
      await repo.updateText(id: original.id, text: 'Train 20 late.');

      final Chit edited = (await repo.byId(original.id))!;

      expect(edited.text, 'Train 20 late.');
      expect(edited.updatedAt, DateTime(2026, 9, 16, 8, 0));

      // Everything else, field by field rather than by comparing a copyWith:
      // a field dropped from the model would pass that comparison happily.
      expect(edited.id, original.id);
      expect(edited.createdAt, original.createdAt);
      expect(edited.localDay, original.localDay);
      expect(edited.audioPath, original.audioPath);
      expect(edited.audioDuration, original.audioDuration);
      expect(edited.weather, original.weather);
      expect(edited.lat, original.lat);
      expect(edited.lon, original.lon);
    });

    test('the recording is still there afterwards', () async {
      await repo.updateText(id: original.id, text: 'Train 20 late.');

      // Text is what the chit says and belongs to the user; audio is what was
      // said and belongs to the moment. Nothing here may touch the second.
      expect(audioFileOf(original).existsSync(), isTrue);
    });

    test('a chit that is only a recording can gain words', () async {
      final Chit voiceOnly = await repo.save(
        stamp: stampAt(morning),
        audioTempPath: await aRecording('second'),
        audioDuration: const Duration(seconds: 4),
      );

      await repo.updateText(
        id: voiceOnly.id,
        text: 'What the machine could not read.',
      );

      final Chit edited = (await repo.byId(voiceOnly.id))!;
      expect(edited.text, 'What the machine could not read.');
      expect(edited.hasAudio, isTrue);
    });

    test('refuses to empty a chit', () {
      expect(
        () => repo.updateText(id: original.id, text: '   '),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('refuses an id that is not a chit', () {
      expect(
        () => repo.updateText(id: 'no-such-chit', text: 'Train 20 late.'),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('the queries of DATA-MODEL.md §4', () {
    Future<Chit> chitAt(DateTime when, String text) =>
        repo.save(stamp: stampAt(when), text: text);

    test('a day reads newest first', () async {
      final Chit first = await chitAt(DateTime(2026, 9, 15, 9, 0), 'First.');
      final Chit second = await chitAt(
        DateTime(2026, 9, 15, 15, 42),
        'Second.',
      );

      expect(await repo.watchDay(20260915).first, <Chit>[second, first]);
    });

    test('an empty day is empty, and says so by being empty', () async {
      expect(await repo.watchDay(20260915).first, isEmpty);
    });

    group('watchDayRange — the timeline, ADR-024', () {
      test('reads the range oldest first, which is left to right', () async {
        // Where the thread is newest first, because it is read down. The
        // strip is read along, so the query hands it the order it draws in.
        final Chit first = await chitAt(DateTime(2026, 9, 14, 9), 'First.');
        final Chit second = await chitAt(DateTime(2026, 9, 15, 11), 'Second.');
        final Chit third = await chitAt(
          DateTime(2026, 9, 16, 15, 42),
          'Third.',
        );

        expect(
          await repo.watchDayRange(fromDay: 20260914, toDay: 20260916).first,
          <Chit>[first, second, third],
        );
      });

      test('both bounds are inclusive', () async {
        await chitAt(DateTime(2026, 9, 14, 9), 'First day.');
        await chitAt(DateTime(2026, 9, 16, 9), 'Last day.');

        expect(
          await repo.watchDayRange(fromDay: 20260914, toDay: 20260916).first,
          hasLength(2),
        );
      });

      test('a day outside the window is not in it', () async {
        await chitAt(DateTime(2026, 9, 13, 23, 59), 'The day before.');
        await chitAt(DateTime(2026, 9, 17, 0, 1), 'The day after.');
        final Chit inside = await chitAt(DateTime(2026, 9, 15, 12), 'Inside.');

        expect(
          await repo.watchDayRange(fromDay: 20260914, toDay: 20260916).first,
          <Chit>[inside],
        );
      });

      test('an empty window is empty', () async {
        expect(
          await repo.watchDayRange(fromDay: 20260914, toDay: 20260916).first,
          isEmpty,
        );
      });

      test('a save reaches a window that is already being watched', () async {
        // The thread and the strip are two queries over one table (a cost
        // ADR-024 accepts), and this is what stops that being two sources of
        // truth: the write re-emits on both without anything keeping them in
        // step.
        final List<int> strip = <int>[];
        final List<int> thread = <int>[];

        final StreamSubscription<List<Chit>> onStrip = repo
            .watchDayRange(fromDay: 20260914, toDay: 20260916)
            .listen((List<Chit> chits) => strip.add(chits.length));
        final StreamSubscription<List<Chit>> onThread = repo
            .watchDay(20260916)
            .listen((List<Chit> chits) => thread.add(chits.length));

        await pumpEventQueue();
        await chitAt(DateTime(2026, 9, 16, 15, 42), 'Saved.');
        await pumpEventQueue();
        await onStrip.cancel();
        await onThread.cancel();

        expect(strip, <int>[0, 1]);
        expect(thread, <int>[0, 1]);
      });

      test('a chit in the window that the thread never sees is still on the '
          'strip', () async {
        // The whole reason the strip needs its own query: two of its three
        // days are days the thread does not read at all.
        final Chit yesterday = await chitAt(
          DateTime(2026, 9, 15, 11),
          'Yesterday.',
        );

        expect(await repo.watchDay(20260916).first, isEmpty);
        expect(
          await repo.watchDayRange(fromDay: 20260914, toDay: 20260916).first,
          <Chit>[yesterday],
        );
      });
    });

    test('a save reaches a day that is already being watched', () async {
      // The thread, the day arc, the calendar heat and the month total are
      // four readings of this one stream. They cannot disagree because nothing
      // keeps them in step — they are the same query (DESIGN-SYSTEM.md §7).
      final List<int> emitted = <int>[];
      final StreamSubscription<List<Chit>> thread = repo
          .watchDay(20260915)
          .listen((List<Chit> day) => emitted.add(day.length));

      await pumpEventQueue();
      await chitAt(DateTime(2026, 9, 15, 9, 0), 'First.');
      await pumpEventQueue();
      await thread.cancel();

      expect(emitted, <int>[0, 1]);
    });

    test(
      'day summaries count per day, and skip the days with nothing',
      () async {
        await chitAt(DateTime(2026, 9, 14, 9, 0), 'One.');
        await chitAt(DateTime(2026, 9, 16, 9, 0), 'Two.');
        await chitAt(DateTime(2026, 9, 16, 10, 0), 'Three.');

        final List<DaySummary> month = await repo
            .watchDaySummaries(fromDay: 20260901, toDay: 20260930)
            .first;

        expect(month, <DaySummary>[
          const DaySummary(localDay: 20260914, count: 1),
          const DaySummary(localDay: 20260916, count: 2),
        ]);
      },
    );

    test('day summaries stop at the edges of the range asked for', () async {
      await chitAt(DateTime(2026, 8, 31, 9, 0), 'August.');
      await chitAt(DateTime(2026, 9, 15, 9, 0), 'September.');
      await chitAt(DateTime(2026, 10, 1, 9, 0), 'October.');

      final List<DaySummary> month = await repo
          .watchDaySummaries(fromDay: 20260901, toDay: 20260930)
          .first;

      expect(month, <DaySummary>[
        const DaySummary(localDay: 20260915, count: 1),
      ]);
    });

    test('written months are every month with a chit, oldest first', () async {
      // ADR-047: what the chevrons step through. A month with nothing in it
      // has no row, which is what keeps the calendar off it.
      await chitAt(DateTime(2026, 9, 15, 9, 0), 'September.');
      await chitAt(DateTime(2026, 9, 16, 9, 0), 'September again.');
      await chitAt(DateTime(2026, 4, 20, 9, 0), 'April.');
      await chitAt(DateTime(2025, 12, 31, 23, 59), 'Last year.');

      expect(await repo.watchWrittenMonths().first, <int>[
        202512,
        202604,
        202609,
      ]);
    });

    test('written months is empty on a fresh install', () async {
      expect(await repo.watchWrittenMonths().first, isEmpty);
    });

    test('the archive reads newest day first, and pages', () async {
      final Chit oldest = await chitAt(DateTime(2026, 9, 14, 9, 0), 'One.');
      final Chit middle = await chitAt(DateTime(2026, 9, 15, 9, 0), 'Two.');
      final Chit newest = await chitAt(DateTime(2026, 9, 15, 15, 42), 'Three.');

      expect(await repo.watchArchive(limit: 10).first, <Chit>[
        newest,
        middle,
        oldest,
      ]);
      expect(await repo.watchArchive(limit: 2).first, <Chit>[newest, middle]);
      expect(await repo.watchArchive(limit: 2, offset: 2).first, <Chit>[
        oldest,
      ]);
    });

    test('an edit does not move a chit in the archive', () async {
      final Chit oldest = await chitAt(DateTime(2026, 9, 14, 9, 0), 'One.');
      final Chit newest = await chitAt(DateTime(2026, 9, 15, 9, 0), 'Two.');

      clock.moveTo(DateTime(2026, 9, 20, 8, 0));
      await repo.updateText(id: oldest.id, text: 'One, corrected.');

      // The archive orders on createdAt and never on updatedAt: a chit belongs
      // to the moment it was written.
      final List<Chit> archive = await repo.watchArchive(limit: 10).first;
      expect(archive.map((Chit c) => c.id), <String>[newest.id, oldest.id]);
    });
  });
}
