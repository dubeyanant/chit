import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/clock.dart';
import '../../../domain/models/recording_state.dart';
import '../../../domain/services/audio_recorder.dart';
import 'composer_controller.dart';

part 'recording_controller.g.dart';

/// The recording sheet's state — BEHAVIOUR.md §3.4, ARCHITECTURE.md §4.4.
///
/// **It hands the result to `ComposerController` rather than returning it**,
/// because the sheet is a modal and not a route (ADR-011): there is nothing
/// downstream of it to give a value to. That also keeps every §3.4 and §3.5
/// rule in a controller, where a test can reach it without a widget (ADR-031).
///
/// **`keepAlive`, and it is the only screen-state controller that is** —
/// ADR-057. A take begins before the sheet exists and finishes after it has
/// gone, so for the length of the permission round-trip there is nothing
/// watching this at all; auto-disposed, it was thrown away mid-`start`, and
/// the microphone opened and shut without a sheet ever appearing. Nothing here
/// leaks in exchange: [start] resets the state, and both ways out of a take
/// reset it again.
@Riverpod(keepAlive: true)
class RecordingController extends _$RecordingController {
  /// How often the elapsed figure is recomputed.
  ///
  /// **Not a pace and not a loop** (ADR-027): it is a readout of something in
  /// progress, so reduced motion does not slow it and §6.4 does not stop it.
  /// Four times a second for a figure drawn in whole seconds, because a one
  /// second period lands wherever the take started and reads as a stutter.
  static const Duration tick = Duration(milliseconds: 250);

  /// How many level readings the wave keeps — one per bar.
  ///
  /// It is the bar count of v6's live wave, and it is named here rather than
  /// in the widget because this is what trims the buffer. At the recorder's
  /// 80ms sampling that is the last 1.6 seconds, which is a glance at what was
  /// just said rather than a record of the take.
  static const int levelWindow = 20;

  Timer? _ticking;
  StreamSubscription<double>? _levels;

  /// When the take began, or `null` when none is running.
  DateTime? _startedAt;

  @override
  RecordingState build() {
    // Read here rather than in each method so that a disposal can still close
    // the platform down. Since this provider is `keepAlive` that means the app
    // being torn down mid-take rather than the sheet going away — but a live
    // microphone is what it costs either way, and `ref.read` after disposal is
    // not allowed where these are.
    final AudioRecorder recorder = ref.watch(audioRecorderProvider);

    ref.onDispose(() {
      final bool running = _startedAt != null;
      _release();
      if (running) unawaited(recorder.cancel());
    });

    return const RecordingState();
  }

  /// The microphone's tap: permission, then both services — TASKS.md D2.
  ///
  /// `true` when the sheet should open. A `false` from either the ask or the
  /// start leaves it closed and marks the composer refused; they are one
  /// outcome here because from the sheet's side they are one event, and
  /// `AudioRecorder` already refuses to tell them apart.
  Future<bool> start() async {
    assert(_startedAt == null, 'one take at a time — BEHAVIOUR.md §3.2');

    final AudioRecorder recorder = ref.read(audioRecorderProvider);
    if (!await recorder.requestPermission() || !await recorder.start()) {
      if (ref.mounted) {
        ref.read(composerControllerProvider.notifier).microphoneWasRefused();
      }
      return false;
    }

    if (!ref.mounted) {
      await recorder.cancel();
      return false;
    }

    state = const RecordingState();
    _startedAt = ref.read(clockProvider).now();
    _ticking = Timer.periodic(tick, (Timer _) => _tick());
    _levels = recorder.levels.listen(_onLevel);

    ref.read(composerControllerProvider.notifier).recordingStarted();
    return true;
  }

  /// **Stop & keep** — the take goes to the open chit.
  Future<void> stopAndKeep() async {
    if (_startedAt == null) return;
    // Cleared before the await, so a second press while the platform is still
    // closing the file does nothing.
    _startedAt = null;
    _ticking?.cancel();
    _ticking = null;

    final Recording? take = await ref.read(audioRecorderProvider).stop();

    _release();
    if (!ref.mounted) return;

    ref.read(composerControllerProvider.notifier).keepRecording(take);
    state = const RecordingState();
  }

  /// The sheet dismissed — nothing kept, nothing written, the file deleted.
  ///
  Future<void> cancel() async {
    if (_startedAt == null) return;
    _startedAt = null;
    _ticking?.cancel();
    _ticking = null;

    await ref.read(audioRecorderProvider).cancel();

    _release();
    if (!ref.mounted) return;

    state = const RecordingState();
    ref.read(composerControllerProvider.notifier).recordingCancelled();
  }

  void _tick() {
    final DateTime? from = _startedAt;
    if (from == null) return;
    state = state.copyWith(
      elapsed: ref.read(clockProvider).now().difference(from),
    );
  }

  /// Pushes a reading onto the wave, dropping the oldest once it is full.
  void _onLevel(double level) {
    final List<double> kept = <double>[...state.levels, level];
    state = state.copyWith(
      levels: kept.length <= levelWindow
          ? kept
          : kept.sublist(kept.length - levelWindow),
    );
  }

  /// Stops watching. It tells the recorder nothing — the callers do that.
  void _release() {
    _ticking?.cancel();
    _ticking = null;
    unawaited(_levels?.cancel());
    _levels = null;
    _startedAt = null;
  }
}
