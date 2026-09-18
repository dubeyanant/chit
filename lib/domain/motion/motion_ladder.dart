import '../models/motion_state.dart';

abstract final class MotionLadder {
  static const double walkingFloor = 0.7;

  static const double travelingFloor = 3.0;

  static const double flyingFloor = 55;

  static const double flyingAltitudeFloor = 2000;

  static MotionState? from({
    required double? speed,
    required double? speedAccuracy,
    required double? altitude,
  }) {
    if (speed == null || speed.isNaN || speed < 0) return null;

    if (speed < walkingFloor) return MotionState.stationary;

    if (_isNoise(speed: speed, speedAccuracy: speedAccuracy)) {
      return MotionState.stationary;
    }

    if (speed < travelingFloor) return MotionState.walking;
    if (speed < flyingFloor) return MotionState.traveling;

    final bool high =
        altitude != null && !altitude.isNaN && altitude > flyingAltitudeFloor;

    return high ? MotionState.flying : MotionState.traveling;
  }

  static bool _isNoise({
    required double speed,
    required double? speedAccuracy,
  }) {
    if (speedAccuracy == null || speedAccuracy.isNaN) return false;
    if (speedAccuracy <= 0) return false;

    return speedAccuracy > speed;
  }
}
