import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/motion_state.dart';
import '../../domain/models/weather_condition.dart';
import 'daos/chit_dao.dart';
import 'tables/chits_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: <Type>[Chits], daos: <Type>[ChitDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.onDevice() : super(driftDatabase(name: 'chit'));

  @override
  int get schemaVersion => 1;

  static const List<SchemaStep> steps = <SchemaStep>[];

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    onUpgrade: (Migrator m, int from, int to) async {
      int at = from;

      for (final SchemaStep step in steps) {
        if (at < step.to && to >= step.to) {
          await step.run(m, this);
          at = step.to;
        }
      }

      if (at != to) {
        throw StateError(
          'chit cannot carry a v$at database to v$to: no step covers it. '
          'A shipped version needs a SchemaStep beside it and a snapshot in '
          'drift_schemas/ — DATA-MODEL.md §5.',
        );
      }
    },
  );
}

@immutable
final class SchemaStep {
  const SchemaStep({required this.to, required this.run});

  final int to;

  final Future<void> Function(Migrator m, AppDatabase db) run;
}

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final AppDatabase db = AppDatabase.onDevice();
  ref.onDispose(() {
    unawaited(db.close());
  });
  return db;
}
