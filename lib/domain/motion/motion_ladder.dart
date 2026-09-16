import '../models/motion_state.dart';

/// Speed to a `MotionState` — the whole of motion's arithmetic, **ADR-037**.
///
/// One pure function, no I/O and no Flutter, for the reason
/// `domain/weather/wmo_mapping.dart` is: the thresholds are a product decision
/// rather than a detail of geolocator, and under ADR-031 this is where a
/// milestone's correctness can actually live.
///
/// **Motion is read off the position fix the pin already needs** (ADR-037).
/// An accelerometer measures acceleration, and recovering speed from it needs
/// a double integration whose error compounds uselessly within seconds; a
/// gyroscope measures rotation and says nothing about travel at all. Speed
/// comes from GPS Doppler, which arrives on the same fix, so motion is a
/// second reading off one call rather than a third signal.
abstract final class MotionLadder {
  /// **0.7 m/s** — 2.5 km/h. Below this the phone is [MotionState.stationary].
  ///
  /// Under a walking pace on purpose: a fix drifts by a metre or two while
  /// sitting on a desk, and the floor has to sit above that drift.
  static const double walkingFloor = 0.7;

  /// **3.0 m/s** — 11 km/h. A brisk run tops out near here, and nothing on
  /// foot sustains more.
  static const double travelingFloor = 3.0;

  /// **55 m/s** — 200 km/h. Faster than any road and faster than all but the
  /// high-speed railways, which [flyingAltitudeFloor] is here to exclude.
  static const double flyingFloor = 55;

  /// **2000 m.** Above [flyingFloor], altitude is what separates a plane from
  /// a Shinkansen. A train at 300 km/h is not at two kilometres.
  ///
  /// An unknown altitude answers [MotionState.traveling], because the quieter
  /// of two claims is the right one to make when the evidence is missing.
  static const double flyingAltitudeFloor = 2000;

  /// [MotionState] for one fix's kinematics, or `null` if there was no reading.
  ///
  /// `null` means *no speed arrived* — no fix, no permission, or a platform
  /// that reported an invalid one — and it is the ordinary ADR-007 outcome
  /// rather than the error one. It is not drawn.
  ///
  /// **An uncertain reading degrades to [MotionState.stationary]**, which is
  /// the state that draws nothing. Claiming anything above stationary needs
  /// [speedAccuracy] to be no larger than [speed] itself — the error smaller
  /// than the thing measured — and without that the answer falls back rather
  /// than guessing upward. This is CLAUDE.md §4.1's *degrade quietly* applied
  /// to a signal: noise can slow a chit down, and it can never put a plane
  /// on one.
  static MotionState? from({
    required double? speed,
    required double? speedAccuracy,
    required double? altitude,
  }) {
    // Both platforms report a negative to mean *no valid reading* — iOS
    // `CLLocation.speed` is -1 when it has none — and a NaN arrives from a
    // malformed platform message. Neither is a slow phone.
    if (speed == null || speed.isNaN || speed < 0) return null;

    if (speed < walkingFloor) return MotionState.stationary;

    if (!_isUsable(speed: speed, speedAccuracy: speedAccuracy)) {
      return MotionState.stationary;
    }

    if (speed < travelingFloor) return MotionState.walking;
    if (speed < flyingFloor) return MotionState.traveling;

    final bool high =
        altitude != null && !altitude.isNaN && altitude > flyingAltitudeFloor;

    return high ? MotionState.flying : MotionState.traveling;
  }

  /// Whether [speed] is worth believing.
  ///
  /// **Zero is unknown, not perfect.** Some platforms report `0.0` for an
  /// accuracy they do not have, and read the other way round that is the most
  /// confident number there is — which would invert this gate exactly when it
  /// matters. A missing accuracy and an impossible one are the same answer
  /// here: no.
  static bool _isUsable({
    required double speed,
    required double? speedAccuracy,
  }) {
    if (speedAccuracy == null || speedAccuracy.isNaN) return false;
    if (speedAccuracy <= 0) return false;

    return speedAccuracy <= speed;
  }
}
