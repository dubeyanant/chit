import 'dart:async';

import 'package:chitt/domain/services/audio_recorder.dart';

final class FakeAudioRecorder implements AudioRecorder {
  bool permitted = true;

  bool canStart = true;

  Recording? take = Recording(
    tempPath: 'take-1.m4a',
    duration: const Duration(seconds: 12),
  );

  int cancels = 0;

  bool running = false;

  final StreamController<double> _levels = StreamController<double>.broadcast();

  void emitLevel(double level) => _levels.add(level);

  @override
  Future<bool> requestPermission() async => permitted;

  @override
  Future<bool> start() async {
    if (!permitted || !canStart) return false;
    running = true;
    return true;
  }

  @override
  Stream<double> get levels => _levels.stream;

  @override
  Future<Recording?> stop() async {
    if (!running) return null;
    running = false;
    return take;
  }

  @override
  Future<void> cancel() async {
    running = false;
    cancels++;
  }

  Future<void> dispose() => _levels.close();
}
