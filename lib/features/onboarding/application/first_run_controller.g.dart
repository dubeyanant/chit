// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'first_run_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the first-run screen is still owed, and the two ways out of it —
/// **ADR-041**.
///
/// **One notifier rather than a state and a separate actions object**, because
/// the two things it does both end the same way: the screen is dismissed and
/// never shown again. A controller whose only job was to call another
/// controller would be ceremony.
///
/// The state is a plain `bool` rather than an `AsyncValue` because the answer
/// has to be available *before* the first route is chosen. `main()` loads the
/// preferences and overrides `firstRunStoreProvider` before `runApp`, so by the
/// time the router's `redirect` reads this there is nothing to wait for — the
/// alternative opens on Today and jumps to the first-run screen a frame later.

@ProviderFor(FirstRunController)
final firstRunControllerProvider = FirstRunControllerProvider._();

/// Whether the first-run screen is still owed, and the two ways out of it —
/// **ADR-041**.
///
/// **One notifier rather than a state and a separate actions object**, because
/// the two things it does both end the same way: the screen is dismissed and
/// never shown again. A controller whose only job was to call another
/// controller would be ceremony.
///
/// The state is a plain `bool` rather than an `AsyncValue` because the answer
/// has to be available *before* the first route is chosen. `main()` loads the
/// preferences and overrides `firstRunStoreProvider` before `runApp`, so by the
/// time the router's `redirect` reads this there is nothing to wait for — the
/// alternative opens on Today and jumps to the first-run screen a frame later.
final class FirstRunControllerProvider
    extends $NotifierProvider<FirstRunController, bool> {
  /// Whether the first-run screen is still owed, and the two ways out of it —
  /// **ADR-041**.
  ///
  /// **One notifier rather than a state and a separate actions object**, because
  /// the two things it does both end the same way: the screen is dismissed and
  /// never shown again. A controller whose only job was to call another
  /// controller would be ceremony.
  ///
  /// The state is a plain `bool` rather than an `AsyncValue` because the answer
  /// has to be available *before* the first route is chosen. `main()` loads the
  /// preferences and overrides `firstRunStoreProvider` before `runApp`, so by the
  /// time the router's `redirect` reads this there is nothing to wait for — the
  /// alternative opens on Today and jumps to the first-run screen a frame later.
  FirstRunControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firstRunControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firstRunControllerHash();

  @$internal
  @override
  FirstRunController create() => FirstRunController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$firstRunControllerHash() =>
    r'd84f4a9b24fbf1b2f483833be93c80a42e388245';

/// Whether the first-run screen is still owed, and the two ways out of it —
/// **ADR-041**.
///
/// **One notifier rather than a state and a separate actions object**, because
/// the two things it does both end the same way: the screen is dismissed and
/// never shown again. A controller whose only job was to call another
/// controller would be ceremony.
///
/// The state is a plain `bool` rather than an `AsyncValue` because the answer
/// has to be available *before* the first route is chosen. `main()` loads the
/// preferences and overrides `firstRunStoreProvider` before `runApp`, so by the
/// time the router's `redirect` reads this there is nothing to wait for — the
/// alternative opens on Today and jumps to the first-run screen a frame later.

abstract class _$FirstRunController extends $Notifier<bool> {
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
