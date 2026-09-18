// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every chit, which find narrows rather than queries.

@ProviderFor(everyChit)
final everyChitProvider = EveryChitProvider._();

/// Every chit, which find narrows rather than queries.

final class EveryChitProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Chit>>,
          List<Chit>,
          Stream<List<Chit>>
        >
    with $FutureModifier<List<Chit>>, $StreamProvider<List<Chit>> {
  /// Every chit, which find narrows rather than queries.
  EveryChitProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'everyChitProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$everyChitHash();

  @$internal
  @override
  $StreamProviderElement<List<Chit>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Chit>> create(Ref ref) {
    return everyChit(ref);
  }
}

String _$everyChitHash() => r'3765a2cf2134ebb33b70b978a03de49d2c252616';

@ProviderFor(Facets)
final facetsProvider = FacetsProvider._();

final class FacetsProvider extends $NotifierProvider<Facets, FindFacets> {
  FacetsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'facetsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$facetsHash();

  @$internal
  @override
  Facets create() => Facets();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FindFacets value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FindFacets>(value),
    );
  }
}

String _$facetsHash() => r'684e2886e4947765ceddc38d28db9cd7bcfba246';

abstract class _$Facets extends $Notifier<FindFacets> {
  FindFacets build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<FindFacets, FindFacets>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FindFacets, FindFacets>,
              FindFacets,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(Filter)
final filterProvider = FilterProvider._();

final class FilterProvider extends $NotifierProvider<Filter, ChitFilter> {
  FilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filterHash();

  @$internal
  @override
  Filter create() => Filter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChitFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChitFilter>(value),
    );
  }
}

String _$filterHash() => r'd71fdf02b1b72152e942f43a9d24979b7303c6d3';

abstract class _$Filter extends $Notifier<ChitFilter> {
  ChitFilter build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ChitFilter, ChitFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChitFilter, ChitFilter>,
              ChitFilter,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// What find is showing: every chit the filter allows, grouped by day.

@ProviderFor(found)
final foundProvider = FoundProvider._();

/// What find is showing: every chit the filter allows, grouped by day.

final class FoundProvider
    extends $FunctionalProvider<List<DayGroup>, List<DayGroup>, List<DayGroup>>
    with $Provider<List<DayGroup>> {
  /// What find is showing: every chit the filter allows, grouped by day.
  FoundProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foundProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foundHash();

  @$internal
  @override
  $ProviderElement<List<DayGroup>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<DayGroup> create(Ref ref) {
    return found(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<DayGroup> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<DayGroup>>(value),
    );
  }
}

String _$foundHash() => r'c2871386f79d78cd3e19c4d9578a8b9e71299fc9';
