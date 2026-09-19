// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'composer_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ComposerController)
final composerControllerProvider = ComposerControllerProvider._();

final class ComposerControllerProvider
    extends $NotifierProvider<ComposerController, ComposerState> {
  ComposerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'composerControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$composerControllerHash();

  @$internal
  @override
  ComposerController create() => ComposerController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ComposerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ComposerState>(value),
    );
  }
}

String _$composerControllerHash() =>
    r'5c8f64e352e0f7455c8ce9966db17cdf2d9ebd85';

abstract class _$ComposerController extends $Notifier<ComposerState> {
  ComposerState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ComposerState, ComposerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ComposerState, ComposerState>,
              ComposerState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
