import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/chit.dart';
import '../../../domain/models/chit_filter.dart';
import '../../../domain/models/motion_state.dart';
import '../../../domain/models/weather_condition.dart';
import '../../../domain/repositories/chit_repository.dart';
import '../../../domain/tags/chit_tags.dart';
import '../../../shared/day_group.dart';

part 'find_providers.g.dart';

/// The words find can offer, and the tags each chit carries.
///
/// Read once per change to the chits and not once per tap: the tags live in
/// the body text, so building this walks every chit's words.
@immutable
final class FindFacets {
  const FindFacets({
    required this.weather,
    required this.motion,
    required this.people,
    required this.topics,
    required this.tagsByChit,
  });

  static const FindFacets none = FindFacets(
    weather: <WeatherCondition>[],
    motion: <MotionState>[],
    people: <TagSpan>[],
    topics: <TagSpan>[],
    tagsByChit: <String, Set<String>>{},
  );

  /// Only what was actually written — a row with nothing in it is not drawn,
  /// the same reason §4.1 draws no settings control.
  final List<WeatherCondition> weather;

  final List<MotionState> motion;

  final List<TagSpan> people;

  final List<TagSpan> topics;

  /// Chit id to the [TagSpan.key]s in its words.
  final Map<String, Set<String>> tagsByChit;

  bool get isEmpty =>
      weather.isEmpty && motion.isEmpty && people.isEmpty && topics.isEmpty;
}

/// Every chit, which find narrows rather than queries.
@riverpod
Stream<List<Chit>> everyChit(Ref ref) =>
    ref.watch(chitRepositoryProvider).watchEvery();

@riverpod
class Facets extends _$Facets {
  @override
  FindFacets build() => switch (ref.watch(everyChitProvider)) {
    AsyncData<List<Chit>>(:final List<Chit> value) => _read(value),
    _ => stateOrNull ?? FindFacets.none,
  };

  static FindFacets _read(List<Chit> chits) {
    final Set<WeatherCondition> weather = <WeatherCondition>{};
    final Set<MotionState> motion = <MotionState>{};
    final Map<String, TagSpan> people = <String, TagSpan>{};
    final Map<String, TagSpan> topics = <String, TagSpan>{};
    final Map<String, Set<String>> tagsByChit = <String, Set<String>>{};

    for (final Chit chit in chits) {
      if (chit.weather != null) weather.add(chit.weather!);

      // `stationary` is stored and never drawn (§3.6.1), and a word find
      // offers is a word a chit shows.
      if (chit.motion != null && chit.motion != MotionState.stationary) {
        motion.add(chit.motion!);
      }

      if (!chit.hasText) continue;

      final List<TagSpan> tags = ChitTags.tagsIn(chit.text!);
      if (tags.isEmpty) continue;

      tagsByChit[chit.id] = <String>{for (final TagSpan tag in tags) tag.key};

      for (final TagSpan tag in tags) {
        switch (tag.kind) {
          case TagKind.person:
            people.putIfAbsent(tag.key, () => tag);
          case TagKind.topic:
            topics.putIfAbsent(tag.key, () => tag);
        }
      }
    }

    return FindFacets(
      // Ranked as §3.6.1 ranks them, so the row reads in the app's own order
      // rather than in whatever order the chits happened to arrive.
      weather: <WeatherCondition>[
        for (final WeatherCondition c in WeatherCondition.values)
          if (weather.contains(c)) c,
      ],
      motion: <MotionState>[
        for (final MotionState m in MotionState.values)
          if (motion.contains(m)) m,
      ],
      people: _alphabetical(people.values),
      topics: _alphabetical(topics.values),
      tagsByChit: tagsByChit,
    );
  }

  static List<TagSpan> _alphabetical(Iterable<TagSpan> tags) =>
      tags.toList(growable: false)
        ..sort(
          (TagSpan a, TagSpan b) =>
              a.label.toLowerCase().compareTo(b.label.toLowerCase()),
        );
}

@riverpod
class Filter extends _$Filter {
  @override
  ChitFilter build() => ChitFilter.none;

  void toggleWeather(WeatherCondition value) =>
      state = state.copyWith(weather: _flip(state.weather, value));

  void toggleMotion(MotionState value) =>
      state = state.copyWith(motion: _flip(state.motion, value));

  void togglePerson(String key) =>
      state = state.copyWith(people: _flip(state.people, key));

  void toggleTopic(String key) =>
      state = state.copyWith(topics: _flip(state.topics, key));

  void clear() => state = ChitFilter.none;

  static Set<T> _flip<T>(Set<T> chosen, T value) => <T>{
    for (final T held in chosen)
      if (held != value) held,
    if (!chosen.contains(value)) value,
  };
}

/// What find is showing: every chit the filter allows, grouped by day.
@riverpod
List<DayGroup> found(Ref ref) {
  final ChitFilter filter = ref.watch(filterProvider);
  final FindFacets facets = ref.watch(facetsProvider);

  final List<Chit> chits = switch (ref.watch(everyChitProvider)) {
    AsyncData<List<Chit>>(:final List<Chit> value) => value,
    _ => const <Chit>[],
  };

  if (filter.isEmpty) return groupByDay(chits);

  return groupByDay(<Chit>[
    for (final Chit chit in chits)
      if (filter.allows(chit, facets.tagsByChit[chit.id] ?? const <String>{}))
        chit,
  ]);
}
