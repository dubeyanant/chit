import 'package:freezed_annotation/freezed_annotation.dart';

import 'motion_state.dart';
import 'weather_condition.dart';

part 'ambient_stamp.freezed.dart';

@freezed
abstract class AmbientStamp with _$AmbientStamp {
  const AmbientStamp._();

  @Assert(
    '(lat == null) == (lon == null)',
    'a coordinate is both halves or neither — half a fix is not a place',
  )
  const factory AmbientStamp({
    required DateTime capturedAt,

    WeatherCondition? weather,

    double? lat,

    double? lon,

    MotionState? motion,
  }) = _AmbientStamp;

  bool get hasLocation => lat != null;
}
