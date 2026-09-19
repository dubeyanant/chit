import 'package:chitt/data/db/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('there is a committed snapshot for every schema version', () {
    final AppDatabase db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(
      GeneratedHelper.versions,
      contains(db.schemaVersion),
      reason:
          'bumping schemaVersion without dumping the snapshot beside it leaves '
          'the next migration with nothing to migrate from.\n\n'
          'dart run drift_dev schema dump lib/data/db/app_database.dart '
          'drift_schemas/\n'
          'dart run drift_dev schema generate drift_schemas/ '
          'test/data/db/generated/',
    );
  });

  test('a database created at v1 is the v1 that was committed', () async {
    final DatabaseConnection connection = await verifier.startAt(1);
    final AppDatabase db = AppDatabase(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 1);
  });

  test('every step is gated on both ends, and they only go up', () {
    int last = 1;

    for (final SchemaStep step in AppDatabase.steps) {
      expect(
        step.to,
        greaterThan(last),
        reason: 'steps run in order and each one ends higher than the last',
      );
      last = step.to;
    }

    final AppDatabase db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(
      last,
      db.schemaVersion,
      reason:
          'the last step must land on the version the app expects — a '
          'schemaVersion with no step under it is a database the app cannot '
          'build, and it is caught here rather than on somebody handset',
    );
  });

  test('a version with no step under it refuses to open', () async {
    final AppDatabase db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await expectLater(
      db.migration.onUpgrade(Migrator(db), db.schemaVersion, 99),
      throwsA(isA<StateError>()),
    );
  });

  test('rows written before a migration survive it', () async {
    final DatabaseConnection connection = await verifier.startAt(1);
    final AppDatabase db = AppDatabase(connection);
    addTearDown(db.close);

    await db.chitDao.insertRow(
      ChitsCompanion.insert(
        id: 'kept',
        createdAt: DateTime(2026, 9, 15, 9, 30).millisecondsSinceEpoch,
        localDay: 20260915,
        updatedAt: DateTime(2026, 9, 15, 9, 30).millisecondsSinceEpoch,
        body: const Value<String>('Written before the upgrade.'),
      ),
    );

    await verifier.migrateAndValidate(db, db.schemaVersion);

    final ChitRow? back = await db.chitDao.byId('kept');

    expect(
      back?.body,
      'Written before the upgrade.',
      reason:
          'migrateAndValidate inspects the schema, not the contents, and a '
          'table rebuild produces the right shape while losing what was in it',
    );
  });
}
