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

/// What both of Today's chit streams carry.
typedef Chits = AsyncValue<List<Chit>>;

/// The seam between the window's arithmetic and the query underneath it.
///
/// A `ProviderContainer` and no widget — ADR-031. Everything here is a claim
/// about wiring rather than about pixels: that the strip asks the repository
/// for the three days the window says, that it reads `todayProvider` rather
/// than the clock, and that a save arrives on it. What fifteen marks crowded
/// into one strip *look* like is a device check, and OPEN-QUESTIONS.md carries it.
///
/// The repository is the **real** one over a database in memory, which is what
/// ADR-031 asks for when a test is about data. There is no second
/// implementation to drift from it.
///
/// Both streams are subscribed in `setUp` and stay subscribed, because that is
/// what the screen does — it watches them for as long as it is on screen.
/// Subscribing per test instead puts the stream's first emission in a race
/// with the saves, and the answer depends on which lands first.
void main() {
  late Directory root;
  late AppDatabase db;
  late FakeClock clock;
  late ChitRepository repo;
  late ProviderContainer container;

  /// Wednesday 16 September 2026, 3:42pm.
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

    // A `@riverpod` provider is auto-dispose: with no subscription held open,
    // a plain `container.read` starts the stream and disposes it again before
    // it can answer. These go when the container does, below.
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
    // Disposing cancels `todayProvider`'s midnight timer. A container left
    // undisposed would hold a pending wall-clock timer until the run ended.
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

  /// The strip's marks, once the database has had its turn.
  Future<List<Chit>> strip() async {
    await pumpEventQueue();
    return settled(container.read(timelineChitsProvider));
  }

  /// The thread's chits, the same way.
  Future<List<Chit>> thread() async {
    await pumpEventQueue();
    return settled(container.read(todayChitsProvider));
  }

  test('the window comes off todayProvider, not off a second clock read', () {
    // The date line, the strip and the thread are three readings of one
    // instant. A strip that read the clock itself could span a different three
    // days from the date written above it, a millisecond either side of
    // midnight.
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
      // The trimming is a display decision. Narrowing the *query* would mean a
      // strip that could never grow backwards, because it would have stopped
      // asking whether there was anything there.
      await chitAt(DateTime(2026, 9, 14, 9), 'Monday.');
      await strip();
      expect(container.read(timelineQueryWindowProvider).fromDay, 20260914);
    });
  });

  test('it asks for exactly the three days the window spans', () async {
    final Chit dayBefore = await chitAt(DateTime(2026, 9, 14, 9), 'Monday.');
    final Chit yesterday = await chitAt(DateTime(2026, 9, 15, 11), 'Tuesday.');
    final Chit today = await chitAt(DateTime(2026, 9, 16, 15), 'Today.');
    // Four days back — outside any window this clock can produce.
    await chitAt(DateTime(2026, 9, 13, 20), 'Sunday.');

    expect(await strip(), <Chit>[dayBefore, yesterday, today]);
  });

  test('the thread reads one day and the strip reads all three', () async {
    await chitAt(DateTime(2026, 9, 15, 11), 'Yesterday.');
    final Chit today = await chitAt(DateTime(2026, 9, 16, 15), 'Today.');

    // The reason the strip needs a query of its own: two of its three days are
    // days the thread does not read at all.
    expect(await thread(), <Chit>[today]);
    expect(await strip(), hasLength(2));
  });

  test('a save reaches both, with nothing keeping them in step', () async {
    expect(await strip(), isEmpty);

    final Chit saved = await chitAt(afternoon, 'Saved.');

    // One write, two streams. The thread and the strip are two queries over
    // one table — a cost ADR-024 accepts — and this is what stops that being
    // two sources of truth.
    expect(await strip(), <Chit>[saved]);
    expect(await thread(), <Chit>[saved]);
  });

  test('a chit saved now lands inside the window it is drawn on', () async {
    // §4.1: *a chit saved at the current time places its mark inside the now
    // ring.* If `save` and the window disagreed about which day now is, the
    // mark would have nowhere to go and would not be drawn at all.
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

    // What the midnight timer in `todayProvider` does when it fires. The wait
    // itself is wall-clock and cannot be driven; what it *does* can be.
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

      // Twenty minutes pass with nothing saved: the tick stays where it was,
      // because the strip is static by design (§4.1).
      final DateTime later = afternoon.add(const Duration(minutes: 20));
      clock.moveTo(later);
      expect(container.read(timelineNowProvider), afternoon);

      // A save re-emits the rows, and now is read again at that moment — so
      // the new mark cannot land ahead of the tick.
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
