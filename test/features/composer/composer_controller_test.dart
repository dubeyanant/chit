import 'dart:async';
import 'dart:io';

import 'package:chit/core/clock.dart';
import 'package:chit/data/audio/audio_store.dart';
import 'package:chit/data/db/app_database.dart';
import 'package:chit/data/repositories/chit_repository_impl.dart';
import 'package:chit/domain/models/chit.dart';
import 'package:chit/domain/models/composer_state.dart';
import 'package:chit/domain/models/motion_state.dart';
import 'package:chit/domain/models/weather_condition.dart';
import 'package:chit/domain/repositories/chit_repository.dart';
import 'package:chit/domain/services/ambient_signals.dart';
import 'package:chit/domain/services/audio_player.dart';
import 'package:chit/domain/services/audio_recorder.dart';
import 'package:chit/domain/services/location_service.dart';
import 'package:chit/domain/services/speech_recognizer.dart';
import 'package:chit/domain/services/weather_service.dart';
import 'package:chit/features/composer/application/composer_controller.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../support/fake_audio_player.dart';
import '../../support/fake_clock.dart';

/// **ADR-040 and ADR-042, through the controller that carries them.**
///
/// The claim under test is the reversal: *a chit is stamped when it is saved,
/// not when it was opened.* It is worth a test precisely because it fails
/// silently — a stamp taken at the wrong moment is still a perfectly plausible
/// time, and nothing but a clock that moves across the save can see it. That
/// is the same argument the old ADR-021 test made, pointing the other way.
void main() {
  late Directory root;
  late AppDatabase db;
  late FakeClock clock;
  late ChitRepository repo;
  late _Location location;
  late FakeAudioPlayer player;

  /// 9:30am — when the chit is opened.
  final DateTime opened = DateTime(2026, 9, 15, 9, 30);

  /// 9:52am — when the user finally presses Save.
  final DateTime savedAt = DateTime(2026, 9, 15, 9, 52);

  setUp(() async {
    root = await Directory.systemTemp.createTemp('chit-composer-test');
    final Directory documents = await Directory(p.join(root.path, 'documents'))
        .create();
    db = AppDatabase(NativeDatabase.memory());
    clock = FakeClock(opened);
    repo = ChitRepositoryImpl(
      dao: db.chitDao,
      audio: AudioStore(Future<Directory>.value(documents)),
      clock: clock,
    );
    location = _Location();
    player = FakeAudioPlayer();
  });

  tearDown(() async {
    await player.dispose();
    await db.close();
    if (root.existsSync()) await root.delete(recursive: true);
  });

  ProviderContainer containerOf([WeatherService? weather]) {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(clock),
        chitRepositoryProvider.overrideWithValue(repo),
        locationServiceProvider.overrideWithValue(location),
        weatherServiceProvider.overrideWithValue(weather ?? _FastWeather()),
        audioPlayerProvider.overrideWithValue(player),
      ],
    );
    addTearDown(container.dispose);

    // Holds the composer open across a save. In the app a widget does this;
    // without it the provider auto-disposes the moment `save` returns and the
    // next call reaches for a `Ref` that is gone — which is a fact about the
    // test harness rather than about the controller.
    container.listen(composerControllerProvider, (ComposerState? _, _) {});

    return container;
  }

  /// The one chit in the database, whatever it is.
  Future<Chit> onlyChit() async {
    final List<Chit> chits = await repo
        .watchDay(Chit.localDayOf(savedAt))
        .first;
    expect(chits, hasLength(1));
    return chits.single;
  }

  /// Waits for [done], a few milliseconds at a time.
  ///
  /// The patch of ADR-042 is deliberately not awaited by `save`, so there is
  /// nothing to hold on to — polling is the honest way to observe something
  /// the production code goes out of its way not to expose.
  Future<void> pumpUntil(Future<bool> Function() done) async {
    for (int i = 0; i < 100; i++) {
      if (await done()) return;
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    fail('the patch never landed');
  }

  group('ADR-040: the chit is stamped when it is saved', () {
    test('the row carries the save time, not the open time', () async {
      final ProviderContainer container = containerOf();
      final ComposerController composer = container.read(
        composerControllerProvider.notifier,
      );

      composer.edit('Train 20 late.');
      expect(
        container.read(composerControllerProvider).stamp.capturedAt,
        opened,
        reason: 'the slip shows when the chit opened — it is a preview',
      );

      clock.moveTo(savedAt);
      await composer.save();

      expect((await onlyChit()).createdAt, savedAt);
    });

    test(
      'a chit written across a midnight is filed on the day it was saved',
      () async {
        // The failure a whole second record used to exist to contain, now
        // impossible rather than merely handled: under ADR-021 a chit opened at
        // 23:58 and saved at 00:05 was filed on the previous day.
        final DateTime beforeMidnight = DateTime(2026, 9, 15, 23, 58);
        final DateTime afterMidnight = DateTime(2026, 9, 16, 0, 5);

        clock.moveTo(beforeMidnight);
        final ProviderContainer container = containerOf();
        final ComposerController composer = container.read(
          composerControllerProvider.notifier,
        );

        composer.edit('Still awake.');
        clock.moveTo(afterMidnight);
        await composer.save();

        final List<Chit> next = await repo
            .watchDay(Chit.localDayOf(afterMidnight))
            .first;

        expect(next, hasLength(1));
        expect(next.single.localDay, Chit.localDayOf(afterMidnight));
      },
    );

    test('saving opens a new chit, stamped at that moment', () async {
      final ProviderContainer container = containerOf();
      final ComposerController composer = container.read(
        composerControllerProvider.notifier,
      );

      composer.edit('Train 20 late.');
      clock.moveTo(savedAt);
      await composer.save();

      final ComposerState fresh = container.read(composerControllerProvider);
      expect(fresh.text, isEmpty);
      expect(fresh.canSave, isFalse);
      expect(fresh.stamp.capturedAt, savedAt);
    });
  });

  group('ADR-042: the row is written first and corrected after', () {
    test('saving does not wait on the capture', () async {
      // The whole reason the patch exists. The weather here never comes back,
      // so a save that awaited it would hang — and under the real 2s timeout
      // it would merely be slow, which is the version nobody notices until
      // they are on a train.
      final ProviderContainer container = containerOf(_HangingWeather());
      final ComposerController composer = container.read(
        composerControllerProvider.notifier,
      );

      composer.edit('Train 20 late.');
      clock.moveTo(savedAt);

      await expectLater(
        composer.save().timeout(const Duration(seconds: 1)),
        completes,
      );
      expect(await onlyChit(), isNotNull);
    });

    test('the fresh reading lands on the row a moment later', () async {
      final ProviderContainer container = containerOf(_FastWeather());
      final ComposerController composer = container.read(
        composerControllerProvider.notifier,
      );

      composer.edit('Train 20 late.');
      clock.moveTo(savedAt);
      await composer.save();

      // Nothing was ever primed in this container, so the insert went out with
      // an empty reading — which is exactly the state a save makes good.
      expect((await onlyChit()).motion, isNull);

      await pumpUntil(() async => (await onlyChit()).motion != null);

      final Chit patched = await onlyChit();
      expect(patched.motion, MotionState.traveling);
      expect(patched.weather, WeatherCondition.raining);
      expect(patched.createdAt, savedAt, reason: 'the patch never moves it');
      expect(
        patched.updatedAt,
        savedAt,
        reason: 'ADR-014: a late signal is not an edit',
      );
    });
  });

  group('ADR-045: a save inside the window asks for nothing', () {
    /// Saves a chit and gives whatever the save started time to finish.
    Future<void> saveAndSettle(ProviderContainer container) async {
      final ComposerController composer = container.read(
        composerControllerProvider.notifier,
      );
      composer.edit('Train 20 late.');
      await composer.save();
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }

    test(
      'a second save minutes later does not ask the services again',
      () async {
        // The whole point, and it is only checkable by counting. A fresh save
        // looks identical from the outside — same row, same word — and what it
        // avoids is a GPS fix and a network call per chit in a sitting.
        final ProviderContainer container = containerOf(_FastWeather());

        await container.read(ambientSignalsProvider.notifier).prime();
        expect(location.fixes, 1, reason: 'the launch capture');

        clock.moveTo(opened.add(const Duration(minutes: 1)));
        await saveAndSettle(container);
        clock.moveTo(opened.add(const Duration(minutes: 2)));
        await saveAndSettle(container);

        expect(
          location.fixes,
          1,
          reason: 'both saves were inside the window the launch capture opened',
        );
      },
    );

    test('a save outside the window asks, and patches the row', () async {
      final ProviderContainer container = containerOf(_FastWeather());

      // Nothing primed, so the reading is stale by definition — there has
      // never been one — and the row goes out empty.
      clock.moveTo(savedAt);
      await saveAndSettle(container);

      expect(location.fixes, 1);
      expect((await onlyChit()).motion, MotionState.traveling);
    });

    test('a fresh save leaves the row exactly as it was written', () async {
      // The row must not be re-written even though the world changed after it:
      // inside the window, what was written is what was true.
      final ProviderContainer container = containerOf(_FastWeather());

      await container.read(ambientSignalsProvider.notifier).prime();
      clock.moveTo(opened.add(const Duration(minutes: 1)));
      location.answer = null;

      await saveAndSettle(container);

      final Chit written = await onlyChit();
      expect(
        written.motion,
        MotionState.traveling,
        reason: 'the reading it was written from was fresh, so it stands',
      );
      expect(written.lat, isNotNull);
    });

    test('the window is measured from the reading, not from the save', () {
      expect(AmbientSignals.freshFor, const Duration(minutes: 5));

      expect(
        AmbientSignals.nothing.isFreshAt(savedAt),
        isFalse,
        reason: 'a reading that never arrived is not a recent one',
      );

      final AmbientReading justNow = (
        weather: null,
        lat: null,
        lon: null,
        motion: null,
        readAt: savedAt,
      );
      expect(justNow.isFreshAt(savedAt), isTrue);
      expect(
        justNow.isFreshAt(savedAt.add(AmbientSignals.freshFor)),
        isFalse,
        reason: 'the boundary belongs to stale — five minutes is the ceiling',
      );
      expect(
        justNow.isFreshAt(savedAt.subtract(const Duration(minutes: 1))),
        isFalse,
        reason: 'a clock that went backwards is not a fresh reading',
      );
    });
  });

  group('BEHAVIOUR.md §3.4: the transcript joins what is already there', () {
    /// A take of [words], twelve seconds long, written to [tempPath].
    ({Recording recording, Transcript transcript}) takeOf(
      String words, {
      String tempPath = 'take-1.m4a',
    }) => (
      recording: Recording(
        tempPath: tempPath,
        duration: const Duration(seconds: 12),
      ),
      transcript: Transcript(committed: words),
    );

    test('an empty field takes the words and the transcript origin', () {
      final ProviderContainer container = containerOf();
      final ComposerController composer = container.read(
        composerControllerProvider.notifier,
      );

      final ({Recording recording, Transcript transcript}) take = takeOf(
        'missed the last train',
      );
      composer.keepRecording(
        recording: take.recording,
        transcript: take.transcript,
      );

      final ComposerState chit = container.read(composerControllerProvider);
      expect(chit.text, 'missed the last train');
      expect(chit.textOrigin, TextOrigin.transcript);
      expect(chit.audioTempPath, 'take-1.m4a');
      expect(chit.audioDuration, const Duration(seconds: 12));
      expect(chit.sttFailed, isFalse);
    });

    test('a field with words in it keeps them, and the words are joined', () {
      final ProviderContainer container = containerOf();
      final ComposerController composer = container.read(
        composerControllerProvider.notifier,
      );

      composer.edit('Train 20 late.');
      final ({Recording recording, Transcript transcript}) take = takeOf(
        'still on the platform',
      );
      composer.keepRecording(
        recording: take.recording,
        transcript: take.transcript,
      );

      final ComposerState chit = container.read(composerControllerProvider);
      expect(chit.text, 'Train 20 late. still on the platform');
      expect(
        chit.textOrigin,
        TextOrigin.transcriptEdited,
        reason: 'part typed and part heard has had a hand in it',
      );
    });

    test('a field holding only spaces is an empty field', () {
      final ProviderContainer container = containerOf();
      final ComposerController composer = container.read(
        composerControllerProvider.notifier,
      );

      composer.edit('   ');
      final ({Recording recording, Transcript transcript}) take = takeOf(
        'nearly home',
      );
      composer.keepRecording(
        recording: take.recording,
        transcript: take.transcript,
      );

      final ComposerState chit = container.read(composerControllerProvider);
      expect(chit.text, 'nearly home');
      expect(chit.textOrigin, TextOrigin.transcript);
    });

    test('the origin slides once, on the first keystroke, and never back', () {
      final ProviderContainer container = containerOf();
      final ComposerController composer = container.read(
        composerControllerProvider.notifier,
      );

      final ({Recording recording, Transcript transcript}) take = takeOf(
        'missed the last train',
      );
      composer.keepRecording(
        recording: take.recording,
        transcript: take.transcript,
      );

      composer.edit('missed the last trainn');
      expect(
        container.read(composerControllerProvider).textOrigin,
        TextOrigin.transcriptEdited,
      );

      composer.edit('missed the last train');
      expect(
        container.read(composerControllerProvider).textOrigin,
        TextOrigin.transcriptEdited,
        reason: 'a one-way move — putting it back does not undo the hand',
      );
    });

    test('emptying the field clears the origin, and typing again is typed', () {
      final ProviderContainer container = containerOf();
      final ComposerController composer = container.read(
        composerControllerProvider.notifier,
      );

      final ({Recording recording, Transcript transcript}) take = takeOf(
        'missed the last train',
      );
      composer.keepRecording(
        recording: take.recording,
        transcript: take.transcript,
      );

      composer.edit('');
      expect(container.read(composerControllerProvider).textOrigin, isNull);

      composer.edit('walked instead');
      expect(
        container.read(composerControllerProvider).textOrigin,
        TextOrigin.typed,
        reason: 'nothing of the recogniser is left in the field',
      );
    });
  });

  group('BEHAVIOUR.md §3.5: the voice survives alone', () {
    test('no words and a recording keeps the audio and says so', () {
      final ProviderContainer container = containerOf();
      final ComposerController composer = container.read(
        composerControllerProvider.notifier,
      );

      composer.keepRecording(
        recording: Recording(
          tempPath: 'take-1.m4a',
          duration: const Duration(seconds: 9),
        ),
        transcript: Transcript.nothing,
      );

      final ComposerState chit = container.read(composerControllerProvider);
      expect(chit.sttFailed, isTrue);
      expect(chit.text, isEmpty, reason: 'nothing partial is ever written');
      expect(chit.textOrigin, isNull);
      expect(chit.audioTempPath, 'take-1.m4a');
      expect(chit.canSave, isTrue, reason: 'a recording is a chit');
    });

    test('the note takes the prompt place rather than sharing it', () async {
      final ProviderContainer container = containerOf();
      final ComposerController composer = container.read(
        composerControllerProvider.notifier,
      );

      composer.keepRecording(
        recording: Recording(
          tempPath: 'take-1.m4a',
          duration: const Duration(seconds: 9),
        ),
        transcript: Transcript.nothing,
      );

      // The five seconds would otherwise come round and put the prompt under
      // the note, which §3.5 gives that space to.
      composer.edit('a');
      composer.edit('');
      await Future<void>.delayed(ComposerController.idle * 1.2);

      expect(container.read(composerControllerProvider).showPrompt, isFalse);
    });

    test('words with no file keep the words rather than losing them', () {
      // The recorder and the recogniser fail apart. Dropping heard words
      // because the *other* plugin failed would be a silent content loss.
      final ProviderContainer container = containerOf();
      final ComposerController composer = container.read(
        composerControllerProvider.notifier,
      );

      composer.keepRecording(
        recording: null,
        transcript: const Transcript(committed: 'nearly home'),
      );

      final ComposerState chit = container.read(composerControllerProvider);
      expect(chit.text, 'nearly home');
      expect(chit.textOrigin, TextOrigin.transcript);
      expect(chit.audioTempPath, isNull);
      expect(
        chit.sttFailed,
        isFalse,
        reason: 'the note promises a recording was kept, and none was',
      );
    });

    test('neither a file nor words changes nothing', () {
      final ProviderContainer container = containerOf();
      final ComposerController composer = container.read(
        composerControllerProvider.notifier,
      );

      composer.edit('Train 20 late.');
      composer.keepRecording(recording: null, transcript: Transcript.nothing);

      final ComposerState chit = container.read(composerControllerProvider);
      expect(chit.text, 'Train 20 late.');
      expect(chit.sttFailed, isFalse);
      expect(chit.isRecording, isFalse);
    });
  });

  group('Discard takes the recording with it — ADR-008', () {
    test('the temp file is deleted and the state is clear', () async {
      final ProviderContainer container = containerOf();
      final ComposerController composer = container.read(
        composerControllerProvider.notifier,
      );

      final File take = File(p.join(root.path, 'take-1.m4a'));
      await take.writeAsString('audio');

      composer.keepRecording(
        recording: Recording(
          tempPath: take.path,
          duration: const Duration(seconds: 9),
        ),
        transcript: Transcript.nothing,
      );
      expect(container.read(composerControllerProvider).sttFailed, isTrue);

      await composer.discard();

      expect(take.existsSync(), isFalse);
      final ComposerState fresh = container.read(composerControllerProvider);
      expect(fresh.audioTempPath, isNull);
      expect(fresh.sttFailed, isFalse);
      expect(fresh.canSave, isFalse);
    });

    test('a refused microphone is forgotten by Discard, not by a save', () {
      final ProviderContainer container = containerOf();
      final ComposerController composer = container.read(
        composerControllerProvider.notifier,
      );

      composer.microphoneWasRefused();
      expect(
        container.read(composerControllerProvider).microphoneRefused,
        isTrue,
      );

      composer.edit('typed instead');
      expect(
        container.read(composerControllerProvider).microphoneRefused,
        isTrue,
        reason: 'it is said once and stays said until the page is cleared',
      );

      unawaited(composer.discard());
      expect(
        container.read(composerControllerProvider).microphoneRefused,
        isFalse,
      );
    });
  });

  group('a take stops sounding when it stops being the open chit\'s', () {
    /// A take on disk, kept on the open chit and playing.
    Future<ComposerController> playingTake(ProviderContainer container) async {
      final ComposerController composer = container.read(
        composerControllerProvider.notifier,
      );
      final File take = File(p.join(root.path, 'take-1.m4a'));
      await take.writeAsString('audio');

      composer.keepRecording(
        recording: Recording(
          tempPath: take.path,
          duration: const Duration(seconds: 9),
        ),
        transcript: const Transcript(committed: 'nearly home'),
      );
      await player.play(id: Playback.openChit, path: take.path);
      expect(player.now.playing, isTrue);
      return composer;
    }

    test('Save stops it, because the file is about to move', () async {
      // Seen on a handset: the take went on playing after Save, with the pill
      // that could have stopped it no longer drawn anywhere.
      final ProviderContainer container = containerOf();
      final ComposerController composer = await playingTake(container);

      clock.moveTo(savedAt);
      await composer.save();

      expect(player.now, Playback.silent);
    });

    test('Discard stops it, because the file is about to go', () async {
      final ProviderContainer container = containerOf();
      final ComposerController composer = await playingTake(container);

      await composer.discard();

      expect(player.now, Playback.silent);
    });

    test('a save leaves a chit playing in the thread alone', () async {
      // `stopIf` names the open chit, so somebody listening back to yesterday
      // while they write today is not interrupted.
      final ProviderContainer container = containerOf();
      final ComposerController composer = container.read(
        composerControllerProvider.notifier,
      );
      await player.play(id: 'seed-04', path: 'audio/seed-04.m4a');

      composer.edit('Train 20 late.');
      clock.moveTo(savedAt);
      await composer.save();

      expect(player.now.holds('seed-04'), isTrue);
      expect(player.now.playing, isTrue);
    });
  });

  group('a chit with a recording and no words is a chit — README §5', () {
    test('it saves, and comes back with its audio and no text', () async {
      final ProviderContainer container = containerOf();
      final ComposerController composer = container.read(
        composerControllerProvider.notifier,
      );

      final File take = File(p.join(root.path, 'take-1.m4a'));
      await take.writeAsString('audio');

      composer.keepRecording(
        recording: Recording(
          tempPath: take.path,
          duration: const Duration(seconds: 9),
        ),
        transcript: Transcript.nothing,
      );

      clock.moveTo(savedAt);
      await composer.save();

      final Chit stored = await onlyChit();
      expect(stored.text, isNull);
      expect(stored.textOrigin, isNull);
      expect(stored.audioPath, isNotNull);
      expect(stored.audioDuration, const Duration(seconds: 9));
      expect(take.existsSync(), isFalse, reason: 'moved, not copied');
    });
  });
}

/// Answers a fix straight away, and counts how often it was asked.
///
/// The count is what ADR-045 is checkable by: a save inside the freshness
/// window looks identical from the outside and differs only in what it did
/// *not* do.
final class _Location implements LocationService {
  GeoFix? answer = const GeoFix(lat: 1, lon: 2, speed: 20, speedAccuracy: 1);
  int fixes = 0;

  @override
  Future<GeoFix?> currentFix() async {
    fixes++;
    return answer;
  }

  @override
  Future<GeoFix?> lastKnownFix() async => answer;

  @override
  Future<LocationPermissionOutcome> requestPermission() async =>
      LocationPermissionOutcome.granted;
}

/// Never comes back, so a save that awaited the capture would hang.
final class _HangingWeather implements WeatherService {
  @override
  Future<WeatherCondition?> currentCondition() =>
      Completer<WeatherCondition?>().future;
}

/// Answers at once, so the patch is observable without waiting out a timeout.
final class _FastWeather implements WeatherService {
  @override
  Future<WeatherCondition?> currentCondition() async =>
      WeatherCondition.raining;
}
