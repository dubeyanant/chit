import 'dart:io';

import 'package:chit/core/clock.dart';
import 'package:chit/data/audio/audio_store.dart';
import 'package:chit/data/db/app_database.dart';
import 'package:chit/data/repositories/chit_repository_impl.dart';
import 'package:chit/domain/models/ambient_stamp.dart';
import 'package:chit/domain/models/chit.dart';
import 'package:chit/domain/models/day_summary.dart';
import 'package:chit/domain/repositories/chit_repository.dart';
import 'package:chit/features/calendar/application/archive_provider.dart';
import 'package:chit/features/calendar/application/month_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';

/// The calendar's providers on a bare `ProviderContainer` over real Drift in
/// memory — ADR-031. Every claim here is about wiring: which days the month
/// asks for, that a selection narrows the archive to one query and clearing
/// widens it back, that navigating re-queries, and above all **that one save
/// reaches the grid, the summary and the archive** — which is BUILD-PLAN.md
/// M4's statement of done, as far as a test can hold it. What a step-four tile
/// *looks* like beside a step-one is a device check, and PROGRESS.md carries
/// it.
void main() {
  late Directory root;
  late AppDatabase db;
  late FakeClock clock;
  late ChitRepository repo;
  late ProviderContainer container;

  /// Thursday 17 September 2026, 3pm.
  final DateTime afternoon = DateTime(2026, 9, 17, 15);

  setUp(() async {
    root = await Directory.systemTemp.createTemp('chit-calendar-test');
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

    // Held open for the life of the container, as the screen holds them. An
    // auto-dispose stream read once and dropped never gets to answer.
    container.listen<MonthShape?>(
      drawnMonthProvider,
      (MonthShape? _, MonthShape? _) {},
      fireImmediately: true,
    );
    container.listen<List<ArchiveDay>?>(
      archiveDaysProvider,
      (List<ArchiveDay>? _, List<ArchiveDay>? _) {},
      fireImmediately: true,
    );
    container.listen<MonthNeighbours>(
      monthNeighboursProvider,
      (MonthNeighbours? _, MonthNeighbours _) {},
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

  // Both helpers read into a typed local before the `!`. Written as
  // `container.read(p)!` the return context makes Dart infer the provider's
  // state as non-nullable, and Riverpod's subscription then fails a runtime
  // type check with a NoSuchMethodError on null deep inside `read` — which
  // is a very long way from the one character that caused it.
  Future<MonthShape> month() async {
    await pumpEventQueue();
    final MonthShape? shape = container.read(drawnMonthProvider);
    return shape!;
  }

  Future<List<ArchiveDay>> archive() async {
    await pumpEventQueue();
    final List<ArchiveDay>? days = container.read(archiveDaysProvider);
    return days!;
  }

  group('the visible month', () {
    test('opens on the month today is in, off todayProvider', () {
      expect(container.read(visibleMonthProvider), const YearMonth(2026, 9));
      expect(
        clock.reads,
        1,
        reason: 'the calendar reads the clock through todayProvider, once',
      );
    });

    test('has nowhere to go on a fresh install, so draws no chevron', () async {
      await pumpEventQueue();
      expect(container.read(monthNeighboursProvider), (
        previous: null,
        next: null,
      ));

      container.read(visibleMonthProvider.notifier)
        ..previous()
        ..next();
      expect(container.read(visibleMonthProvider), const YearMonth(2026, 9));
    });

    test('goes back to the nearest written month, skipping empty ones —'
        ' ADR-047', () async {
      // July and April have chits; August, June and May do not. Stepping
      // one calendar month at a time would land on an empty August with a
      // dead chevron beside it, which is what the first device pass saw.
      await chitAt(DateTime(2026, 7, 4, 9), 'July.');
      await chitAt(DateTime(2026, 4, 20, 9), 'April.');
      await pumpEventQueue();

      final VisibleMonth notifier = container.read(
        visibleMonthProvider.notifier,
      );
      expect(container.read(monthNeighboursProvider), (
        previous: const YearMonth(2026, 7),
        next: null,
      ));

      notifier.previous();
      expect(container.read(visibleMonthProvider), const YearMonth(2026, 7));
      expect(container.read(monthNeighboursProvider), (
        previous: const YearMonth(2026, 4),
        next: const YearMonth(2026, 9),
      ));

      notifier.previous();
      expect(container.read(visibleMonthProvider), const YearMonth(2026, 4));
      expect(container.read(monthNeighboursProvider).previous, isNull);

      // The floor: nothing earlier, so previous() is a no-op.
      notifier.previous();
      expect(container.read(visibleMonthProvider), const YearMonth(2026, 4));
    });

    test('comes forward the same way, and lands on the current month whether '
        'or not it holds anything', () async {
      await chitAt(DateTime(2026, 4, 20, 9), 'April.');
      await chitAt(DateTime(2026, 7, 4, 9), 'July.');
      await pumpEventQueue();

      final VisibleMonth notifier = container.read(
        visibleMonthProvider.notifier,
      )..previous();
      notifier.previous();
      expect(container.read(visibleMonthProvider), const YearMonth(2026, 4));

      notifier.next();
      expect(container.read(visibleMonthProvider), const YearMonth(2026, 7));

      // September has nothing written in it and is still where next() lands:
      // it is today's month, and the way back to it cannot depend on a chit.
      notifier.next();
      expect(container.read(visibleMonthProvider), const YearMonth(2026, 9));
      expect(container.read(monthNeighboursProvider).next, isNull);

      notifier.next();
      expect(container.read(visibleMonthProvider), const YearMonth(2026, 9));
    });

    test('a save in a new month gives the chevron somewhere to go', () async {
      await pumpEventQueue();
      expect(container.read(monthNeighboursProvider).previous, isNull);

      await chitAt(DateTime(2026, 8, 2, 9), 'August.');
      await pumpEventQueue();

      expect(
        container.read(monthNeighboursProvider).previous,
        const YearMonth(2026, 8),
      );
    });
  });

  group('the month asks for exactly its own days', () {
    test(
      'a chit on the last day before and the first day after are not in it',
      () async {
        await chitAt(DateTime(2026, 8, 31, 23, 59), 'August.');
        await chitAt(DateTime(2026, 9, 1, 0, 1), 'First.');
        await chitAt(DateTime(2026, 9, 17, 12), 'Today.');

        final MonthShape september = await month();
        expect(september.total, 2);
        expect(september.countOf(1), 1);
        expect(september.countOf(17), 1);
        expect(september.countOf(31), 0);
      },
    );

    test('and re-queries when the month changes', () async {
      await chitAt(DateTime(2026, 8, 31, 23, 59), 'August.');
      await chitAt(DateTime(2026, 8, 3, 9), 'Also August.');
      await chitAt(DateTime(2026, 9, 5, 9), 'September.');

      container.read(visibleMonthProvider.notifier).previous();

      final MonthShape august = await month();
      expect(august.month, const YearMonth(2026, 8));
      expect(august.total, 2);
      expect(august.lastDrawnDay, 31);
      expect(august.isCurrentMonth, isFalse);
    });

    test('is null until the query has first answered', () {
      expect(container.read(drawnMonthProvider), isNull);
    });

    test(
      'holds the last month while the next is in flight — ADR-049',
      () async {
        // The handset saw the bar, the grid and the summary vanish for the
        // frames a change of month took. September under its own name is a
        // slow answer while August is fetched; a blank is a wrong one.
        await chitAt(DateTime(2026, 8, 3, 9), 'August.');
        await chitAt(DateTime(2026, 9, 5, 9), 'September.');
        final MonthShape september = await month();
        expect(september.month, const YearMonth(2026, 9));

        container.read(visibleMonthProvider.notifier).previous();

        expect(container.read(visibleMonthProvider), const YearMonth(2026, 8));
        expect(
          container.read(drawnMonthProvider),
          september,
          reason: 'the month asked for has moved; the month drawn has not yet',
        );

        final MonthShape august = await month();
        expect(august.month, const YearMonth(2026, 8));
        expect(august.total, 1);
      },
    );
  });

  test('one save reaches the grid, the summary and the archive', () async {
    // BUILD-PLAN.md M4: done when saving a chit on Today changes the
    // calendar density and the month total without a refresh, because both
    // read the same stream. Nothing here tells the calendar anything.
    expect((await month()).summary, ('Nothing written', ' this month'));
    expect(await archive(), isEmpty);

    final Chit saved = await chitAt(afternoon, 'Saved on Today.');

    final MonthShape after = await month();
    expect(after.countOf(17), 1);
    expect(MonthShape.densityStep(after.countOf(17)), 1);
    expect(after.summary, ('1 chit', ' over one day'));
    expect(await archive(), <ArchiveDay>[
      ArchiveDay(localDay: 20260917, chits: <Chit>[saved]),
    ]);

    await chitAt(afternoon.add(const Duration(minutes: 5)), 'And another.');
    expect(MonthShape.densityStep((await month()).countOf(17)), 2);
    expect((await archive()).single.chits, hasLength(2));
  });

  group('the archive', () {
    test(
      'is every day newest first, and newest chit first within a day',
      () async {
        final Chit older = await chitAt(DateTime(2026, 9, 11, 8), 'Friday.');
        final Chit morning = await chitAt(DateTime(2026, 9, 16, 9), 'Morning.');
        final Chit night = await chitAt(DateTime(2026, 9, 16, 21), 'Night.');

        expect(await archive(), <ArchiveDay>[
          ArchiveDay(localDay: 20260916, chits: <Chit>[night, morning]),
          ArchiveDay(localDay: 20260911, chits: <Chit>[older]),
        ]);
      },
    );

    test('a selected day narrows it to that day', () async {
      await chitAt(DateTime(2026, 9, 11, 8), 'Friday.');
      final Chit tuesday = await chitAt(DateTime(2026, 9, 15, 9), 'Tuesday.');

      container.read(selectedDayProvider.notifier).toggle(20260915);

      expect(await archive(), <ArchiveDay>[
        ArchiveDay(localDay: 20260915, chits: <Chit>[tuesday]),
      ]);
    });

    test('the same tile again, or clear, widens it back', () async {
      await chitAt(DateTime(2026, 9, 11, 8), 'Friday.');
      await chitAt(DateTime(2026, 9, 15, 9), 'Tuesday.');
      final SelectedDay selection = container.read(
        selectedDayProvider.notifier,
      );

      selection.toggle(20260915);
      expect(await archive(), hasLength(1));

      selection.toggle(20260915);
      expect(container.read(selectedDayProvider), isNull);
      expect(await archive(), hasLength(2));

      selection.toggle(20260911);
      selection.clear();
      expect(await archive(), hasLength(2));
    });

    test('changing the month clears the selection', () async {
      // Somewhere for previous() to go — a chevron only lands on a written
      // month (ADR-047).
      await chitAt(DateTime(2026, 8, 2, 9), 'August.');
      await chitAt(DateTime(2026, 9, 15, 9), 'Tuesday.');
      await pumpEventQueue();
      container.read(selectedDayProvider.notifier).toggle(20260915);
      expect(container.read(selectedDayProvider), 20260915);

      container.read(visibleMonthProvider.notifier).previous();

      expect(container.read(visibleMonthProvider), const YearMonth(2026, 8));
      expect(container.read(selectedDayProvider), isNull);
      expect(await archive(), hasLength(2));
    });

    test('is paged, and a page more widens the query', () async {
      const int pageSize = ArchivePages.pageSize;
      for (int i = 0; i < pageSize + 5; i++) {
        await chitAt(DateTime(2026, 9, 1).add(Duration(hours: i)), 'Chit $i.');
      }

      int loaded(List<ArchiveDay> days) =>
          days.fold(0, (int n, ArchiveDay d) => n + d.chits.length);

      expect(container.read(archiveLimitProvider), pageSize);
      expect(loaded(await archive()), pageSize);

      container.read(archivePagesProvider.notifier).more();

      expect(container.read(archiveLimitProvider), pageSize * 2);
      expect(loaded(await archive()), pageSize + 5);
    });

    test('is null until the query has first answered', () {
      expect(container.read(archiveDaysProvider), isNull);
    });

    test(
      'holds the last answer while a selection is in flight — ADR-049',
      () async {
        await chitAt(DateTime(2026, 9, 11, 8), 'Friday.');
        await chitAt(DateTime(2026, 9, 15, 9), 'Tuesday.');
        final List<ArchiveDay> every = await archive();
        expect(every, hasLength(2));

        container.read(selectedDayProvider.notifier).toggle(20260915);

        expect(
          container.read(archiveDaysProvider),
          every,
          reason: 'the query has changed; the archive drawn has not yet',
        );
        expect(await archive(), hasLength(1));
      },
    );
  });

  test('the summary rows are DaySummary, one per written day', () async {
    await chitAt(DateTime(2026, 9, 5, 9), 'One.');
    await chitAt(DateTime(2026, 9, 5, 10), 'Two.');
    await pumpEventQueue();

    expect(container.read(monthSummariesProvider).value, <DaySummary>[
      const DaySummary(localDay: 20260905, count: 2),
    ]);
  });
}
