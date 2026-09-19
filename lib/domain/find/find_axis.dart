import '../ambient/ambient_words.dart';
import '../models/motion_state.dart';
import '../models/weather_condition.dart';
import '../tags/chit_tags.dart';

/// The four things find can look down — BEHAVIOUR.md §4.6.
enum FindAxis {
  /// The sky a chit was written under, alphabetical.
  weather(
    slug: 'weather',
    label: 'weather',
    empty: 'No chit knows what the sky was doing.',
  ),

  /// Whether the phone was moving, alphabetical.
  motion(
    slug: 'motion',
    label: 'motion',
    empty: 'Nothing was written on the move.',
  ),

  /// `@somebody`, most written first.
  people(
    slug: 'people',
    label: 'people',
    empty: 'No chit names anybody yet. Write @ and a name.',
  ),

  /// `#something`, most written first.
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

  /// What the axis is called in a route.
  final String slug;

  /// What the axis is called on screen.
  final String label;

  /// What the screen says when the axis has nothing to offer.
  final String empty;

  /// Whether this axis is ordered by how often it was written.
  ///
  /// The two ambient axes have a handful of values apiece and a reader knows
  /// all of them, so alphabetical is the order that lets them be *found*. The
  /// two tag axes grow without limit, so the useful ones have to rise.
  bool get byFrequency => switch (this) {
    FindAxis.weather || FindAxis.motion => false,
    FindAxis.people || FindAxis.topics => true,
  };

  /// The word a value is *drawn* as, given the slug a route carries.
  ///
  /// **A slug is not a word** (ADR-088): the two ambient axes are keyed on the
  /// enum name, so `clearNight` and `traveling` are what a route holds while
  /// `clear night` and `travelling` are what §3.6 says out loud. A tag's slug
  /// is already its folded label, so it is its own word.
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

  /// The axis a tag written in a chit belongs to (ADR-086).
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

/// Where a list of [count] rows sits in a viewport [height] tall.
///
/// **Bottom when it fits, top when it does not** (ADR-084). Measured rather
/// than guessed at a count, because the answer depends on the handset: five
/// weathers fit anywhere, and a year of tags fits nowhere. A list that has
/// overflowed must start at the top, or its first row — the one written most
/// — would open off the top of the screen.
bool sitsAtBottom({
  required int count,
  required double rowHeight,
  required double height,
}) => count * rowHeight <= height;
