import 'package:intl/intl.dart';

import '../domain/models/chit.dart';

/// *Today*, *Yesterday*, then *Friday 11 September* — the one way a day is
/// named to a reader.
///
/// The year appears only when [localDay] is not in [today]'s, because a
/// journal is read close to when it was written and a year on every heading
/// would be the app counting for the reader.
///
/// *It lived on `ArchiveDay` until the editor's header wanted the same phrase
/// for a single chit*, which is ARCHITECTURE.md §2's rule for moving a thing
/// to `shared/`. Both days are named the same way because it is one function,
/// not two that agree today.
String dayLabel({required int localDay, required int today}) {
  if (localDay == today) return 'Today';

  final DateTime date = Chit.dateOf(localDay);
  final DateTime now = Chit.dateOf(today);
  if (date == Chit.startOfLocalDay(now, offsetDays: -1)) return 'Yesterday';

  final String dayAndMonth = DateFormat('EEEE d MMMM').format(date);
  return date.year == now.year ? dayAndMonth : '$dayAndMonth ${date.year}';
}
