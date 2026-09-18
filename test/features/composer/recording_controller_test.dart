import 'package:chit/core/clock.dart';
import 'package:chit/domain/models/composer_state.dart';
import 'package:chit/domain/models/recording_state.dart';
import 'package:chit/domain/services/audio_recorder.dart';
import 'package:chit/domain/services/speech_recognizer.dart';
import 'package:chit/features/composer/application/composer_controller.dart';
import 'package:chit/features/composer/application/recording_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_audio_recorder.dart';
import '../../support/fake_clock.dart';
import '../../support/fake_speech_recognizer.dart';

/// **The sheet's two services, without a sheet** — BEHAVIOUR.md §3.4, ADR-031.
///
/// What is worth testing here is the choreography rather than any value: the
/// order the two are started and stopped in, what happens when one fails and
/// the other does not, and where the words end up. None of it is visible on
/// screen, and all of it is wrong in ways that look fine.
void main() {
  late FakeClock clock;
  late FakeAudioRecorder recorder;
  late FakeSpeechRecognizer recognizer;

  /// When the microphone is tapped.
  final DateTime began = DateTime(2026, 9, 18, 21, 4);

  setUp(() {
    clock = FakeClock(began);
    recorder = FakeAudioRecorder();
    recognizer = FakeSpeechRecognizer();
  });

  tearDown(() => recorder.dispose());

  ProviderContainer containerOf() {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(clock),
        audioRecorderProvider.overrideWithValue(recorder),
        speechRecognizerProvider.overrideWithValue(recognizer),
      ],
    );
    addTearDown(container.dispose);

    // Holds both controllers open across an await, the way the screen does.
    container.listen(recordingControllerProvider, (RecordingState? _, _) {});
    container.listen(composerControllerProvider, (ComposerState? _, _) {});
    return container;
  }

  RecordingController sheetOf(ProviderContainer c) =>
      c.read(recordingControllerProvider.notifier);

  /// Lets the streams deliver what was put on them.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('the microphone is tapped', () {
    test('a granted microphone starts both services', () async {
      final ProviderContainer container = containerOf();

      expect(await sheetOf(container).start(), isTrue);
      expect(recorder.running, isTrue);
      expect(
        container.read(composerControllerProvider).isRecording,
        isTrue,
        reason: 'the sheet is up',
      );
    });

    test('a refused microphone opens nothing and says so once', () async {
      final ProviderContainer container = containerOf();
      recorder.permitted = false;

      expect(await sheetOf(container).start(), isFalse);
      expect(recorder.running, isFalse);

      final ComposerState chit = container.read(composerControllerProvider);
      expect(chit.microphoneRefused, isTrue);
      expect(chit.isRecording, isFalse, reason: 'the sheet does not open');
    });

    test('a platform that will not begin is the same refusal', () async {
      // TASKS.md D2 and ARCHITECTURE.md §6: a `false` from either half is one
      // event from the sheet's side, and the recorder already refuses to tell
      // them apart.
      final ProviderContainer container = containerOf();
      recorder.canStart = false;

      expect(await sheetOf(container).start(), isFalse);
      expect(
        container.read(composerControllerProvider).microphoneRefused,
        isTrue,
      );
    });
  });

  group('while the take runs', () {
    test('the elapsed figure comes off the clock, not off a counter', () async {
      final ProviderContainer container = containerOf();
      await sheetOf(container).start();

      clock.moveTo(began.add(const Duration(seconds: 47)));
      await Future<void>.delayed(RecordingController.tick * 2);

      expect(
        container.read(recordingControllerProvider).elapsed,
        const Duration(seconds: 47),
      );
    });

    test('the levels reach the state as the recorder reports them', () async {
      final ProviderContainer container = containerOf();
      await sheetOf(container).start();

      recorder.emitLevel(0.62);
      recorder.emitLevel(0.31);
      await settle();

      expect(container.read(recordingControllerProvider).levels, <double>[
        0.62,
        0.31,
      ]);
    });

    test('the wave keeps only its window, newest last', () async {
      // The bar at the right is the sound a moment ago; the one that falls off
      // the left is 1.6 seconds old and nobody is looking at it.
      final ProviderContainer container = containerOf();
      await sheetOf(container).start();

      const int window = RecordingController.levelWindow;
      for (int i = 0; i <= window; i++) {
        recorder.emitLevel(i / window);
      }
      await settle();

      final List<double> kept = container
          .read(recordingControllerProvider)
          .levels;
      expect(kept, hasLength(window));
      expect(kept.first, 1 / window, reason: 'the oldest reading dropped off');
      expect(kept.last, 1);
    });

    test('the transcript accrues with its pending word', () async {
      final ProviderContainer container = containerOf();
      await sheetOf(container).start();

      recognizer.hear(committed: 'missed the last', pending: 'train');
      await settle();

      final Transcript heard = container
          .read(recordingControllerProvider)
          .transcript;
      expect(heard.committed, 'missed the last');
      expect(heard.pending, 'train');
      expect(heard.words, 'missed the last train');
    });

    test('a recogniser that never starts is noted and nothing else', () async {
      final ProviderContainer container = containerOf();
      recognizer.canHear = false;

      expect(await sheetOf(container).start(), isTrue);
      await settle();

      final RecordingState sheet = container.read(recordingControllerProvider);
      expect(sheet.recognitionGaveUp, isTrue);
      expect(
        recorder.running,
        isTrue,
        reason: 'the take goes on — §3.5 keeps the audio',
      );
    });
  });

  group('Stop & keep', () {
    test('hands the take and the words to the open chit', () async {
      final ProviderContainer container = containerOf();
      await sheetOf(container).start();

      recognizer.heard('missed the last train');
      await settle();
      await sheetOf(container).stopAndKeep();

      final ComposerState chit = container.read(composerControllerProvider);
      expect(chit.text, 'missed the last train');
      expect(chit.audioTempPath, 'take-1.m4a');
      expect(chit.audioDuration, const Duration(seconds: 12));
      expect(chit.isRecording, isFalse);
      expect(recognizer.stops, 1);
    });

    test('keeps a word that was still being revised', () async {
      // Stop & keep can land mid-revision, and a word being revised is still
      // a word that was said.
      final ProviderContainer container = containerOf();
      await sheetOf(container).start();

      recognizer.hear(committed: 'missed the last', pending: 'train');
      await settle();
      await sheetOf(container).stopAndKeep();

      expect(
        container.read(composerControllerProvider).text,
        'missed the last train',
      );
    });

    test('does not wait on a recogniser that already gave up', () async {
      final ProviderContainer container = containerOf();
      recognizer.canHear = false;
      await sheetOf(container).start();
      await settle();

      await sheetOf(container).stopAndKeep();

      expect(recognizer.stops, 0, reason: 'there was nothing left to stop');
      expect(
        container.read(composerControllerProvider).sttFailed,
        isTrue,
        reason: 'the audio is kept and the field is empty — §3.5',
      );
    });

    test('leaves the sheet back where it started', () async {
      final ProviderContainer container = containerOf();
      await sheetOf(container).start();
      recognizer.heard('one');
      recorder.emitLevel(0.9);
      await settle();

      await sheetOf(container).stopAndKeep();

      expect(
        container.read(recordingControllerProvider),
        const RecordingState(),
      );
    });

    test('a second press does nothing at all', () async {
      final ProviderContainer container = containerOf();
      await sheetOf(container).start();
      recognizer.heard('one');
      await settle();

      await sheetOf(container).stopAndKeep();
      await sheetOf(container).stopAndKeep();

      expect(container.read(composerControllerProvider).text, 'one');
    });
  });

  group('the sheet is dismissed', () {
    test('cancel keeps nothing and deletes the take', () async {
      final ProviderContainer container = containerOf();
      await sheetOf(container).start();
      recognizer.heard('never mind');
      await settle();

      await sheetOf(container).cancel();

      final ComposerState chit = container.read(composerControllerProvider);
      expect(chit.text, isEmpty);
      expect(chit.audioTempPath, isNull);
      expect(chit.isRecording, isFalse);
      expect(recorder.cancels, 1);
      expect(recognizer.stops, 1);
    });

    test(
      'a sheet that vanished without cancelling still closes the mic',
      () async {
        // The disposal path: no cancel, no Stop & keep, the provider simply
        // gone. Nothing in the app should do this, and a live microphone is
        // what it costs when something does.
        final ProviderContainer container = ProviderContainer(
          overrides: [
            clockProvider.overrideWithValue(clock),
            audioRecorderProvider.overrideWithValue(recorder),
            speechRecognizerProvider.overrideWithValue(recognizer),
          ],
        );
        container.listen(composerControllerProvider, (ComposerState? _, _) {});

        await container.read(recordingControllerProvider.notifier).start();
        expect(recorder.running, isTrue);

        container.dispose();
        await settle();

        expect(recorder.running, isFalse);
        expect(recorder.cancels, 1);
        expect(recognizer.stops, 1);
      },
    );
  });
}
