import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/extensions.dart';
import '../../domain/ambient/ambient_fact.dart';
import '../../domain/ambient/ambient_words.dart';
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

  static const String writing = 'writing';

  static const String wasEdited = 'edited';

  final AmbientStamp stamp;

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
