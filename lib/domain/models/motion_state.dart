/// What the phone was doing when a chit was opened — BEHAVIOUR.md §3.6.
///
/// A closed set of four, in the spirit of the five words of `WeatherCondition`: the
/// states a person would name, and no others. Unlike a condition, a motion
/// state is never written as a word — it is drawn as an icon (ADR-039),
/// because "traveling" is a fact about the phone rather than a feeling about
/// the moment, and the words for it all read like a fitness tracker.
///
/// **There is no `running` and no `cycling`.** Motion is read off the speed of
/// a position fix (ADR-037), and speed cannot tell a cyclist at 20 km/h from a
/// car in traffic at 20 km/h. A state the signal cannot defend is the same
/// mistake as a temperature reading on a chit.
///
/// The thresholds that produce these live in one pure function,
/// `domain/motion/motion_ladder.dart`.
enum MotionState {
  /// Still — or moving too uncertainly to claim otherwise.
  ///
  /// **Stored, and never drawn.** It is what most chits are, and an icon on
  /// every one of them would distinguish nothing; it is also where an unusable
  /// reading lands, so that noise can never put a plane on a chit.
  stationary,

  /// On foot.
  walking,

  /// A ground vehicle — car, bus, train, bicycle. The distinctions between
  /// those are not ones speed can make.
  traveling,

  /// Airborne.
  ///
  /// Rare in practice: most devices disable GPS in airplane mode, and without
  /// a fix there is no speed. ADR-037 states that cost rather than hiding it.
  flying,
}
