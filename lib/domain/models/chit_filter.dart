import 'package:freezed_annotation/freezed_annotation.dart';

import '../tags/chit_tags.dart';
import 'chit.dart';
import 'motion_state.dart';
import 'weather_condition.dart';

part 'chit_filter.freezed.dart';

/// The four axes find filters on — BEHAVIOUR.md §4.6.
///
/// **Any within an axis, all across them.** Picking `raining` and `windy` asks
/// for either; picking `raining` and `@anant` asks for both. That is what a
/// reader means by narrowing: another word in the same row widens the net,
/// another row tightens it.
@freezed
abstract class ChitFilter with _$ChitFilter {
  const ChitFilter._();

  const factory ChitFilter({
    @Default(<WeatherCondition>{}) Set<WeatherCondition> weather,
    @Default(<MotionState>{}) Set<MotionState> motion,

    /// [TagSpan.key]s, so `@Anant_Dubey` and `@anant dubey` are one person.
    @Default(<String>{}) Set<String> people,

    /// [TagSpan.key]s, the same way.
    @Default(<String>{}) Set<String> topics,
  }) = _ChitFilter;

  /// Nothing picked, which shows everything rather than nothing.
  static const ChitFilter none = ChitFilter();

  bool get isEmpty =>
      weather.isEmpty && motion.isEmpty && people.isEmpty && topics.isEmpty;

  /// How many words are lit, for the line that says what is being shown.
  int get chosen =>
      weather.length + motion.length + people.length + topics.length;

  /// Whether [chit] passes, given the [tags] already read out of its words.
  ///
  /// [tags] is passed in rather than parsed here: a filter is re-applied on
  /// every tap, and re-reading every chit's words each time is the version
  /// that gets slow.
  bool allows(Chit chit, Set<String> tags) =>
      _passes(weather, chit.weather) &&
      _passes(motion, chit.motion) &&
      _tagged(people, tags) &&
      _tagged(topics, tags);

  static bool _passes<T>(Set<T> chosen, T? had) =>
      chosen.isEmpty || (had != null && chosen.contains(had));

  static bool _tagged(Set<String> chosen, Set<String> tags) =>
      chosen.isEmpty || chosen.any(tags.contains);
}
