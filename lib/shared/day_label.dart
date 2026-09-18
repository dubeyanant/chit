import 'package:intl/intl.dart';

import '../domain/models/chit.dart';

String dayLabel({required int localDay, required int today}) {
  if (localDay == today) return 'Today';

  final DateTime date = Chit.dateOf(localDay);
  final DateTime now = Chit.dateOf(today);
  if (date == Chit.startOfLocalDay(now, offsetDays: -1)) return 'Yesterday';

  final String dayAndMonth = DateFormat('EEEE d MMMM').format(date);
  return date.year == now.year ? dayAndMonth : '$dayAndMonth ${date.year}';
}
