// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guide_memory.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(guideMemory)
final guideMemoryProvider = GuideMemoryProvider._();

final class GuideMemoryProvider
    extends $FunctionalProvider<GuideMemory, GuideMemory, GuideMemory>
    with $Provider<GuideMemory> {
  GuideMemoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guideMemoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guideMemoryHash();

  @$internal
  @override
  $ProviderElement<GuideMemory> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GuideMemory create(Ref ref) {
    return guideMemory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GuideMemory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GuideMemory>(value),
    );
  }
}

String _$guideMemoryHash() => r'8eda35d725ca1dd7697b7c89efe7686cdc6257ed';
