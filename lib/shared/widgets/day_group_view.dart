import 'package:flutter/material.dart';

import '../../core/extensions.dart';
import '../day_group.dart';
import 'day_thread.dart';

/// A day's heading — its label, a hairline, its count — over its thread.
final class DayGroupView extends StatelessWidget {
  const DayGroupView({required this.day, required this.today, super.key});

  final DayGroup day;

  final int today;

  @override
  Widget build(BuildContext context) {
    final space = context.space;
    final type = context.type;
    final int count = day.chits.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: space.s1),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Semantics(
                header: true,
                child: Text(day.label(today: today), style: type.dayHeading),
              ),
              SizedBox(width: space.s3),
              Expanded(
                child: SizedBox(
                  height: 1,
                  child: ColoredBox(color: context.colors.hairSoft),
                ),
              ),
              SizedBox(width: space.s3),
              Text(
                count == 1 ? '1 chit' : '$count chits',
                style: type.sectionCount,
              ),
            ],
          ),
        ),
        DayThread(chits: day.chits),
      ],
    );
  }
}
