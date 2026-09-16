import 'package:chit/data/db/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

/// The migration harness, built before there is anything to migrate.
///
/// That is the point of it. The first migration is not the moment to discover
/// that the snapshot was never taken, that the tooling does not run on this
/// machine, or that a column name the generator cannot spell has been sitting
/// in the schema since v1 — which is exactly what this harness caught when it
/// was written, and why the text column is called `body` (DATA-MODEL.md §1).
///
/// The snapshots live in `drift_schemas/` and are taken with
/// `dart run drift_dev schema dump lib/data/db/app_database.dart drift_schemas/`;
/// the helper this reads is written by
/// `dart run drift_dev schema generate drift_schemas/ test/data/db/generated/`.
/// **Once a version has shipped to a real handset, its snapshot and its
/// migration step are never edited** (DATA-MODEL.md §6).
void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    // This file opens several databases on purpose — one per schema claim.
    // The warning it would otherwise print is about production code sharing
    // an executor, which is not what is happening here.
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('there is a committed snapshot for every schema version', () {
    // The test that will actually fire one day. Bumping `schemaVersion`
    // without dumping the snapshot beside it leaves the next migration with
    // nothing to migrate *from*, and nothing else would notice.
    expect(
      GeneratedHelper.versions,
      contains(AppDatabase(NativeDatabase.memory()).schemaVersion),
      reason:
          'run: dart run drift_dev schema dump lib/data/db/app_database.dart '
          'drift_schemas/ — then regenerate test/data/db/generated/',
    );
  });

  test('a database created at v1 is the v1 that was committed', () async {
    final DatabaseConnection connection = await verifier.startAt(1);
    final AppDatabase db = AppDatabase(connection);

    await verifier.migrateAndValidate(db, 1);
    await db.close();
  });

  test('a v1 database migrates to the v2 that was committed', () async {
    // The claim this file was built for, finally firing. v2 adds
    // `chits.motion` (ADR-037), and this is the only thing that checks the
    // step actually produces the shape the Dart code expects rather than
    // merely running without throwing.
    final DatabaseConnection connection = await verifier.startAt(1);
    final AppDatabase db = AppDatabase(connection);

    await verifier.migrateAndValidate(db, 2);
    await db.close();
  });

  test('a chit written at v1 survives the upgrade, with a null motion', () async {
    // What a migration is actually for, and the claim `migrateAndValidate`
    // does not make: it checks the *shape* that comes out, not that the rows
    // that were already there came through it. `motion` is nullable precisely
    // so a chit written before M3 answers *I do not know* rather than carrying
    // a backfilled guess (DATA-MODEL.md §6).
    final InitializedSchema schema = await verifier.schemaAt(1);

    schema.rawDatabase.execute(
      'INSERT INTO chits (id, created_at, local_day, body, text_origin, '
      'updated_at) VALUES (?, ?, ?, ?, ?, ?)',
      <Object>[
        'written-before-m3',
        1757980000000,
        20260915,
        'the rain has not stopped',
        'typed',
        1757980000000,
      ],
    );

    final AppDatabase db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 2);
    await db.close();

    final Map<String, Object?> row = schema.rawDatabase.select(
      'SELECT body, motion FROM chits WHERE id = ?',
      <Object>['written-before-m3'],
    ).single;

    expect(row['body'], 'the rain has not stopped');
    expect(row['motion'], null, reason: 'nothing is backfilled');
  });

  test('the schema the code expects is the schema createAll() writes', () async {
    // Not the same claim as the one above. This one catches a table changed in
    // Dart without a version bump — the failure mode that makes every query
    // after it wrong in a way no query reports.
    final AppDatabase db = AppDatabase(NativeDatabase.memory());

    await db.validateDatabaseSchema();
    await db.close();
  });

  test('an upgrade with no step refuses loudly', () async {
    // v1 → v2 exists now. v2 → v3 does not, and what is checked here is that
    // the strategy fails rather than opening a database whose shape nobody has
    // looked at. This assertion moves up a version every time one ships.
    final AppDatabase db = AppDatabase(NativeDatabase.memory());
    await expectLater(
      db.migration.onUpgrade(Migrator(db), 2, 3),
      throwsA(isA<StateError>()),
    );
    await db.close();
  });
}
