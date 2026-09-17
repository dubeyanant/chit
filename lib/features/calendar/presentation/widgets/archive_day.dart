import 'package:flutter/material.dart';

import '../../../../core/extensions.dart';
import '../../../../shared/widgets/day_thread.dart';
import '../../application/archive_provider.dart';

/// One day in the archive: its heading, and the same thread Today draws.
///
/// BEHAVIOUR.md §4.2 — *every day grouped newest-first, using the same thread
/// treatment as Today*. The treatment is the same because it is the same
/// widget: [DayThread] moved to `shared/widgets` for this screen, so the two
/// tabs cannot draw a chit two ways.
///
/// The heading is the day's name, a hairline running off to the right, and the
/// count — the shape of Today's *earlier* row, with a date where the word was.
///
/// **The three are centred on one another, as *earlier*'s are.** *v6 sets this
/// row on the baseline*, which in CSS puts the hairline on the text's baseline
/// and in Flutter — where a box with no text in it has no baseline — put it at
/// the top of the row, a few pixels above the middle of the name. The second
/// seeded pass saw it sitting high and asked for it centred.
final class ArchiveDayGroup extends StatelessWidget {
  /// The group for [day], labelled relative to [today].
  const ArchiveDayGroup({required this.day, required this.today, super.key});

  /// The day and its chits.
  final ArchiveDay day;

  /// Today as `yyyymmdd`, so the heading can say *Today* or *Yesterday*.
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
