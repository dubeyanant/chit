import 'package:freezed_annotation/freezed_annotation.dart';

import 'motion_state.dart';
import 'weather_condition.dart';

part 'ambient_stamp.freezed.dart';

/// What was captured around a chit: a time, and maybe a condition, a place and
/// a motion.
///
/// They travel together because they are captured at the same instant and
/// drawn as one row (BEHAVIOUR.md §3.6, §4.1). Everything but the time is
/// best-effort and never blocks (ADR-007) — a signal that did not arrive is
/// `null` here, and a `null` is not drawn rather than drawn as an absence.
///
/// [capturedAt] is the moment the chit was *opened*, which is what README §2
/// means by "captured automatically when a chit is opened". It becomes the
/// chit's `createdAt`, so the time on the stamp and the mark on the day arc
/// are the same fact.
///
/// **Only one of [weather] and [motion] is ever drawn** — ADR-038 ranks them
/// and `domain/ambient/ambient_fact.dart` picks the winner. Both are stored
/// regardless: what a chit records and what a chit shows are different
/// questions, and the ladder answers only the second.
@freezed
abstract class AmbientStamp with _$AmbientStamp {
  /// Lets this class carry getters. Freezed requires it.
  const AmbientStamp._();

  /// A stamp. [lat] and [lon] are both halves of one signal or neither.
  @Assert(
    '(lat == null) == (lon == null)',
    'a coordinate is both halves or neither — half a fix is not a place',
  )
  const factory AmbientStamp({
    /// The moment the chit was opened, in the device's local zone.
    required DateTime capturedAt,

    /// The condition, if the call came back in time.
    WeatherCondition? weather,

    /// Latitude, if a fix came back in time. Stored, never displayed.
    double? lat,

    /// Longitude, if a fix came back in time. Stored, never displayed.
    double? lon,

    /// What the phone was doing, read off the same fix (ADR-037).
    ///
    /// `null` when no usable speed arrived — which is most of the time
    /// indoors, and always when location was refused.
    MotionState? motion,
  }) = _AmbientStamp;

  /// Whether a fix was captured. BEHAVIOUR.md §3.6 draws a pin from this and
  /// nothing more — never a name, never a coordinate, never a map.
  bool get hasLocation => lat != null;
}
