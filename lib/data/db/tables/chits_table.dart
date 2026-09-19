import 'package:drift/drift.dart';

import '../../../domain/models/motion_state.dart';
import '../../../domain/models/weather_condition.dart';

@DataClassName('ChitRow')
@TableIndex(name: 'chits_day_time', columns: <Symbol>{#localDay, #createdAt})
class Chits extends Table {
  TextColumn get id => text()();

  IntColumn get createdAt => integer()();

  IntColumn get localDay => integer()();

  TextColumn get body => text().nullable()();

  TextColumn get audioPath => text().nullable()();

  IntColumn get audioMs => integer().nullable()();

  TextColumn get photoPath => text().nullable()();

  TextColumn get weather => textEnum<WeatherCondition>().nullable()();

  RealColumn get lat => real().nullable()();

  RealColumn get lon => real().nullable()();

  TextColumn get motion => textEnum<MotionState>().nullable()();

  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<String> get customConstraints => <String>[
    'CHECK (COALESCE(body, audio_path, photo_path) IS NOT NULL)',
    'CHECK (body IS NULL OR length(trim(body)) > 0)',
    'CHECK ((audio_path IS NULL) = (audio_ms IS NULL))',
    'CHECK ((lat IS NULL) = (lon IS NULL))',
  ];
}
