import 'dart:async';

import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as plugin;

import '../../domain/services/speech_recognizer.dart';

/// [SpeechRecognizer] over `speech_to_text`, on the device — ADR-005, ADR-053.
///
/// **`onDevice: true` is set here and nowhere else.** That one flag is the
/// whole of ADR-005: with it the recogniser either runs locally or fails, and
/// there is no path along which a recorded thought reaches a network. Failing
/// is the acceptable half of that trade, because §3.5 already keeps the audio.
///
/// **It never throws and it never reports an error.** A plugin that would not
/// initialise, a platform that refused to stay on the device, a language with
/// no model and a take in which nothing was said all end the stream the same
/// way — closed, with nothing on it.
final class OnDeviceSpeechRecognizer implements SpeechRecognizer {
  /// A recogniser. Nothing is initialised until the first take.
  OnDeviceSpeechRecognizer();

  /// How long [stop] waits for the last word after the platform has been told
  /// to stop.
  ///
  /// The recogniser revises its final word *after* the microphone closes, and
  /// that word is the one most likely to be wrong. Waiting for it is the one
  /// place this app waits for a signal at all (ADR-007 refuses everywhere
  /// else) and the reason is the exception ARCHITECTURE.md §6 names: ambient
  /// signals fail silently, the user's content does not.
  ///
  /// Comfortably longer than [_finalTimeout], so the plugin's own promotion
  /// lands inside it and the ceiling only bites when the platform has stopped
  /// answering altogether.
  static const Duration finalPause = Duration(milliseconds: 900);

  /// How long the plugin waits for the platform's final result before
  /// promoting the last partial to one. Its own default is two seconds, which
  /// would hold the sheet open long past the point a person notices.
  static const Duration _finalTimeout = Duration(milliseconds: 450);

  /// Local recognition, revised as it goes, tuned for sentences.
  ///
  /// `cancelOnError: false` because the plugin's automatic cancel on a
  /// permanent error would throw away a final result we would rather keep;
  /// [_onError] ends the take itself, keeping every word already heard.
  static final plugin.SpeechListenOptions _options = plugin.SpeechListenOptions(
    onDevice: true,
    listenMode: plugin.ListenMode.dictation,
  );

  final plugin.SpeechToText _speech = plugin.SpeechToText();

  /// Whether `initialize` worked, once it has been asked. Asked once per run:
  /// a device with no recogniser does not acquire one between takes.
  bool? _available;

  /// The running take, or `null` between takes.
  StreamController<Transcript>? _session;

  /// Completes when the running take's stream has closed. [stop] waits on it.
  Completer<void>? _ended;

  @override
  Stream<Transcript> start() {
    assert(_session == null, 'one take at a time — BEHAVIOUR.md §3.2');

    final StreamController<Transcript> session = StreamController<Transcript>();
    _session = session;
    _ended = Completer<void>();
    unawaited(_beginListening(session));
    return session.stream;
  }

  @override
  Future<void> stop() async {
    final Completer<void>? ended = _ended;
    if (ended == null) return;

    try {
      await _speech.stop();
    } on Object {
      await _end();
      return;
    }

    // The final result and the `done` status arrive after this; whichever
    // lands first closes the stream. The ceiling is for the platform that
    // sends neither.
    await ended.future.timeout(finalPause, onTimeout: _end);
  }

  /// Initialises on the first take and starts listening, or ends the take.
  Future<void> _beginListening(StreamController<Transcript> session) async {
    try {
      _available ??= await _speech.initialize(
        onError: _onError,
        onStatus: _onStatus,
        finalTimeout: _finalTimeout,
      );

      if (_available ?? false) {
        await _speech.listen(onResult: _onResult, listenOptions: _options);
        return;
      }
    } on Object {
      // A platform channel that fell over is a recogniser that heard nothing.
    }
    await _end();
  }

  /// A partial or final result from the platform.
  void _onResult(SpeechRecognitionResult result) {
    final StreamController<Transcript>? session = _session;
    if (session == null || session.isClosed) return;
    session.add(
      transcriptOf(result.recognizedWords, settled: result.finalResult),
    );
  }

  /// Anything the platform calls an error ends the take, whatever its code.
  ///
  /// *There is no error table, and the four codes TASKS.md group B named do
  /// not appear here.* Android marks every error permanent and stops listening
  /// as it reports one, so a code-by-code rule would be a rule about one
  /// platform's vocabulary that changes nothing: D5 already says the three
  /// causes share a branch, and closing the stream **is** that branch. Words
  /// already heard are kept — the take that half-worked is worth what it
  /// heard.
  void _onError(SpeechRecognitionError error) => unawaited(_end());

  /// `done` means every result has been delivered — the take is over.
  void _onStatus(String status) {
    if (status == plugin.SpeechToText.doneStatus) unawaited(_end());
  }

  /// Closes the running take's stream, once, and releases [stop].
  Future<void> _end() async {
    final StreamController<Transcript>? session = _session;
    final Completer<void>? ended = _ended;
    _session = null;
    _ended = null;

    await session?.close();
    if (ended != null && !ended.isCompleted) ended.complete();
  }

  /// The plugin's [words] as the sheet draws them.
  ///
  /// A [settled] result has nothing left to revise, so every word is
  /// committed. On a partial it is the **last** word that is still being
  /// heard — the recogniser lengthens and rewrites its tail as more of a
  /// sound arrives, and leaves what is behind it alone.
  static Transcript transcriptOf(String words, {required bool settled}) {
    final String said = words.trim();
    if (said.isEmpty) return Transcript.nothing;
    if (settled) return Transcript(committed: said);

    final int lastGap = said.lastIndexOf(RegExp(r'\s'));
    if (lastGap < 0) return Transcript(pending: said);

    return Transcript(
      committed: said.substring(0, lastGap).trimRight(),
      pending: said.substring(lastGap + 1),
    );
  }
}
