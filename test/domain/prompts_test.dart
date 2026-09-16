import 'package:chit/domain/models/ambient_stamp.dart';
import 'package:chit/domain/models/weather_condition.dart';
import 'package:chit/domain/prompts.dart';
import 'package:flutter_test/flutter_test.dart';

/// The prompt book — BEHAVIOUR.md §3.3, ADR-029.
///
/// Two kinds of claim here and they fail differently. The **choice** fails
/// loudly if it is wrong, because the wrong words are on the screen. The
/// **copy** fails quietly: a prompt that instructs rather than offers reads
/// fine to whoever wrote it, and it is a different app by the tenth one.
void main() {
  AmbientStamp at(int hour, {WeatherCondition? weather, int minute = 0}) =>
      AmbientStamp(
        capturedAt: DateTime(2026, 9, 16, hour, minute),
        weather: weather,
      );

  group('the choice is the most specific thing that fits', () {
    test('weather and the hour together beat either alone', () {
      expect(
        Prompts.forStamp(at(8, weather: WeatherCondition.raining)),
        'Raining. How has it started?',
      );
    });

    test('weather alone, when the hour has no pair for it', () {
      // There is no rain entry for the afternoon, so the rain entries win on
      // their own — the afternoon ones are a step less specific.
      final String words = Prompts.forStamp(
        at(15, weather: WeatherCondition.raining),
      );

      expect(words.toLowerCase(), contains('rain'));
    });

    test('the hour alone, when no weather arrived', () {
      // ADR-007's ordinary outcome: the service said nothing, and the prompt
      // still knows what time it is.
      expect(Prompts.forStamp(at(8)), isNot(Prompts.neutral));
      expect(Prompts.forStamp(at(2)), contains('up'));
    });

    test('the small hours are their own part of the day', () {
      // ADR-006 works hardest to protect 00:00–05:00, and a chit written at
      // 00:20 belongs to the night before. Asking it how the morning has
      // started would file the day wrong in the only place the user can see.
      expect(Prompts.forStamp(at(0, minute: 20)), contains('up'));
      expect(Prompts.forStamp(at(4, minute: 59)), contains('up'));
      expect(Prompts.forStamp(at(5)), isNot(contains('up')));
    });
  });

  group('it is stable, and it varies', () {
    test('the same stamp always gives the same words', () {
      // It is read on every rebuild, so anything random here would change the
      // prompt mid-fade.
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
      // The seed is the stamp's own seconds and not an epoch, because an epoch
      // is a different number in a different time zone — and a prompt that
      // differs between two developers is a test that fails somewhere else.
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
      // The specification names it, so it stays reachable rather than being
      // quietly replaced by a set of variations on it.
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
      // §3.3: *a prompt shown after a pause is an offer.* Every one of them
      // is a question, and none of them is excited about it. The design log's
      // objection to a score is the same objection: chit does not have
      // opinions about how much you write.
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
      // The field holds about forty characters to the line at 17.5px (§6.2),
      // and a prompt that wraps is a paragraph where a nudge was meant.
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
