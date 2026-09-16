import 'package:drift/drift.dart';

import '../../../domain/models/chit.dart';
import '../../../domain/models/day_summary.dart';
import '../app_database.dart';
import '../tables/chits_table.dart';

part 'chit_dao.g.dart';

/// Every query the screens run. DATA-MODEL.md §4.
///
/// Four queries behind six readings: the thread reads one day, the timeline
/// reads three (ADR-024), the calendar's density and its month summary are one
/// more between them, and the archive is the fourth. That is the mechanism
/// behind DESIGN-SYSTEM.md §7's requirement that the two tabs never disagree —
/// they are not kept in step, they are the same data.
///
/// *It was three until ADR-024 widened the strip under the date from one day to
/// three; the thread and the timeline can no longer be one query, and
/// DATA-MODEL.md §4 records that as a cost of the decision.*
///
/// Reads return rows. Turning a row into a [Chit] is the repository's job, and
/// so is deciding what goes into one — a caller that writes here directly can
/// break the `createdAt` / `localDay` pairing of ADR-006.
@DriftAccessor(tables: <Type>[Chits])
class ChitDao extends DatabaseAccessor<AppDatabase> with _$ChitDaoMixin {
  /// A DAO over [db].
  ChitDao(super.db);

  /// One day's chits, newest first. Today's thread.
  Stream<List<ChitRow>> watchDay(int localDay) =>
      (select(chits)
            ..where(($ChitsTable t) => t.localDay.equals(localDay))
            ..orderBy(<OrderClauseGenerator<$ChitsTable>>[
              ($ChitsTable t) => OrderingTerm.desc(t.createdAt),
            ]))
          .watch();

  /// Every chit between [fromDay] and [toDay], inclusive, **oldest first**.
  ///
  /// The timeline, and the one query that reads more than a day (ADR-024).
  /// Ascending where [watchDay] is descending, because this is read left to
  /// right along a line rather than down a thread — and a caller that wants it
  /// the other way is asking for a different screen, not a different sort.
  ///
  /// It filters on `localDay` rather than on a `createdAt` range so the
  /// window is the same local-calendar window the thread and the calendar use
  /// (ADR-006). A millisecond range over `createdAt` would include a chit
  /// written at 23:59 on the day before the window in a timezone that has
  /// since moved, and would not use the index.
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

  /// How many chits each day between [fromDay] and [toDay] holds, inclusive.
  ///
  /// Days with nothing written have no row. The calendar draws an empty tile
  /// from a missing day rather than from a zero.
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

  /// Everything, newest day first and newest chit within a day first.
  ///
  /// Ordered on `localDay` and `createdAt`, never on `updatedAt`: editing a
  /// chit does not move it, because it belongs to the moment it was written
  /// (ADR-014).
  Stream<List<ChitRow>> watchArchive({required int limit, int offset = 0}) =>
      (select(chits)
            ..orderBy(<OrderClauseGenerator<$ChitsTable>>[
              ($ChitsTable t) => OrderingTerm.desc(t.localDay),
              ($ChitsTable t) => OrderingTerm.desc(t.createdAt),
            ])
            ..limit(limit, offset: offset))
          .watch();

  /// One row, or null if there is none.
  Future<ChitRow?> byId(String id) => (select(
    chits,
  )..where(($ChitsTable t) => t.id.equals(id))).getSingleOrNull();

  /// Writes a row. The check constraints of [Chits] apply.
  Future<void> insertRow(ChitsCompanion row) => into(chits).insert(row);

  /// Changes the text of one chit and nothing else — ADR-014.
  ///
  /// `createdAt`, `localDay` and `audioPath` are not parameters, so an edit
  /// cannot move a chit in the thread, relight a calendar tile, or lose a
  /// recording. Returns the number of rows written: 0 if [id] is unknown.
  Future<int> updateTextOf({
    required String id,
    required String text,
    required TextOrigin textOrigin,
    required DateTime updatedAt,
  }) => (update(chits)..where(($ChitsTable t) => t.id.equals(id))).write(
    ChitsCompanion(
      body: Value<String?>(text),
      textOrigin: Value<TextOrigin?>(textOrigin),
      updatedAt: Value<int>(updatedAt.millisecondsSinceEpoch),
    ),
  );

  /// Every audio path the database knows about. The half of the orphan sweep
  /// that answers "is this file still somebody's recording?" (ADR-008).
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
