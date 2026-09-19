import 'package:chitt/domain/models/motion_state.dart';
import 'package:chitt/domain/motion/motion_ladder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  MotionState? at(double? speed, {double? altitude}) => MotionLadder.from(
    speed: speed,
    speedAccuracy: speed == null || speed <= 0 ? 0.1 : speed / 10,
    altitude: altitude,
  );

  MotionState? gated(double speed, double? accuracy, {double? altitude}) =>
      MotionLadder.from(
        speed: speed,
        speedAccuracy: accuracy,
        altitude: altitude,
      );

  group('no reading at all is null, and null is not drawn', () {
    test('a fix that carried no speed', () {
      expect(at(null), isNull);
    });

    test('a negative speed is a platform saying it has none', () {
      for (final double invalid in <double>[-1, -0.001, -99]) {
        expect(at(invalid), isNull, reason: '$invalid m/s');
      }
    });

    test('a NaN speed is a malformed message, not a still phone', () {
      expect(at(double.nan), isNull);
    });
  });

  group('the four bands of ADR-037', () {
    test('below the walking floor is stationary', () {
      for (final double speed in <double>[
        0,
        0.1,
        0.35,
        MotionLadder.walkingFloor - 0.001,
      ]) {
        expect(at(speed), MotionState.stationary, reason: '$speed m/s');
      }
    });

    test('the walking floor itself walks', () {
      expect(at(MotionLadder.walkingFloor), MotionState.walking);
    });

    test('a walking pace walks', () {
      for (final double speed in <double>[
        0.9,
        1.4,
        2.5,
        MotionLadder.travelingFloor - 0.001,
      ]) {
        expect(at(speed), MotionState.walking, reason: '$speed m/s');
      }
    });

    test('anything faster than a run is travelling', () {
      for (final double speed in <double>[
        MotionLadder.travelingFloor,
        5,
        14,
        30,
        MotionLadder.flyingFloor - 0.001,
      ]) {
        expect(at(speed), MotionState.traveling, reason: '$speed m/s');
      }
    });
  });

  group('flying needs the altitude as well as the speed', () {
    test('fast and high is flying', () {
      expect(
        at(
          MotionLadder.flyingFloor,
          altitude: MotionLadder.flyingAltitudeFloor + 1,
        ),
        MotionState.flying,
      );
      expect(at(250, altitude: 11000), MotionState.flying);
    });

    test('fast and low is a high-speed train, and it travels', () {
      for (final double? altitude in <double?>[
        null,
        0,
        120,
        MotionLadder.flyingAltitudeFloor,
        double.nan,
      ]) {
        expect(
          at(83, altitude: altitude),
          MotionState.traveling,
          reason: 'altitude $altitude',
        );
      }
    });
  });

  group('a reading noisier than the thing it measures is not a claim', () {
    test('an error larger than the speed is not a claim worth making', () {
      expect(gated(1.4, 2), MotionState.stationary, reason: 'walking');
      expect(gated(20, 25), MotionState.stationary, reason: 'travelling');
      expect(
        gated(200, 300, altitude: 10000),
        MotionState.stationary,
        reason: 'flying — noise must never put a plane on a chit',
      );
    });

    test('an error exactly the size of the speed still passes', () {
      expect(gated(1.4, 1.4), MotionState.walking);
    });

    test('the gate never applies below the walking floor', () {
      expect(gated(0.2, null), MotionState.stationary);
    });
  });

  group('an accuracy nobody reported is not an accuracy of zero — ADR-078', () {
    test('a speed with no error beside it is still a speed', () {
      for (final double? unreported in <double?>[null, double.nan, 0, -1]) {
        expect(
          gated(22, unreported),
          MotionState.traveling,
          reason: 'accuracy $unreported',
        );
        expect(
          gated(1.4, unreported),
          MotionState.walking,
          reason: 'accuracy $unreported',
        );
      }
    });

    test('which is how a train read as standing still', () {
      expect(
        gated(22, 0),
        MotionState.traveling,
        reason:
            'Android reports 0.0 for an accuracy it does not have, and '
            'the old gate read that as noise — open item 18',
      );
    });

    test('a still phone is still still', () {
      expect(gated(0.1, 0), MotionState.stationary);
    });
  });

  test('every state is reachable — nothing is in the enum by accident', () {
    final Set<MotionState?> reached = <MotionState?>{
      at(null),
      at(0),
      at(1.4),
      at(20),
      at(250, altitude: 11000),
    };

    expect(reached, <MotionState?>{null, ...MotionState.values});
  });
}
