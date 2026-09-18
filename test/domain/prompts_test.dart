import 'package:chitta/domain/models/ambient_stamp.dart';
import 'package:chitta/domain/models/motion_state.dart';
import 'package:chitta/domain/models/weather_condition.dart';
import 'package:chitta/domain/prompts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AmbientStamp at(
    int hour, {
    WeatherCondition? weather,
    MotionState? motion,
    int minute = 0,
  }) => AmbientStamp(
    capturedAt: DateTime(2026, 9, 16, hour, minute),
    weather: weather,
    motion: motion,
  );

  group('motion outranks the weather and the hour — ADR-037, ADR-038', () {
    test('a chit opened on the move is asked about the move', () {
      final String words = Prompts.forStamp(
        at(
          19,
          weather: WeatherCondition.raining,
          motion: MotionState.traveling,
        ),
      );

      expect(words.toLowerCase(), isNot(contains('rain')));
      expect(words, 'On the way home. How did the day go?');
    });

    test('each moving state has something of its own to ask', () {
      for (final MotionState motion in <MotionState>[
        MotionState.walking,
        MotionState.traveling,
        MotionState.flying,
      ]) {
        expect(
          Prompts.forStamp(at(14, motion: motion)),
          isNot(Prompts.forStamp(at(14))),
          reason: '${motion.name} should not be asked the plain afternoon one',
        );
      }
    });

    test('stationary is asked exactly what a chit with no motion is asked', () {
      for (final int hour in <int>[2, 8, 14, 19, 22]) {
        expect(
          Prompts.forStamp(
            at(
              hour,
              weather: WeatherCondition.raining,
              motion: MotionState.stationary,
            ),
          ),
          Prompts.forStamp(at(hour, weather: WeatherCondition.raining)),
          reason: '$hour:00',
        );
      }
    });

    test('a walk in the rain is asked about both', () {
      expect(
        Prompts.forStamp(
          at(
            14,
            weather: WeatherCondition.raining,
            motion: MotionState.walking,
          ),
        ),
        "Walking in the rain. What's it like?",
      );
    });
  });

  group('the choice is the most specific thing that fits', () {
    test('weather and the hour together beat either alone', () {
      expect(
        Prompts.forStamp(at(8, weather: WeatherCondition.raining)),
        'Raining. How has it started?',
      );
    });

    test('weather alone, when the hour has no pair for it', () {
      final String words = Prompts.forStamp(
        at(15, weather: WeatherCondition.raining),
      );

      expect(words.toLowerCase(), contains('rain'));
    });

    test('the hour alone, when no weather arrived', () {
      expect(Prompts.forStamp(at(8)), isNot(Prompts.neutral));
      expect(Prompts.forStamp(at(2)), contains('up'));
    });

    test('the small hours are their own part of the day', () {
      expect(Prompts.forStamp(at(0, minute: 20)), contains('up'));
      expect(Prompts.forStamp(at(4, minute: 59)), contains('up'));
      expect(Prompts.forStamp(at(5)), isNot(contains('up')));
    });
  });

  group('it is stable, and it varies', () {
    test('the same stamp always gives the same words', () {
      final AmbientStamp stamp = at(15, weather: WeatherCondition.clear);

      expect(
        List<String>.generate(20, (_) => Prompts.forStamp(stamp)).toSet(),
        hasLength(1),
      );
    });

    test('two chits in the same hour and weather are not always asked the '
        'same thing', () {
      final Set<String> said = <String>{
        for (int second = 0; second < 10; second++)
          Prompts.forStamp(
            AmbientStamp(
              capturedAt: DateTime(2026, 9, 16, 15, 42, second),
              weather: WeatherCondition.clear,
            ),
          ),
      };

      expect(said.length, greaterThan(1));
    });

    test('nothing depends on the machine it runs on', () {
      final AmbientStamp noon = AmbientStamp(
        capturedAt: DateTime(2026, 9, 16, 12, 0, 7),
      );

      expect(Prompts.forStamp(noon), Prompts.forStamp(noon.copyWith()));
    });
  });

  group('every moment has something to say', () {
    test('every hour of the day, with no weather at all', () {
      for (int hour = 0; hour < 24; hour++) {
        expect(
          Prompts.forStamp(at(hour)),
          isNot(Prompts.neutral),
          reason: '$hour:00 fell through to the floor',
        );
      }
    });

    test('every condition, at every hour', () {
      for (final WeatherCondition condition in WeatherCondition.values) {
        for (int hour = 0; hour < 24; hour++) {
          expect(
            Prompts.forStamp(at(hour, weather: condition)),
            isNotEmpty,
            reason: '$condition at $hour:00',
          );
        }
      }
    });

    test('§3.3\'s own line is still in the book', () {
      expect(Prompts.all, contains(Prompts.neutral));
    });
  });

  group('the copy', () {
    test('says nothing twice', () {
      expect(Prompts.all.toSet(), hasLength(Prompts.all.length));
    });

    test('is a set worth having — more than twenty of them', () {
      expect(Prompts.all.length, greaterThanOrEqualTo(20));
    });

    test('offers rather than instructs', () {
      for (final String words in Prompts.all) {
        expect(words, endsWith('?'), reason: '"$words" is not a question');
        expect(words, isNot(contains('!')), reason: '"$words" shouts');
        expect(
          words.toLowerCase(),
          isNot(contains("let's")),
          reason: '"$words" is an instruction wearing a question mark',
        );
      }
    });

    test('is short enough to sit on one line of the field', () {
      for (final String words in Prompts.all) {
        expect(
          words.length,
          lessThanOrEqualTo(46),
          reason: '"$words" is ${words.length} characters',
        );
      }
    });
  });
}
