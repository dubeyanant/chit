// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_permission.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Asking for the place, which happens at a save and nowhere else — ADR-094.
///
/// **The OS owns how many times somebody is asked.** Android shows the dialog
/// twice and then answers `deniedForever` without one; this asks until it gets
/// an answer that will not change, and **draws nothing of its own either way**
/// — no screen before the dialog, no explanation after a refusal. A permission
/// the app cannot have is a quieter chit, which is not an error state.

@ProviderFor(PlacePermission)
final placePermissionProvider = PlacePermissionProvider._();

/// Asking for the place, which happens at a save and nowhere else — ADR-094.
///
/// **The OS owns how many times somebody is asked.** Android shows the dialog
/// twice and then answers `deniedForever` without one; this asks until it gets
/// an answer that will not change, and **draws nothing of its own either way**
/// — no screen before the dialog, no explanation after a refusal. A permission
/// the app cannot have is a quieter chit, which is not an error state.
final class PlacePermissionProvider
    extends $NotifierProvider<PlacePermission, bool> {
  /// Asking for the place, which happens at a save and nowhere else — ADR-094.
  ///
  /// **The OS owns how many times somebody is asked.** Android shows the dialog
  /// twice and then answers `deniedForever` without one; this asks until it gets
  /// an answer that will not change, and **draws nothing of its own either way**
  /// — no screen before the dialog, no explanation after a refusal. A permission
  /// the app cannot have is a quieter chit, which is not an error state.
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

String _$placePermissionHash() => r'69b074616146b7140f56a2b8dd2f4811db852bb7';

/// Asking for the place, which happens at a save and nowhere else — ADR-094.
///
/// **The OS owns how many times somebody is asked.** Android shows the dialog
/// twice and then answers `deniedForever` without one; this asks until it gets
/// an answer that will not change, and **draws nothing of its own either way**
/// — no screen before the dialog, no explanation after a refusal. A permission
/// the app cannot have is a quieter chit, which is not an error state.

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
