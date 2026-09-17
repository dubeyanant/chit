// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'month_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Which month the calendar is showing, and the two chevrons.
///
/// It opens on the month today falls in, and **re-reads that at midnight**
/// with everything else — off [todayProvider], so on the first of a month a
/// phone left open rolls the calendar over with the date line (ADR-033).
/// That also returns a reader who had gone back a few months to the current
/// one, which is what they would want on a new day anyway.
///
/// [next] never goes past the current month. There is nothing there to draw:
/// a future month is a grid of days that have not happened, and BEHAVIOUR.md
/// §4.2 will not even draw the rest of *this* one.

@ProviderFor(VisibleMonth)
final visibleMonthProvider = VisibleMonthProvider._();

/// Which month the calendar is showing, and the two chevrons.
///
/// It opens on the month today falls in, and **re-reads that at midnight**
/// with everything else — off [todayProvider], so on the first of a month a
/// phone left open rolls the calendar over with the date line (ADR-033).
/// That also returns a reader who had gone back a few months to the current
/// one, which is what they would want on a new day anyway.
///
/// [next] never goes past the current month. There is nothing there to draw:
/// a future month is a grid of days that have not happened, and BEHAVIOUR.md
/// §4.2 will not even draw the rest of *this* one.
final class VisibleMonthProvider
    extends $NotifierProvider<VisibleMonth, YearMonth> {
  /// Which month the calendar is showing, and the two chevrons.
  ///
  /// It opens on the month today falls in, and **re-reads that at midnight**
  /// with everything else — off [todayProvider], so on the first of a month a
  /// phone left open rolls the calendar over with the date line (ADR-033).
  /// That also returns a reader who had gone back a few months to the current
  /// one, which is what they would want on a new day anyway.
  ///
  /// [next] never goes past the current month. There is nothing there to draw:
  /// a future month is a grid of days that have not happened, and BEHAVIOUR.md
  /// §4.2 will not even draw the rest of *this* one.
  VisibleMonthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'visibleMonthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$visibleMonthHash();

  @$internal
  @override
  VisibleMonth create() => VisibleMonth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(YearMonth value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<YearMonth>(value),
    );
  }
}

String _$visibleMonthHash() => r'793a77b5a1e886366d00b51849d314fd482305ae';

/// Which month the calendar is showing, and the two chevrons.
///
/// It opens on the month today falls in, and **re-reads that at midnight**
/// with everything else — off [todayProvider], so on the first of a month a
/// phone left open rolls the calendar over with the date line (ADR-033).
/// That also returns a reader who had gone back a few months to the current
/// one, which is what they would want on a new day anyway.
///
/// [next] never goes past the current month. There is nothing there to draw:
/// a future month is a grid of days that have not happened, and BEHAVIOUR.md
/// §4.2 will not even draw the rest of *this* one.

abstract class _$VisibleMonth extends $Notifier<YearMonth> {
  YearMonth build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<YearMonth, YearMonth>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<YearMonth, YearMonth>,
              YearMonth,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// How many chits each day of the visible month holds — one query for the
/// grid's density and the summary under it (DATA-MODEL.md §4).
///
/// A stream, so a save on Today reaches the tile and the total without either
/// being told: both are readings of this, and this re-emits on the write.
/// That is the milestone's statement of done and it is true by construction
/// rather than by anything keeping the two tabs in step.

@ProviderFor(monthSummaries)
final monthSummariesProvider = MonthSummariesProvider._();

/// How many chits each day of the visible month holds — one query for the
/// grid's density and the summary under it (DATA-MODEL.md §4).
///
/// A stream, so a save on Today reaches the tile and the total without either
/// being told: both are readings of this, and this re-emits on the write.
/// That is the milestone's statement of done and it is true by construction
/// rather than by anything keeping the two tabs in step.

final class MonthSummariesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DaySummary>>,
          List<DaySummary>,
          Stream<List<DaySummary>>
        >
    with $FutureModifier<List<DaySummary>>, $StreamProvider<List<DaySummary>> {
  /// How many chits each day of the visible month holds — one query for the
  /// grid's density and the summary under it (DATA-MODEL.md §4).
  ///
  /// A stream, so a save on Today reaches the tile and the total without either
  /// being told: both are readings of this, and this re-emits on the write.
  /// That is the milestone's statement of done and it is true by construction
  /// rather than by anything keeping the two tabs in step.
  MonthSummariesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'monthSummariesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$monthSummariesHash();

  @$internal
  @override
  $StreamProviderElement<List<DaySummary>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DaySummary>> create(Ref ref) {
    return monthSummaries(ref);
  }
}

String _$monthSummariesHash() => r'8acdb70073daaf52106240f1d6ea035cfc3eed9b';

/// The visible month as the grid draws it, or **null until the query has
/// answered**.
///
/// Null rather than an empty shape, for the reason Today's thread waits for
/// its first frame: an empty month drawn while the real one is in flight is
/// *Nothing written this month* said about a month that was written in, which
/// is a wrong answer rather than a slow one.

@ProviderFor(monthShape)
final monthShapeProvider = MonthShapeProvider._();

/// The visible month as the grid draws it, or **null until the query has
/// answered**.
///
/// Null rather than an empty shape, for the reason Today's thread waits for
/// its first frame: an empty month drawn while the real one is in flight is
/// *Nothing written this month* said about a month that was written in, which
/// is a wrong answer rather than a slow one.

final class MonthShapeProvider
    extends $FunctionalProvider<MonthShape?, MonthShape?, MonthShape?>
    with $Provider<MonthShape?> {
  /// The visible month as the grid draws it, or **null until the query has
  /// answered**.
  ///
  /// Null rather than an empty shape, for the reason Today's thread waits for
  /// its first frame: an empty month drawn while the real one is in flight is
  /// *Nothing written this month* said about a month that was written in, which
  /// is a wrong answer rather than a slow one.
  MonthShapeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'monthShapeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$monthShapeHash();

  @$internal
  @override
  $ProviderElement<MonthShape?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MonthShape? create(Ref ref) {
    return monthShape(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MonthShape? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MonthShape?>(value),
    );
  }
}

String _$monthShapeHash() => r'2de4b2ac8b7a2c4bec4713188204545040774093';
