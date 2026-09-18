// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_recorder.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(audioRecorder)
final audioRecorderProvider = AudioRecorderProvider._();

final class AudioRecorderProvider
    extends $FunctionalProvider<AudioRecorder, AudioRecorder, AudioRecorder>
    with $Provider<AudioRecorder> {
  AudioRecorderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioRecorderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioRecorderHash();

  @$internal
  @override
  $ProviderElement<AudioRecorder> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AudioRecorder create(Ref ref) {
    return audioRecorder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioRecorder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioRecorder>(value),
    );
  }
}

String _$audioRecorderHash() => r'965378ef55edf74317a1a1c1d745a038320dd0a7';
