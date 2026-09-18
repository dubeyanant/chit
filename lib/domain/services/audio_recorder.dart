import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_recorder.g.dart';

@immutable
final class Recording {
  Recording({required this.tempPath, required this.duration})
    : assert(tempPath.isNotEmpty, 'a recording is somewhere'),
      assert(duration > Duration.zero, 'a recording of no length is nothing');

  final String tempPath;

  final Duration duration;

  @override
  bool operator ==(Object other) =>
      other is Recording &&
      other.tempPath == tempPath &&
      other.duration == duration;

  @override
  int get hashCode => Object.hash(tempPath, duration);

  @override
  String toString() => 'Recording($tempPath, $duration)';
}

abstract interface class AudioRecorder {
  Future<bool> requestPermission();

  Future<bool> start();

  Stream<double> get levels;

  Future<Recording?> stop();

  Future<void> cancel();
}

@Riverpod(keepAlive: true)
AudioRecorder audioRecorder(Ref ref) => throw UnimplementedError(
  'audioRecorderProvider is overridden at the root — see main.dart',
);
