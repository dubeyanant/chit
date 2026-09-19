import '../ambient/ambient_words.dart';
import '../models/motion_state.dart';
import '../models/weather_condition.dart';
import '../tags/chit_tags.dart';

enum FindAxis {
  weather(
    slug: 'weather',
    label: 'weather',
    empty: 'No chit knows what the sky was doing.',
  ),

  motion(
    slug: 'motion',
    label: 'motion',
    empty: 'Nothing was written on the move.',
  ),

  people(
    slug: 'people',
    label: 'people',
    empty: 'No chit names anybody yet. Write @ and a name.',
  ),

  topics(
    slug: 'topics',
    label: 'topics',
    empty: 'No chit carries a topic yet. Write # and a word.',
  );

  const FindAxis({
    required this.slug,
    required this.label,
    required this.empty,
  });

  final String slug;

  final String label;

  final String empty;

  bool get byFrequency => switch (this) {
    FindAxis.weather || FindAxis.motion => false,
    FindAxis.people || FindAxis.topics => true,
  };

  String wordOf(String slug) => switch (this) {
    FindAxis.weather => _weather(slug)?.word ?? slug,
    FindAxis.motion => _motion(slug)?.word ?? slug,
    FindAxis.people => slug,
    FindAxis.topics => '#$slug',
  };

  static WeatherCondition? _weather(String slug) {
    for (final WeatherCondition it in WeatherCondition.values) {
      if (it.name == slug) return it;
    }
    return null;
  }

  static MotionState? _motion(String slug) {
    for (final MotionState it in MotionState.values) {
      if (it.name == slug && it != MotionState.stationary) return it;
    }
    return null;
  }

  static FindAxis ofTag(TagKind kind) => switch (kind) {
    TagKind.person => FindAxis.people,
    TagKind.topic => FindAxis.topics,
  };

  static FindAxis? ofSlug(String slug) {
    for (final FindAxis axis in FindAxis.values) {
      if (axis.slug == slug) return axis;
    }
    return null;
  }
}

bool sitsAtBottom({
  required int count,
  required double rowHeight,
  required double height,
}) => count * rowHeight <= height;
