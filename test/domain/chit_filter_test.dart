import 'package:chitta/domain/models/chit.dart';
import 'package:chitta/domain/models/chit_filter.dart';
import 'package:chitta/domain/models/motion_state.dart';
import 'package:chitta/domain/models/weather_condition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime when = DateTime(2026, 9, 15, 15, 42);

  Chit chit({WeatherCondition? weather, MotionState? motion}) => Chit(
    id: 'a',
    createdAt: when,
    localDay: Chit.localDayOf(when),
    updatedAt: when,
    text: 'Train 20 late.',
    weather: weather,
    motion: motion,
  );

  const Set<String> noTags = <String>{};

  test('nothing chosen allows everything', () {
    expect(ChitFilter.none.isEmpty, isTrue);
    expect(ChitFilter.none.allows(chit(), noTags), isTrue);
    expect(ChitFilter.none.chosen, 0);
  });

  group('any within an axis', () {
    const ChitFilter wet = ChitFilter(
      weather: <WeatherCondition>{
        WeatherCondition.raining,
        WeatherCondition.windy,
      },
    );

    test('either word is enough', () {
      expect(wet.allows(chit(weather: WeatherCondition.raining), noTags), true);
      expect(wet.allows(chit(weather: WeatherCondition.windy), noTags), true);
    });

    test('a third is not', () {
      expect(wet.allows(chit(weather: WeatherCondition.clear), noTags), false);
    });

    test('a chit with no weather at all is not a match', () {
      expect(
        wet.allows(chit(), noTags),
        isFalse,
        reason: 'a signal that did not arrive cannot answer for one that did',
      );
    });
  });

  group('all across axes', () {
    const ChitFilter rainingAndWalking = ChitFilter(
      weather: <WeatherCondition>{WeatherCondition.raining},
      motion: <MotionState>{MotionState.walking},
    );

    test('both have to hold', () {
      expect(
        rainingAndWalking.allows(
          chit(weather: WeatherCondition.raining, motion: MotionState.walking),
          noTags,
        ),
        isTrue,
      );
    });

    test('one of two is not enough', () {
      expect(
        rainingAndWalking.allows(
          chit(weather: WeatherCondition.raining),
          noTags,
        ),
        isFalse,
      );
      expect(
        rainingAndWalking.allows(chit(motion: MotionState.walking), noTags),
        isFalse,
      );
    });

    test('another word in the same row widens, another row tightens', () {
      const ChitFilter wider = ChitFilter(
        weather: <WeatherCondition>{
          WeatherCondition.raining,
          WeatherCondition.clear,
        },
      );
      const ChitFilter tighter = ChitFilter(
        weather: <WeatherCondition>{WeatherCondition.raining},
        motion: <MotionState>{MotionState.flying},
      );

      final Chit clear = chit(weather: WeatherCondition.clear);
      expect(wider.allows(clear, noTags), isTrue);
      expect(tighter.allows(clear, noTags), isFalse);
    });
  });

  group('people and topics read the keys, not the words', () {
    const ChitFilter anant = ChitFilter(people: <String>{'person:anant'});

    test('a chit carrying the key passes', () {
      expect(anant.allows(chit(), <String>{'person:anant'}), isTrue);
    });

    test('a chit carrying a different one does not', () {
      expect(anant.allows(chit(), <String>{'person:mira'}), isFalse);
    });

    test('a topic of the same name is a different tag', () {
      expect(anant.allows(chit(), <String>{'topic:anant'}), isFalse);
    });

    test('people and topics are two axes, so both must hold', () {
      const ChitFilter both = ChitFilter(
        people: <String>{'person:anant'},
        topics: <String>{'topic:rent'},
      );

      expect(both.allows(chit(), <String>{'person:anant'}), isFalse);
      expect(
        both.allows(chit(), <String>{'person:anant', 'topic:rent'}),
        isTrue,
      );
    });
  });

  test('chosen counts every lit word across the four rows', () {
    const ChitFilter filter = ChitFilter(
      weather: <WeatherCondition>{
        WeatherCondition.raining,
        WeatherCondition.windy,
      },
      motion: <MotionState>{MotionState.walking},
      people: <String>{'person:anant'},
      topics: <String>{'topic:rent', 'topic:work'},
    );

    expect(filter.chosen, 6);
    expect(filter.isEmpty, isFalse);
  });
}
