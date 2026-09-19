import 'dart:async';
import 'dart:io';

import 'package:chitta/data/audio/audio_store.dart';
import 'package:chitta/data/audio/just_audio_player.dart';
import 'package:chitta/domain/services/audio_player.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio_platform_interface/just_audio_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeJustAudio platform;
  late Directory takes;
  late JustAudioPlayer player;
  late List<Playback> seen;
  late StreamSubscription<Playback> watching;

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.ryanheise.audio_session'),
          (MethodCall _) async => null,
        );
  });

  setUp(() async {
    platform = _FakeJustAudio();
    JustAudioPlatform.instance = platform;
    takes = Directory.systemTemp.createTempSync('chit-player-');
    for (final String name in <String>['a.m4a', 'b.m4a']) {
      File('${takes.path}/$name').writeAsBytesSync(<int>[0, 1, 2, 3]);
    }
    player = JustAudioPlayer(AudioStore(Future<Directory>.value(takes)));
    seen = <Playback>[];
    watching = player.playback.listen(seen.add);
  });

  tearDown(() async {
    await watching.cancel();
    await player.dispose();
    takes.deleteSync(recursive: true);
  });

  String path(String name) => '${takes.path}/$name';

  test('a pill tapped while another sounds is lit, and pauses', () async {
    await player.play(id: 'a', path: path('a.m4a'));
    await pumpEventQueue();
    expect(seen.last.holds('a'), isTrue);
    expect(seen.last.playing, isTrue);

    await player.play(id: 'b', path: path('b.m4a'));
    await pumpEventQueue();

    expect(seen.last.holds('b'), isTrue, reason: 'the second pill took over');
    expect(seen.last.playing, isTrue, reason: 'and it is lit, not just heard');
    expect(platform.loaded.last, endsWith('b.m4a'));

    await player.pause();
    await pumpEventQueue();
    expect(seen.last.holds('b'), isTrue);
    expect(seen.last.playing, isFalse);
  });

  test('the native player is built once and kept across both pills', () async {
    await player.play(id: 'a', path: path('a.m4a'));
    await pumpEventQueue();
    await player.play(id: 'b', path: path('b.m4a'));
    await pumpEventQueue();

    expect(platform.platformInits, 1);
    expect(platform.loaded, hasLength(2), reason: 'two files, one player');
  });

  test('a paused pill resumes without being reloaded', () async {
    await player.play(id: 'a', path: path('a.m4a'));
    await pumpEventQueue();
    await player.pause();
    await pumpEventQueue();

    await player.play(id: 'a', path: path('a.m4a'));
    await pumpEventQueue();

    expect(seen.last.holds('a'), isTrue);
    expect(seen.last.playing, isTrue);
    expect(platform.loaded, hasLength(1), reason: 'resumed, not started over');
  });

  test(
    'a pill coming back does not inherit the last one\'s playhead',
    () async {
      await player.play(id: 'a', path: path('a.m4a'));
      await pumpEventQueue();
      platform.player.emitPositionOf(const Duration(seconds: 2));
      await pumpEventQueue();

      expect(
        seen.last.position,
        greaterThanOrEqualTo(const Duration(seconds: 2)),
        reason: 'a is 2s in',
      );

      platform.player.blockLoad();
      unawaited(player.play(id: 'b', path: path('b.m4a')));
      await pumpEventQueue();

      platform.player.emitPositionOf(const Duration(seconds: 2));
      await pumpEventQueue();

      platform.player.unblockLoad();
      await pumpEventQueue();

      expect(seen.last.holds('b'), isTrue);
      expect(
        seen.last.position,
        lessThan(const Duration(seconds: 1)),
        reason: 'b starts at its own beginning, not two seconds into a',
      );
    },
  );

  test('a file that is not there leaves the player silent', () async {
    await player.play(id: 'gone', path: path('gone.m4a'));
    await pumpEventQueue();

    expect(seen.last, Playback.silent);
    expect(platform.loaded, isEmpty);
  });

  test(
    'a take carries the length the player decoded, not the row\'s',
    () async {
      await player.play(id: 'a', path: path('a.m4a'));
      await pumpEventQueue();

      expect(seen.last.length, const Duration(seconds: 3));
    },
  );

  test('a take that finishes holds at its end, lit', () async {
    await player.play(id: 'a', path: path('a.m4a'));
    await pumpEventQueue();

    platform.player.emitCompleted();
    await pumpEventQueue();

    expect(seen.last.holds('a'), isTrue, reason: 'it is still this pill');
    expect(
      seen.last.position,
      seen.last.length,
      reason: 'the last bar is lit, which is what finishing looks like',
    );
    expect(seen.last.playing, isFalse);
  });

  test('a finished take plays again from its own beginning', () async {
    await player.play(id: 'a', path: path('a.m4a'));
    await pumpEventQueue();
    platform.player.emitCompleted();
    await pumpEventQueue();

    await player.play(id: 'a', path: path('a.m4a'));
    await pumpEventQueue();

    expect(seen.last.holds('a'), isTrue);
    expect(
      seen.last.position,
      lessThan(const Duration(seconds: 1)),
      reason: 'the held end must not survive the replay',
    );
    expect(platform.loaded, hasLength(1), reason: 'sought, not reloaded');
  });
}

final class _FakeJustAudio extends JustAudioPlatform {
  final Map<String, _FakePlatformPlayer> _players =
      <String, _FakePlatformPlayer>{};

  final List<String> loaded = <String>[];

  int platformInits = 0;

  late _FakePlatformPlayer player;

  @override
  Future<AudioPlayerPlatform> init(InitRequest request) async {
    platformInits++;
    player = _FakePlatformPlayer(request.id, loaded);
    _players[request.id] = player;
    return player;
  }

  @override
  Future<DisposePlayerResponse> disposePlayer(
    DisposePlayerRequest request,
  ) async {
    await _players.remove(request.id)?.dispose(DisposeRequest());
    return DisposePlayerResponse();
  }

  @override
  Future<DisposeAllPlayersResponse> disposeAllPlayers(
    DisposeAllPlayersRequest request,
  ) async {
    for (final _FakePlatformPlayer player in _players.values) {
      await player.dispose(DisposeRequest());
    }
    _players.clear();
    return DisposeAllPlayersResponse();
  }
}

final class _FakePlatformPlayer extends AudioPlayerPlatform {
  _FakePlatformPlayer(super.id, this._loaded);

  static const Duration _take = Duration(seconds: 3);

  final List<String> _loaded;
  final StreamController<PlaybackEventMessage> _events =
      StreamController<PlaybackEventMessage>.broadcast();

  ProcessingStateMessage _state = ProcessingStateMessage.idle;
  Duration _position = Duration.zero;
  Completer<void>? _sounding;
  Completer<void>? _loadGate;

  void blockLoad() => _loadGate ??= Completer<void>();

  void unblockLoad() {
    _loadGate?.complete();
    _loadGate = null;
  }

  void emitPositionOf(Duration at) {
    _position = at;
    _emit();
  }

  void emitCompleted() {
    _sounding?.complete();
    _sounding = null;
    _position = _take;
    _state = ProcessingStateMessage.completed;
    _emit();
  }

  @override
  Stream<PlaybackEventMessage> get playbackEventMessageStream => _events.stream;

  void _emit() {
    if (_events.isClosed) return;
    _events.add(
      PlaybackEventMessage(
        processingState: _state,

        updateTime: DateTime.now(),
        updatePosition: _position,
        bufferedPosition: _position,
        duration: _take,
        icyMetadata: null,
        currentIndex: 0,
        androidAudioSessionId: null,
      ),
    );
  }

  @override
  Future<LoadResponse> load(LoadRequest request) async {
    final ConcatenatingAudioSourceMessage playlist =
        request.audioSourceMessage as ConcatenatingAudioSourceMessage;
    final UriAudioSourceMessage source =
        playlist.children.first as UriAudioSourceMessage;

    if (_loadGate case final Completer<void> gate) await gate.future;

    _loaded.add(source.uri);
    _state = ProcessingStateMessage.loading;
    _emit();
    _position = Duration.zero;
    _state = ProcessingStateMessage.ready;
    _emit();
    return LoadResponse(duration: _take);
  }

  @override
  Future<PlayResponse> play(PlayRequest request) async {
    if (_sounding != null) return PlayResponse();
    _sounding = Completer<void>();
    await _sounding!.future;
    return PlayResponse();
  }

  @override
  Future<PauseResponse> pause(PauseRequest request) async {
    _sounding?.complete();
    _sounding = null;
    _emit();
    return PauseResponse();
  }

  @override
  Future<SeekResponse> seek(SeekRequest request) async {
    _position = request.position ?? Duration.zero;
    _emit();
    return SeekResponse();
  }

  @override
  Future<DisposeResponse> dispose(DisposeRequest request) async {
    _sounding?.complete();
    _sounding = null;
    _state = ProcessingStateMessage.idle;
    _emit();
    await _events.close();
    return DisposeResponse();
  }

  @override
  Future<SetVolumeResponse> setVolume(SetVolumeRequest request) async =>
      SetVolumeResponse();

  @override
  Future<SetSpeedResponse> setSpeed(SetSpeedRequest request) async =>
      SetSpeedResponse();

  @override
  Future<SetPitchResponse> setPitch(SetPitchRequest request) async =>
      SetPitchResponse();

  @override
  Future<SetSkipSilenceResponse> setSkipSilence(
    SetSkipSilenceRequest request,
  ) async => SetSkipSilenceResponse();

  @override
  Future<SetLoopModeResponse> setLoopMode(SetLoopModeRequest request) async =>
      SetLoopModeResponse();

  @override
  Future<SetShuffleModeResponse> setShuffleMode(
    SetShuffleModeRequest request,
  ) async => SetShuffleModeResponse();

  @override
  Future<SetShuffleOrderResponse> setShuffleOrder(
    SetShuffleOrderRequest request,
  ) async => SetShuffleOrderResponse();

  @override
  Future<SetAutomaticallyWaitsToMinimizeStallingResponse>
  setAutomaticallyWaitsToMinimizeStalling(
    SetAutomaticallyWaitsToMinimizeStallingRequest request,
  ) async => SetAutomaticallyWaitsToMinimizeStallingResponse();

  @override
  Future<SetCanUseNetworkResourcesForLiveStreamingWhilePausedResponse>
  setCanUseNetworkResourcesForLiveStreamingWhilePaused(
    SetCanUseNetworkResourcesForLiveStreamingWhilePausedRequest request,
  ) async => SetCanUseNetworkResourcesForLiveStreamingWhilePausedResponse();

  @override
  Future<SetPreferredPeakBitRateResponse> setPreferredPeakBitRate(
    SetPreferredPeakBitRateRequest request,
  ) async => SetPreferredPeakBitRateResponse();

  @override
  Future<SetAllowsExternalPlaybackResponse> setAllowsExternalPlayback(
    SetAllowsExternalPlaybackRequest request,
  ) async => SetAllowsExternalPlaybackResponse();

  @override
  Future<SetAndroidAudioAttributesResponse> setAndroidAudioAttributes(
    SetAndroidAudioAttributesRequest request,
  ) async => SetAndroidAudioAttributesResponse();

  @override
  Future<AudioEffectSetEnabledResponse> audioEffectSetEnabled(
    AudioEffectSetEnabledRequest request,
  ) async => AudioEffectSetEnabledResponse();
}
