import 'package:freezed_annotation/freezed_annotation.dart';

part 'day_summary.freezed.dart';

@freezed
abstract class DaySummary with _$DaySummary {
  const factory DaySummary({required int localDay, required int count}) =
      _DaySummary;
}
