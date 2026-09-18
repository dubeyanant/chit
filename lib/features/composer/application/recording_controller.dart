import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/clock.dart';
import '../../../domain/models/recording_state.dart';
import '../../../domain/services/audio_recorder.dart';
import 'recording_sink.dart';

part 'recording_controller.g.dart';

/// The recording sheet's state — BEHAVIOUR.md §3.4, ARCHITECTURE.md §4.4.
///
/// **It hands the result to a [RecordingSink] rather than returning it**,
/// because the sheet is a modal and not a route (ADR-011): there is nothing
/// downstream of it to give a value to. That also keeps every §3.4 rule in a
/// controller, where a test can reach it without a widget (ADR-031). *The sink
/// was `ComposerController` by name until M6's editor became the second screen
/// to record* (ADR-065); now whoever taps the microphone owns the take.
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

  /// Who the take is for — chosen at [start] and held for the take's life
  /// (ADR-065). Null between takes.
  RecordingSink? _sink;

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

  /// The microphone's tap: permission, then both services.
  ///
  /// `true` when the sheet should open. A `false` from either the ask or the
  /// start leaves it closed and marks the owner refused; they are one
  /// outcome here because from the sheet's side they are one event, and
  /// `AudioRecorder` already refuses to tell them apart.
  ///
  /// [into] is who gets the take — the open chit or the editor (ADR-065).
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

  /// **Stop & keep** — the take goes to whoever started it.
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

    final RecordingSink? owner = _sink;
    _sink = null;
    owner?.keepRecording(take);
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
