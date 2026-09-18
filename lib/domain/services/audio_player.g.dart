part of 'audio_player.dart';

@ProviderFor(audioPlayer)
final audioPlayerProvider = AudioPlayerProvider._();

final class AudioPlayerProvider
    extends $FunctionalProvider<AudioPlayer, AudioPlayer, AudioPlayer>
    with $Provider<AudioPlayer> {
  AudioPlayerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioPlayerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioPlayerHash();

  @$internal
  @override
  $ProviderElement<AudioPlayer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AudioPlayer create(Ref ref) {
    return audioPlayer(ref);
  }

  Override overrideWithValue(AudioPlayer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioPlayer>(value),
    );
  }
}

String _$audioPlayerHash() => r'bdf41f6f46bbbd6cd7f76d0f6c4a2b93a8b8ca13';

@ProviderFor(playback)
final playbackProvider = PlaybackProvider._();

final class PlaybackProvider
    extends
        $FunctionalProvider<AsyncValue<Playback>, Playback, Stream<Playback>>
    with $FutureModifier<Playback>, $StreamProvider<Playback> {
  PlaybackProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playbackProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playbackHash();

  @$internal
  @override
  $StreamProviderElement<Playback> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Playback> create(Ref ref) {
    return playback(ref);
  }
}

String _$playbackHash() => r'69238b99c4cad01171927e35c170585d62c0c90a';
