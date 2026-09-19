import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/ambient/ambient_words.dart';
import '../../../domain/find/find_axis.dart';
import '../../../domain/models/chit.dart';
import '../../../domain/models/motion_state.dart';
import '../../../domain/models/weather_condition.dart';
import '../../../domain/repositories/chit_repository.dart';
import '../../../domain/tags/chit_tags.dart';
import '../../../shared/day_group.dart';

part 'find_providers.g.dart';

@immutable
final class FindValue {
  const FindValue({
    required this.slug,
    required this.label,
    required this.count,
  });

  final String slug;

  final String label;

  final int count;

  @override
  bool operator ==(Object other) =>
      other is FindValue &&
      other.slug == slug &&
      other.label == label &&
      other.count == count;

  @override
  int get hashCode => Object.hash(slug, label, count);

  @override
  String toString() => 'FindValue($slug, $count)';
}

@riverpod
Stream<List<Chit>> everyChit(Ref ref) =>
    ref.watch(chitRepositoryProvider).watchEvery();

@riverpod
class AxisValues extends _$AxisValues {
  @override
  Map<FindAxis, List<FindValue>>? build() =>
      switch (ref.watch(everyChitProvider)) {
        AsyncData<List<Chit>>(:final List<Chit> value) => _read(value),
        _ => stateOrNull,
      };

  static Map<FindAxis, List<FindValue>> _read(List<Chit> chits) {
    final Map<String, int> weather = <String, int>{};
    final Map<String, int> motion = <String, int>{};
    final Map<String, _Counted> people = <String, _Counted>{};
    final Map<String, _Counted> topics = <String, _Counted>{};

    for (final Chit chit in chits) {
      if (chit.weather != null) {
        weather.update(chit.weather!.name, _up, ifAbsent: _one);
      }

      if (chit.motion != null && chit.motion != MotionState.stationary) {
        motion.update(chit.motion!.name, _up, ifAbsent: _one);
      }

      if (!chit.hasText) continue;

      for (final TagSpan tag in ChitTags.tagsIn(chit.text!)) {
        final Map<String, _Counted> into = switch (tag.kind) {
          TagKind.person => people,
          TagKind.topic => topics,
        };

        into.update(
          tag.key,
          (_Counted it) => it.more(),
          ifAbsent: () => _Counted(tag.label, 1),
        );
      }
    }

    return <FindAxis, List<FindValue>>{
      FindAxis.weather: _alphabetical(<FindValue>[
        for (final WeatherCondition it in WeatherCondition.values)
          if (weather[it.name] case final int n)
            FindValue(slug: it.name, label: it.word, count: n),
      ]),
      FindAxis.motion: _alphabetical(<FindValue>[
        for (final MotionState it in MotionState.values)
          if (motion[it.name] case final int n)
            FindValue(slug: it.name, label: it.word, count: n),
      ]),
      FindAxis.people: _byFrequency(people),
      FindAxis.topics: _byFrequency(topics),
    };
  }

  static int _up(int n) => n + 1;

  static int _one() => 1;

  static List<FindValue> _alphabetical(List<FindValue> values) =>
      values..sort((FindValue a, FindValue b) => a.label.compareTo(b.label));

  static List<FindValue> _byFrequency(Map<String, _Counted> counted) {
    final List<FindValue> values = <FindValue>[
      for (final MapEntry<String, _Counted> it in counted.entries)
        FindValue(
          slug: it.key.split(':').last,
          label: it.value.label,
          count: it.value.count,
        ),
    ];

    values.sort((FindValue a, FindValue b) {
      final int byCount = b.count.compareTo(a.count);
      return byCount != 0
          ? byCount
          : a.label.toLowerCase().compareTo(b.label.toLowerCase());
    });

    return values;
  }
}

@immutable
final class _Counted {
  const _Counted(this.label, this.count);

  final String label;
  final int count;

  _Counted more() => _Counted(label, count + 1);
}

@riverpod
List<DayGroup>? chitsOfValue(Ref ref, FindAxis axis, String slug) {
  final List<Chit>? chits = switch (ref.watch(everyChitProvider)) {
    AsyncData<List<Chit>>(:final List<Chit> value) => value,
    _ => null,
  };

  if (chits == null) return null;

  return groupByDay(<Chit>[
    for (final Chit chit in chits)
      if (_carries(chit, axis, slug)) chit,
  ]);
}

bool _carries(Chit chit, FindAxis axis, String slug) => switch (axis) {
  FindAxis.weather => chit.weather?.name == slug,
  FindAxis.motion => chit.motion?.name == slug,
  FindAxis.people => _tagged(chit, 'person:$slug'),
  FindAxis.topics => _tagged(chit, 'topic:$slug'),
};

bool _tagged(Chit chit, String key) {
  if (!chit.hasText) return false;
  for (final TagSpan tag in ChitTags.tagsIn(chit.text!)) {
    if (tag.key == key) return true;
  }
  return false;
}
