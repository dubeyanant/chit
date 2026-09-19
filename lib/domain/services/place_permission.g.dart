// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_permission.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlacePermission)
final placePermissionProvider = PlacePermissionProvider._();

final class PlacePermissionProvider
    extends $NotifierProvider<PlacePermission, PlaceAsk> {
  PlacePermissionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'placePermissionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$placePermissionHash();

  @$internal
  @override
  PlacePermission create() => PlacePermission();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlaceAsk value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlaceAsk>(value),
    );
  }
}

String _$placePermissionHash() => r'f5c43f50284e380aeb51d23e9ccfd8f56e54905e';

abstract class _$PlacePermission extends $Notifier<PlaceAsk> {
  PlaceAsk build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PlaceAsk, PlaceAsk>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PlaceAsk, PlaceAsk>,
              PlaceAsk,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
