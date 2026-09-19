// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shell_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(anyChitWritten)
final anyChitWrittenProvider = AnyChitWrittenProvider._();

final class AnyChitWrittenProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  AnyChitWrittenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'anyChitWrittenProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$anyChitWrittenHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return anyChitWritten(ref);
  }
}

String _$anyChitWrittenHash() => r'90b47c6451066c9037fb50ceb88e21c1110b08ca';

@ProviderFor(anyChitTagged)
final anyChitTaggedProvider = AnyChitTaggedProvider._();

final class AnyChitTaggedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  AnyChitTaggedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'anyChitTaggedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$anyChitTaggedHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return anyChitTagged(ref);
  }
}

String _$anyChitTaggedHash() => r'673de4345797d848e5d145bdd44eb5a8380a7dd6';

@ProviderFor(anyAmbientAxis)
final anyAmbientAxisProvider = AnyAmbientAxisProvider._();

final class AnyAmbientAxisProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  AnyAmbientAxisProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'anyAmbientAxisProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$anyAmbientAxisHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return anyAmbientAxis(ref);
  }
}

String _$anyAmbientAxisHash() => r'67dbb671da867a4946f8a11295a91f5c772ebd75';

@ProviderFor(findGoesSomewhere)
final findGoesSomewhereProvider = FindGoesSomewhereProvider._();

final class FindGoesSomewhereProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  FindGoesSomewhereProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'findGoesSomewhereProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$findGoesSomewhereHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return findGoesSomewhere(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$findGoesSomewhereHash() => r'c47cad69cae882b7c10166017f2e6633abdbe26b';
