/// The weather words BEHAVIOUR.md §3.6 allows, and no others.
///
/// A closed set is the point. Conditions are recorded as words because
/// "raining" is a feeling and a temperature reading is not, and a word that
/// is not one of these five has no place on a chit.
///
/// Open-Meteo's WMO codes are mapped into this enum by one pure function in
/// `domain/weather/wmo_mapping.dart` — M3. The mapping is ours, not the
/// service's, which is why it lives in this layer.
enum WeatherCondition {
  /// Rain, drizzle, showers, thunderstorms — anything falling.
  raining,

  /// Clear or nearly clear, in daylight.
  clear,

  /// Cloud, fog, haze. The sky is closed.
  overcast,

  /// Our own threshold on wind speed rather than a WMO code. It wins over
  /// [clear] and never over [raining].
  windy,

  /// [clear], after dark. The one condition that knows what time it is.
  clearNight,
}
