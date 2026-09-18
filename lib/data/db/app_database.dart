import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/motion_state.dart';
import '../../domain/models/weather_condition.dart';
import 'daos/chit_dao.dart';
import 'tables/chits_table.dart';

part 'app_database.g.dart';

/// The Drift database and its migrations. ADR-003.
///
/// One table, and the queries that read it live in [ChitDao] rather than here.
///
/// **Opening is lazy.** `driftDatabase(name: 'chit')` resolves its own path
/// when the first statement runs, so there is no async bootstrap and no
/// loading state between launch and the home screen. README §1 — *opening the
/// app costs nothing* — is a startup requirement as much as a visual one.
@DriftDatabase(tables: <Type>[Chits], daos: <Type>[ChitDao])
class AppDatabase extends _$AppDatabase {
  /// A database over [executor]. Tests pass `NativeDatabase.memory()`.
  AppDatabase(super.executor);

  /// The database as it exists on a handset: a file the platform picks.
  AppDatabase.onDevice() : super(driftDatabase(name: 'chit'));

  /// **One version, and it is whatever the tables above say** — ADR-059.
  ///
  /// It stays 1 through every schema change until chit holds data somebody
  /// would miss. *There were three, with steps and committed snapshots for
  /// each, and they went when the app was still only ever installed on the
  /// owner's own phone:* a migration is a promise to rows that exist, and
  /// keeping one for rows that do not is a cost paid on every schema change
  /// and by every session that has to read it.
  @override
  int get schemaVersion => 1;

  /// Creates the schema, and **refuses to touch a database it did not create**.
  ///
  /// The refusal is the whole of the migration story now. An install carrying
  /// an older shape has to be reinstalled, and the loud failure is what stops
  /// that being discovered as a column that is silently missing three screens
  /// later (CLAUDE.md §4.1 — fail loudly in development).
  ///
  /// **The day chit holds anything worth keeping, this comes back** — steps,
  /// snapshots under `drift_schemas/`, and a test that runs them against real
  /// rows. Open item 38 says so, and it is not a decision to make in a hurry
  /// when somebody has already lost a chit.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    onUpgrade: (Migrator _, int from, int to) async => throw StateError(
      'chit has no migrations (ADR-059). This database is v$from and the app '
      'expects v$to — reinstall the app to start from an empty one.',
    ),
  );
}

/// The database, opened once and closed with the app.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final AppDatabase db = AppDatabase.onDevice();
  ref.onDispose(() {
    unawaited(db.close());
  });
  return db;
}
