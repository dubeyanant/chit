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

/// What each axis can offer, read once per change to the chits.

@ProviderFor(AxisValues)
final axisValuesProvider = AxisValuesProvider._();

/// What each axis can offer, read once per change to the chits.
final class AxisValuesProvider
    extends $NotifierProvider<AxisValues, Map<FindAxis, List<FindValue>>?> {
  /// What each axis can offer, read once per change to the chits.
  AxisValuesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'axisValuesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$axisValuesHash();

  @$internal
  @override
  AxisValues create() => AxisValues();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<FindAxis, List<FindValue>>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<FindAxis, List<FindValue>>?>(
        value,
      ),
    );
  }
}

String _$axisValuesHash() => r'6d4c1ffa43f47bc8197a0fe9eea85a8c06d79093';

/// What each axis can offer, read once per change to the chits.

abstract class _$AxisValues extends $Notifier<Map<FindAxis, List<FindValue>>?> {
  Map<FindAxis, List<FindValue>>? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              Map<FindAxis, List<FindValue>>?,
              Map<FindAxis, List<FindValue>>?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<FindAxis, List<FindValue>>?,
                Map<FindAxis, List<FindValue>>?
              >,
              Map<FindAxis, List<FindValue>>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The chits carrying one value of one axis, grouped by day.

@ProviderFor(chitsOfValue)
final chitsOfValueProvider = ChitsOfValueFamily._();

/// The chits carrying one value of one axis, grouped by day.

final class ChitsOfValueProvider
    extends
        $FunctionalProvider<List<DayGroup>?, List<DayGroup>?, List<DayGroup>?>
    with $Provider<List<DayGroup>?> {
  /// The chits carrying one value of one axis, grouped by day.
  ChitsOfValueProvider._({
    required ChitsOfValueFamily super.from,
    required (FindAxis, String) super.argument,
  }) : super(
         retry: null,
         name: r'chitsOfValueProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chitsOfValueHash();

  @override
  String toString() {
    return r'chitsOfValueProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<List<DayGroup>?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<DayGroup>? create(Ref ref) {
    final argument = this.argument as (FindAxis, String);
    return chitsOfValue(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<DayGroup>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<DayGroup>?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChitsOfValueProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chitsOfValueHash() => r'd83bbed4398b7263d716a2e778c4437a8a26f78e';

/// The chits carrying one value of one axis, grouped by day.

final class ChitsOfValueFamily extends $Family
    with $FunctionalFamilyOverride<List<DayGroup>?, (FindAxis, String)> {
  ChitsOfValueFamily._()
    : super(
        retry: null,
        name: r'chitsOfValueProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The chits carrying one value of one axis, grouped by day.

  ChitsOfValueProvider call(FindAxis axis, String slug) =>
      ChitsOfValueProvider._(argument: (axis, slug), from: this);

  @override
  String toString() => r'chitsOfValueProvider';
}
