import 'dart:async';
import 'dart:io';

import 'package:chitta/data/audio/audio_store.dart';
import 'package:chitta/data/db/app_database.dart';
import 'package:chitta/data/repositories/chit_repository_impl.dart';
import 'package:chitta/domain/models/ambient_stamp.dart';
import 'package:chitta/domain/models/audio_edit.dart';
import 'package:chitta/domain/models/chit.dart';
import 'package:chitta/domain/models/day_summary.dart';
import 'package:chitta/domain/models/motion_state.dart';
import 'package:chitta/domain/models/weather_condition.dart';
import 'package:chitta/domain/repositories/chit_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../support/fake_clock.dart';

void main() {
  late Directory root;
  late Directory documents;
  late Directory cache;
  late AppDatabase db;
  late FakeClock clock;
  late ChitRepository repo;

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
      await repo.update(id: saved.id, text: 'Late one, corrected.');

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

      expect(patched.id, original.id);
      expect(patched.text, original.text);
      expect(patched.audioPath, original.audioPath);
      expect(patched.audioDuration, original.audioDuration);
    });

    test('createdAt and localDay never move', () async {
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

    test('an unknown id is silent, where update throws', () async {
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

  group('update (ADR-014, ADR-063)', () {
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

    test('a text edit touches text and updatedAt — and nothing else', () async {
      await repo.update(id: original.id, text: 'Train 20 late.');

      final Chit edited = (await repo.byId(original.id))!;

      expect(edited.text, 'Train 20 late.');
      expect(edited.updatedAt, DateTime(2026, 9, 16, 8, 0));

      expect(edited.id, original.id);
      expect(edited.createdAt, original.createdAt);
      expect(edited.localDay, original.localDay);
      expect(edited.audioPath, original.audioPath);
      expect(edited.audioDuration, original.audioDuration);
      expect(edited.weather, original.weather);
      expect(edited.lat, original.lat);
      expect(edited.lon, original.lon);
    });

    test('the recording is still there after a text edit', () async {
      await repo.update(id: original.id, text: 'Train 20 late.');

      expect(audioFileOf(original).existsSync(), isTrue);
    });

    test(
      'removing the recording clears the row and deletes the file',
      () async {
        await repo.update(
          id: original.id,
          text: 'Train 20 late.',
          audio: const AudioEdit.remove(),
        );

        final Chit edited = (await repo.byId(original.id))!;
        expect(edited.hasAudio, isFalse);
        expect(edited.audioDuration, isNull);
        expect(edited.text, 'Train 20 late.');
        expect(edited.updatedAt, DateTime(2026, 9, 16, 8, 0));
        expect(audioFileOf(original).existsSync(), isFalse);
      },
    );

    test('replacing the recording moves the new one over the old', () async {
      final String newTake = p.join(cache.path, 'second.m4a');
      await File(newTake).writeAsString('a different take');
      final String before = audioFileOf(original).readAsStringSync();

      await repo.update(
        id: original.id,
        text: original.text,
        audio: AudioEdit.replace(
          tempPath: newTake,
          duration: const Duration(seconds: 21),
        ),
      );

      final Chit edited = (await repo.byId(original.id))!;
      expect(edited.audioPath, original.audioPath, reason: 'same name');
      expect(edited.audioDuration, const Duration(seconds: 21));
      expect(File(newTake).existsSync(), isFalse, reason: 'moved, not copied');
      expect(audioFileOf(edited).readAsStringSync(), isNot(before));
    });

    test('a recording-only chit can be given a replacement', () async {
      final Chit voiceOnly = await repo.save(
        stamp: stampAt(morning),
        audioTempPath: await aRecording('third'),
        audioDuration: const Duration(seconds: 4),
      );

      await repo.update(
        id: voiceOnly.id,
        text: null,
        audio: AudioEdit.replace(
          tempPath: await aRecording('fourth'),
          duration: const Duration(seconds: 6),
        ),
      );

      final Chit edited = (await repo.byId(voiceOnly.id))!;
      expect(edited.text, isNull);
      expect(edited.audioDuration, const Duration(seconds: 6));
    });

    test(
      'refuses to leave a chit with nothing, before any file moves',
      () async {
        final Chit voiceOnly = await repo.save(
          stamp: stampAt(morning),
          audioTempPath: await aRecording('fifth'),
          audioDuration: const Duration(seconds: 4),
        );

        await expectLater(
          repo.update(
            id: voiceOnly.id,
            text: '  ',
            audio: const AudioEdit.remove(),
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          audioFileOf(voiceOnly).existsSync(),
          isTrue,
          reason: 'the invariant is checked before the disk is touched',
        );
        expect((await repo.byId(voiceOnly.id))!.hasAudio, isTrue);
      },
    );

    test('blank text with a recording kept is stored as null', () async {
      await repo.update(id: original.id, text: '   ');

      final Chit edited = (await repo.byId(original.id))!;
      expect(edited.text, isNull);
      expect(edited.hasAudio, isTrue);
    });

    test('a chit that is only a recording can gain words', () async {
      final Chit voiceOnly = await repo.save(
        stamp: stampAt(morning),
        audioTempPath: await aRecording('second'),
        audioDuration: const Duration(seconds: 4),
      );

      await repo.update(
        id: voiceOnly.id,
        text: 'What the machine could not read.',
      );

      final Chit edited = (await repo.byId(voiceOnly.id))!;
      expect(edited.text, 'What the machine could not read.');
      expect(edited.hasAudio, isTrue);
    });

    test('refuses to empty a text-only chit', () async {
      final Chit words = await repo.save(
        stamp: stampAt(morning),
        text: 'Only words.',
      );
      expect(
        () => repo.update(id: words.id, text: '   '),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('refuses an id that is not a chit', () {
      expect(
        () => repo.update(id: 'no-such-chit', text: 'Train 20 late.'),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('delete (ADR-063, open item 9)', () {
    test('the row and the recording go together', () async {
      final Chit chit = await repo.save(
        stamp: stampAt(morning),
        text: 'Gone soon.',
        audioTempPath: await aRecording(),
        audioDuration: const Duration(seconds: 9),
      );

      await repo.delete(chit.id);

      expect(await repo.byId(chit.id), isNull);
      expect(audioFileOf(chit).existsSync(), isFalse);
    });

    test('the thread and the calendar re-emit without it', () async {
      final Chit chit = await repo.save(
        stamp: stampAt(morning),
        text: 'Gone soon.',
      );
      final Chit stays = await repo.save(
        stamp: stampAt(morning),
        text: 'Stays.',
      );

      await repo.delete(chit.id);

      final List<Chit> day = await repo.watchDay(chit.localDay).first;
      expect(day.map((Chit c) => c.id), <String>[stays.id]);
      final List<DaySummary> summaries = await repo
          .watchDaySummaries(fromDay: chit.localDay, toDay: chit.localDay)
          .first;
      expect(summaries.single.count, 1);
    });

    test('deleting what is already gone is the outcome wanted', () async {
      await expectLater(repo.delete('no-such-chit'), completes);
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
      await repo.update(id: oldest.id, text: 'One, corrected.');

      final List<Chit> archive = await repo.watchArchive(limit: 10).first;
      expect(archive.map((Chit c) => c.id), <String>[newest.id, oldest.id]);
    });
  });
}
