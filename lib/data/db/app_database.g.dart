// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ChitsTable extends Chits with TableInfo<$ChitsTable, ChitRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localDayMeta = const VerificationMeta(
    'localDay',
  );
  @override
  late final GeneratedColumn<int> localDay = GeneratedColumn<int>(
    'local_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioPathMeta = const VerificationMeta(
    'audioPath',
  );
  @override
  late final GeneratedColumn<String> audioPath = GeneratedColumn<String>(
    'audio_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioMsMeta = const VerificationMeta(
    'audioMs',
  );
  @override
  late final GeneratedColumn<int> audioMs = GeneratedColumn<int>(
    'audio_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<WeatherCondition?, String>
  weather = GeneratedColumn<String>(
    'weather',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<WeatherCondition?>($ChitsTable.$converterweathern);
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
    'lon',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MotionState?, String> motion =
      GeneratedColumn<String>(
        'motion',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<MotionState?>($ChitsTable.$convertermotionn);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    localDay,
    body,
    audioPath,
    audioMs,
    weather,
    lat,
    lon,
    motion,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chits';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChitRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('local_day')) {
      context.handle(
        _localDayMeta,
        localDay.isAcceptableOrUnknown(data['local_day']!, _localDayMeta),
      );
    } else if (isInserting) {
      context.missing(_localDayMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('audio_path')) {
      context.handle(
        _audioPathMeta,
        audioPath.isAcceptableOrUnknown(data['audio_path']!, _audioPathMeta),
      );
    }
    if (data.containsKey('audio_ms')) {
      context.handle(
        _audioMsMeta,
        audioMs.isAcceptableOrUnknown(data['audio_ms']!, _audioMsMeta),
      );
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    }
    if (data.containsKey('lon')) {
      context.handle(
        _lonMeta,
        lon.isAcceptableOrUnknown(data['lon']!, _lonMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChitRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChitRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      localDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_day'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      ),
      audioPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_path'],
      ),
      audioMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}audio_ms'],
      ),
      weather: $ChitsTable.$converterweathern.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}weather'],
        ),
      ),
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      ),
      lon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lon'],
      ),
      motion: $ChitsTable.$convertermotionn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}motion'],
        ),
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ChitsTable createAlias(String alias) {
    return $ChitsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<WeatherCondition, String, String>
  $converterweather = const EnumNameConverter<WeatherCondition>(
    WeatherCondition.values,
  );
  static JsonTypeConverter2<WeatherCondition?, String?, String?>
  $converterweathern = JsonTypeConverter2.asNullable($converterweather);
  static JsonTypeConverter2<MotionState, String, String> $convertermotion =
      const EnumNameConverter<MotionState>(MotionState.values);
  static JsonTypeConverter2<MotionState?, String?, String?> $convertermotionn =
      JsonTypeConverter2.asNullable($convertermotion);
}

class ChitRow extends DataClass implements Insertable<ChitRow> {
  /// A UUID generated on the device (ADR-004), so a row keeps its identity if
  /// a sync layer ever arrives.
  final String id;

  /// When the chit was opened, as UTC milliseconds.
  final int createdAt;

  /// `yyyymmdd`, device-local, computed once at write time (ADR-006).
  final int localDay;

  /// What the chit says. `NULL` on a chit that is only a recording.
  final String? body;

  /// The recording, relative to the app documents directory (ADR-008).
  final String? audioPath;

  /// How long the recording runs, in milliseconds.
  final int? audioMs;

  /// One of the five words of BEHAVIOUR.md §3.6, or `NULL` if it never
  /// arrived (ADR-007).
  final WeatherCondition? weather;

  /// Latitude. Stored, never displayed.
  final double? lat;

  /// Longitude. Stored, never displayed.
  final double? lon;

  /// What the phone was doing when the chit was opened, or `NULL` if no
  /// usable speed arrived (ADR-037). Added in schema v2.
  ///
  /// **No index and no check constraint.** Nothing queries it — [Chits.weather]
  /// is indexed because a backlog item wants it, and this has no such caller.
  /// And `CHECK (motion IS NULL OR lat IS NOT NULL)` would be true today only
  /// because motion happens to be read off the fix; that is a fact about this
  /// milestone's implementation, not about what a chit is, and the other five
  /// constraints below are all the second kind.
  final MotionState? motion;

  /// When the text was last changed (ADR-014), as UTC milliseconds.
  final int updatedAt;
  const ChitRow({
    required this.id,
    required this.createdAt,
    required this.localDay,
    this.body,
    this.audioPath,
    this.audioMs,
    this.weather,
    this.lat,
    this.lon,
    this.motion,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['local_day'] = Variable<int>(localDay);
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<String>(body);
    }
    if (!nullToAbsent || audioPath != null) {
      map['audio_path'] = Variable<String>(audioPath);
    }
    if (!nullToAbsent || audioMs != null) {
      map['audio_ms'] = Variable<int>(audioMs);
    }
    if (!nullToAbsent || weather != null) {
      map['weather'] = Variable<String>(
        $ChitsTable.$converterweathern.toSql(weather),
      );
    }
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lon != null) {
      map['lon'] = Variable<double>(lon);
    }
    if (!nullToAbsent || motion != null) {
      map['motion'] = Variable<String>(
        $ChitsTable.$convertermotionn.toSql(motion),
      );
    }
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  ChitsCompanion toCompanion(bool nullToAbsent) {
    return ChitsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      localDay: Value(localDay),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      audioPath: audioPath == null && nullToAbsent
          ? const Value.absent()
          : Value(audioPath),
      audioMs: audioMs == null && nullToAbsent
          ? const Value.absent()
          : Value(audioMs),
      weather: weather == null && nullToAbsent
          ? const Value.absent()
          : Value(weather),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lon: lon == null && nullToAbsent ? const Value.absent() : Value(lon),
      motion: motion == null && nullToAbsent
          ? const Value.absent()
          : Value(motion),
      updatedAt: Value(updatedAt),
    );
  }

  factory ChitRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChitRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      localDay: serializer.fromJson<int>(json['localDay']),
      body: serializer.fromJson<String?>(json['body']),
      audioPath: serializer.fromJson<String?>(json['audioPath']),
      audioMs: serializer.fromJson<int?>(json['audioMs']),
      weather: $ChitsTable.$converterweathern.fromJson(
        serializer.fromJson<String?>(json['weather']),
      ),
      lat: serializer.fromJson<double?>(json['lat']),
      lon: serializer.fromJson<double?>(json['lon']),
      motion: $ChitsTable.$convertermotionn.fromJson(
        serializer.fromJson<String?>(json['motion']),
      ),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'localDay': serializer.toJson<int>(localDay),
      'body': serializer.toJson<String?>(body),
      'audioPath': serializer.toJson<String?>(audioPath),
      'audioMs': serializer.toJson<int?>(audioMs),
      'weather': serializer.toJson<String?>(
        $ChitsTable.$converterweathern.toJson(weather),
      ),
      'lat': serializer.toJson<double?>(lat),
      'lon': serializer.toJson<double?>(lon),
      'motion': serializer.toJson<String?>(
        $ChitsTable.$convertermotionn.toJson(motion),
      ),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  ChitRow copyWith({
    String? id,
    int? createdAt,
    int? localDay,
    Value<String?> body = const Value.absent(),
    Value<String?> audioPath = const Value.absent(),
    Value<int?> audioMs = const Value.absent(),
    Value<WeatherCondition?> weather = const Value.absent(),
    Value<double?> lat = const Value.absent(),
    Value<double?> lon = const Value.absent(),
    Value<MotionState?> motion = const Value.absent(),
    int? updatedAt,
  }) => ChitRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    localDay: localDay ?? this.localDay,
    body: body.present ? body.value : this.body,
    audioPath: audioPath.present ? audioPath.value : this.audioPath,
    audioMs: audioMs.present ? audioMs.value : this.audioMs,
    weather: weather.present ? weather.value : this.weather,
    lat: lat.present ? lat.value : this.lat,
    lon: lon.present ? lon.value : this.lon,
    motion: motion.present ? motion.value : this.motion,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ChitRow copyWithCompanion(ChitsCompanion data) {
    return ChitRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      localDay: data.localDay.present ? data.localDay.value : this.localDay,
      body: data.body.present ? data.body.value : this.body,
      audioPath: data.audioPath.present ? data.audioPath.value : this.audioPath,
      audioMs: data.audioMs.present ? data.audioMs.value : this.audioMs,
      weather: data.weather.present ? data.weather.value : this.weather,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      motion: data.motion.present ? data.motion.value : this.motion,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChitRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('localDay: $localDay, ')
          ..write('body: $body, ')
          ..write('audioPath: $audioPath, ')
          ..write('audioMs: $audioMs, ')
          ..write('weather: $weather, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('motion: $motion, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    localDay,
    body,
    audioPath,
    audioMs,
    weather,
    lat,
    lon,
    motion,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChitRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.localDay == this.localDay &&
          other.body == this.body &&
          other.audioPath == this.audioPath &&
          other.audioMs == this.audioMs &&
          other.weather == this.weather &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.motion == this.motion &&
          other.updatedAt == this.updatedAt);
}

class ChitsCompanion extends UpdateCompanion<ChitRow> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<int> localDay;
  final Value<String?> body;
  final Value<String?> audioPath;
  final Value<int?> audioMs;
  final Value<WeatherCondition?> weather;
  final Value<double?> lat;
  final Value<double?> lon;
  final Value<MotionState?> motion;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const ChitsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.localDay = const Value.absent(),
    this.body = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.audioMs = const Value.absent(),
    this.weather = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.motion = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChitsCompanion.insert({
    required String id,
    required int createdAt,
    required int localDay,
    this.body = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.audioMs = const Value.absent(),
    this.weather = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.motion = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       localDay = Value(localDay),
       updatedAt = Value(updatedAt);
  static Insertable<ChitRow> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? localDay,
    Expression<String>? body,
    Expression<String>? audioPath,
    Expression<int>? audioMs,
    Expression<String>? weather,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<String>? motion,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (localDay != null) 'local_day': localDay,
      if (body != null) 'body': body,
      if (audioPath != null) 'audio_path': audioPath,
      if (audioMs != null) 'audio_ms': audioMs,
      if (weather != null) 'weather': weather,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (motion != null) 'motion': motion,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChitsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<int>? localDay,
    Value<String?>? body,
    Value<String?>? audioPath,
    Value<int?>? audioMs,
    Value<WeatherCondition?>? weather,
    Value<double?>? lat,
    Value<double?>? lon,
    Value<MotionState?>? motion,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return ChitsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      localDay: localDay ?? this.localDay,
      body: body ?? this.body,
      audioPath: audioPath ?? this.audioPath,
      audioMs: audioMs ?? this.audioMs,
      weather: weather ?? this.weather,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      motion: motion ?? this.motion,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (localDay.present) {
      map['local_day'] = Variable<int>(localDay.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (audioPath.present) {
      map['audio_path'] = Variable<String>(audioPath.value);
    }
    if (audioMs.present) {
      map['audio_ms'] = Variable<int>(audioMs.value);
    }
    if (weather.present) {
      map['weather'] = Variable<String>(
        $ChitsTable.$converterweathern.toSql(weather.value),
      );
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (motion.present) {
      map['motion'] = Variable<String>(
        $ChitsTable.$convertermotionn.toSql(motion.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChitsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('localDay: $localDay, ')
          ..write('body: $body, ')
          ..write('audioPath: $audioPath, ')
          ..write('audioMs: $audioMs, ')
          ..write('weather: $weather, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('motion: $motion, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ChitsTable chits = $ChitsTable(this);
  late final Index chitsLocalDay = Index(
    'chits_local_day',
    'CREATE INDEX chits_local_day ON chits (local_day)',
  );
  late final Index chitsCreatedAt = Index(
    'chits_created_at',
    'CREATE INDEX chits_created_at ON chits (created_at)',
  );
  late final Index chitsWeather = Index(
    'chits_weather',
    'CREATE INDEX chits_weather ON chits (weather)',
  );
  late final ChitDao chitDao = ChitDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    chits,
    chitsLocalDay,
    chitsCreatedAt,
    chitsWeather,
  ];
}

typedef $$ChitsTableCreateCompanionBuilder = ChitsCompanion Function({
  required String id,
  required int createdAt,
  required int localDay,
  Value<String?> body,
  Value<String?> audioPath,
  Value<int?> audioMs,
  Value<WeatherCondition?> weather,
  Value<double?> lat,
  Value<double?> lon,
  Value<MotionState?> motion,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$ChitsTableUpdateCompanionBuilder = ChitsCompanion Function({
  Value<String> id,
  Value<int> createdAt,
  Value<int> localDay,
  Value<String?> body,
  Value<String?> audioPath,
  Value<int?> audioMs,
  Value<WeatherCondition?> weather,
  Value<double?> lat,
  Value<double?> lon,
  Value<MotionState?> motion,
  Value<int> updatedAt,
  Value<int> rowid,
});

class $$ChitsTableFilterComposer extends Composer<_$AppDatabase, $ChitsTable> {
  $$ChitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localDay => $composableBuilder(
    column: $table.localDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get audioMs => $composableBuilder(
    column: $table.audioMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<WeatherCondition?, WeatherCondition, String>
  get weather => $composableBuilder(
    column: $table.weather,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MotionState?, MotionState, String>
  get motion => $composableBuilder(
    column: $table.motion,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChitsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChitsTable> {
  $$ChitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localDay => $composableBuilder(
    column: $table.localDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get audioMs => $composableBuilder(
    column: $table.audioMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weather => $composableBuilder(
    column: $table.weather,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motion => $composableBuilder(
    column: $table.motion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChitsTable> {
  $$ChitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get localDay =>
      $composableBuilder(column: $table.localDay, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get audioPath =>
      $composableBuilder(column: $table.audioPath, builder: (column) => column);

  GeneratedColumn<int> get audioMs =>
      $composableBuilder(column: $table.audioMs, builder: (column) => column);

  GeneratedColumnWithTypeConverter<WeatherCondition?, String> get weather =>
      $composableBuilder(column: $table.weather, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MotionState?, String> get motion =>
      $composableBuilder(column: $table.motion, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ChitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChitsTable,
          ChitRow,
          $$ChitsTableFilterComposer,
          $$ChitsTableOrderingComposer,
          $$ChitsTableAnnotationComposer,
          $$ChitsTableCreateCompanionBuilder,
          $$ChitsTableUpdateCompanionBuilder,
          (ChitRow, BaseReferences<_$AppDatabase, $ChitsTable, ChitRow>),
          ChitRow,
          PrefetchHooks Function()
        > {
  $$ChitsTableTableManager(_$AppDatabase db, $ChitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> localDay = const Value.absent(),
                Value<String?> body = const Value.absent(),
                Value<String?> audioPath = const Value.absent(),
                Value<int?> audioMs = const Value.absent(),
                Value<WeatherCondition?> weather = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lon = const Value.absent(),
                Value<MotionState?> motion = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChitsCompanion(
                id: id,
                createdAt: createdAt,
                localDay: localDay,
                body: body,
                audioPath: audioPath,
                audioMs: audioMs,
                weather: weather,
                lat: lat,
                lon: lon,
                motion: motion,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required int localDay,
                Value<String?> body = const Value.absent(),
                Value<String?> audioPath = const Value.absent(),
                Value<int?> audioMs = const Value.absent(),
                Value<WeatherCondition?> weather = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lon = const Value.absent(),
                Value<MotionState?> motion = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ChitsCompanion.insert(
                id: id,
                createdAt: createdAt,
                localDay: localDay,
                body: body,
                audioPath: audioPath,
                audioMs: audioMs,
                weather: weather,
                lat: lat,
                lon: lon,
                motion: motion,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChitsTable, ChitRow>(table),
                  BaseReferences<_$AppDatabase, $ChitsTable, ChitRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChitsTable,
      ChitRow,
      $$ChitsTableFilterComposer,
      $$ChitsTableOrderingComposer,
      $$ChitsTableAnnotationComposer,
      $$ChitsTableCreateCompanionBuilder,
      $$ChitsTableUpdateCompanionBuilder,
      (ChitRow, BaseReferences<_$AppDatabase, $ChitsTable, ChitRow>),
      ChitRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ChitsTableTableManager get chits =>
      $$ChitsTableTableManager(_db, _db.chits);
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The database, opened once and closed with the app.

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

/// The database, opened once and closed with the app.

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  /// The database, opened once and closed with the app.
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'db0fc1ed01b10fe9d0204e3174f1ed7bbc213393';
