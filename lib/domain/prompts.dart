import 'package:flutter/foundation.dart';

import 'models/ambient_stamp.dart';
import 'models/weather_condition.dart';

/// Which part of the day a chit was opened in.
///
/// The bands are the ones a person would name, not even sixths of a clock.
/// [smallHours] is deliberately the hours ADR-006 works hardest to protect —
/// a chit written at 00:20 belongs to the night before, and it should not be
/// asked how the morning has started.
enum _PartOfDay {
  /// 00:00–04:59. Still up.
  smallHours,

  /// 05:00–11:59.
  morning,

  /// 12:00–16:59.
  afternoon,

  /// 17:00–20:59.
  evening,

  /// 21:00–23:59.
  night,
}

/// One prompt, and the moment it is for.
@immutable
final class _Entry {
  const _Entry(this.words, {this.weather, this.when});

  final String words;
  final WeatherCondition? weather;
  final _PartOfDay? when;

  /// How much this entry claims to know. Weather outranks the hour, because
  /// the hour is always available and a condition is the rarer signal.
  int get specificity => (weather == null ? 0 : 2) + (when == null ? 0 : 1);

  bool matches(WeatherCondition? condition, _PartOfDay part) =>
      (weather == null || weather == condition) &&
      (when == null || when == part);
}

/// The words the five-second prompt offers — BEHAVIOUR.md §3.3, **ADR-029**.
///
/// *"A prompt shown immediately is an instruction. A prompt shown after a
/// pause is an offer."* These are the offers, and which one is made is read
/// off the ambient stamp the chit already holds: the hour it was opened, and
/// the weather if it arrived.
///
/// **They are questions, and they are short.** Nothing here encourages,
/// congratulates or suggests a subject. A prompt that says *"Let's reflect on
/// today!"* is an instruction wearing a question mark, and the design log's
/// objection to it is the same as its objection to a score: chit does not have
/// opinions about how much you write.
///
/// The rule lives in `domain` for the reason `weather/wmo_mapping.dart` does —
/// it is a product decision rather than a detail of anything. Nothing here
/// reads a clock; the stamp is the only input, which is what makes it pure and
/// what makes ADR-021 hold: the prompt is for the moment the chit **opened**.
abstract final class Prompts {
  /// The line BEHAVIOUR.md §3.3 names, and the floor under everything else.
  ///
  /// It is what an opened chit gets when the weather did not arrive and the
  /// hour has nothing to say — which is to say, never in practice, since every
  /// hour is in some band. It is in the book so the book cannot come up empty.
  static const String neutral = 'What just happened?';

  /// The prompt for [stamp].
  ///
  /// The **most specific** entry that fits wins: weather and hour together,
  /// then weather, then hour, then [neutral]. Where several fit equally, one
  /// is picked from the stamp's own clock fields — so it is stable for the life
  /// of a chit and does not flicker on a rebuild, and two chits a few minutes
  /// apart in the same weather are not asked the same question.
  static String forStamp(AmbientStamp stamp) {
    final _PartOfDay part = _partOf(stamp.capturedAt);

    final List<_Entry> fitting = <_Entry>[
      for (final _Entry entry in _book)
        if (entry.matches(stamp.weather, part)) entry,
    ];

    int best = 0;
    for (final _Entry entry in fitting) {
      if (entry.specificity > best) best = entry.specificity;
    }

    final List<String> shortlist = <String>[
      for (final _Entry entry in fitting)
        if (entry.specificity == best) entry.words,
    ];

    // Local clock fields rather than an epoch, which would make the choice
    // depend on the machine's time zone — and a prompt that differs between
    // two developers' test runs is a test that fails somewhere else.
    //
    // Added rather than combined into one number on purpose: `second * 1000`
    // is always even, so against a two-entry shortlist the seconds would have
    // counted for nothing and every chit in an hour would have been asked the
    // same question. A weak mix is fine for choosing between two or three; a
    // structured one is not.
    final DateTime at = stamp.capturedAt;
    final int seed = at.minute + at.second + at.millisecond;

    return shortlist[seed % shortlist.length];
  }

  static _PartOfDay _partOf(DateTime at) => switch (at.hour) {
    < 5 => _PartOfDay.smallHours,
    < 12 => _PartOfDay.morning,
    < 17 => _PartOfDay.afternoon,
    < 21 => _PartOfDay.evening,
    _ => _PartOfDay.night,
  };

  /// Every prompt in the app.
  ///
  /// Kept as one flat list rather than a map of buckets so that adding one is
  /// adding a line, and so that the specificity rule is the only thing that
  /// decides — a map would let two buckets quietly own the same moment.
  static const List<_Entry> _book = <_Entry>[
    _Entry(neutral),

    // The hour, when that is all there is.
    _Entry('How has it started?', when: _PartOfDay.morning),
    _Entry("What's the first thing today?", when: _PartOfDay.morning),
    _Entry("How's the day going?", when: _PartOfDay.afternoon),
    _Entry("What's happened so far?", when: _PartOfDay.afternoon),
    _Entry('How did the day go?', when: _PartOfDay.evening),
    _Entry('Anything left over from today?', when: _PartOfDay.evening),
    _Entry('How did it end?', when: _PartOfDay.night),
    _Entry('Anything from today worth keeping?', when: _PartOfDay.night),
    _Entry("Still up. What's going on?", when: _PartOfDay.smallHours),
    _Entry("What's keeping you up?", when: _PartOfDay.smallHours),

    // The weather, at any hour.
    _Entry("Rain. What's it like out?", weather: WeatherCondition.raining),
    _Entry('What has the rain changed?', weather: WeatherCondition.raining),
    _Entry("Clear out. What's happening?", weather: WeatherCondition.clear),
    _Entry('What does the day look like?', weather: WeatherCondition.clear),
    _Entry(
      "Grey out. What's on your mind?",
      weather: WeatherCondition.overcast,
    ),
    _Entry(
      "Sky's closed. Anything worth noting?",
      weather: WeatherCondition.overcast,
    ),
    _Entry("Windy out. What's it like?", weather: WeatherCondition.windy),
    _Entry("What's the wind doing?", weather: WeatherCondition.windy),
    _Entry(
      'Clear night. Anything on your mind?',
      weather: WeatherCondition.clearNight,
    ),
    _Entry(
      "Clear night. What's left from today?",
      weather: WeatherCondition.clearNight,
    ),

    // Both, where the pair says more than either half.
    _Entry(
      'Raining. How has it started?',
      weather: WeatherCondition.raining,
      when: _PartOfDay.morning,
    ),
    _Entry(
      "Still up, still raining. What's going on?",
      weather: WeatherCondition.raining,
      when: _PartOfDay.smallHours,
    ),
    _Entry(
      'Rain tonight. How did the day go?',
      weather: WeatherCondition.raining,
      when: _PartOfDay.evening,
    ),
    _Entry(
      "Clear morning. What's the first thing?",
      weather: WeatherCondition.clear,
      when: _PartOfDay.morning,
    ),
    _Entry(
      'Grey morning. How has it started?',
      weather: WeatherCondition.overcast,
      when: _PartOfDay.morning,
    ),
    _Entry(
      "Windy afternoon. What's happening?",
      weather: WeatherCondition.windy,
      when: _PartOfDay.afternoon,
    ),
    _Entry(
      "Clear night, and still up. What's keeping you?",
      weather: WeatherCondition.clearNight,
      when: _PartOfDay.smallHours,
    ),
  ];

  /// Every prompt the book holds, in the order it holds them.
  ///
  /// For the tests that check the copy as a whole — that nothing is said
  /// twice, and that nothing shouts.
  @visibleForTesting
  static List<String> get all => <String>[
    for (final _Entry entry in _book) entry.words,
  ];
}
