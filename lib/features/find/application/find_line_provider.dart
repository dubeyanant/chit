import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/find_line.dart';
import '../../today/application/today_controller.dart';

part 'find_line_provider.g.dart';

@Riverpod(keepAlive: true)
class FindVisit extends _$FindVisit {
  @override
  int build() => 0;

  void arrived() => state = state + 1;
}

@riverpod
String findLine(Ref ref) => FindLine.forVisit(
  ref.watch(todayLocalDayProvider) + ref.watch(findVisitProvider),
);
