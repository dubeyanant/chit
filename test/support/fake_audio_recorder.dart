import 'dart:async';

import 'package:chit/domain/services/audio_recorder.dart';

/// An [AudioRecorder] that can be told to refuse — CLAUDE.md §4.1's Liskov
/// rule.
///
/// **It refuses the way the real one refuses**, which is the only reason a
/// §3.5 test proves anything. `RecordAudioRecorder` never throws: a withheld
/// microphone, a platform that fell over and a take that wrote nothing are a
/// `false` or a `null`. So are they here, and there is no way to make this
/// throw — a fake that can fail in a way the real one cannot is a fake that
/// tests a path the app does not have.
final class FakeAudioRecorder implements AudioRecorder {
  /// What [requestPermission] answers. `false` is a withheld microphone.
  bool permitted = true;

  /// What [start] answers once permission is in hand. `false` is a platform
  /// that would not begin.
  bool canStart = true;

  /// The take [stop] hands back, or `null` for one that wrote nothing.
  Recording? take = Recording(
    tempPath: 'take-1.m4a',
    duration: const Duration(seconds: 12),
  );

  /// How many takes have been cancelled — the sheet's dismissal, and the only
  /// way the file goes away before Save.
  int cancels = 0;

  /// Whether a take is running, by this object's reckoning.
  bool running = false;

  final StreamController<double> _levels = StreamController<double>.broadcast();

  /// Reports [level] to whoever is drawing the waveform.
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

  /// Closes the level stream. Call it from a `tearDown`.
  Future<void> dispose() => _levels.close();
}
