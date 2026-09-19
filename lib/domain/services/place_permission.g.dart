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
    extends $NotifierProvider<PlacePermission, bool> {
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
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$placePermissionHash() => r'53cc1abc5ab55fbd9dc80e1bbb460f5cd5b3648d';

abstract class _$PlacePermission extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
