// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ambient_resume.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ambientResume)
final ambientResumeProvider = AmbientResumeProvider._();

final class AmbientResumeProvider
    extends
        $FunctionalProvider<
          AppLifecycleListener,
          AppLifecycleListener,
          AppLifecycleListener
        >
    with $Provider<AppLifecycleListener> {
  AmbientResumeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ambientResumeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ambientResumeHash();

  @$internal
  @override
  $ProviderElement<AppLifecycleListener> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AppLifecycleListener create(Ref ref) {
    return ambientResume(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLifecycleListener value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLifecycleListener>(value),
    );
  }
}

String _$ambientResumeHash() => r'b0c740c972d78ea54866d235482f535505222afa';
