import 'package:flutter/foundation.dart';

import 'models/ambient_stamp.dart';
import 'models/motion_state.dart';
import 'models/weather_condition.dart';

enum _PartOfDay { smallHours, morning, afternoon, evening, night }

@immutable
final class _Entry {
  const _Entry(this.words, {this.weather, this.motion, this.when});

  final String words;
  final WeatherCondition? weather;
  final MotionState? motion;
  final _PartOfDay? when;

  int get specificity =>
      (motion == null ? 0 : 4) +
      (weather == null ? 0 : 2) +
      (when == null ? 0 : 1);

  bool matches(
    WeatherCondition? condition,
    MotionState? state,
    _PartOfDay part,
  ) =>
      (weather == null || weather == condition) &&
      (motion == null || motion == state) &&
      (when == null || when == part);
}

abstract final class Prompts {
  static const String neutral = 'What just happened?';

  static String forStamp(AmbientStamp stamp) {
    final _PartOfDay part = _partOf(stamp.capturedAt);

    final List<_Entry> fitting = <_Entry>[
      for (final _Entry entry in _book)
        if (entry.matches(stamp.weather, stamp.motion, part)) entry,
    ];

    int best = 0;
    for (final _Entry entry in fitting) {
      if (entry.specificity > best) best = entry.specificity;
    }

    final List<String> shortlist = <String>[
      for (final _Entry entry in fitting)
        if (entry.specificity == best) entry.words,
    ];

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

  static const List<_Entry> _book = <_Entry>[
    _Entry(neutral),

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

    _Entry('Where are you headed?', motion: MotionState.traveling),
    _Entry("On the way. What's on your mind?", motion: MotionState.traveling),
    _Entry("Out walking. What's about?", motion: MotionState.walking),
    _Entry('Walking. What are you turning over?', motion: MotionState.walking),
    _Entry("In the air. What's the thought?", motion: MotionState.flying),
    _Entry('Flying. What did you leave behind?', motion: MotionState.flying),

    _Entry(
      'On the way home. How did the day go?',
      motion: MotionState.traveling,
      when: _PartOfDay.evening,
    ),
    _Entry(
      "Walking in the rain. What's it like?",
      motion: MotionState.walking,
      weather: WeatherCondition.raining,
    ),
    _Entry(
      "In the air, and still up. What's keeping you?",
      motion: MotionState.flying,
      when: _PartOfDay.smallHours,
    ),

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

  @visibleForTesting
  static List<String> get all => <String>[
    for (final _Entry entry in _book) entry.words,
  ];
}
