part of 'month_provider.dart';

@ProviderFor(writtenMonths)
final writtenMonthsProvider = WrittenMonthsProvider._();

final class WrittenMonthsProvider
    extends
        $FunctionalProvider<AsyncValue<List<int>>, List<int>, Stream<List<int>>>
    with $FutureModifier<List<int>>, $StreamProvider<List<int>> {
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

@ProviderFor(monthNeighbours)
final monthNeighboursProvider = MonthNeighboursProvider._();

final class MonthNeighboursProvider
    extends
        $FunctionalProvider<MonthNeighbours, MonthNeighbours, MonthNeighbours>
    with $Provider<MonthNeighbours> {
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

  Override overrideWithValue(MonthNeighbours value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MonthNeighbours>(value),
    );
  }
}

String _$monthNeighboursHash() => r'01705e7e9b04da1bc1164c5efdac0bafd56a05df';

@ProviderFor(VisibleMonth)
final visibleMonthProvider = VisibleMonthProvider._();

final class VisibleMonthProvider
    extends $NotifierProvider<VisibleMonth, YearMonth> {
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

  Override overrideWithValue(YearMonth value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<YearMonth>(value),
    );
  }
}

String _$visibleMonthHash() => r'9a7ce3da527ad4a0dc53510142d6a8e81c778f9d';

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

@ProviderFor(monthSummaries)
final monthSummariesProvider = MonthSummariesProvider._();

final class MonthSummariesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DaySummary>>,
          List<DaySummary>,
          Stream<List<DaySummary>>
        >
    with $FutureModifier<List<DaySummary>>, $StreamProvider<List<DaySummary>> {
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

@ProviderFor(DrawnMonth)
final drawnMonthProvider = DrawnMonthProvider._();

final class DrawnMonthProvider
    extends $NotifierProvider<DrawnMonth, MonthShape?> {
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

  Override overrideWithValue(MonthShape? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MonthShape?>(value),
    );
  }
}

String _$drawnMonthHash() => r'066c411dfaed1dedff56fc71e2b519d244dfa710';

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
