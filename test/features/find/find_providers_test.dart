import 'dart:io';

import 'package:chitta/core/clock.dart';
import 'package:chitta/data/audio/audio_store.dart';
import 'package:chitta/data/db/app_database.dart';
import 'package:chitta/data/repositories/chit_repository_impl.dart';
import 'package:chitta/domain/find/find_axis.dart';
import 'package:chitta/domain/models/ambient_stamp.dart';
import 'package:chitta/domain/models/chit.dart';
import 'package:chitta/domain/models/motion_state.dart';
import 'package:chitta/domain/models/weather_condition.dart';
import 'package:chitta/domain/repositories/chit_repository.dart';
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

    container.listen<Map<FindAxis, List<FindValue>>?>(
      axisValuesProvider,
      (Map<FindAxis, List<FindValue>>? _, Map<FindAxis, List<FindValue>>? _) {},
    );
  });

  tearDown(() async {
    await db.close();
    if (root.existsSync()) await root.delete(recursive: true);
  });

  int hour = 0;

  Future<Chit> write(
    String text, {
    WeatherCondition? weather,
    MotionState? motion,
  }) => repo.save(
    stamp: AmbientStamp(
      capturedAt: monday.add(Duration(hours: hour++)),
      weather: weather,
      motion: motion,
    ),
    text: text,
  );

  Future<void> settle() async {
    for (int i = 0; i < 100; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
      if (container.read(axisValuesProvider)?.isNotEmpty ?? false) return;
    }
  }

  List<FindValue> valuesOf(FindAxis axis) =>
      container.read(axisValuesProvider)?[axis] ?? const <FindValue>[];

  List<String> labelsOf(FindAxis axis) => <String>[
    for (final FindValue it in valuesOf(axis)) it.label,
  ];

  setUp(() => hour = 0);

  group('still loading is not the same as nothing there — ADR-085', () {
    test('the values are null until the chits have arrived', () {
      expect(
        container.read(axisValuesProvider),
        isNull,
        reason:
            'an empty map here is what made the axis screen draw its '
            'empty state for a frame and then throw it away',
      );
    });

    test('and a value screen is null too, not an empty day list', () {
      expect(
        container.read(chitsOfValueProvider(FindAxis.people, 'anant')),
        isNull,
      );
    });

    test(
      'an app with nothing in it loads to empty, which is an answer',
      () async {
        await write('no tags, no sky');
        await settle();

        final Map<FindAxis, List<FindValue>>? values = container.read(
          axisValuesProvider,
        );

        expect(values, isNotNull);
        for (final FindAxis axis in FindAxis.values) {
          expect(values![axis], isEmpty, reason: '${axis.slug} has nothing');
        }
      },
    );

    test('an axis with nothing on it stays empty while others fill', () async {
      await write('wet', weather: WeatherCondition.raining);
      await settle();

      final Map<FindAxis, List<FindValue>> values = container.read(
        axisValuesProvider,
      )!;

      expect(values[FindAxis.weather], hasLength(1));
      expect(values[FindAxis.motion], isEmpty);
      expect(values[FindAxis.people], isEmpty);
      expect(values[FindAxis.topics], isEmpty);
    });
  });

  group('the two ambient axes read alphabetically — §4.6', () {
    test('weather, whatever order it was written in', () async {
      await write('a', weather: WeatherCondition.windy);
      await write('b', weather: WeatherCondition.clear);
      await write('c', weather: WeatherCondition.raining);
      await write('d', weather: WeatherCondition.clearNight);
      await settle();

      expect(labelsOf(FindAxis.weather), <String>[
        'clear',
        'clear night',
        'raining',
        'windy',
      ]);
    });

    test('motion, and never stationary', () async {
      await write('a', motion: MotionState.walking);
      await write('b', motion: MotionState.flying);
      await write('c', motion: MotionState.stationary);
      await settle();

      expect(labelsOf(FindAxis.motion), <String>['flying', 'walking']);
    });

    test('a sky nobody wrote under is not offered', () async {
      await write('a', weather: WeatherCondition.raining);
      await settle();

      expect(labelsOf(FindAxis.weather), <String>['raining']);
    });
  });

  group('the two tag axes read by how often they were written', () {
    test('most written first', () async {
      await write('@mira and @anant');
      await write('@anant again');
      await write('@anant once more');
      await write('@rahul');
      await write('@rahul twice');
      await settle();

      expect(labelsOf(FindAxis.people), <String>['anant', 'rahul', 'mira']);
      expect(
        <int>[for (final FindValue v in valuesOf(FindAxis.people)) v.count],
        <int>[3, 2, 1],
      );
    });

    test('a tie breaks alphabetically, so nothing swaps on a save', () async {
      await write('@zoe');
      await write('@adam');
      await write('@mira');
      await settle();

      expect(labelsOf(FindAxis.people), <String>['adam', 'mira', 'zoe']);
    });

    test('one person written two ways counts as one', () async {
      await write('@Anant_Dubey');
      await write('again, @anant_dubey');
      await settle();

      expect(valuesOf(FindAxis.people), hasLength(1));
      expect(valuesOf(FindAxis.people).single.count, 2);
      expect(
        valuesOf(FindAxis.people).single.label,
        'anant dubey',
        reason:
            'the rows arrive newest first, so the latest spelling is the '
            'one drawn — change how you write a name and the list follows',
      );
    });

    test('an underscore is what joins a name — a space does not', () async {
      await write('@anant_dubey');
      await write('@anant dubey');
      await settle();

      expect(labelsOf(FindAxis.people), <String>[
        'anant',
        'anant dubey',
      ], reason: 'the second chit tags @anant and leaves "dubey" as words');
    });

    test('naming somebody twice in one chit counts once', () async {
      await write('@anant and @anant again');
      await write('@mira');
      await settle();

      expect(
        <String, int>{
          for (final FindValue v in valuesOf(FindAxis.people)) v.label: v.count,
        },
        <String, int>{'anant': 1, 'mira': 1},
      );
    });

    test('topics are their own axis, not mixed in with people', () async {
      await write('@anant about #rent');
      await settle();

      expect(labelsOf(FindAxis.people), <String>['anant']);
      expect(labelsOf(FindAxis.topics), <String>['rent']);
    });
  });

  group('a value opens the chits carrying it', () {
    List<String> chitsOf(FindAxis axis, String slug) => <String>[
      for (final DayGroup day
          in container.read(chitsOfValueProvider(axis, slug)) ??
              const <DayGroup>[])
        for (final Chit chit in day.chits) chit.text!,
    ];

    test('weather, newest first', () async {
      await write('first wet', weather: WeatherCondition.raining);
      await write('dry', weather: WeatherCondition.clear);
      await write('second wet', weather: WeatherCondition.raining);
      await settle();

      expect(chitsOf(FindAxis.weather, 'raining'), <String>[
        'second wet',
        'first wet',
      ]);
    });

    test('a person, reached by the folded label', () async {
      await write('one @Anant_Dubey');
      await write('two @anant_dubey');
      await write('three @mira');
      await settle();

      expect(chitsOf(FindAxis.people, 'anant dubey'), <String>[
        'two @anant_dubey',
        'one @Anant_Dubey',
      ]);
    });

    test('a topic of the same name is a different value', () async {
      await write('person @rent');
      await write('topic #rent');
      await settle();

      expect(chitsOf(FindAxis.people, 'rent'), <String>['person @rent']);
      expect(chitsOf(FindAxis.topics, 'rent'), <String>['topic #rent']);
    });

    test('a value nothing carries is empty, not an error', () async {
      await write('a', weather: WeatherCondition.raining);
      await settle();

      expect(chitsOf(FindAxis.weather, 'windy'), isEmpty);
      expect(chitsOf(FindAxis.people, 'nobody'), isEmpty);
    });

    test('the slug is the enum name, not the word on screen', () async {
      await write('night', weather: WeatherCondition.clearNight);
      await settle();

      final FindValue value = valuesOf(FindAxis.weather).single;
      expect(value.slug, 'clearNight');
      expect(value.label, 'clear night');
      expect(chitsOf(FindAxis.weather, value.slug), <String>['night']);
    });
  });
}
