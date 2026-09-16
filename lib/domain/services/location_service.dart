import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_service.g.dart';

/// One reading of where the device is and how fast it is going.
///
/// **A class rather than two nullable doubles**, because `AmbientStamp`
/// asserts that a coordinate is whole and half a fix is not a place. Making it
/// one value is what stops that assert ever having to fire — CLAUDE.md §4.1
/// prefers a type that cannot be wrong to a validation that runs.
///
/// *It used to be a record, `({double lat, double lon})`.* It stopped being
/// one when motion arrived (ADR-037): a record cannot give a field a default,
/// so every caller would have had to spell out three nullable kinematics it
/// does not care about, and a fix is now a thing with optional parts rather
/// than a pair.
///
/// **[lat] and [lon] are the place; the rest is the movement.** They arrive on
/// one platform call and are separated here because they answer different
/// questions: the place draws the pin of BEHAVIOUR.md §3.6, and the movement
/// goes through `domain/motion/motion_ladder.dart` and draws nothing on its
/// own.
@immutable
final class GeoFix {
  /// A fix. The kinematics are absent unless the platform supplied them.
  const GeoFix({
    required this.lat,
    required this.lon,
    this.speed,
    this.speedAccuracy,
    this.altitude,
  });

  /// Latitude. Stored, never displayed.
  final double lat;

  /// Longitude. Stored, never displayed.
  final double lon;

  /// Ground speed in **metres per second**, or `null` if none was reported.
  ///
  /// Negative and NaN values reach the ladder untouched and are refused there
  /// — iOS reports -1 for a speed it does not have, and deciding that here as
  /// well would put the same rule in two places.
  final double? speed;

  /// The error on [speed], in metres per second.
  ///
  /// ADR-037 will not claim movement without it. Some platforms report `0.0`
  /// for an accuracy they do not have, which the ladder reads as unknown.
  final double? speedAccuracy;

  /// Metres above sea level, or `null`. Separates a plane from a fast train.
  final double? altitude;

  @override
  bool operator ==(Object other) =>
      other is GeoFix &&
      other.lat == lat &&
      other.lon == lon &&
      other.speed == speed &&
      other.speedAccuracy == speedAccuracy &&
      other.altitude == altitude;

  @override
  int get hashCode => Object.hash(lat, lon, speed, speedAccuracy, altitude);

  @override
  String toString() =>
      'GeoFix($lat, $lon, speed: $speed ±$speedAccuracy, altitude: $altitude)';
}

/// How asking for location turned out — **ADR-041**.
///
/// It exists so that `features` can put a permission dialog on screen without
/// importing geolocator (ARCHITECTURE.md §1), and so a fake can refuse the way
/// the real one does — CLAUDE.md §4.1's Liskov rule, which is the only thing
/// keeping the first-run screen's tests honest.
enum LocationPermissionOutcome {
  /// The fix will arrive. Precise or coarse — ADR-016 accepts both.
  granted,

  /// Refused, and the system would let us ask again. **We do not.**
  denied,

  /// Refused, and the system will not show the dialog again.
  deniedForever,

  /// Location is switched off on the device. Not a refusal, and not something
  /// the app can fix by asking.
  serviceDisabled,
}

/// Where the device is, when it can say (ADR-016).
///
/// Asked for at **high accuracy, with the coarse fix accepted when that is all
/// the user granted**. Both outcomes are a successful capture and neither
/// changes the UI: BEHAVIOUR.md §3.6 shows a pin and never a name.
///
/// **Best-effort, and it never blocks** (ADR-007). A refused permission, a
/// disabled service and a slow fix are all the same answer here — `null`, and
/// a `null` is not drawn.
abstract interface class LocationService {
  /// A fix, or `null` if none arrived.
  ///
  /// Returning `null` is the ordinary outcome, not the error one: it is what
  /// a refused permission looks like, and the composer is not allowed to care.
  /// An implementation should not throw, and `AmbientCapture` does not trust
  /// it not to.
  ///
  /// **One call answers two signals** — the place and the motion (ADR-037).
  /// That is the whole reason motion costs no new permission and no new
  /// dialog: it is a second reading off a call already being made, rather than
  /// a third signal beside ADR-007's two.
  Future<GeoFix?> currentFix();

  /// Raises the system permission dialog, once — **ADR-041**.
  ///
  /// Called by the first-run screen and by nothing else. [currentFix] never
  /// calls it: a fix asked for without permission is simply `null`, which is
  /// the ordinary ADR-007 outcome, and a capture that could raise a dialog
  /// would put a system prompt over a chit somebody was writing.
  ///
  /// Never throws. A platform that fails to answer is
  /// [LocationPermissionOutcome.denied], because from the app's side there is
  /// nothing to tell apart.
  Future<LocationPermissionOutcome> requestPermission();
}

/// The location service the app runs on.
///
/// Unimplemented on purpose, for the reason `chitRepositoryProvider` is:
/// `domain` cannot import `data` (ARCHITECTURE.md §1), so the implementation
/// is supplied at the root. M2 supplies a fixed value; M3 supplies
/// `GeolocatorLocationService` and nothing else changes.
@Riverpod(keepAlive: true)
LocationService locationService(Ref ref) => throw UnimplementedError(
  'locationServiceProvider is overridden at the root — see main.dart',
);
