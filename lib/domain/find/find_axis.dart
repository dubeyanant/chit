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
