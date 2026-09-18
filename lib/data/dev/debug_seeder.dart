import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../../core/clock.dart';
import '../../domain/models/chit.dart';
import '../../domain/models/motion_state.dart';
import '../../domain/models/weather_condition.dart';
import '../audio/audio_store.dart';
import '../db/app_database.dart';
import '../db/daos/chit_dao.dart';

typedef SeedOutcome = ({int rows, int recordings});

final class DebugSeeder {
  const DebugSeeder({
    required this._dao,
    required this._audio,
    required this._clock,
    required this._temp,
  });

  static const String idPrefix = 'seed-';

  static const String modeSeed = 'seed';

  static const String modeClear = 'clear';

  static int get count => _fixture.length;

  final ChitDao _dao;
  final AudioStore _audio;
  final Clock _clock;
  final Future<Directory> _temp;

  Future<String> apply(String mode) async {
    switch (mode) {
      case modeSeed:
        final SeedOutcome done = await seed();
        return 'chit: seeded ${done.rows} rows and ${done.recordings} '
            'recordings (${count - done.rows} were already there)';
      case modeClear:
        final SeedOutcome done = await clear();
        return 'chit: cleared ${done.rows} seeded rows and '
            '${done.recordings} recordings';
      default:
        throw ArgumentError.value(
          mode,
          'mode',
          'CHIT_SEED takes "$modeSeed" or "$modeClear"',
        );
    }
  }

  Future<SeedOutcome> seed() async {
    final DateTime now = _clock.now();
    int rows = 0;
    int recordings = 0;

    for (final (int index, _Seed seed) in _fixture.indexed) {
      final String id = _idOf(index);
      if (await _dao.byId(id) != null) continue;

      final DateTime at = Chit.startOfLocalDay(
        now,
        offsetDays: -seed.daysAgo,
      ).add(Duration(hours: seed.hour, minutes: seed.minute));

      String? audioPath;
      if (seed.audioSeconds != null) {
        audioPath = await _audio.keep(
          tempPath: await _placeholderRecording(id, seed.audioSeconds!),
          chitId: id,
        );
        recordings++;
      }

      final bool pinned = seed.pinned;
      await _dao.insertRow(
        ChitsCompanion.insert(
          id: id,
          createdAt: at.millisecondsSinceEpoch,
          localDay: Chit.localDayOf(at),

          updatedAt: at.millisecondsSinceEpoch,
          body: Value<String?>(seed.text),
          audioPath: Value<String?>(audioPath),
          audioMs: Value<int?>(
            seed.audioSeconds == null ? null : seed.audioSeconds! * 1000,
          ),
          weather: Value<WeatherCondition?>(seed.weather),
          lat: Value<double?>(pinned ? _lat + index * _jitter : null),
          lon: Value<double?>(pinned ? _lon - index * _jitter : null),
          motion: Value<MotionState?>(seed.motion),
        ),
      );
      rows++;
    }

    return (rows: rows, recordings: recordings);
  }

  Future<SeedOutcome> clear() async {
    int recordings = 0;

    for (final ChitRow row in await _dao.rowsWithIdPrefix(idPrefix)) {
      final String? path = row.audioPath;
      if (path == null) continue;

      final File file = await _audio.resolve(path);
      if (file.existsSync()) {
        await file.delete();
        recordings++;
      }
    }

    final int rows = await _dao.deleteWithIdPrefix(idPrefix);
    return (rows: rows, recordings: recordings);
  }

  static String _idOf(int index) =>
      '$idPrefix${(index + 1).toString().padLeft(2, '0')}';

  Future<String> _placeholderRecording(String id, int seconds) async {
    final Directory dir = await _temp;
    if (!dir.existsSync()) await dir.create(recursive: true);

    final File file = File(p.join(dir.path, 'chit-$id.m4a'));
    await file.writeAsBytes(_tone(seconds));
    return file.path;
  }

  static Uint8List _tone(int seconds) {
    const int rate = 8000;
    const int amplitude = 6000;
    final int samples = rate * seconds;
    final int dataBytes = samples * 2;

    final ByteData out = ByteData(44 + dataBytes);
    void ascii(int at, String tag) {
      for (int i = 0; i < tag.length; i++) {
        out.setUint8(at + i, tag.codeUnitAt(i));
      }
    }

    ascii(0, 'RIFF');
    out.setUint32(4, 36 + dataBytes, Endian.little);
    ascii(8, 'WAVE');
    ascii(12, 'fmt ');
    out
      ..setUint32(16, 16, Endian.little)
      ..setUint16(20, 1, Endian.little)
      ..setUint16(22, 1, Endian.little)
      ..setUint32(24, rate, Endian.little)
      ..setUint32(28, rate * 2, Endian.little)
      ..setUint16(32, 2, Endian.little)
      ..setUint16(34, 16, Endian.little);
    ascii(36, 'data');
    out.setUint32(40, dataBytes, Endian.little);

    for (int i = 0; i < samples; i++) {
      final double wave = math.sin(2 * math.pi * 440 * i / rate);
      out.setInt16(44 + i * 2, (wave * amplitude).round(), Endian.little);
    }

    return out.buffer.asUint8List();
  }

  static const double _lat = 19.076;
  static const double _lon = 72.8777;

  static const double _jitter = 0.0007;

  static const List<_Seed> _fixture = <_Seed>[
    _Seed(
      1,
      21,
      48,
      'Called Ma. Told her about the flat.',
      WeatherCondition.clearNight,
    ),
    _Seed(
      1,
      19,
      5,
      'Market. Forgot the dal again.',
      WeatherCondition.windy,
      audioSeconds: 14,
      motion: MotionState.walking,
    ),
    _Seed(
      1,
      18,
      52,
      'Bus stuck at the signal.',
      WeatherCondition.windy,
      motion: MotionState.traveling,
    ),
    _Seed(
      1,
      13,
      15,
      'Lunch at the desk. Fourth day.',
      WeatherCondition.overcast,
    ),
    _Seed(1, 7, 40, 'Ran 4k. Knee held up.', WeatherCondition.clear),

    _Seed(2, 23, 55, null, WeatherCondition.clearNight, audioSeconds: 47),
    _Seed(
      2,
      18,
      30,
      'Tea with S. Good one.',
      WeatherCondition.overcast,
      audioSeconds: 9,
    ),
    _Seed(
      2,
      12,
      10,
      'Reorg meeting pushed again. Third time.',
      WeatherCondition.overcast,
      motion: MotionState.traveling,
    ),
    _Seed(2, 12, 4, 'Left the charger at home.', WeatherCondition.overcast),
    _Seed(2, 9, 10, 'Train 20 late.', WeatherCondition.raining),

    _Seed(
      4,
      22,
      2,
      'Quiet one. Early night.',
      WeatherCondition.raining,
      pinned: false,
    ),
    _Seed(
      6,
      8,
      5,
      "Didn't sleep. Room too cold, again.",
      WeatherCondition.clear,
      audioSeconds: 22,
    ),
    _Seed(6, 20, 30, 'Landlord called. Rent up.', null),
    _Seed(9, 14, 20, 'Dentist. Not as bad.', WeatherCondition.overcast),

    _Seed(
      12,
      7,
      55,
      'Ran 5k. Slow.',
      WeatherCondition.clear,
      motion: MotionState.walking,
    ),
    _Seed(12, 13, 0, 'Fish for lunch. Regret.', WeatherCondition.clear),
    _Seed(12, 21, 15, 'Read forty pages.', WeatherCondition.clearNight),

    _Seed(20, 10, 30, 'Long call with the bank.', WeatherCondition.raining),
    _Seed(
      35,
      11,
      20,
      'Window seat. Clouds all the way.',
      null,
      motion: MotionState.flying,
    ),
    _Seed(41, 9, 12, 'New month. Same desk.', WeatherCondition.clear),
  ];
}

final class _Seed {
  const _Seed(
    this.daysAgo,
    this.hour,
    this.minute,
    this.text,
    this.weather, {
    this.audioSeconds,
    this.motion,
    this.pinned = true,
  }) : assert(
         text != null || audioSeconds != null,
         'a seeded chit is still a chit — README §5',
       );

  final int daysAgo;
  final int hour;
  final int minute;
  final String? text;
  final WeatherCondition? weather;
  final int? audioSeconds;
  final MotionState? motion;
  final bool pinned;
}
