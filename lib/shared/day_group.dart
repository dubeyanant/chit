import 'package:flutter/foundation.dart';

import '../domain/models/chit.dart';
import 'day_label.dart';

@immutable
final class DayGroup {
  const DayGroup({required this.localDay, required this.chits});

  final int localDay;

  final List<Chit> chits;

  String label({required int today}) =>
      dayLabel(localDay: localDay, today: today);

  @override
  bool operator ==(Object other) =>
      other is DayGroup &&
      other.localDay == localDay &&
      listEquals(other.chits, chits);

  @override
  int get hashCode => Object.hash(localDay, Object.hashAll(chits));

  @override
  String toString() => 'DayGroup($localDay, ${chits.length} chits)';
}

List<DayGroup> groupByDay(List<Chit> chits) {
  final List<DayGroup> days = <DayGroup>[];
  int? current;
  List<Chit> bucket = <Chit>[];

  for (final Chit chit in chits) {
    if (chit.localDay != current) {
      if (current != null) {
        days.add(DayGroup(localDay: current, chits: bucket));
      }
      current = chit.localDay;
      bucket = <Chit>[];
    }
    bucket.add(chit);
  }
  if (current != null) days.add(DayGroup(localDay: current, chits: bucket));

  return days;
}
