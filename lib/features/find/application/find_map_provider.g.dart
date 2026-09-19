// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_map_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LatestFix)
final latestFixProvider = LatestFixProvider._();

final class LatestFixProvider extends $NotifierProvider<LatestFix, GeoPoint?> {
  LatestFixProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'latestFixProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$latestFixHash();

  @$internal
  @override
  LatestFix create() => LatestFix();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeoPoint? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeoPoint?>(value),
    );
  }
}

String _$latestFixHash() => r'fed6c24c4594adb7ee7df5767af96398108ea6c3';

abstract class _$LatestFix extends $Notifier<GeoPoint?> {
  GeoPoint? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<GeoPoint?, GeoPoint?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GeoPoint?, GeoPoint?>,
              GeoPoint?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
