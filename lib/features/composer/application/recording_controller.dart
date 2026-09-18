import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/clock.dart';
import '../../../domain/models/recording_state.dart';
import '../../../domain/services/audio_recorder.dart';
import 'recording_sink.dart';

part 'recording_controller.g.dart';

@Riverpod(keepAlive: true)
class RecordingController extends _$RecordingController {
  static const Duration tick = Duration(milliseconds: 250);

  static const int levelWindow = 20;

  Timer? _ticking;
  StreamSubscription<double>? _levels;

  DateTime? _startedAt;

  RecordingSink? _sink;

  @override
  RecordingState build() {
    final AudioRecorder recorder = ref.watch(audioRecorderProvider);

    ref.onDispose(() {
      final bool running = _startedAt != null;
      _release();
      if (running) unawaited(recorder.cancel());
    });

    return const RecordingState();
  }

  Future<bool> start({required RecordingSink into}) async {
    assert(_startedAt == null, 'one take at a time — BEHAVIOUR.md §3.2');

    final AudioRecorder recorder = ref.read(audioRecorderProvider);
    if (!await recorder.requestPermission() || !await recorder.start()) {
      if (ref.mounted) into.microphoneWasRefused();
      return false;
    }

    if (!ref.mounted) {
      await recorder.cancel();
      return false;
    }

    state = const RecordingState();
    _sink = into;
    _startedAt = ref.read(clockProvider).now();
    _ticking = Timer.periodic(tick, (Timer _) => _tick());
    _levels = recorder.levels.listen(_onLevel);

    into.recordingStarted();
    return true;
  }

  Future<void> stopAndKeep() async {
    if (_startedAt == null) return;

    _startedAt = null;
    _ticking?.cancel();
    _ticking = null;

    final Recording? take = await ref.read(audioRecorderProvider).stop();

    _release();
    if (!ref.mounted) return;

    final RecordingSink? owner = _sink;
    _sink = null;
    owner?.keepRecording(take);
    state = const RecordingState();
  }

  Future<void> cancel() async {
    if (_startedAt == null) return;
    _startedAt = null;
    _ticking?.cancel();
    _ticking = null;

    await ref.read(audioRecorderProvider).cancel();

    _release();
    if (!ref.mounted) return;

    state = const RecordingState();
    final RecordingSink? owner = _sink;
    _sink = null;
    owner?.recordingCancelled();
  }

  void _tick() {
    final DateTime? from = _startedAt;
    if (from == null) return;
    state = state.copyWith(
      elapsed: ref.read(clockProvider).now().difference(from),
    );
  }

  void _onLevel(double level) {
    final List<double> kept = <double>[...state.levels, level];
    state = state.copyWith(
      levels: kept.length <= levelWindow
          ? kept
          : kept.sublist(kept.length - levelWindow),
    );
  }

  void _release() {
    _ticking?.cancel();
    _ticking = null;
    unawaited(_levels?.cancel());
    _levels = null;
    _startedAt = null;
  }
}
