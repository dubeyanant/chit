import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_recorder.g.dart';

/// A recording that has been stopped and is sitting in a temp file.
///
/// Both halves are required because a recording has a length (README §5,
/// `Chit`'s invariant) and a length without a file is nothing. It is what
/// `ComposerState.audioTempPath` and `audioDuration` are set from, together,
/// so they cannot be set apart.
@immutable
final class Recording {
  /// A recording at [tempPath] that ran for [duration].
  Recording({required this.tempPath, required this.duration})
    : assert(tempPath.isNotEmpty, 'a recording is somewhere'),
      assert(duration > Duration.zero, 'a recording of no length is nothing');

  /// Where the file is until Save moves it (ADR-008). Absolute.
  final String tempPath;

  /// How long it ran, start to stop — the audio pill's figure.
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

/// Records the microphone to a temp file — BEHAVIOUR.md §3.4, ADR-008.
///
/// One take at a time. The sheet asks for permission, starts, watches
/// [levels] for its waveform, and either [stop]s and keeps what came back or
/// [cancel]s. Nothing here knows about words — a recording is the record
/// (ADR-058).
///
/// **It never throws.** A refusal, a platform that fell over and a take that
/// wrote nothing all answer as a `false` or a `null`, because the sheet has
/// one thing to do with any of them: not open, or close with nothing kept.
/// A fake must refuse the same way — CLAUDE.md §4.1's Liskov rule.
abstract interface class AudioRecorder {
  /// Raises the system microphone dialog if the platform still needs to —
  /// BEHAVIOUR.md §4.4: asked the first time the microphone is tapped, never
  /// at first run. `true` once recording is allowed.
  Future<bool> requestPermission();

  /// Begins writing a new temp file. `true` when the platform is recording.
  ///
  /// `false` when permission is absent or the platform refused; the sheet
  /// does not open on a `false` (ARCHITECTURE.md §6). Calling it while a take
  /// is already running is a programming error, not a platform outcome.
  Future<bool> start();

  /// The input level while a take runs, **0 to 1** — silence to full scale.
  /// The waveform draws this and nothing else; the scale it came off is the
  /// implementation's business.
  Stream<double> get levels;

  /// Ends the take. The file and its length, or `null` when nothing was
  /// written — never started, or the platform produced no file.
  Future<Recording?> stop();

  /// Ends the take and deletes whatever was written. Nothing is returned
  /// because nothing is kept.
  Future<void> cancel();
}

/// The recorder the app runs on.
///
/// Unimplemented on purpose, for the reason `locationServiceProvider` is:
/// `domain` cannot import `data` (ARCHITECTURE.md §1), so `main.dart`
/// supplies `RecordAudioRecorder` and tests supply a fake.
@Riverpod(keepAlive: true)
AudioRecorder audioRecorder(Ref ref) => throw UnimplementedError(
  'audioRecorderProvider is overridden at the root — see main.dart',
);
