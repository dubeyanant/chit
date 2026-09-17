// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'month_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every month with a chit in it, as `yyyymm`, oldest first — what the
/// chevrons step through (ADR-047).

@ProviderFor(writtenMonths)
final writtenMonthsProvider = WrittenMonthsProvider._();

/// Every month with a chit in it, as `yyyymm`, oldest first — what the
/// chevrons step through (ADR-047).

final class WrittenMonthsProvider
    extends
        $FunctionalProvider<AsyncValue<List<int>>, List<int>, Stream<List<int>>>
    with $FutureModifier<List<int>>, $StreamProvider<List<int>> {
  /// Every month with a chit in it, as `yyyymm`, oldest first — what the
  /// chevrons step through (ADR-047).
  WrittenMonthsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'writtenMonthsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$writtenMonthsHash();

  @$internal
  @override
  $StreamProviderElement<List<int>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<int>> create(Ref ref) {
    return writtenMonths(ref);
  }
}

String _$writtenMonthsHash() => r'2a168052acb92914f227ee1afc404ec8a2974e06';

/// The two chevrons' destinations for the visible month.

@ProviderFor(monthNeighbours)
final monthNeighboursProvider = MonthNeighboursProvider._();

/// The two chevrons' destinations for the visible month.

final class MonthNeighboursProvider
    extends
        $FunctionalProvider<MonthNeighbours, MonthNeighbours, MonthNeighbours>
    with $Provider<MonthNeighbours> {
  /// The two chevrons' destinations for the visible month.
  MonthNeighboursProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'monthNeighboursProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$monthNeighboursHash();

  @$internal
  @override
  $ProviderElement<MonthNeighbours> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MonthNeighbours create(Ref ref) {
    return monthNeighbours(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MonthNeighbours value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MonthNeighbours>(value),
    );
  }
}

String _$monthNeighboursHash() => r'01705e7e9b04da1bc1164c5efdac0bafd56a05df';

/// Which month the calendar is showing, and the two chevrons.
///
/// It opens on the month today falls in, and **re-reads that at midnight**
/// with everything else — off [todayProvider], so on the first of a month a
/// phone left open rolls the calendar over with the date line (ADR-033).
/// That also returns a reader who had gone back a few months to the current
/// one, which is what they would want on a new day anyway.
///
/// **A chevron only ever lands on a month with something in it** — ADR-047.
/// [previous] goes to the nearest written month before this one and [next] to
/// the nearest after, or back to the current month, which counts whatever it
/// holds. Neither does anything when there is nowhere to go; the bar draws no
/// chevron for that side, so a month nobody can write in is never shown.
/// *They stepped one calendar month at a time for one commit*, and the first
/// device pass found an empty August with a dead chevron beside it.

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
/// **A chevron only ever lands on a month with something in it** — ADR-047.
/// [previous] goes to the nearest written month before this one and [next] to
/// the nearest after, or back to the current month, which counts whatever it
/// holds. Neither does anything when there is nowhere to go; the bar draws no
/// chevron for that side, so a month nobody can write in is never shown.
/// *They stepped one calendar month at a time for one commit*, and the first
/// device pass found an empty August with a dead chevron beside it.
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
  /// **A chevron only ever lands on a month with something in it** — ADR-047.
  /// [previous] goes to the nearest written month before this one and [next] to
  /// the nearest after, or back to the current month, which counts whatever it
  /// holds. Neither does anything when there is nowhere to go; the bar draws no
  /// chevron for that side, so a month nobody can write in is never shown.
  /// *They stepped one calendar month at a time for one commit*, and the first
  /// device pass found an empty August with a dead chevron beside it.
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

String _$visibleMonthHash() => r'9a7ce3da527ad4a0dc53510142d6a8e81c778f9d';

/// Which month the calendar is showing, and the two chevrons.
///
/// It opens on the month today falls in, and **re-reads that at midnight**
/// with everything else — off [todayProvider], so on the first of a month a
/// phone left open rolls the calendar over with the date line (ADR-033).
/// That also returns a reader who had gone back a few months to the current
/// one, which is what they would want on a new day anyway.
///
/// **A chevron only ever lands on a month with something in it** — ADR-047.
/// [previous] goes to the nearest written month before this one and [next] to
/// the nearest after, or back to the current month, which counts whatever it
/// holds. Neither does anything when there is nowhere to go; the bar draws no
/// chevron for that side, so a month nobody can write in is never shown.
/// *They stepped one calendar month at a time for one commit*, and the first
/// device pass found an empty August with a dead chevron beside it.

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

/// The month the grid draws: the visible month once its query has answered,
/// and **the last month that answered until then** — ADR-049. Null only
/// before the first answer.
///
/// Null rather than an empty shape at first, for the reason Today's thread
/// waits for its first frame: an empty month drawn while the real one is in
/// flight is *Nothing written this month* said about a month that was written
/// in, which is a wrong answer rather than a slow one.
///
/// **And the last answer rather than null after that.** *For one commit this
/// went back to null on every change of month*, and the handset saw it as a
/// flicker: the bar, the grid and the summary vanished for the frames the
/// query took and came back, and the archive under them jumped up and down
/// with them. The month that was true a moment ago, under its own name, is a
/// slow answer; a blank is a wrong one. The bar takes its name from this and
/// not from [visibleMonthProvider], so the name and the grid change together.

@ProviderFor(DrawnMonth)
final drawnMonthProvider = DrawnMonthProvider._();

/// The month the grid draws: the visible month once its query has answered,
/// and **the last month that answered until then** — ADR-049. Null only
/// before the first answer.
///
/// Null rather than an empty shape at first, for the reason Today's thread
/// waits for its first frame: an empty month drawn while the real one is in
/// flight is *Nothing written this month* said about a month that was written
/// in, which is a wrong answer rather than a slow one.
///
/// **And the last answer rather than null after that.** *For one commit this
/// went back to null on every change of month*, and the handset saw it as a
/// flicker: the bar, the grid and the summary vanished for the frames the
/// query took and came back, and the archive under them jumped up and down
/// with them. The month that was true a moment ago, under its own name, is a
/// slow answer; a blank is a wrong one. The bar takes its name from this and
/// not from [visibleMonthProvider], so the name and the grid change together.
final class DrawnMonthProvider
    extends $NotifierProvider<DrawnMonth, MonthShape?> {
  /// The month the grid draws: the visible month once its query has answered,
  /// and **the last month that answered until then** — ADR-049. Null only
  /// before the first answer.
  ///
  /// Null rather than an empty shape at first, for the reason Today's thread
  /// waits for its first frame: an empty month drawn while the real one is in
  /// flight is *Nothing written this month* said about a month that was written
  /// in, which is a wrong answer rather than a slow one.
  ///
  /// **And the last answer rather than null after that.** *For one commit this
  /// went back to null on every change of month*, and the handset saw it as a
  /// flicker: the bar, the grid and the summary vanished for the frames the
  /// query took and came back, and the archive under them jumped up and down
  /// with them. The month that was true a moment ago, under its own name, is a
  /// slow answer; a blank is a wrong one. The bar takes its name from this and
  /// not from [visibleMonthProvider], so the name and the grid change together.
  DrawnMonthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'drawnMonthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$drawnMonthHash();

  @$internal
  @override
  DrawnMonth create() => DrawnMonth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MonthShape? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MonthShape?>(value),
    );
  }
}

String _$drawnMonthHash() => r'066c411dfaed1dedff56fc71e2b519d244dfa710';

/// The month the grid draws: the visible month once its query has answered,
/// and **the last month that answered until then** — ADR-049. Null only
/// before the first answer.
///
/// Null rather than an empty shape at first, for the reason Today's thread
/// waits for its first frame: an empty month drawn while the real one is in
/// flight is *Nothing written this month* said about a month that was written
/// in, which is a wrong answer rather than a slow one.
///
/// **And the last answer rather than null after that.** *For one commit this
/// went back to null on every change of month*, and the handset saw it as a
/// flicker: the bar, the grid and the summary vanished for the frames the
/// query took and came back, and the archive under them jumped up and down
/// with them. The month that was true a moment ago, under its own name, is a
/// slow answer; a blank is a wrong one. The bar takes its name from this and
/// not from [visibleMonthProvider], so the name and the grid change together.

abstract class _$DrawnMonth extends $Notifier<MonthShape?> {
  MonthShape? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<MonthShape?, MonthShape?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MonthShape?, MonthShape?>,
              MonthShape?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
