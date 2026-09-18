import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/clock.dart';
import '../../../domain/models/recording_state.dart';
import '../../../domain/services/audio_recorder.dart';
import '../../../domain/services/speech_recognizer.dart';
import 'composer_controller.dart';

part 'recording_controller.g.dart';

/// The recording sheet's state — BEHAVIOUR.md §3.4, ARCHITECTURE.md §4.4.
///
/// **Two services, one take** (TASKS.md D1). The recogniser takes no file and
/// no stream, so the only way to keep the audio *and* have words is to run
/// both at once; this is the thing that runs them, and neither knows the other
/// exists. Whether a phone will let them share the microphone is open item 32
/// and nothing here can settle it.
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
  StreamSubscription<Transcript>? _words;

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
    final SpeechRecognizer recognizer = ref.watch(speechRecognizerProvider);

    ref.onDispose(() {
      final bool running = _startedAt != null;
      _release();
      if (running) {
        unawaited(recognizer.stop());
        unawaited(recorder.cancel());
      }
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

    // Started after the recorder, and deliberately not awaited: the file is
    // the part that must not be missed, and a recogniser that takes a moment
    // to wake costs a word rather than the take.
    _words = ref
        .read(speechRecognizerProvider)
        .start()
        .listen(_onWords, onDone: _onRecognizerDone);

    ref.read(composerControllerProvider.notifier).recordingStarted();
    return true;
  }

  /// **Stop & keep** — the take and whatever was heard go to the open chit.
  ///
  /// The recogniser is stopped **first**, because its last word lands after
  /// the microphone closes (ADR-053) and the transcript is read from state
  /// once that has happened. Skipped when it has already given up, since
  /// stopping a recogniser that has stopped is a wait for nothing.
  Future<void> stopAndKeep() async {
    if (_startedAt == null) return;
    // Cleared before the first await, so a second press while this one is
    // still waiting on the recogniser's last word does nothing — and so the
    // stream closing under [stop] is not read as the recogniser giving up.
    _startedAt = null;
    _ticking?.cancel();
    _ticking = null;

    if (!state.recognitionGaveUp) {
      await ref.read(speechRecognizerProvider).stop();
    }
    final Recording? take = await ref.read(audioRecorderProvider).stop();
    final Transcript heard = state.transcript;

    _release();
    if (!ref.mounted) return;

    ref
        .read(composerControllerProvider.notifier)
        .keepRecording(recording: take, transcript: heard);
    state = const RecordingState();
  }

  /// The sheet dismissed — nothing kept, nothing written, the file deleted.
  ///
  /// Both services are stopped before the subscriptions go, so the recogniser
  /// has somewhere to close its stream to; releasing first would leave `stop`
  /// waiting out its own ceiling for a listener that is no longer there.
  Future<void> cancel() async {
    if (_startedAt == null) return;
    _startedAt = null;
    _ticking?.cancel();
    _ticking = null;

    await ref.read(speechRecognizerProvider).stop();
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

  void _onWords(Transcript heard) => state = state.copyWith(transcript: heard);

  /// The recogniser's stream closed while the take is still running — a
  /// platform that gave up, or one that never started (ADR-053).
  void _onRecognizerDone() {
    if (_startedAt == null) return;
    state = state.copyWith(recognitionGaveUp: true);
  }

  /// Stops watching. It tells neither service anything — the callers do that,
  /// in the order each of them needs.
  void _release() {
    _ticking?.cancel();
    _ticking = null;
    unawaited(_levels?.cancel());
    _levels = null;
    unawaited(_words?.cancel());
    _words = null;
    _startedAt = null;
  }
}
