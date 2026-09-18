import 'package:chit/domain/models/chit.dart';
import 'package:chit/shared/day_label.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  int dayOf(int y, int m, int d) => Chit.localDayOf(DateTime(y, m, d, 12));

  final int today = dayOf(2026, 9, 17);

  test('today is Today', () {
    expect(dayLabel(localDay: today, today: today), 'Today');
  });

  test('the day before is Yesterday', () {
    expect(dayLabel(localDay: dayOf(2026, 9, 16), today: today), 'Yesterday');
  });

  test('anything older is its weekday and date', () {
    expect(
      dayLabel(localDay: dayOf(2026, 9, 11), today: today),
      'Friday 11 September',
    );
  });

  test('the year appears only when it is not this one', () {
    expect(
      dayLabel(localDay: dayOf(2025, 12, 31), today: today),
      'Wednesday 31 December 2025',
    );
  });

  test('a month boundary is still Yesterday', () {
    expect(
      dayLabel(localDay: dayOf(2026, 8, 31), today: dayOf(2026, 9, 1)),
      'Yesterday',
    );
  });
}
