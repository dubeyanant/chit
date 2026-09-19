@Assert(
  "text == null || text != ''",
  'empty text is no text: an empty field is the chit §3.1 refuses to save',
)
import 'package:freezed_annotation/freezed_annotation.dart';

import 'ambient_stamp.dart';
import 'motion_state.dart';
import 'weather_condition.dart';

part 'chit.freezed.dart';

@freezed
abstract class Chit with _$Chit {
  const Chit._();

  @Assert(
    'text != null || audioPath != null',
    'a chit with neither text nor audio is not a chit — README §5',
  )
  @Assert(
    "text == null || text != ''",
    'empty text is no text: an empty field is the chit §3.1 refuses to save',
  )
  @Assert(
    '(lat == null) == (lon == null)',
    'a coordinate is both halves or neither',
  )
  @Assert(
    '(audioPath == null) == (audioDuration == null)',
    'a recording has a length; a length without a recording is nothing',
  )
  const factory Chit({
    required String id,

    required DateTime createdAt,

    required int localDay,

    required DateTime updatedAt,

    String? text,

    String? audioPath,

    Duration? audioDuration,

    WeatherCondition? weather,

    double? lat,

    double? lon,

    MotionState? motion,
  }) = _Chit;

  static int localDayOf(DateTime when) =>
      when.year * 10000 + when.month * 100 + when.day;

  static DateTime startOfLocalDay(DateTime when, {int offsetDays = 0}) =>
      DateTime(when.year, when.month, when.day + offsetDays);

  static DateTime dateOf(int localDay) =>
      DateTime(localDay ~/ 10000, (localDay ~/ 100) % 100, localDay % 100);

  AmbientStamp get stamp => AmbientStamp(
    capturedAt: createdAt,
    weather: weather,
    lat: lat,
    lon: lon,
    motion: motion,
  );

  bool get wasEdited => updatedAt.isAfter(createdAt);

  bool get hasText => text != null;

  bool get hasAudio => audioPath != null;
}
