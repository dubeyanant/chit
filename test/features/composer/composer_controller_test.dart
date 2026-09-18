import 'dart:async';
import 'dart:io';

import 'package:chitta/core/clock.dart';
import 'package:chitta/data/audio/audio_store.dart';
import 'package:chitta/data/db/app_database.dart';
import 'package:chitta/data/repositories/chit_repository_impl.dart';
import 'package:chitta/domain/models/ambient_stamp.dart';
import 'package:chitta/domain/models/chit.dart';
import 'package:chitta/domain/models/composer_state.dart';
import 'package:chitta/domain/models/motion_state.dart';
import 'package:chitta/domain/models/weather_condition.dart';
import 'package:chitta/domain/repositories/chit_repository.dart';
import 'package:chitta/domain/services/ambient_signals.dart';
import 'package:chitta/domain/services/audio_player.dart';
import 'package:chitta/domain/services/audio_recorder.dart';
import 'package:chitta/domain/services/location_service.dart';
import 'package:chitta/domain/services/weather_service.dart';
import 'package:chitta/features/composer/application/composer_controller.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../support/fake_audio_player.dart';
import '../../support/fake_clock.dart';

void main() {
  late Directory root;
  late AppDatabase db;
  late FakeClock clock;
  late ChitRepository repo;
  late _Location location;
  late FakeAudioPlayer player;

  final DateTime opened = DateTime(2026, 9, 15, 9, 30);

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

    container.listen(composerControllerProvider, (ComposerState? _, _) {});

    return container;
  }

  Future<Chit> onlyChit() async {
    final List<Chit> chits = await repo
        .watchDay(Chit.localDayOf(savedAt))
        .first;
    expect(chits, hasLength(1));
    return chits.single;
  }

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

      clock.moveTo(savedAt);
      await saveAndSettle(container);

      expect(location.fixes, 1);
      expect((await onlyChit()).motion, MotionState.traveling);
    });

    test('a fresh save leaves the row exactly as it was written', () async {
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

  group('Remove takes the recording with it — ADR-008, ADR-060', () {
    Future<(ComposerController, File)> keptTake(
      ProviderContainer container,
    ) async {
      final ComposerController composer = container.read(
        composerControllerProvider.notifier,
      );
      final File take = File(p.join(root.path, 'take-1.m4a'));
      await take.writeAsString('audio');

      composer.keepRecording(
        Recording(tempPath: take.path, duration: const Duration(seconds: 9)),
      );
      return (composer, take);
    }

    test('the temp file is deleted and the take is gone', () async {
      final ProviderContainer container = containerOf();
      final (ComposerController composer, File take) = await keptTake(
        container,
      );

      await composer.removeTake();

      expect(take.existsSync(), isFalse);
      final ComposerState after = container.read(composerControllerProvider);
      expect(after.audioTempPath, isNull);
      expect(after.audioDuration, isNull);
      expect(after.hasAudio, isFalse, reason: 'the microphone comes back');

      expect(after.canSave, isFalse);
    });

    test('the words are left exactly as they were', () async {
      final ProviderContainer container = containerOf();
      final (ComposerController composer, _) = await keptTake(container);

      composer.edit('Both, and then only one.');
      await composer.removeTake();

      final ComposerState after = container.read(composerControllerProvider);
      expect(after.text, 'Both, and then only one.');
      expect(after.canSave, isTrue, reason: 'the words can still be saved');
    });

    test('the stamp does not move, because this is not a new chit', () async {
      final ProviderContainer container = containerOf();
      final (ComposerController composer, _) = await keptTake(container);
      final AmbientStamp before = container
          .read(composerControllerProvider)
          .stamp;

      clock.moveTo(savedAt);
      await composer.removeTake();

      expect(container.read(composerControllerProvider).stamp, before);
    });

    test('removing nothing does nothing', () async {
      final ProviderContainer container = containerOf();
      final ComposerController composer = container.read(
        composerControllerProvider.notifier,
      );

      composer.edit('words alone');
      await composer.removeTake();

      expect(container.read(composerControllerProvider).text, 'words alone');
    });

    test('a refused microphone is forgotten once one is allowed', () {
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
        reason: 'it is said once and stays said',
      );

      composer.recordingStarted();
      expect(
        container.read(composerControllerProvider).microphoneRefused,
        isFalse,
        reason: 'getting as far as the sheet means it was allowed',
      );
    });
  });

  group('a take stops sounding when it stops being the open chit\'s', () {
    Future<ComposerController> playingTake(ProviderContainer container) async {
      final ComposerController composer = container.read(
        composerControllerProvider.notifier,
      );
      final File take = File(p.join(root.path, 'take-1.m4a'));
      await take.writeAsString('audio');

      composer.keepRecording(
        Recording(tempPath: take.path, duration: const Duration(seconds: 9)),
      );
      await player.play(id: Playback.openChit, path: take.path);
      expect(player.now.playing, isTrue);
      return composer;
    }

    test('Save stops it, because the file is about to move', () async {
      final ProviderContainer container = containerOf();
      final ComposerController composer = await playingTake(container);

      clock.moveTo(savedAt);
      await composer.save();

      expect(player.now, Playback.silent);
    });

    test('Remove stops it, because the file is about to go', () async {
      final ProviderContainer container = containerOf();
      final ComposerController composer = await playingTake(container);

      await composer.removeTake();

      expect(player.now, Playback.silent);
    });

    test('a save leaves a chit playing in the thread alone', () async {
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
        Recording(tempPath: take.path, duration: const Duration(seconds: 9)),
      );

      clock.moveTo(savedAt);
      await composer.save();

      final Chit stored = await onlyChit();
      expect(stored.text, isNull);
      expect(stored.audioPath, isNotNull);
      expect(stored.audioDuration, const Duration(seconds: 9));
      expect(take.existsSync(), isFalse, reason: 'moved, not copied');
    });
  });
}

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

final class _HangingWeather implements WeatherService {
  @override
  Future<WeatherCondition?> currentCondition() =>
      Completer<WeatherCondition?>().future;
}

final class _FastWeather implements WeatherService {
  @override
  Future<WeatherCondition?> currentCondition() async =>
      WeatherCondition.raining;
}
