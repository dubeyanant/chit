import 'package:chit/core/clock.dart';
import 'package:chit/domain/models/composer_state.dart';
import 'package:chit/domain/models/recording_state.dart';
import 'package:chit/domain/services/audio_recorder.dart';
import 'package:chit/features/composer/application/composer_controller.dart';
import 'package:chit/features/composer/application/recording_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_audio_recorder.dart';
import '../../support/fake_clock.dart';

/// **The sheet's take, without a sheet** — BEHAVIOUR.md §3.4, ADR-031.
///
/// What is worth testing here is the choreography rather than any value: when
/// the recorder is started and stopped, what a refusal does, and where the
/// take ends up. None of it is visible on screen, and all of it is wrong in
/// ways that look fine.
void main() {
  late FakeClock clock;
  late FakeAudioRecorder recorder;

  /// When the microphone is tapped.
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

    // **Nothing listens to `recordingControllerProvider` here, on purpose.**
    // A listener used to be added for symmetry with the composer, and it hid
    // ADR-057's bug for a whole milestone: auto-disposed and unwatched, the
    // controller was thrown away during `start`'s permission round-trip, so on
    // a handset the microphone opened and no sheet ever appeared. The app has
    // no listener at that moment either — the sheet is built afterwards — so
    // neither does this.
    //
    // The composer's listener stays: it really is auto-disposed, and a widget
    // really does hold it open.
    container.listen(composerControllerProvider, (ComposerState? _, _) {});
    return container;
  }

  RecordingController sheetOf(ProviderContainer c) =>
      c.read(recordingControllerProvider.notifier);

  /// Lets the level stream deliver what was put on it.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('the microphone is tapped', () {
    test('the take survives the permission round-trip — ADR-057', () async {
      // **The bug this whole file missed.** Between the tap and the sheet
      // being built, nothing in the app watches this controller, and an
      // auto-disposed provider does not survive an await with no listeners.
      // On a handset that read as a microphone that opened and a sheet that
      // never came. Asserting `started` is not enough on its own — what makes
      // this a guard is that the container above has no listener on it.
      final ProviderContainer container = containerOf();

      final bool started = await sheetOf(container).start();

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
  });

  group('Stop & keep', () {
    test('hands the take to the open chit', () async {
      final ProviderContainer container = containerOf();
      await sheetOf(container).start();

      await sheetOf(container).stopAndKeep();

      final ComposerState chit = container.read(composerControllerProvider);
      expect(chit.audioTempPath, 'take-1.m4a');
      expect(chit.audioDuration, const Duration(seconds: 12));
      expect(chit.isRecording, isFalse);
    });

    test('leaves the field alone — a take is not words', () async {
      // §3.4: a chit can hold words, a recording, or both, and keeping a take
      // is not an edit to what was written.
      final ProviderContainer container = containerOf();
      container
          .read(composerControllerProvider.notifier)
          .edit('Train 20 late.');

      await sheetOf(container).start();
      await sheetOf(container).stopAndKeep();

      final ComposerState chit = container.read(composerControllerProvider);
      expect(chit.text, 'Train 20 late.');
      expect(chit.hasAudio, isTrue);
    });

    test('a take that wrote nothing keeps nothing', () async {
      final ProviderContainer container = containerOf();
      recorder.take = null;
      await sheetOf(container).start();

      await sheetOf(container).stopAndKeep();

      final ComposerState chit = container.read(composerControllerProvider);
      expect(chit.hasAudio, isFalse);
      expect(chit.isRecording, isFalse, reason: 'the sheet still closes');
    });

    test('leaves the sheet back where it started', () async {
      final ProviderContainer container = containerOf();
      await sheetOf(container).start();
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
      await sheetOf(container).start();

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
        // The disposal path: no cancel, no Stop & keep, the provider simply
        // gone. Nothing in the app should do this, and a live microphone is
        // what it costs when something does.
        final ProviderContainer container = ProviderContainer(
          overrides: [
            clockProvider.overrideWithValue(clock),
            audioRecorderProvider.overrideWithValue(recorder),
          ],
        );
        container.listen(composerControllerProvider, (ComposerState? _, _) {});

        await container.read(recordingControllerProvider.notifier).start();
        expect(recorder.running, isTrue);

        container.dispose();
        await settle();

        expect(recorder.running, isFalse);
        expect(recorder.cancels, 1);
      },
    );
  });
}
