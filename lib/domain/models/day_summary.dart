import 'package:freezed_annotation/freezed_annotation.dart';

part 'day_summary.freezed.dart';

/// How many chits a day holds. One row of the calendar's grouped query.
///
/// The count is a fact about the data. Turning it into one of the four density
/// steps of BEHAVIOUR.md §4.2 is a design scale and happens in the
/// presentation layer, where it can be re-tuned without a migration
/// (DATA-MODEL.md §4).
@freezed
abstract class DaySummary with _$DaySummary {
  /// A day and its count.
  const factory DaySummary({
    /// `yyyymmdd`, device-local at the moment each chit was written (ADR-006).
    required int localDay,

    /// How many chits carry that [localDay]. Never zero — a day with nothing
    /// written has no row at all, which is what makes an empty tile empty.
    required int count,
  }) = _DaySummary;
}
