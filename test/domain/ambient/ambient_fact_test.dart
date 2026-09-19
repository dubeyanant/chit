import 'package:chitt/domain/ambient/ambient_fact.dart';
import 'package:chitt/domain/models/ambient_stamp.dart';
import 'package:chitt/domain/models/motion_state.dart';
import 'package:chitt/domain/models/weather_condition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AmbientFact? factOf({MotionState? motion, WeatherCondition? weather}) =>
      AmbientFact.of(
        AmbientStamp(
          capturedAt: DateTime(2026, 9, 16, 20, 46),
          weather: weather,
          motion: motion,
        ),
      );

  const List<AmbientFact> ladder = <AmbientFact>[
    MotionFact(MotionState.flying),
    MotionFact(MotionState.traveling),
    WeatherFact(WeatherCondition.raining),
    WeatherFact(WeatherCondition.windy),
    MotionFact(MotionState.walking),
    WeatherFact(WeatherCondition.overcast),
    WeatherFact(WeatherCondition.clear),
    WeatherFact(WeatherCondition.clearNight),
  ];

  group('a stamp with nothing to say says nothing', () {
    test('no weather and no motion is no fact', () {
      expect(factOf(), isNull);
    });

    test('stationary alone is no fact', () {
      expect(factOf(motion: MotionState.stationary), isNull);
    });
  });

  group('either signal alone is drawn', () {
    test('every condition, with no motion', () {
      for (final WeatherCondition weather in WeatherCondition.values) {
        expect(
          factOf(weather: weather),
          WeatherFact(weather),
          reason: weather.name,
        );
      }
    });

    test('every motion state but stationary, with no weather', () {
      for (final MotionState motion in MotionState.values) {
        expect(
          factOf(motion: motion),
          motion == MotionState.stationary ? isNull : MotionFact(motion),
          reason: motion.name,
        );
      }
    });
  });

  test('every motion and weather pair resolves to the higher rung', () {
    for (final MotionState? motion in <MotionState?>[
      null,
      ...MotionState.values,
    ]) {
      for (final WeatherCondition? weather in <WeatherCondition?>[
        null,
        ...WeatherCondition.values,
      ]) {
        final AmbientFact? expected = ladder
            .where(
              (AmbientFact fact) => switch (fact) {
                MotionFact(:final MotionState state) => state == motion,
                WeatherFact(:final WeatherCondition condition) =>
                  condition == weather,
              },
            )
            .firstOrNull;

        expect(
          factOf(motion: motion, weather: weather),
          expected,
          reason: 'motion ${motion?.name}, weather ${weather?.name}',
        );
      }
    }
  });

  group('the rungs that decide the design', () {
    test('a vehicle displaces the rain', () {
      expect(
        factOf(
          motion: MotionState.traveling,
          weather: WeatherCondition.raining,
        ),
        const MotionFact(MotionState.traveling),
      );
    });

    test('the rain displaces a walk', () {
      expect(
        factOf(motion: MotionState.walking, weather: WeatherCondition.raining),
        const WeatherFact(WeatherCondition.raining),
      );
    });

    test('a walk displaces a closed sky', () {
      expect(
        factOf(motion: MotionState.walking, weather: WeatherCondition.overcast),
        const MotionFact(MotionState.walking),
      );
    });

    test(
      'a chit at a desk in the rain reads exactly as it did before motion',
      () {
        expect(
          factOf(
            motion: MotionState.stationary,
            weather: WeatherCondition.raining,
          ),
          const WeatherFact(WeatherCondition.raining),
        );
      },
    );
  });
}
