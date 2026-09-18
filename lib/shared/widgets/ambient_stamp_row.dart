import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/extensions.dart';
import '../../domain/ambient/ambient_fact.dart';
import '../../domain/models/ambient_stamp.dart';
import '../../domain/models/motion_state.dart';
import '../../domain/models/weather_condition.dart';
import 'motion_icon.dart';

final class AmbientStampRow extends StatelessWidget {
  const AmbientStampRow.open({required this.stamp, super.key})
    : _onOpenChit = true;

  const AmbientStampRow.saved({required this.stamp, super.key})
    : _onOpenChit = false;

  final AmbientStamp stamp;

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
          for (final (int index, Widget fact) in _facts(
            context,
          ).indexed) ...<Widget>[
            if (index > 0) SizedBox(width: space.s3),
            fact,
          ],
        ],
      ),
    );
  }

  List<Widget> _facts(BuildContext context) {
    final AmbientFact? fact = AmbientFact.of(stamp);

    return <Widget>[
      Text(_timeOf(stamp.capturedAt)),

      if (fact != null)
        switch (fact) {
          WeatherFact(:final WeatherCondition condition) => Text(
            condition.word,
          ),

          MotionFact(:final MotionState state) => MotionIcon(
            state: state,
            colour: _onOpenChit
                ? context.colors.inkMuted
                : context.colors.inkFaint,
            size: context.space.s3,
          ),
        },
    ];
  }

  static String _timeOf(DateTime at) =>
      DateFormat('h:mm a').format(at).toLowerCase();
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
