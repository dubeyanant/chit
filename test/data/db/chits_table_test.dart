import 'package:chitta/data/db/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Matcher refusedByACheck() => throwsA(
    predicate(
      (Object e) => e.toString().contains('CHECK constraint failed'),
      'a CHECK constraint refusing the row',
    ),
  );

  Future<void> insert({
    Value<String?> body = const Value<String?>.absent(),
    Value<String?> audioPath = const Value<String?>.absent(),
    Value<int?> audioMs = const Value<int?>.absent(),
    Value<double?> lat = const Value<double?>.absent(),
    Value<double?> lon = const Value<double?>.absent(),
  }) => db
      .into(db.chits)
      .insert(
        ChitsCompanion.insert(
          id: 'a',
          createdAt: 0,
          localDay: 20260915,
          updatedAt: 0,
          body: body,
          audioPath: audioPath,
          audioMs: audioMs,
          lat: lat,
          lon: lon,
        ),
      );

  group('the invariant of README §5', () {
    test('a row with neither text nor audio is refused', () {
      expect(insert, refusedByACheck());
    });

    test('text of nothing but spaces is refused', () {
      expect(
        () => insert(body: const Value<String?>('   ')),
        refusedByACheck(),
      );
    });

    test('a recording without a length is refused', () {
      expect(
        () => insert(audioPath: const Value<String?>('audio/a.m4a')),
        refusedByACheck(),
      );
    });

    test('half a coordinate is refused', () {
      expect(
        () => insert(
          body: const Value<String?>('Train 20 late.'),
          lat: const Value<double?>(19.07),
        ),
        refusedByACheck(),
      );
    });

    test('all three legal shapes are accepted', () async {
      await insert(body: const Value<String?>('Train 20 late.'));
      await db.delete(db.chits).go();

      await insert(
        body: const Value<String?>('Train 20 late.'),
        audioPath: const Value<String?>('audio/a.m4a'),
        audioMs: const Value<int?>(9000),
      );
      await db.delete(db.chits).go();

      await insert(
        audioPath: const Value<String?>('audio/a.m4a'),
        audioMs: const Value<int?>(9000),
      );

      expect(await db.select(db.chits).get(), hasLength(1));
    });
  });

  group('the shape of the table', () {
    Future<String> schemaOf(String name) async {
      final QueryRow row = await db
          .customSelect(
            'SELECT sql FROM sqlite_master WHERE name = ?',
            variables: <Variable<Object>>[Variable<String>(name)],
          )
          .getSingle();
      return row.read<String>('sql');
    }

    test('the primary key survives the custom constraints beside it', () async {
      expect(await schemaOf('chits'), contains('PRIMARY KEY'));
    });

    test(
      'the one index of DATA-MODEL.md §1 reads in the archive\'s order',
      () async {
        final String index = await schemaOf('chits_day_time');
        expect(index, contains('local_day'));
        expect(index, contains('created_at'));
        expect(
          index.indexOf('local_day'),
          lessThan(index.indexOf('created_at')),
          reason:
              'the archive orders by day first; a suffix column cannot '
              'answer a prefix query',
        );
      },
    );
  });
}
