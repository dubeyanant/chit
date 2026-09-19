import 'dart:io';
import 'dart:math' as math;

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

  Future<Set<int>> daysBack() async => <int>{
    for (final Chit chit in await seeded())
      Chit.startOfLocalDay(afternoon)
          .difference(Chit.startOfLocalDay(chit.createdAt))
          .inDays,
  };

  Future<List<File>> recordings() async {
    final Directory dir = Directory(p.join(documents.path, AudioStore.folder));
    if (!dir.existsSync()) return <File>[];
    return dir.listSync().whereType<File>().toList();
  }

  group('seed', () {
    test('writes the whole fixture, and every row is a legal chit', () async {
      final SeedOutcome done = await seeder.seed();

      expect(done.rows, DebugSeeder.count);
      expect(done.recordings, 6);

      final List<Chit> chits = await seeded();
      expect(chits, hasLength(DebugSeeder.count));
      expect(await recordings(), hasLength(6));
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
    });

    test('covers three months, which is what the calendar is for', () async {
      await seeder.seed();
      final Set<int> written = await daysBack();

      expect(
        written.reduce(math.max),
        greaterThanOrEqualTo(88),
        reason:
            'the chevrons and the archive need three months behind them '
            '— DATA-MODEL.md §6',
      );

      final List<Chit> chits = await seeded();
      expect(
        chits.map((Chit c) => c.localDay ~/ 100).toSet(),
        hasLength(greaterThanOrEqualTo(4)),
        reason: 'three months back from any date touches four of them',
      );
    });

    test('leaves a week nothing was written in, for ADR-048', () async {
      await seeder.seed();
      final Set<int> written = await daysBack();

      int run = 0;
      int longest = 0;
      for (int day = 1; day <= written.reduce(math.max); day++) {
        run = written.contains(day) ? 0 : run + 1;
        if (run > longest) longest = run;
      }

      expect(
        longest,
        greaterThanOrEqualTo(7),
        reason:
            'a past month draws only the weeks with something in them, '
            'and nothing exercises that without an empty one',
      );
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
      expect(await seeded(), hasLength(DebugSeeder.count));
      expect(await recordings(), hasLength(6));
    });

    test('a seeded row is never edited — updatedAt is createdAt', () async {
      await seeder.seed();
      for (final Chit chit in await seeded()) {
        expect(chit.updatedAt, chit.createdAt, reason: chit.id);
      }
    });

    test('the pinned chits walk the world, newest first — ADR-089', () async {
      await seeder.seed();

      final List<Chit> pinned =
          (await seeded()).where((Chit c) => c.lat != null).toList()
            ..sort((Chit a, Chit b) => b.createdAt.compareTo(a.createdAt));

      expect(pinned.length, greaterThan(12));

      // **The twelve newest are twelve different places.** This is the whole
      // point of the fixture: deleting the newest chit and opening find again
      // has to land the map somewhere else, or there is no way to look at it
      // anywhere but where the handset is.
      final Set<String> places = <String>{
        for (final Chit chit in pinned.take(12))
          '${chit.lat!.round()},${chit.lon!.round()}',
      };

      expect(places, hasLength(12));
    });

    test('every seeded fix is far from the others — no two share a city',
        () async {
      await seeder.seed();

      final List<Chit> pinned =
          (await seeded()).where((Chit c) => c.lat != null).toList()
            ..sort((Chit a, Chit b) => b.createdAt.compareTo(a.createdAt));

      // Consecutive by recency means consecutive in the list of places, so any
      // two neighbours are continents apart rather than streets apart.
      for (int i = 1; i < 12; i++) {
        final double apart =
            (pinned[i].lat! - pinned[i - 1].lat!).abs() +
            (pinned[i].lon! - pinned[i - 1].lon!).abs();

        expect(apart, greaterThan(1), reason: 'rows $i and ${i - 1}');
      }
    });
  });

  group('clear', () {
    test('removes the seeded rows and their recordings', () async {
      await seeder.seed();
      final SeedOutcome done = await seeder.clear();

      expect(done.rows, DebugSeeder.count);
      expect(done.recordings, 6);
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

      expect(done.rows, DebugSeeder.count);
      expect(await seeded(), isEmpty);
      expect(await recordings(), isEmpty);
    });
  });

  group('apply', () {
    test('seed and clear are the two modes', () async {
      expect(
        await seeder.apply(DebugSeeder.modeSeed),
        contains('seeded ${DebugSeeder.count}'),
      );
      expect(
        await seeder.apply(DebugSeeder.modeClear),
        contains('cleared ${DebugSeeder.count}'),
      );
    });

    test('anything else is a typo, and loud', () {
      expect(() => seeder.apply('sead'), throwsArgumentError);
    });
  });
}
