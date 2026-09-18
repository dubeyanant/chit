import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/extensions.dart';
import '../../domain/ambient/ambient_fact.dart';
import '../../domain/models/ambient_stamp.dart';
import '../../domain/models/motion_state.dart';
import '../../domain/models/weather_condition.dart';

final class AmbientStampRow extends StatelessWidget {
  const AmbientStampRow.open({required this.stamp, super.key})
    : edited = false,
      _onOpenChit = true;

  const AmbientStampRow.saved({
    required this.stamp,
    this.edited = false,
    super.key,
  }) : _onOpenChit = false;

  /// What the open chit says before a signal arrives, so the line is never
  /// blank and the field never moves under the thumb — BEHAVIOUR.md §3.6.1.
  static const String writing = 'writing';

  /// Drawn only where [edited] is true, which is where `updatedAt` has moved.
  static const String wasEdited = 'edited';

  final AmbientStamp stamp;

  /// Whether this chit has been changed since it was written.
  final bool edited;

  final bool _onOpenChit;

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    final space = context.space;

    return DefaultTextStyle(
      style: _onOpenChit ? type.ambientStamp : type.chitMeta,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final (int index, Widget fact) in _facts().indexed) ...<Widget>[
            if (index > 0) SizedBox(width: space.s3),
            fact,
          ],
        ],
      ),
    );
  }

  List<Widget> _facts() {
    final AmbientFact? fact = AmbientFact.of(stamp);

    // The open chit carries no time at all: it is stamped when it is saved
    // (ADR-040), so any clock drawn here is a preview that goes stale.
    if (_onOpenChit) {
      return <Widget>[Text(fact == null ? writing : _wordOf(fact))];
    }

    return <Widget>[
      Text(_timeOf(stamp.capturedAt)),
      if (fact != null) Text(_wordOf(fact)),
      if (edited) const Text(wasEdited),
    ];
  }

  static String _wordOf(AmbientFact fact) => switch (fact) {
    WeatherFact(:final WeatherCondition condition) => condition.word,
    MotionFact(:final MotionState state) => state.word,
  };

  static String _timeOf(DateTime at) =>
      DateFormat('h:mm a').format(at).toLowerCase();
}

extension on MotionState {
  String get word {
    assert(
      this != MotionState.stationary,
      'stationary is never drawn — ADR-038 filters it before here',
    );

    return switch (this) {
      MotionState.stationary => '',
      MotionState.walking => 'walking',
      MotionState.traveling => 'travelling',
      MotionState.flying => 'flying',
    };
  }
}

extension on WeatherCondition {
  String get word => switch (this) {
    WeatherCondition.raining => 'raining',
    WeatherCondition.clear => 'clear',
    WeatherCondition.overcast => 'overcast',
    WeatherCondition.windy => 'windy',
    WeatherCondition.clearNight => 'clear night',
  };
}
