import 'dart:io';

import 'package:chitta/core/clock.dart';
import 'package:chitta/data/audio/audio_store.dart';
import 'package:chitta/data/db/app_database.dart';
import 'package:chitta/data/repositories/chit_repository_impl.dart';
import 'package:chitta/domain/models/ambient_stamp.dart';
import 'package:chitta/domain/models/chit.dart';
import 'package:chitta/domain/models/motion_state.dart';
import 'package:chitta/domain/models/weather_condition.dart';
import 'package:chitta/domain/repositories/chit_repository.dart';
import 'package:chitta/domain/tags/chit_tags.dart';
import 'package:chitta/features/find/application/find_providers.dart';
import 'package:chitta/shared/day_group.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../support/fake_clock.dart';

void main() {
  late Directory root;
  late AppDatabase db;
  late FakeClock clock;
  late ChitRepository repo;
  late ProviderContainer container;

  final DateTime monday = DateTime(2026, 9, 14, 9, 0);

  setUp(() async {
    root = await Directory.systemTemp.createTemp('chit-find-test');
    final Directory documents = await Directory(p.join(root.path, 'documents'))
        .create();
    db = AppDatabase(NativeDatabase.memory());
    clock = FakeClock(monday);
    repo = ChitRepositoryImpl(
      dao: db.chitDao,
      audio: AudioStore(Future<Directory>.value(documents)),
      clock: clock,
    );

    container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(clock),
        chitRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    container.listen(facetsProvider, (FindFacets? _, FindFacets _) {});
    container.listen(foundProvider, (List<DayGroup>? _, List<DayGroup> _) {});
  });

  tearDown(() async {
    await db.close();
    if (root.existsSync()) await root.delete(recursive: true);
  });

  Future<Chit> write(
    String text, {
    required DateTime at,
    WeatherCondition? weather,
    MotionState? motion,
  }) => repo.save(
    stamp: AmbientStamp(capturedAt: at, weather: weather, motion: motion),
    text: text,
  );

  Future<void> settle() async {
    for (int i = 0; i < 100; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
      if (container.read(facetsProvider).isEmpty == false) return;
    }
  }

  List<String> foundText() => <String>[
    for (final DayGroup day in container.read(foundProvider))
      for (final Chit chit in day.chits) chit.text!,
  ];

  group('the facets are only what was written', () {
    test('a sky nobody saw is not offered', () async {
      await write(
        'Wet.',
        at: monday,
        weather: WeatherCondition.raining,
      );
      await settle();

      expect(container.read(facetsProvider).weather, <WeatherCondition>[
        WeatherCondition.raining,
      ]);
    });

    test('stationary is never offered, being never drawn — §3.6.1', () async {
      await write('Still.', at: monday, motion: MotionState.stationary);
      await write(
        'Moving.',
        at: monday.add(const Duration(hours: 1)),
        motion: MotionState.walking,
      );
      await settle();

      expect(container.read(facetsProvider).motion, <MotionState>[
        MotionState.walking,
      ]);
    });

    test('people and topics come out of the words', () async {
      await write('Called @anant_dubey about #rent.', at: monday);
      await settle();

      final FindFacets facets = container.read(facetsProvider);

      expect(
        <String>[for (final TagSpan t in facets.people) t.label],
        <String>['anant dubey'],
      );
      expect(
        <String>[for (final TagSpan t in facets.topics) t.label],
        <String>['rent'],
      );
    });

    test('one person written two ways is offered once', () async {
      await write('@Anant again', at: monday);
      await write('@anant_dubey?', at: monday.add(const Duration(hours: 1)));
      await write('@anant once more', at: monday.add(const Duration(hours: 2)));
      await settle();

      expect(
        container.read(facetsProvider).people.map((TagSpan t) => t.key),
        <String>['person:anant', 'person:anant dubey'],
        reason: 'two distinct people, alphabetical, case folded',
      );
    });
  });

  group('what the filter leaves behind', () {
    Future<void> threeChits() async {
      await write(
        'Wet walk with @anant.',
        at: monday,
        weather: WeatherCondition.raining,
        motion: MotionState.walking,
      );
      await write(
        'Dry desk, #rent due.',
        at: monday.add(const Duration(hours: 2)),
        weather: WeatherCondition.clear,
      );
      await write(
        'Wet desk, @anant again.',
        at: monday.add(const Duration(days: 1)),
        weather: WeatherCondition.raining,
      );
      await settle();
    }

    test('nothing chosen shows everything, newest day first', () async {
      await threeChits();

      expect(foundText(), <String>[
        'Wet desk, @anant again.',
        'Dry desk, #rent due.',
        'Wet walk with @anant.',
      ]);
    });

    test('one word narrows to the chits carrying it', () async {
      await threeChits();

      container.read(filterProvider.notifier).toggleWeather(
        WeatherCondition.raining,
      );

      expect(foundText(), <String>[
        'Wet desk, @anant again.',
        'Wet walk with @anant.',
      ]);
    });

    test('a second row tightens it', () async {
      await threeChits();

      final Filter filter = container.read(filterProvider.notifier);
      filter.toggleWeather(WeatherCondition.raining);
      filter.toggleMotion(MotionState.walking);

      expect(foundText(), <String>['Wet walk with @anant.']);
    });

    test('a second word in the same row widens it', () async {
      await threeChits();

      final Filter filter = container.read(filterProvider.notifier);
      filter.toggleWeather(WeatherCondition.raining);
      filter.toggleWeather(WeatherCondition.clear);

      expect(foundText(), hasLength(3));
    });

    test('a person filter reaches both spellings', () async {
      await threeChits();

      container.read(filterProvider.notifier).togglePerson('person:anant');

      expect(foundText(), <String>[
        'Wet desk, @anant again.',
        'Wet walk with @anant.',
      ]);
    });

    test('tapping the same word again lets it go', () async {
      await threeChits();

      final Filter filter = container.read(filterProvider.notifier);
      filter.toggleWeather(WeatherCondition.raining);
      expect(foundText(), hasLength(2));

      filter.toggleWeather(WeatherCondition.raining);
      expect(container.read(filterProvider).isEmpty, isTrue);
      expect(foundText(), hasLength(3));
    });

    test('Show everything puts every word out at once', () async {
      await threeChits();

      final Filter filter = container.read(filterProvider.notifier);
      filter.toggleWeather(WeatherCondition.raining);
      filter.togglePerson('person:anant');
      expect(container.read(filterProvider).chosen, 2);

      filter.clear();
      expect(container.read(filterProvider).isEmpty, isTrue);
      expect(foundText(), hasLength(3));
    });

    test('a combination nothing answers leaves nothing', () async {
      await threeChits();

      final Filter filter = container.read(filterProvider.notifier);
      filter.toggleWeather(WeatherCondition.clear);
      filter.togglePerson('person:anant');

      expect(foundText(), isEmpty);
    });
  });

  test('a recording with no words carries no tags and is still found', () async {
    await write('Words.', at: monday);
    await settle();

    expect(container.read(facetsProvider).tagsByChit, isEmpty);
    expect(foundText(), <String>['Words.']);
  });
}
