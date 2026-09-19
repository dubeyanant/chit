import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/ambient_stamp.dart';
import '../models/audio_edit.dart';
import '../models/chit.dart';
import '../models/day_summary.dart';
import '../models/motion_state.dart';
import '../models/weather_condition.dart';

part 'chit_repository.g.dart';

abstract interface class ChitRepository {
  Future<Chit> save({
    required AmbientStamp stamp,
    String? text,
    String? audioTempPath,
    Duration? audioDuration,
  });

  Future<void> update({
    required String id,
    required String? text,
    AudioEdit audio = const AudioEdit.keep(),
  });

  Future<void> delete(String id);

  Future<void> updateAmbient({
    required String id,
    required WeatherCondition? weather,
    required double? lat,
    required double? lon,
    required MotionState? motion,
  });

  Future<Chit?> byId(String id);

  Stream<List<Chit>> watchDay(int localDay);

  Stream<List<Chit>> watchDayRange({required int fromDay, required int toDay});

  Stream<List<DaySummary>> watchDaySummaries({
    required int fromDay,
    required int toDay,
  });

  Stream<List<int>> watchWrittenMonths();

  Stream<List<Chit>> watchArchive({required int fromDay, required int toDay});

  Stream<List<Chit>> watchEvery();

  Future<void> discardTemp(String tempPath);

  Future<void> reconcileAudio();
}

@Riverpod(keepAlive: true)
ChitRepository chitRepository(Ref ref) => throw UnimplementedError(
  'chitRepositoryProvider is overridden at the root — see main.dart',
);
