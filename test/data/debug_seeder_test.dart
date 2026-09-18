import 'dart:io';

import 'package:chitta/data/audio/audio_store.dart';
import 'package:chitta/data/db/app_database.dart';
import 'package:chitta/data/dev/debug_seeder.dart';
import 'package:chitta/data/repositories/chit_repository_impl.dart';
import 'package:chitta/domain/models/ambient_stamp.dart';
import 'package:chitta/domain/models/chit.dart';
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
  late AppDatabase db;
  late FakeClock clock;
  late AudioStore audio;
  late DebugSeeder seeder;
  late ChitRepository repo;

  final DateTime afternoon = DateTime(2026, 9, 17, 15);

  setUp(() async {
    root = await Directory.systemTemp.createTemp('chit-seeder-test');
    documents = await Directory(p.join(root.path, 'documents')).create();
    db = AppDatabase(NativeDatabase.memory());
    clock = FakeClock(afternoon);
    audio = AudioStore(Future<Directory>.value(documents));
    seeder = DebugSeeder(
      dao: db.chitDao,
      audio: audio,
      clock: clock,
      temp: Directory(p.join(root.path, 'cache')).create(),
    );
    repo = ChitRepositoryImpl(dao: db.chitDao, audio: audio, clock: clock);
  });

  tearDown(() async {
    await db.close();
    if (root.existsSync()) await root.delete(recursive: true);
  });

  Future<List<Chit>> seeded() async => <Chit>[
    for (final ChitRow row in await db.chitDao.rowsWithIdPrefix(
      DebugSeeder.idPrefix,
    ))
      (await repo.byId(row.id))!,
  ];

  Future<List<File>> recordings() async {
    final Directory dir = Directory(p.join(documents.path, AudioStore.folder));
    if (!dir.existsSync()) return <File>[];
    return dir.listSync().whereType<File>().toList();
  }

  group('seed', () {
    test('writes the whole fixture, and every row is a legal chit', () async {
      final SeedOutcome done = await seeder.seed();

      expect(done.rows, DebugSeeder.count);
      expect(done.rows, 20);
      expect(done.recordings, 4);

      final List<Chit> chits = await seeded();
      expect(chits, hasLength(20));
      expect(await recordings(), hasLength(4));
    });

    test('covers all three shapes of README §5', () async {
      await seeder.seed();
      final List<Chit> chits = await seeded();

      expect(
        chits.where((Chit c) => c.hasText && !c.hasAudio),
        isNotEmpty,
        reason: 'words alone',
      );
      expect(
        chits.where((Chit c) => c.hasText && c.hasAudio),
        isNotEmpty,
        reason: 'words and a recording',
      );
      expect(
        chits.where((Chit c) => c.hasAudio && !c.hasText),
        hasLength(1),
        reason: 'a recording alone, the shape most likely to be forgotten',
      );
    });

    test('is dated relative to the day it runs', () async {
      await seeder.seed();
      final List<Chit> chits = await seeded();

      Iterable<Chit> on(int day) => chits.where((Chit c) => c.localDay == day);

      expect(on(20260916), hasLength(5));
      expect(on(20260915), hasLength(5));

      expect(on(20260917), isEmpty);

      expect(on(20260905), hasLength(3));
      expect(on(20260911), hasLength(2));
      expect(chits.where((Chit c) => c.localDay < 20260901), hasLength(3));
    });

    test('has a six-minute burst, for the strip', () async {
      await seeder.seed();
      final List<Chit> chits = await seeded();

      expect(
        chits.map((Chit c) => c.createdAt),
        containsAll(<DateTime>[
          DateTime(2026, 9, 15, 12, 4),
          DateTime(2026, 9, 15, 12, 10),
        ]),
      );
    });

    test('reaches every weather word and all three motion marks', () async {
      await seeder.seed();
      final List<Chit> chits = await seeded();

      expect(
        chits.map((Chit c) => c.weather).toSet(),
        containsAll(WeatherCondition.values),
      );
      expect(
        chits.map((Chit c) => c.motion).toSet(),
        containsAll(<MotionState>[
          MotionState.walking,
          MotionState.traveling,
          MotionState.flying,
        ]),
      );
      expect(chits.where((Chit c) => c.lat == null), isNotEmpty);
      expect(chits.where((Chit c) => c.weather == null), isNotEmpty);
    });

    test('is idempotent — a second run writes nothing', () async {
      await seeder.seed();
      final SeedOutcome again = await seeder.seed();

      expect(again.rows, 0);
      expect(again.recordings, 0);
      expect(await seeded(), hasLength(20));
      expect(await recordings(), hasLength(4));
    });

    test('a seeded row is never edited — updatedAt is createdAt', () async {
      await seeder.seed();
      for (final Chit chit in await seeded()) {
        expect(chit.updatedAt, chit.createdAt, reason: chit.id);
      }
    });
  });

  group('clear', () {
    test('removes the seeded rows and their recordings', () async {
      await seeder.seed();
      final SeedOutcome done = await seeder.clear();

      expect(done.rows, 20);
      expect(done.recordings, 4);
      expect(await seeded(), isEmpty);
      expect(await recordings(), isEmpty);
    });

    test("leaves a person's own chit alone", () async {
      final Chit mine = await repo.save(
        stamp: AmbientStamp(capturedAt: afternoon),
        text: 'Mine, not seeded.',
      );
      await seeder.seed();

      await seeder.clear();

      expect(await repo.byId(mine.id), mine);
      expect(await seeded(), isEmpty);
    });

    test('on nothing is not an error', () async {
      final SeedOutcome done = await seeder.clear();
      expect(done, (rows: 0, recordings: 0));
    });

    test('seed, clear, seed, clear lands where it started', () async {
      await seeder.seed();
      await seeder.clear();
      await seeder.seed();
      final SeedOutcome done = await seeder.clear();

      expect(done.rows, 20);
      expect(await seeded(), isEmpty);
      expect(await recordings(), isEmpty);
    });
  });

  group('apply', () {
    test('seed and clear are the two modes', () async {
      expect(await seeder.apply(DebugSeeder.modeSeed), contains('seeded 20'));
      expect(await seeder.apply(DebugSeeder.modeClear), contains('cleared 20'));
    });

    test('anything else is a typo, and loud', () {
      expect(() => seeder.apply('sead'), throwsArgumentError);
    });
  });
}
