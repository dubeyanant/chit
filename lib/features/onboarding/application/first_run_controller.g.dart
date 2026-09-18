// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'first_run_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FirstRunController)
final firstRunControllerProvider = FirstRunControllerProvider._();

final class FirstRunControllerProvider
    extends $NotifierProvider<FirstRunController, bool> {
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
