import 'dart:io';

import 'package:chit/core/clock.dart';
import 'package:chit/data/audio/audio_store.dart';
import 'package:chit/data/db/app_database.dart';
import 'package:chit/data/repositories/chit_repository_impl.dart';
import 'package:chit/domain/models/ambient_stamp.dart';
import 'package:chit/domain/models/chit.dart';
import 'package:chit/domain/repositories/chit_repository.dart';
import 'package:chit/features/editor/application/editor_controller.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';

/// What the editor loads, through a bare `ProviderContainer` — ADR-031.
///
/// M6 group B is a screen you can reach and read, so what a test can hold is
/// what it reads: the right chit, and the null that means the row has gone.
/// Whether the slip *looks* like the one in the thread is a device check and
/// PROGRESS.md carries it.
void main() {
  late Directory root;
  late AppDatabase db;
  late ChitRepository repo;
  late ProviderContainer container;

  /// Thursday 17 September 2026, 3pm.
  final DateTime afternoon = DateTime(2026, 9, 17, 15);

  setUp(() async {
    root = await Directory.systemTemp.createTemp('chit-editor-test');
    db = AppDatabase(NativeDatabase.memory());
    final FakeClock clock = FakeClock(afternoon);
    repo = ChitRepositoryImpl(
      dao: db.chitDao,
      audio: AudioStore(Future<Directory>.value(root)),
      clock: clock,
    );
    container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(clock),
        chitRepositoryProvider.overrideWithValue(repo),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
    if (root.existsSync()) await root.delete(recursive: true);
  });

  Future<Chit> given(String text) => repo.save(
    stamp: AmbientStamp(capturedAt: afternoon),
    text: text,
  );

  test('it opens on the chit the id names', () async {
    final Chit wanted = await given('Room too cold, again.');
    await given('And a second one, so the id has to do work.');

    final Chit? got = await container.read(
      editorChitProvider(wanted.id).future,
    );

    expect(got, wanted);
  });

  test('an id with no row answers null, and the screen leaves on it', () async {
    // An id outlives its row across a delete (group F), which is the case
    // this exists for. `byId` answers null rather than throwing, because
    // nothing here is a fault.
    expect(await container.read(editorChitProvider('gone').future), isNull);
  });

  test('the stamp it carries is the one the row was written with', () async {
    // The editor cannot move a stamp, and the first half of that claim is
    // that it reads the stored one rather than composing a fresh one.
    final Chit saved = await given('A chit with a moment attached.');

    final Chit? got = await container.read(editorChitProvider(saved.id).future);

    expect(got!.stamp.capturedAt, saved.stamp.capturedAt);
    expect(got.localDay, saved.localDay);
  });
}
