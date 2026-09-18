import 'dart:io';

import 'package:chit/core/clock.dart';
import 'package:chit/data/audio/audio_store.dart';
import 'package:chit/data/db/app_database.dart';
import 'package:chit/data/repositories/chit_repository_impl.dart';
import 'package:chit/domain/models/ambient_stamp.dart';
import 'package:chit/domain/models/chit.dart';
import 'package:chit/domain/repositories/chit_repository.dart';
import 'package:chit/features/today/application/timeline_provider.dart';
import 'package:chit/features/today/application/today_controller.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';

typedef Chits = AsyncValue<List<Chit>>;

void main() {
  late Directory root;
  late AppDatabase db;
  late FakeClock clock;
  late ChitRepository repo;
  late ProviderContainer container;

  final DateTime afternoon = DateTime(2026, 9, 16, 15, 42);

  setUp(() async {
    root = await Directory.systemTemp.createTemp('chit-timeline-test');
    db = AppDatabase(NativeDatabase.memory());
    clock = FakeClock(afternoon);
    repo = ChitRepositoryImpl(
      dao: db.chitDao,
      audio: AudioStore(Future<Directory>.value(root)),
      clock: clock,
    );

    container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(clock),
        chitRepositoryProvider.overrideWithValue(repo),
      ],
    );

    container.listen<Chits>(
      timelineChitsProvider,
      (Chits? _, Chits _) {},
      fireImmediately: true,
    );
    container.listen<Chits>(
      todayChitsProvider,
      (Chits? _, Chits _) {},
      fireImmediately: true,
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
    if (root.existsSync()) await root.delete(recursive: true);
  });

  Future<Chit> chitAt(DateTime when, String text) => repo.save(
    stamp: AmbientStamp(capturedAt: when),
    text: text,
  );

  List<Chit> settled(Chits value) => switch (value) {
    AsyncData<List<Chit>>(:final List<Chit> value) => value,
    _ => <Chit>[],
  };

  Future<List<Chit>> strip() async {
    await pumpEventQueue();
    return settled(container.read(timelineChitsProvider));
  }

  Future<List<Chit>> thread() async {
    await pumpEventQueue();
    return settled(container.read(todayChitsProvider));
  }

  test('the window comes off todayProvider, not off a second clock read', () {
    final DateTime today = container.read(todayProvider);

    expect(
      container.read(timelineQueryWindowProvider),
      TimelineWindow.around(today),
    );
    expect(
      clock.reads,
      1,
      reason: 'the whole screen reads the clock once, in todayProvider',
    );
  });

  group('what is drawn is narrower than what is asked for — ADR-035', () {
    test('an empty database draws today alone', () async {
      await strip();

      expect(container.read(timelineQueryWindowProvider).dayCount, 3);
      expect(container.read(timelineWindowProvider).dayCount, 1);
    });

    test(
      'the oldest chit in the window decides how wide the strip is',
      () async {
        await chitAt(DateTime(2026, 9, 15, 11), 'Yesterday.');
        await strip();

        expect(container.read(timelineWindowProvider).dayCount, 2);
        expect(
          container.read(timelineWindowProvider).start,
          DateTime(2026, 9, 15),
        );
      },
    );

    test('a chit on the oldest day of the window opens all three', () async {
      await chitAt(DateTime(2026, 9, 14, 9), 'Monday.');
      await strip();

      expect(
        container.read(timelineWindowProvider),
        container.read(timelineQueryWindowProvider),
      );
    });

    test('the query is three days wide whatever is drawn', () async {
      await chitAt(DateTime(2026, 9, 14, 9), 'Monday.');
      await strip();
      expect(container.read(timelineQueryWindowProvider).fromDay, 20260914);
    });
  });

  test('it asks for exactly the three days the window spans', () async {
    final Chit dayBefore = await chitAt(DateTime(2026, 9, 14, 9), 'Monday.');
    final Chit yesterday = await chitAt(DateTime(2026, 9, 15, 11), 'Tuesday.');
    final Chit today = await chitAt(DateTime(2026, 9, 16, 15), 'Today.');

    await chitAt(DateTime(2026, 9, 13, 20), 'Sunday.');

    expect(await strip(), <Chit>[dayBefore, yesterday, today]);
  });

  test('the thread reads one day and the strip reads all three', () async {
    await chitAt(DateTime(2026, 9, 15, 11), 'Yesterday.');
    final Chit today = await chitAt(DateTime(2026, 9, 16, 15), 'Today.');

    expect(await thread(), <Chit>[today]);
    expect(await strip(), hasLength(2));
  });

  test('a save reaches both, with nothing keeping them in step', () async {
    expect(await strip(), isEmpty);

    final Chit saved = await chitAt(afternoon, 'Saved.');

    expect(await strip(), <Chit>[saved]);
    expect(await thread(), <Chit>[saved]);
  });

  test('a chit saved now lands inside the window it is drawn on', () async {
    final Chit saved = await chitAt(afternoon, 'Just now.');
    final TimelineWindow window = container.read(timelineWindowProvider);

    expect(window.fractionOf(saved.createdAt), isNotNull);
    expect(
      window.fractionOf(saved.createdAt),
      closeTo(window.fractionOf(container.read(todayProvider))!, 1e-9),
    );
  });

  test('the strip rolls over with the rest of the screen', () async {
    await chitAt(DateTime(2026, 9, 14, 23), 'Monday night.');
    expect(await strip(), hasLength(1));

    clock.moveTo(DateTime(2026, 9, 17, 0, 1));
    container.invalidate(todayProvider);

    expect(container.read(timelineQueryWindowProvider).fromDay, 20260915);
    expect(
      await strip(),
      isEmpty,
      reason: 'Monday fell off the far end when Thursday arrived',
    );
    expect(
      container.read(timelineWindowProvider).dayCount,
      1,
      reason: 'and with nothing left in the window, the strip is today alone',
    );
  });

  group('now keeps up with a save — ADR-066', () {
    test('the tick at now is re-read when a chit is saved', () async {
      container.listen<DateTime>(
        timelineNowProvider,
        (DateTime? _, DateTime _) {},
        fireImmediately: true,
      );
      expect(container.read(timelineNowProvider), afternoon);

      final DateTime later = afternoon.add(const Duration(minutes: 20));
      clock.moveTo(later);
      expect(container.read(timelineNowProvider), afternoon);

      await repo.save(
        stamp: AmbientStamp(capturedAt: later),
        text: 'Now.',
      );
      await container.read(timelineChitsProvider.future);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(timelineNowProvider), later);
    });
  });
}
