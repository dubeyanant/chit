import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/clock.dart';
import '../../domain/models/ambient_stamp.dart';
import '../../domain/models/audio_edit.dart';
import '../../domain/models/chit.dart';
import '../../domain/models/day_summary.dart';
import '../../domain/models/motion_state.dart';
import '../../domain/models/weather_condition.dart';
import '../../domain/repositories/chit_repository.dart';
import '../audio/audio_store.dart';
import '../db/app_database.dart';
import '../db/daos/chit_dao.dart';

final class ChitRepositoryImpl implements ChitRepository {
  const ChitRepositoryImpl({
    required this._dao,
    required this._audio,
    required this._clock,
  });

  static const Uuid _uuid = Uuid();

  final ChitDao _dao;
  final AudioStore _audio;
  final Clock _clock;

  @override
  Future<Chit> save({
    required AmbientStamp stamp,
    String? text,
    String? audioTempPath,
    Duration? audioDuration,
  }) async {
    final String? words = switch (text?.trim()) {
      null || '' => null,
      final String trimmed => trimmed,
    };

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

    final String? audioPath = audioTempPath == null
        ? null
        : await _audio.keep(tempPath: audioTempPath, chitId: id);

    final Chit chit = Chit(
      id: id,
      createdAt: stamp.capturedAt,
      localDay: Chit.localDayOf(stamp.capturedAt),

      updatedAt: stamp.capturedAt,
      text: words,
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
  Future<void> update({
    required String id,
    required String? text,
    AudioEdit audio = const AudioEdit.keep(),
  }) async {
    final Chit? existing = await byId(id);
    if (existing == null) {
      throw StateError('no chit with id $id');
    }

    final String? words = switch (text?.trim()) {
      null || '' => null,
      final String trimmed => trimmed,
    };

    final bool willHaveAudio = switch (audio) {
      KeepAudio() => existing.hasAudio,
      RemoveAudio() => false,
      ReplaceAudio() => true,
    };
    if (words == null && !willHaveAudio) {
      throw ArgumentError(
        'a chit with neither text nor audio is not a chit — README §5',
      );
    }

    final (Value<String?> audioPath, Value<int?> audioMs) = switch (audio) {
      KeepAudio() => (
        const Value<String?>.absent(),
        const Value<int?>.absent(),
      ),
      RemoveAudio() => (const Value<String?>(null), const Value<int?>(null)),
      ReplaceAudio(:final String tempPath, :final Duration duration) => (
        Value<String?>(await _audio.keep(tempPath: tempPath, chitId: id)),
        Value<int?>(duration.inMilliseconds),
      ),
    };

    await _dao.updateChitOf(
      id: id,
      text: words,
      audioPath: audioPath,
      audioMs: audioMs,
      updatedAt: _clock.now(),
    );

    if (audio is RemoveAudio && existing.audioPath != null) {
      await _audio.delete(existing.audioPath!);
    }
  }

  @override
  Future<void> delete(String id) async {
    final Chit? existing = await byId(id);
    if (existing == null) return;

    await _dao.deleteRow(id);
    if (existing.audioPath != null) {
      await _audio.delete(existing.audioPath!);
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
  Stream<List<Chit>> watchArchive({required int fromDay, required int toDay}) =>
      _dao.watchArchive(fromDay: fromDay, toDay: toDay).map(_chitsOf);

  @override
  Stream<bool> watchAnyWritten() => _dao.watchAnyWritten();

  @override
  Stream<List<Chit>> watchEvery() => _dao.watchEvery().map(_chitsOf);

  @override
  Future<void> discardTemp(String tempPath) => _audio.discardTemp(tempPath);

  @override
  Future<void> reconcileAudio() async => _audio.sweep(await _dao.audioPaths());

  List<Chit> _chitsOf(List<ChitRow> rows) => <Chit>[
    for (final ChitRow row in rows) _chitOf(row),
  ];

  Chit _chitOf(ChitRow row) => Chit(
    id: row.id,
    createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
    localDay: row.localDay,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
    text: row.body,
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
