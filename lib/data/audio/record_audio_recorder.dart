import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart' as plugin;

import '../../core/clock.dart';
import '../../domain/services/audio_recorder.dart';

/// [AudioRecorder] over `record` — ADR-008, ADR-052.
///
/// **Nothing here decides anything.** It asks the plugin, translates the
/// answer, and hands a file and a length on. Whether a take is kept is the
/// sheet's business; where the file goes after Save is `AudioStore`'s.
///
/// **It never throws.** Every method answers the way a refusal answers —
/// `false`, or `null` — because a plugin that fell over and a microphone the
/// user withheld are the same event from the sheet's side.
///
/// The temp directory arrives as a [Future] rather than a [Directory] for the
/// reason `AudioStore`'s does: constructing this costs nothing and startup
/// stays synchronous. Tests hand it a temporary directory.
final class RecordAudioRecorder implements AudioRecorder {
  /// A recorder writing under [_temp], timing takes on [_clock].
  RecordAudioRecorder({required this._temp, required this._clock});

  /// The recorder as it runs on a handset.
  factory RecordAudioRecorder.appCache({required Clock clock}) =>
      RecordAudioRecorder(temp: getTemporaryDirectory(), clock: clock);

  /// How often [levels] reports. **A sampling period, not a pace** — it is a
  /// property of the recorder, the way the record dot's 1.2s is the dot's
  /// (ADR-027), and it does not change under reduced motion: the waveform
  /// stops moving there by not being drawn from it, not by starving it.
  static const Duration levelInterval = Duration(milliseconds: 80);

  /// The quietest level that draws as anything. Below this a reading is
  /// silence, and the waveform draws its floor.
  static const double silenceDbfs = -60;

  /// Voice, mono, AAC in an `.m4a` — the extension `AudioStore` expects, and
  /// the one container both platforms encode and `just_audio` plays without a
  /// transcode. Mono at 64 kbps is speech-sized; a stereo music profile would
  /// double every file for nothing a voice carries.
  static const plugin.RecordConfig _config = plugin.RecordConfig(
    numChannels: 1,
    bitRate: 64000,
  );

  final Future<Directory> _temp;
  final Clock _clock;
  final plugin.AudioRecorder _recorder = plugin.AudioRecorder();

  /// When the running take began, or `null` between takes.
  DateTime? _startedAt;

  @override
  Future<bool> requestPermission() async {
    try {
      return await _recorder.hasPermission();
    } on Object {
      // A platform channel that fell over. Indistinguishable from a refusal
      // to everything downstream, and treated as one.
      return false;
    }
  }

  @override
  Future<bool> start() async {
    assert(_startedAt == null, 'one take at a time — BEHAVIOUR.md §3.2');

    try {
      // **Never raises a dialog.** [requestPermission] is the only thing that
      // asks; a take started without permission is simply refused.
      if (!await _recorder.hasPermission(request: false)) return false;

      final DateTime now = _clock.now();
      await _recorder.start(_config, path: tempPathFor(await _temp, now));
      _startedAt = now;
      return true;
    } on Object {
      return false;
    }
  }

  @override
  Stream<double> get levels => _recorder
      .onAmplitudeChanged(levelInterval)
      .map((plugin.Amplitude a) => levelOf(a.current));

  @override
  Future<Recording?> stop() async {
    final DateTime? startedAt = _startedAt;
    _startedAt = null;
    if (startedAt == null) return null;

    try {
      final String? path = await _recorder.stop();
      final Duration duration = _clock.now().difference(startedAt);

      // The plugin answers a path for a take it could not finish, and a file
      // it never wrote. Either is nothing kept, not an error.
      if (path == null || !File(path).existsSync()) return null;
      if (duration <= Duration.zero) return null;

      return Recording(tempPath: path, duration: duration);
    } on Object {
      return null;
    }
  }

  @override
  Future<void> cancel() async {
    _startedAt = null;
    try {
      // The plugin's cancel stops and deletes the file in one call.
      await _recorder.cancel();
    } on Object {
      // Nothing to keep and nothing to tell: the file, if any, is in the
      // cache, and the OS sweeps that.
    }
  }

  /// Where a take begun at [startedAt] is written.
  ///
  /// The name is the clock's, so two takes cannot collide and no id is spent
  /// on a file that may never be kept. The extension is the one
  /// `AudioStore` keeps.
  static String tempPathFor(Directory temp, DateTime startedAt) =>
      p.join(temp.path, 'take-${startedAt.microsecondsSinceEpoch}.m4a');

  /// A dBFS reading as the 0-to-1 level the waveform draws.
  ///
  /// Full scale is 0 dBFS and everything at or below [silenceDbfs] is the
  /// floor; the plugin reports silence as `-160` on some platforms and as
  /// `-infinity` on others, and both are the floor. Linear in decibels —
  /// which is to say logarithmic in pressure — because that is the scale a
  /// voice reads as even on.
  static double levelOf(double dbfs) {
    if (!dbfs.isFinite) return 0;
    return ((dbfs - silenceDbfs) / -silenceDbfs).clamp(0, 1).toDouble();
  }
}
