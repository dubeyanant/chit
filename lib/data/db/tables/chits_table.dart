import 'package:drift/drift.dart';

import '../../../domain/models/chit.dart';
import '../../../domain/models/weather_condition.dart';

/// The one table. DATA-MODEL.md §1.
///
/// Three indexes: [Chits.localDay] because every calendar and archive query
/// groups on it, [Chits.createdAt] because the arc and the ordering within a
/// day read it, and [Chits.weather] because backlog item 2 wants it and it
/// costs nothing now.
///
/// **The row class is `ChitRow`, not `Chit`.** Drift would name it `Chit` and
/// collide with the domain model, and the two are not the same thing: this one
/// is a row, the other is a chit. The repository is where one becomes the
/// other.
///
/// **The column is `body`, and the field it carries is a chit's `text`.**
/// DATA-MODEL.md §1 used to name this column `text`. That name cannot be used:
/// `text` is Drift's own column builder, so a getter called `text` is a
/// compile error — and the versioned-schema classes that
/// `drift_dev schema generate` writes for the migration test derive their Dart
/// names from the SQL, so a column called `text` breaks the migration harness
/// at exactly the version where it first has work to do. `body` is the word
/// the design documents already use for a chit's words, and the rename stops
/// at this layer: README §5 still calls the field `text`, and so does the
/// domain model.
@DataClassName('ChitRow')
@TableIndex(name: 'chits_local_day', columns: <Symbol>{#localDay})
@TableIndex(name: 'chits_created_at', columns: <Symbol>{#createdAt})
@TableIndex(name: 'chits_weather', columns: <Symbol>{#weather})
class Chits extends Table {
  /// A UUID generated on the device (ADR-004), so a row keeps its identity if
  /// a sync layer ever arrives.
  TextColumn get id => text()();

  /// When the chit was opened, as UTC milliseconds.
  IntColumn get createdAt => integer()();

  /// `yyyymmdd`, device-local, computed once at write time (ADR-006).
  IntColumn get localDay => integer()();

  /// What the chit says. `NULL` only for BEHAVIOUR.md §3.5.
  TextColumn get body => text().nullable()();

  /// The recording, relative to the app documents directory (ADR-008).
  TextColumn get audioPath => text().nullable()();

  /// Where the words came from. `NULL` exactly when the text is.
  TextColumn get textOrigin => textEnum<TextOrigin>().nullable()();

  /// How long the recording runs, in milliseconds.
  IntColumn get audioMs => integer().nullable()();

  /// One of the five words of BEHAVIOUR.md §3.6, or `NULL` if it never
  /// arrived (ADR-007).
  TextColumn get weather => textEnum<WeatherCondition>().nullable()();

  /// Latitude. Stored, never displayed.
  RealColumn get lat => real().nullable()();

  /// Longitude. Stored, never displayed.
  RealColumn get lon => real().nullable()();

  /// When the text was last changed (ADR-014), as UTC milliseconds.
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  /// The invariant of README §5, in the place that cannot be bypassed.
  ///
  /// The domain model asserts the same three things and the repository tests
  /// exercise them, but an assert is compiled out of a release build and a
  /// test only runs on the code it was pointed at. This one holds for every
  /// write the app will ever make, including the ones a future milestone
  /// writes without reading DATA-MODEL.md §2 first.
  @override
  List<String> get customConstraints => <String>[
    'CHECK (body IS NOT NULL OR audio_path IS NOT NULL)',
    'CHECK ((body IS NULL) = (text_origin IS NULL))',
    'CHECK (body IS NULL OR length(trim(body)) > 0)',
    'CHECK ((audio_path IS NULL) = (audio_ms IS NULL))',
    'CHECK ((lat IS NULL) = (lon IS NULL))',
  ];
}
