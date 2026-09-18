import 'package:drift/drift.dart';

import '../../../domain/models/day_summary.dart';
import '../../../domain/models/motion_state.dart';
import '../../../domain/models/weather_condition.dart';
import '../app_database.dart';
import '../tables/chits_table.dart';

part 'chit_dao.g.dart';

@DriftAccessor(tables: <Type>[Chits])
class ChitDao extends DatabaseAccessor<AppDatabase> with _$ChitDaoMixin {
  ChitDao(super.db);

  Stream<List<ChitRow>> watchDay(int localDay) =>
      (select(chits)
            ..where(($ChitsTable t) => t.localDay.equals(localDay))
            ..orderBy(<OrderClauseGenerator<$ChitsTable>>[
              ($ChitsTable t) => OrderingTerm.desc(t.createdAt),
            ]))
          .watch();

  Stream<List<ChitRow>> watchDayRange({
    required int fromDay,
    required int toDay,
  }) =>
      (select(chits)
            ..where(
              ($ChitsTable t) => t.localDay.isBetweenValues(fromDay, toDay),
            )
            ..orderBy(<OrderClauseGenerator<$ChitsTable>>[
              ($ChitsTable t) => OrderingTerm.asc(t.createdAt),
            ]))
          .watch();

  Stream<List<DaySummary>> watchDaySummaries({
    required int fromDay,
    required int toDay,
  }) {
    final Expression<int> count = chits.id.count();
    final JoinedSelectStatement<$ChitsTable, ChitRow> query = selectOnly(chits)
      ..addColumns(<Expression<Object>>[chits.localDay, count])
      ..where(chits.localDay.isBetweenValues(fromDay, toDay))
      ..groupBy(<Expression<Object>>[chits.localDay])
      ..orderBy(<OrderingTerm>[OrderingTerm.asc(chits.localDay)]);

    return query.watch().map(
      (List<TypedResult> rows) => <DaySummary>[
        for (final TypedResult row in rows)
          DaySummary(
            localDay: row.read(chits.localDay)!,
            count: row.read(count)!,
          ),
      ],
    );
  }

  Stream<List<int>> watchWrittenMonths() {
    const CustomExpression<int> month = CustomExpression<int>(
      'local_day / 100',
    );
    final JoinedSelectStatement<$ChitsTable, ChitRow> query = selectOnly(chits)
      ..addColumns(<Expression<Object>>[month])
      ..groupBy(<Expression<Object>>[month])
      ..orderBy(<OrderingTerm>[OrderingTerm.asc(month)]);

    return query.watch().map(
      (List<TypedResult> rows) => <int>[
        for (final TypedResult row in rows) row.read(month)!,
      ],
    );
  }

  Stream<List<ChitRow>> watchArchive({
    required int fromDay,
    required int toDay,
  }) =>
      (select(chits)
            ..where(
              ($ChitsTable t) => t.localDay.isBetweenValues(fromDay, toDay),
            )
            ..orderBy(<OrderClauseGenerator<$ChitsTable>>[
              ($ChitsTable t) => OrderingTerm.desc(t.localDay),
              ($ChitsTable t) => OrderingTerm.desc(t.createdAt),
            ]))
          .watch();

  Future<ChitRow?> byId(String id) => (select(
    chits,
  )..where(($ChitsTable t) => t.id.equals(id))).getSingleOrNull();

  Future<void> insertRow(ChitsCompanion row) => into(chits).insert(row);

  Future<void> transact(Future<void> Function() writes) => transaction(writes);

  Future<int> updateChitOf({
    required String id,
    required String? text,
    required Value<String?> audioPath,
    required Value<int?> audioMs,
    required DateTime updatedAt,
  }) => (update(chits)..where(($ChitsTable t) => t.id.equals(id))).write(
    ChitsCompanion(
      body: Value<String?>(text),
      audioPath: audioPath,
      audioMs: audioMs,
      updatedAt: Value<int>(updatedAt.millisecondsSinceEpoch),
    ),
  );

  Future<int> deleteRow(String id) =>
      (delete(chits)..where(($ChitsTable t) => t.id.equals(id))).go();

  Future<int> updateAmbientOf({
    required String id,
    required WeatherCondition? weather,
    required double? lat,
    required double? lon,
    required MotionState? motion,
  }) => (update(chits)..where(($ChitsTable t) => t.id.equals(id))).write(
    ChitsCompanion(
      weather: Value<WeatherCondition?>(weather),
      lat: Value<double?>(lat),
      lon: Value<double?>(lon),
      motion: Value<MotionState?>(motion),
    ),
  );

  Future<List<ChitRow>> rowsWithIdPrefix(String prefix) =>
      (select(chits)
            ..where(($ChitsTable t) => t.id.like('$prefix%'))
            ..orderBy(<OrderClauseGenerator<$ChitsTable>>[
              ($ChitsTable t) => OrderingTerm.asc(t.createdAt),
            ]))
          .get();

  Future<int> deleteWithIdPrefix(String prefix) =>
      (delete(chits)..where(($ChitsTable t) => t.id.like('$prefix%'))).go();

  Future<List<String>> audioPaths() async {
    final JoinedSelectStatement<$ChitsTable, ChitRow> query = selectOnly(chits)
      ..addColumns(<Expression<Object>>[chits.audioPath])
      ..where(chits.audioPath.isNotNull());

    final List<TypedResult> rows = await query.get();
    return <String>[
      for (final TypedResult row in rows) row.read(chits.audioPath)!,
    ];
  }
}
