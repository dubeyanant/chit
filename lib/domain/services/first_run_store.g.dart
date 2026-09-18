// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'first_run_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(firstRunStore)
final firstRunStoreProvider = FirstRunStoreProvider._();

final class FirstRunStoreProvider
    extends $FunctionalProvider<FirstRunStore, FirstRunStore, FirstRunStore>
    with $Provider<FirstRunStore> {
  FirstRunStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firstRunStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firstRunStoreHash();

  @$internal
  @override
  $ProviderElement<FirstRunStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FirstRunStore create(Ref ref) {
    return firstRunStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirstRunStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirstRunStore>(value),
    );
  }
}

String _$firstRunStoreHash() => r'af6ddeba6db8e7a01f4ceda2befd02e5ea4e6b03';
