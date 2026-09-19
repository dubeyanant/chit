import 'package:chitt/core/clock.dart';
import 'package:chitt/domain/models/composer_state.dart';
import 'package:chitt/domain/models/recording_state.dart';
import 'package:chitt/domain/services/audio_recorder.dart';
import 'package:chitt/features/composer/application/composer_controller.dart';
import 'package:chitt/features/composer/application/recording_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_audio_recorder.dart';
import '../../support/fake_clock.dart';

void main() {
  late FakeClock clock;
  late FakeAudioRecorder recorder;

  final DateTime began = DateTime(2026, 9, 18, 21, 4);

  setUp(() {
    clock = FakeClock(began);
    recorder = FakeAudioRecorder();
  });

  tearDown(() => recorder.dispose());

  ProviderContainer containerOf() {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(clock),
        audioRecorderProvider.overrideWithValue(recorder),
      ],
    );
    addTearDown(container.dispose);

    container.listen(composerControllerProvider, (ComposerState? _, _) {});
    return container;
  }

  RecordingController sheetOf(ProviderContainer c) =>
      c.read(recordingControllerProvider.notifier);

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('the microphone is tapped', () {
    test('the take survives the permission round-trip — ADR-057', () async {
      final ProviderContainer container = containerOf();

      final bool started = await sheetOf(container)
          .start(into: container.read(composerControllerProvider.notifier));

      expect(started, isTrue);
      expect(recorder.running, isTrue, reason: 'and it was not cancelled');
      expect(
        recorder.cancels,
        0,
        reason: 'a disposal mid-start cancels the take it just began',
      );
    });

    test('a granted microphone opens the sheet', () async {
      final ProviderContainer container = containerOf();

      expect(
        await sheetOf(container)
            .start(into: container.read(composerControllerProvider.notifier)),
        isTrue,
      );
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

      expect(
        await sheetOf(container)
            .start(into: container.read(composerControllerProvider.notifier)),
        isFalse,
      );
      expect(recorder.running, isFalse);

      final ComposerState chit = container.read(composerControllerProvider);
      expect(chit.microphoneRefused, isTrue);
      expect(chit.isRecording, isFalse, reason: 'the sheet does not open');
    });

    test('a platform that will not begin is the same refusal', () async {
      final ProviderContainer container = containerOf();
      recorder.canStart = false;

      expect(
        await sheetOf(container)
            .start(into: container.read(composerControllerProvider.notifier)),
        isFalse,
      );
      expect(
        container.read(composerControllerProvider).microphoneRefused,
        isTrue,
      );
    });
  });

  group('while the take runs', () {
    test('the elapsed figure comes off the clock, not off a counter', () async {
      final ProviderContainer container = containerOf();
      await sheetOf(container)
          .start(into: container.read(composerControllerProvider.notifier));

      clock.moveTo(began.add(const Duration(seconds: 47)));
      await Future<void>.delayed(RecordingController.tick * 2);

      expect(
        container.read(recordingControllerProvider).elapsed,
        const Duration(seconds: 47),
      );
    });

    test('the levels reach the state as the recorder reports them', () async {
      final ProviderContainer container = containerOf();
      await sheetOf(container)
          .start(into: container.read(composerControllerProvider.notifier));

      recorder.emitLevel(0.62);
      recorder.emitLevel(0.31);
      await settle();

      expect(container.read(recordingControllerProvider).levels, <double>[
        0.62,
        0.31,
      ]);
    });

    test('the wave keeps only its window, newest last', () async {
      final ProviderContainer container = containerOf();
      await sheetOf(container)
          .start(into: container.read(composerControllerProvider.notifier));

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
  });

  group('Stop & keep', () {
    test('hands the take to the open chit', () async {
      final ProviderContainer container = containerOf();
      await sheetOf(container)
          .start(into: container.read(composerControllerProvider.notifier));

      await sheetOf(container).stopAndKeep();

      final ComposerState chit = container.read(composerControllerProvider);
      expect(chit.audioTempPath, 'take-1.m4a');
      expect(chit.audioDuration, const Duration(seconds: 12));
      expect(chit.isRecording, isFalse);
    });

    test('leaves the field alone — a take is not words', () async {
      final ProviderContainer container = containerOf();
      container
          .read(composerControllerProvider.notifier)
          .edit('Train 20 late.');

      await sheetOf(container)
          .start(into: container.read(composerControllerProvider.notifier));
      await sheetOf(container).stopAndKeep();

      final ComposerState chit = container.read(composerControllerProvider);
      expect(chit.text, 'Train 20 late.');
      expect(chit.hasAudio, isTrue);
    });

    test('a take that wrote nothing keeps nothing', () async {
      final ProviderContainer container = containerOf();
      recorder.take = null;
      await sheetOf(container)
          .start(into: container.read(composerControllerProvider.notifier));

      await sheetOf(container).stopAndKeep();

      final ComposerState chit = container.read(composerControllerProvider);
      expect(chit.hasAudio, isFalse);
      expect(chit.isRecording, isFalse, reason: 'the sheet still closes');
    });

    test('leaves the sheet back where it started', () async {
      final ProviderContainer container = containerOf();
      await sheetOf(container)
          .start(into: container.read(composerControllerProvider.notifier));
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
      await sheetOf(container)
          .start(into: container.read(composerControllerProvider.notifier));

      await sheetOf(container).stopAndKeep();
      await sheetOf(container).stopAndKeep();

      expect(
        container.read(composerControllerProvider).audioTempPath,
        'take-1.m4a',
      );
    });
  });

  group('the sheet is dismissed', () {
    test('cancel keeps nothing and deletes the take', () async {
      final ProviderContainer container = containerOf();
      await sheetOf(container)
          .start(into: container.read(composerControllerProvider.notifier));

      await sheetOf(container).cancel();

      final ComposerState chit = container.read(composerControllerProvider);
      expect(chit.text, isEmpty);
      expect(chit.audioTempPath, isNull);
      expect(chit.isRecording, isFalse);
      expect(recorder.cancels, 1);
    });

    test(
      'a sheet that vanished without cancelling still closes the mic',
      () async {
        final ProviderContainer container = ProviderContainer(
          overrides: [
            clockProvider.overrideWithValue(clock),
            audioRecorderProvider.overrideWithValue(recorder),
          ],
        );
        container.listen(composerControllerProvider, (ComposerState? _, _) {});

        await container
            .read(recordingControllerProvider.notifier)
            .start(into: container.read(composerControllerProvider.notifier));
        expect(recorder.running, isTrue);

        container.dispose();
        await settle();

        expect(recorder.running, isFalse);
        expect(recorder.cancels, 1);
      },
    );
  });
}
