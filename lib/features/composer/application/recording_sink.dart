import '../../../domain/services/audio_recorder.dart';

abstract interface class RecordingSink {
  void microphoneWasRefused();

  void recordingStarted();

  void keepRecording(Recording? take);

  void recordingCancelled();
}
