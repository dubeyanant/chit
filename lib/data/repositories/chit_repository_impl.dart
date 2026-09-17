import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/clock.dart';
import '../../domain/models/ambient_stamp.dart';
import '../../domain/models/chit.dart';
import '../../domain/models/day_summary.dart';
import '../../domain/models/motion_state.dart';
import '../../domain/models/weather_condition.dart';
import '../../domain/repositories/chit_repository.dart';
import '../audio/audio_store.dart';
import '../db/app_database.dart';
import '../db/daos/chit_dao.dart';

/// [ChitRepository] over the Drift database and the audio store.
///
/// This is the one place that knows a chit is a row plus a file. It is also
/// the one place that computes `localDay` (ADR-006) and the one place that
/// moves a recording (ADR-008) — both of those are pairs that have to be
/// written together, and a DAO caller that does it itself gets one of them
/// wrong eventually.
final class ChitRepositoryImpl implements ChitRepository {
  /// A repository over a DAO, an audio store and a clock.
  ///
  // The fields are assigned rather than declared as initialising formals
  // because a named parameter cannot be private: `prefer_initializing_formals`
  // asks for a spelling the language does not allow.
  // ignore_for_file: prefer_initializing_formals
  const ChitRepositoryImpl({
    required ChitDao dao,
    required AudioStore audio,
    required Clock clock,
  }) : _dao = dao,
       _audio = audio,
       _clock = clock;

  static const Uuid _uuid = Uuid();

  final ChitDao _dao;
  final AudioStore _audio;
  final Clock _clock;

  @override
  Future<Chit> save({
    required AmbientStamp stamp,
    String? text,
    TextOrigin? textOrigin,
    String? audioTempPath,
    Duration? audioDuration,
  }) async {
    // Blank is not a value. An untouched field and a field of spaces are the
    // same nothing, and §3.1 refuses to save either of them on its own.
    final String? words = switch (text?.trim()) {
      null || '' => null,
      final String trimmed => trimmed,
    };

    if (words != null && textOrigin == null) {
      throw ArgumentError.notNull('textOrigin');
    }
    if ((audioTempPath == null) != (audioDuration == null)) {
      throw ArgumentError(
        'a recording has a length; a length without a recording is nothing',
      );
    }
    if (words == null && audioTempPath == null) {
      throw ArgumentError(
        'a chit with neither text nor audio is not a chit — README §5',
      );
    }

    final String id = _uuid.v4();

    // The file moves first. A row pointing at a file that is not there is a
    // corruption; a file that no row points at is an orphan, and the sweep
    // collects those (ADR-008).
    final String? audioPath = audioTempPath == null
        ? null
        : await _audio.keep(tempPath: audioTempPath, chitId: id);

    final Chit chit = Chit(
      id: id,
      createdAt: stamp.capturedAt,
      localDay: Chit.localDayOf(stamp.capturedAt),
      updatedAt: _clock.now(),
      text: words,
      textOrigin: words == null ? null : textOrigin,
      audioPath: audioPath,
      audioDuration: audioDuration,
      weather: stamp.weather,
      lat: stamp.lat,
      lon: stamp.lon,
      motion: stamp.motion,
    );

    await _dao.insertRow(
      ChitsCompanion.insert(
        id: chit.id,
        createdAt: chit.createdAt.millisecondsSinceEpoch,
        localDay: chit.localDay,
        updatedAt: chit.updatedAt.millisecondsSinceEpoch,
        body: Value<String?>(chit.text),
        textOrigin: Value<TextOrigin?>(chit.textOrigin),
        audioPath: Value<String?>(chit.audioPath),
        audioMs: Value<int?>(chit.audioDuration?.inMilliseconds),
        weather: Value<WeatherCondition?>(chit.weather),
        lat: Value<double?>(chit.lat),
        lon: Value<double?>(chit.lon),
        motion: Value<MotionState?>(chit.motion),
      ),
    );

    return chit;
  }

  @override
  Future<void> updateText({
    required String id,
    required String text,
    required TextOrigin textOrigin,
  }) async {
    final String words = text.trim();
    if (words.isEmpty) {
      throw ArgumentError.value(
        text,
        'text',
        'a chit cannot be emptied from here — README §5',
      );
    }

    final int written = await _dao.updateTextOf(
      id: id,
      text: words,
      textOrigin: textOrigin,
      updatedAt: _clock.now(),
    );

    if (written == 0) {
      throw StateError('no chit with id $id');
    }
  }

  @override
  Future<void> updateAmbient({
    required String id,
    required WeatherCondition? weather,
    required double? lat,
    required double? lon,
    required MotionState? motion,
  }) async {
    // No `written == 0` check, and no throw. Unlike `updateText` there is
    // nobody waiting on this and no screen that could report it — a row gone
    // between the insert and the patch is an ordinary race (ADR-042).
    await _dao.updateAmbientOf(
      id: id,
      weather: weather,
      lat: lat,
      lon: lon,
      motion: motion,
    );
  }

  @override
  Future<Chit?> byId(String id) async {
    final ChitRow? row = await _dao.byId(id);
    return row == null ? null : _chitOf(row);
  }

  @override
  Stream<List<Chit>> watchDay(int localDay) =>
      _dao.watchDay(localDay).map(_chitsOf);

  @override
  Stream<List<Chit>> watchDayRange({
    required int fromDay,
    required int toDay,
  }) => _dao.watchDayRange(fromDay: fromDay, toDay: toDay).map(_chitsOf);

  @override
  Stream<List<DaySummary>> watchDaySummaries({
    required int fromDay,
    required int toDay,
  }) => _dao.watchDaySummaries(fromDay: fromDay, toDay: toDay);

  @override
  Stream<List<int>> watchWrittenMonths() => _dao.watchWrittenMonths();

  @override
  Stream<List<Chit>> watchArchive({required int limit, int offset = 0}) =>
      _dao.watchArchive(limit: limit, offset: offset).map(_chitsOf);

  @override
  Future<void> reconcileAudio() async => _audio.sweep(await _dao.audioPaths());

  List<Chit> _chitsOf(List<ChitRow> rows) => <Chit>[
    for (final ChitRow row in rows) _chitOf(row),
  ];

  /// A row, as the thing it is a row of.
  ///
  /// `localDay` is read from its column and never recomputed from `createdAt`
  /// — that recomputation is exactly what ADR-006 exists to prevent, and it
  /// would silently move every chit the first time the device changes zone.
  Chit _chitOf(ChitRow row) => Chit(
    id: row.id,
    createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
    localDay: row.localDay,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
    text: row.body,
    textOrigin: row.textOrigin,
    audioPath: row.audioPath,
    audioDuration: row.audioMs == null
        ? null
        : Duration(milliseconds: row.audioMs!),
    weather: row.weather,
    lat: row.lat,
    lon: row.lon,
    motion: row.motion,
  );
}
