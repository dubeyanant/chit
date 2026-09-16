import '../models/ambient_stamp.dart';
import '../models/motion_state.dart';
import '../models/weather_condition.dart';

/// The one ambient fact a stamp draws beside the time — **ADR-038**.
///
/// BEHAVIOUR.md §3.6 sets three facts on one line with no separators, and the
/// argument for that spacing is that three things are already the most an
/// 11.5px row can carry. Motion is a fourth signal, so it does not get a
/// fourth slot: weather and motion **share** one, and [of] ranks them.
///
/// Sealed rather than a nullable pair, so the widget that draws this switches
/// exhaustively with no `default:` (CLAUDE.md §4.1). A sixth condition or a
/// fifth motion state then arrives as a compile error rather than as a blank
/// space on a chit.
sealed class AmbientFact {
  const AmbientFact._();

  /// The fact worth drawing on [stamp], or `null` if there is none.
  ///
  /// **The ladder, highest first:** flying, travelling, raining, windy,
  /// walking, overcast, clear and clear night. Being in the air says more
  /// about a moment than the sky does, and inside a vehicle the weather
  /// outside is no longer what you are in; below that, rain is a feeling and
  /// outranks a mode of travel you are not using.
  ///
  /// `MotionState.stationary` is **never** a fact. It is what most chits are,
  /// and a mark on all of them would distinguish nothing — the same argument
  /// §3.6 makes for keeping the pin out of the thread. It is also where an
  /// unusable speed lands (ADR-037), so silence is what noise produces.
  ///
  /// The consequence worth noticing: a chit written at a desk in the rain
  /// still reads `raining`, exactly as it did before motion existed. An icon
  /// appears only by displacing a word, and only when the phone was moving.
  static AmbientFact? of(AmbientStamp stamp) {
    final MotionState? motion = stamp.motion;
    final WeatherCondition? weather = stamp.weather;

    for (final AmbientFact candidate in <AmbientFact>[
      if (motion == MotionState.flying) const MotionFact(MotionState.flying),
      if (motion == MotionState.traveling)
        const MotionFact(MotionState.traveling),
      if (weather == WeatherCondition.raining)
        const WeatherFact(WeatherCondition.raining),
      if (weather == WeatherCondition.windy)
        const WeatherFact(WeatherCondition.windy),
      if (motion == MotionState.walking) const MotionFact(MotionState.walking),
      if (weather == WeatherCondition.overcast)
        const WeatherFact(WeatherCondition.overcast),
      if (weather == WeatherCondition.clear)
        const WeatherFact(WeatherCondition.clear),
      if (weather == WeatherCondition.clearNight)
        const WeatherFact(WeatherCondition.clearNight),
    ]) {
      return candidate;
    }

    return null;
  }
}

/// A motion state worth drawing. An icon, never a word (ADR-039).
final class MotionFact extends AmbientFact {
  /// Wraps [state], which is never `MotionState.stationary`.
  const MotionFact(this.state) : super._();

  /// What the phone was doing.
  final MotionState state;

  @override
  bool operator ==(Object other) => other is MotionFact && other.state == state;

  @override
  int get hashCode => state.hashCode;

  @override
  String toString() => 'MotionFact(${state.name})';
}

/// A condition worth drawing. One of the five words of §3.6.
final class WeatherFact extends AmbientFact {
  /// Wraps [condition].
  const WeatherFact(this.condition) : super._();

  /// The condition when the chit was opened.
  final WeatherCondition condition;

  @override
  bool operator ==(Object other) =>
      other is WeatherFact && other.condition == condition;

  @override
  int get hashCode => condition.hashCode;

  @override
  String toString() => 'WeatherFact(${condition.name})';
}
