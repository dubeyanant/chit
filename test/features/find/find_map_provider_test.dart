import 'dart:io';

import 'package:chitta/core/clock.dart';
import 'package:chitta/data/db/app_database.dart';
import 'package:chitta/data/files/file_store.dart';
import 'package:chitta/data/repositories/chit_repository_impl.dart';
import 'package:chitta/domain/geo/geo_point.dart';
import 'package:chitta/domain/models/ambient_stamp.dart';
import 'package:chitta/domain/repositories/chit_repository.dart';
import 'package:chitta/features/find/application/find_map_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../support/fake_clock.dart';

void main() {
  late Directory root;
  late AppDatabase db;
  late ChitRepository repo;
  late ProviderContainer container;

  final DateTime monday = DateTime(2026, 9, 14, 9, 0);

  setUp(() async {
    root = await Directory.systemTemp.createTemp('chit-find-map-test');
    final Directory documents = await Directory(p.join(root.path, 'documents'))
        .create();
    db = AppDatabase(NativeDatabase.memory());
    final FakeClock clock = FakeClock(monday);
    repo = ChitRepositoryImpl(
      dao: db.chitDao,
      audio: FileStore(
        Future<Directory>.value(documents),
        folder: 'audio',
        extension: '.m4a',
      ),
      photos: FileStore(
        Future<Directory>.value(documents),
        folder: 'photos',
        extension: '.jpg',
      ),
      clock: clock,
    );

    container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(clock),
        chitRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    container.listen<GeoPoint?>(
      latestFixProvider,
      (GeoPoint? _, GeoPoint? _) {},
    );
  });

  tearDown(() async {
    await db.close();
    if (root.existsSync()) await root.delete(recursive: true);
  });

  int hour = 0;

  Future<void> write(String text, {double? lat, double? lon}) => repo.save(
    stamp: AmbientStamp(
      capturedAt: monday.add(Duration(hours: hour++)),
      lat: lat,
      lon: lon,
    ),
    text: text,
  );

  Future<void> settle() async {
    for (int i = 0; i < 100; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  }

  setUp(() => hour = 0);

  test('nothing has arrived yet, so there is no fix and no map', () {
    expect(container.read(latestFixProvider), isNull);
  });

  test('chits with no fix on any of them draw no map at all', () async {
    await write('a thought');
    await write('another');
    await settle();

    expect(
      container.read(latestFixProvider),
      isNull,
      reason: 'a phone that refused location forever has nothing to draw',
    );
  });

  test('the newest chit that knew where it was, is the one drawn', () async {
    await write('at home', lat: 19.076, lon: 72.8777);
    await write('at work', lat: 18.5204, lon: 73.8567);
    await settle();

    expect(container.read(latestFixProvider), const GeoPoint(18.5204, 73.8567));
  });

  test('a later chit with no fix does not take the map away', () async {
    await write('outside', lat: 12.9716, lon: 77.5946);
    await write('indoors, no signal');
    await settle();

    expect(
      container.read(latestFixProvider),
      const GeoPoint(12.9716, 77.5946),
      reason: 'the newest *pinned* chit, not the newest chit',
    );
  });
}
