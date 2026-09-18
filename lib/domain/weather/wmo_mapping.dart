import '../models/weather_condition.dart';

/// A WMO code, the daylight flag and the wind, to one of the five words of
/// BEHAVIOUR.md §3.6.
///
/// One pure function, no I/O and no Flutter, for the reason
/// `domain/motion/motion_ladder.dart` is: **the mapping is ours, not
/// Open-Meteo's.** Which code counts as *raining* and how hard the wind has to
/// blow before a chit says *windy* are product decisions about what a person
/// would write down, and they belong in the layer that owns the vocabulary.
///
/// **Nothing falls through to `null` by accident.** Every code in the published
/// WMO table resolves here, and an unrecognised one is a *stated* outcome —
/// `null`, not drawn (ADR-007) — rather than a gap somebody forgot.
abstract final class WmoMapping {
  /// **7.0 m/s — 25 km/h.** At or above this a chit says `windy`.
  ///
  /// Beaufort 4: raises dust and loose paper, moves small branches. It is the
  /// point where wind stops being weather you are in and becomes weather you
  /// would mention.
  ///
  /// **Chosen high on purpose.** A coastal city sits at 15–20 km/h most
  /// afternoons, and a word that is true every day carries nothing — the same
  /// failure that keeps `MotionState.stationary` off the screen. Untuned:
  /// nobody has watched this fire against a real forecast.
  static const double windyFloor = 7;

  /// The word for one reading, or `null` if there is nothing to say.
  ///
  /// **Precedence: raining, then windy, then overcast, then the clear sky.**
  /// §3.6 says `windy` *"wins over `clear` and never over `raining`"* and is
  /// silent about overcast; this puts wind above it too. A grey day is the
  /// default state of a sky and a windy one is not, so the wind is the fact
  /// worth the slot.
  ///
  /// **Wind is read even when the code is not recognised.** It is a measured
  /// number rather than a category, so it stands on its own — an unknown code
  /// in a gale still says `windy`.
  ///
  /// **A clear sky with no [isDay] says nothing at all.** `clear` and
  /// `clearNight` are the same sky and differ only by the flag, so without it
  /// there is no honest answer — and guessing `clear` at two in the morning is
  /// the kind of confident wrongness ADR-007 would rather do without.
  static WeatherCondition? from({
    required int? code,
    required bool? isDay,
    required double? windSpeed,
  }) {
    if (code != null && _falling.contains(code)) {
      return WeatherCondition.raining;
    }

    if (windSpeed != null && !windSpeed.isNaN && windSpeed >= windyFloor) {
      return WeatherCondition.windy;
    }

    if (code == null) return null;
    if (_closed.contains(code)) return WeatherCondition.overcast;

    if (_open.contains(code)) {
      if (isDay == null) return null;
      return isDay ? WeatherCondition.clear : WeatherCondition.clearNight;
    }

    // A code outside the published table. Open-Meteo has never sent one, and
    // if it starts, a chit carries a time and no word rather than a guess.
    return null;
  }

  /// Anything liquid coming down, and the storms that bring it.
  ///
  /// Drizzle, freezing drizzle, rain, freezing rain, rain showers, and
  /// thunderstorms with and without hail.
  static const Set<int> _falling = <int>{
    51, 53, 55, // drizzle: light, moderate, dense
    56, 57, // freezing drizzle: light, dense
    61, 63, 65, // rain: slight, moderate, heavy
    66, 67, // freezing rain: light, heavy
    80, 81, 82, // rain showers: slight, moderate, violent
    95, // thunderstorm
    96, 99, // thunderstorm with hail
  };

  /// The sky is closed — and, for now, snowing.
  ///
  /// Overcast, fog and rime fog belong here plainly. **Snow is here because
  /// §3.6 has no word for it**, and of the five it may have, `overcast` is the
  /// only one that is not actually false during snowfall: the sky *is* closed.
  /// Calling it `raining` would put a wrong noun in somebody's own journal,
  /// which is a worse failure than under-describing it. OPEN-QUESTIONS.md carries
  /// this as an open item — a sixth word is the real answer, the day chit ships
  /// somewhere it snows.
  static const Set<int> _closed = <int>{
    3, // overcast
    45, 48, // fog, depositing rime fog
    71, 73, 75, // snow: slight, moderate, heavy
    77, // snow grains
    85, 86, // snow showers: slight, heavy
  };

  /// Clear, or near enough that a person would call it clear.
  ///
  /// §3.6's word is *"clear or nearly clear"*, so mainly-clear and partly-cloudy
  /// sit here rather than under [_closed]. Only a fully overcast sky is closed.
  static const Set<int> _open = <int>{
    0, // clear sky
    1, // mainly clear
    2, // partly cloudy
  };

  /// Every code this mapping recognises. The test walks it to prove that
  /// nothing in the published table falls through.
  static Set<int> get known => <int>{..._falling, ..._closed, ..._open};
}
