import 'dart:async';
import 'dart:io';

import 'package:chit/data/audio/audio_store.dart';
import 'package:chit/data/audio/just_audio_player.dart';
import 'package:chit/domain/services/audio_player.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio_platform_interface/just_audio_platform_interface.dart';

/// **The adapter over `just_audio`, with a fake platform under the real
/// plugin** — ADR-008, and the M5 lesson about fakes read the other way.
///
/// `FakeAudioPlayer` stands in for this class everywhere else, and it was
/// honest: a second pill took the first one off. The real one did not — the
/// plugin carries `playing` across a source change and its `play()` returns
/// early while it is set, so a pill tapped over one that was sounding was
/// heard but never lit, and the tap that should have paused it did nothing.
/// Seen on a handset, 18 September 2026. The plugin's Dart side is where that
/// happens, so the fake below sits *under* it, where the OS does, and the
/// plugin runs for real.
///
/// The platform fake keeps the one habit that matters: `play` does not return
/// until the take stops, which is what the adapter's `unawaited` is for.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeJustAudio platform;
  late Directory takes;
  late JustAudioPlayer player;
  late List<Playback> seen;
  late StreamSubscription<Playback> watching;

  setUpAll(() {
    // `audio_session` asks the OS for its configuration over a channel; with
    // nothing answering it would throw inside the plugin's `play`.
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

    // The tap that used to do nothing.
    await player.pause();
    await pumpEventQueue();
    expect(seen.last.holds('b'), isTrue);
    expect(seen.last.playing, isFalse);
  });

  test('the native player is built once and kept across both pills', () async {
    // The regression this file exists for the second time. Clearing the
    // plugin's `playing` flag with `stop()` also releases the decoder, and
    // the pill that follows is silent on a device while every other test
    // here still passes.
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

  test('a pill coming back does not inherit the last one\'s playhead', () async {
    // **The wave that would not move.** While the next file loads, the
    // position stream still answers with the one that is leaving; that figure
    // landing on the pill arriving is a playhead that starts halfway, and
    // `_onPosition`'s backwards guard then holds it there until the sound
    // catches up. Seen on a handset as a frozen wave over a recording that was
    // audibly running.
    await player.play(id: 'a', path: path('a.m4a'));
    await pumpEventQueue();
    platform.player.emitPositionOf(const Duration(seconds: 2));
    await pumpEventQueue();
    // Ranges, not equalities: the plugin interpolates the playhead from the
    // wall clock between platform events, so an exact figure is a test that
    // fails on a loaded machine and proves nothing extra on a quiet one.
    expect(
      seen.last.position,
      greaterThanOrEqualTo(const Duration(seconds: 2)),
      reason: 'a is 2s in',
    );

    platform.player.blockLoad();
    unawaited(player.play(id: 'b', path: path('b.m4a')));
    await pumpEventQueue();

    // The old file, still talking, while the new one is on its way in.
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
  });

  test('a file that is not there leaves the player silent', () async {
    await player.play(id: 'gone', path: path('gone.m4a'));
    await pumpEventQueue();

    expect(seen.last, Playback.silent);
    expect(platform.loaded, isEmpty);
  });
}

/// The plugin's platform side, faked: one player per `init`, disposed on
/// request, and every file it was asked to load in order.
final class _FakeJustAudio extends JustAudioPlatform {
  final Map<String, _FakePlatformPlayer> _players =
      <String, _FakePlatformPlayer>{};

  /// Every uri loaded, across every player, in order.
  final List<String> loaded = <String>[];

  /// How many native players the plugin has asked for.
  ///
  /// **One, for the life of the adapter.** `AudioPlayer.stop()` releases the
  /// native player and the next `setFilePath` builds another; `pause()` keeps
  /// it. Nothing else in the suite can see that difference, and on a handset
  /// it was the sound of the first tap after launch.
  int platformInits = 0;

  /// The one native player, for a test that has to talk to it directly.
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

/// One platform player. It loads at once, reports what it is told to, and its
/// `play` holds until `pause` or `dispose` — as the real one does.
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

  /// Holds the next [load] open, so a test can let the file that is leaving
  /// say something while the next one is on its way in. The real platform
  /// takes a handful of frames to open a file and does exactly this.
  void blockLoad() => _loadGate ??= Completer<void>();

  /// Lets it through.
  void unblockLoad() {
    _loadGate?.complete();
    _loadGate = null;
  }

  /// Reports [at] as the playhead, without anything having moved.
  void emitPositionOf(Duration at) {
    _position = at;
    _emit();
  }

  @override
  Stream<PlaybackEventMessage> get playbackEventMessageStream => _events.stream;

  void _emit() {
    if (_events.isClosed) return;
    _events.add(
      PlaybackEventMessage(
        processingState: _state,
        // The plugin interpolates a playhead from this; a fixed instant would
        // read as hours in. It is the platform's own clock, not the app's
        // (ADR-012 bans `DateTime.now()` in `lib/`, not under the OS).
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
    // Held open before anything changes, so that while a test blocks the load
    // the platform still reports the file that is leaving — which is the race
    // the real one has.
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

  // The settings the plugin pushes when it activates a player. All accepted,
  // none remembered: nothing here is about them.

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
