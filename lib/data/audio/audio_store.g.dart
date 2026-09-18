// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(audioStore)
final audioStoreProvider = AudioStoreProvider._();

final class AudioStoreProvider
    extends $FunctionalProvider<AudioStore, AudioStore, AudioStore>
    with $Provider<AudioStore> {
  AudioStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioStoreHash();

  @$internal
  @override
  $ProviderElement<AudioStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AudioStore create(Ref ref) {
    return audioStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioStore>(value),
    );
  }
}

String _$audioStoreHash() => r'3f07863b193ba288a4e49953dc468088f1b474dd';
