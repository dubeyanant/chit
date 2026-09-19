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
