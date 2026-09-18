import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/clock.dart';
import '../../../domain/models/ambient_stamp.dart';
import '../../../domain/models/chit.dart';
import '../../../domain/models/composer_state.dart';
import '../../../domain/repositories/chit_repository.dart';
import '../../../domain/services/ambient_signals.dart';
import '../../../domain/services/audio_player.dart';
import '../../../domain/services/audio_recorder.dart';
import 'recording_sink.dart';

part 'composer_controller.g.dart';

@riverpod
class ComposerController extends _$ComposerController implements RecordingSink {
  static const Duration idle = Duration(seconds: 5);

  Timer? _idle;

  @override
  ComposerState build() {
    ref.onDispose(_cancelPrompt);

    ref.watch(ambientSignalsProvider);

    return _openChit();
  }

  ComposerState _openChit() {
    _armPrompt();
    return ComposerState(stamp: _stampNow());
  }

  void _armPrompt() {
    _idle?.cancel();
    _idle = Timer(idle, () {
      if (!ref.mounted) return;
      state = state.copyWith(showPrompt: true);
    });
  }

  void _cancelPrompt() {
    _idle?.cancel();
    _idle = null;
  }

  void edit(String text) {
    final bool blank = text.trim().isEmpty;

    state = state.copyWith(text: text, showPrompt: false);

    if (blank) {
      _armPrompt();
    } else {
      _cancelPrompt();
    }
  }

  Future<void> save() async {
    final ComposerState chit = state;
    if (!chit.canSave) return;

    if (chit.hasAudio) {
      await ref.read(audioPlayerProvider).stopIf(Playback.openChit);
      if (!ref.mounted) return;
    }

    final DateTime now = ref.read(clockProvider).now();
    final AmbientReading held = ref.read(ambientSignalsProvider);
    final bool fresh = held.isFreshAt(now);

    final Chit saved = await ref
        .read(chitRepositoryProvider)
        .save(
          stamp: AmbientStamp(
            capturedAt: now,
            weather: held.weather,
            lat: held.lat,
            lon: held.lon,
            motion: held.motion,
          ),
          text: chit.text,
          audioTempPath: chit.audioTempPath,
          audioDuration: chit.audioDuration,
        );

    if (!fresh) unawaited(_refreshAmbience(saved.id));

    if (!ref.mounted) return;
    state = _openChit();
  }

  AmbientStamp _stampNow() {
    final AmbientReading held = ref.read(ambientSignalsProvider);

    return AmbientStamp(
      capturedAt: ref.read(clockProvider).now(),
      weather: held.weather,
      lat: held.lat,
      lon: held.lon,
      motion: held.motion,
    );
  }

  Future<void> _refreshAmbience(String id) async {
    await ref.read(ambientSignalsProvider.notifier).refresh();

    if (!ref.mounted) return;

    final AmbientReading fresh = ref.read(ambientSignalsProvider);

    await ref
        .read(chitRepositoryProvider)
        .updateAmbient(
          id: id,
          weather: fresh.weather,
          lat: fresh.lat,
          lon: fresh.lon,
          motion: fresh.motion,
        );
  }

  @override
  void recordingStarted() {
    _cancelPrompt();
    state = state.copyWith(
      isRecording: true,
      showPrompt: false,
      microphoneRefused: false,
    );
  }

  @override
  void recordingCancelled() {
    state = state.copyWith(isRecording: false);
    if (!state.canSave) _armPrompt();
  }

  @override
  void microphoneWasRefused() =>
      state = state.copyWith(isRecording: false, microphoneRefused: true);

  @override
  void keepRecording(Recording? recording) {
    final ComposerState chit = state;
    if (recording == null) {
      state = chit.copyWith(isRecording: false);
      return;
    }

    _cancelPrompt();

    state = chit.copyWith(
      audioTempPath: recording.tempPath,
      audioDuration: recording.duration,
      isRecording: false,
      showPrompt: false,
    );
  }

  Future<void> removeTake() async {
    final String? take = state.audioTempPath;
    if (take == null) return;

    state = state.copyWith(audioTempPath: null, audioDuration: null);
    if (!state.canSave) _armPrompt();

    await ref.read(audioPlayerProvider).stopIf(Playback.openChit);
    await ref.read(chitRepositoryProvider).discardTemp(take);
  }
}
