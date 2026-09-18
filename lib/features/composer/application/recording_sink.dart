import '../../../domain/services/audio_recorder.dart';

/// Where a take goes when the sheet is done with it — **ADR-065**.
///
/// The recording sheet and `RecordingController` are one piece of machinery
/// and two screens use it: the open chit attaches a kept take, the editor
/// stages one as a replacement. **A take has one owner, chosen at the tap** —
/// `RecordingController.start` takes the sink and holds it for the take's
/// life, so keep and cancel cannot land on a screen that did not ask.
///
/// The four calls are the four things a sheet can tell the screen under it.
/// Nothing here returns anything: the sheet does not wait on its owner.
abstract interface class RecordingSink {
  /// Permission was withheld, or the platform refused to start. The sheet
  /// does not open; the owner says so in its own way (TASKS.md D2, ADR-056).
  void microphoneWasRefused();

  /// The sheet is up and the microphone is live.
  void recordingStarted();

  /// **Stop & keep.** [take] is `null` when the platform produced no file,
  /// which the owner treats as nothing kept.
  void keepRecording(Recording? take);

  /// The sheet was dismissed without keeping anything.
  void recordingCancelled();
}
