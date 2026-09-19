import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart' as plugin;

import '../../core/clock.dart';
import '../../domain/services/audio_recorder.dart';

final class RecordAudioRecorder implements AudioRecorder {
  RecordAudioRecorder({required this._temp, required this._clock});

  factory RecordAudioRecorder.appCache({required Clock clock}) =>
      RecordAudioRecorder(temp: getTemporaryDirectory(), clock: clock);

  static const Duration levelInterval = Duration(milliseconds: 80);

  static const double silenceDbfs = -60;

  static const plugin.RecordConfig _config = plugin.RecordConfig(
    numChannels: 1,
    bitRate: 64000,
  );

  final Future<Directory> _temp;
  final Clock _clock;
  final plugin.AudioRecorder _recorder = plugin.AudioRecorder();

  DateTime? _startedAt;

  @override
  Future<bool> requestPermission() async {
    try {
      return await _recorder.hasPermission();
    } on Object {
      return false;
    }
  }

  @override
  Future<bool> start() async {
    assert(_startedAt == null, 'one take at a time — BEHAVIOUR.md §3.2');

    try {
      if (!await _recorder.hasPermission(request: false)) return false;

      final Directory temp = await _temp;
      await _recorder.start(_config, path: tempPathFor(temp, _clock.now()));
      _startedAt = _clock.now();
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
      await _recorder.cancel();
    } on Object {}
  }

  static String tempPathFor(Directory temp, DateTime startedAt) =>
      p.join(temp.path, 'take-${startedAt.microsecondsSinceEpoch}.m4a');

  static double levelOf(double dbfs) {
    if (!dbfs.isFinite) return 0;
    return ((dbfs - silenceDbfs) / -silenceDbfs).clamp(0, 1).toDouble();
  }
}
