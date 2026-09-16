import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/chit.dart';
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

  @override
  int get schemaVersion => 2;

  /// One `from → to` step per version, each tested against a checked-in
  /// schema snapshot in `drift_schemas/`.
  ///
  /// **The rule: once a version has shipped to a real handset, its step is
  /// never edited** (DATA-MODEL.md §6). v1 has shipped to a handset, so its
  /// shape is settled and v2 adds to it rather than altering it.
  ///
  /// **v1 → v2 adds `chits.motion`** (ADR-037). Nullable and with no default,
  /// so every row written before M3 answers `NULL` — which is exactly what a
  /// chit opened indoors says today, and is not drawn either.
  ///
  /// **Nothing is backfilled.** There is no way to know what a phone was doing
  /// last Tuesday, and a guess written into a row is indistinguishable from a
  /// fact a month later.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    onUpgrade: (Migrator m, int from, int to) async {
      if (from == 1 && to == 2) {
        await m.addColumn(chits, chits.motion);
        return;
      }

      throw StateError('no migration from v$from to v$to exists yet');
    },
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
