import 'package:geolocator/geolocator.dart';

import '../../domain/services/location_service.dart';

/// [LocationService] over `geolocator` — ADR-016, ADR-025, ADR-037, ADR-041.
///
/// **Nothing here decides anything.** It asks the platform, translates the
/// answer, and hands the numbers on untouched: whether a speed means *walking*
/// is `domain/motion/motion_ladder.dart`'s business, and whether a refusal is
/// worth telling the user about is the first-run screen's. This class is the
/// seam and nothing more, which is what keeps the product rules out of `data`.
///
/// **It never throws.** Every method answers the way a refusal answers —
/// `null`, or a `denied` — because ADR-007 says a signal that does not arrive
/// is simply absent, and there is nothing a caller could do with an exception
/// that it would not do with an absence.
final class GeolocatorLocationService implements LocationService {
  /// The service.
  const GeolocatorLocationService();

  /// How long one fresh fix may take before [lastKnownFix] answers instead.
  ///
  /// **Ten seconds, and that is not generous.** A high-accuracy fix is a GPS
  /// fix: cold, indoors, or under cloud it takes tens of seconds and sometimes
  /// never arrives at all. *This was 1.5s until 17 September, which is why the
  /// pin never appeared on a handset — the fix was always still coming when the
  /// timeout fired.*
  ///
  /// Nothing waits on this (ADR-044). At launch the capture runs from a
  /// post-frame callback, and at save it runs behind a row already written.
  static const Duration fixTimeout = Duration(seconds: 10);

  @override
  Future<LocationPermissionOutcome> requestPermission() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return LocationPermissionOutcome.serviceDisabled;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      // Asked only when the system would actually show something. Calling
      // `requestPermission` on a `deniedForever` returns immediately without a
      // dialog on both platforms, but going through `checkPermission` first
      // keeps that an explicit branch rather than a platform behaviour we are
      // quietly relying on.
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      return _outcomeOf(permission);
    } on Object {
      // A platform channel that fell over. Indistinguishable from a refusal
      // to everything downstream, and treated as one.
      return LocationPermissionOutcome.denied;
    }
  }

  @override
  Future<GeoFix?> currentFix() async {
    try {
      // **Never raises a dialog.** A fix asked for without permission is an
      // ordinary `null`; a capture that could prompt would put a system dialog
      // over a chit somebody was writing. The first-run screen is the only
      // thing that asks.
      if (!await _isPermitted()) return null;

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          // ADR-016: ask for precise. **A coarse grant still answers this** —
          // the platform simply returns a less exact position rather than
          // failing, so there is no fallback branch to write. Both are a
          // successful capture and neither changes the UI.
          accuracy: LocationAccuracy.high,
          timeLimit: fixTimeout,
        ),
      );

      return _fixOf(position, withKinematics: true);
    } on Object {
      // Timed out, no signal, permission revoked mid-flight, platform error.
      //
      // **The cached fix answers instead** — ADR-044. Indoors and under cloud a
      // GPS fix often never arrives at all, and a pin that needs a satellite is
      // a pin nobody ever sees. A place a few minutes old is the same place at
      // the resolution §3.6 draws it: the pin says *somewhere was recorded* and
      // stops there.
      //
      // **Its kinematics are dropped**, which is the honest half of this. A
      // stale coordinate is still true; a stale speed would say `traveling`
      // about a phone on a desk. So this recovers the pin and never the motion.
      return lastKnownFix();
    }
  }

  @override
  Future<GeoFix?> lastKnownFix() async {
    try {
      if (!await _isPermitted()) return null;

      final Position? position = await Geolocator.getLastKnownPosition();
      if (position == null) return null;

      // **The kinematics are dropped.** ADR-025 accepts a stale *place* —
      // at the resolution of five weather words across a city, an hour-old
      // coordinate is almost always the same answer. An hour-old *speed* is
      // not: it would say `traveling` about a phone sitting on a desk, which
      // is the one thing ADR-037's gate exists to prevent.
      return _fixOf(position, withKinematics: false);
    } on Object {
      return null;
    }
  }

  /// Whether a fix may be asked for at all, without prompting for anything.
  Future<bool> _isPermitted() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;

    final LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// A [Position] as a [GeoFix], with the kinematics passed on **unjudged**.
  ///
  /// `speed`, `speedAccuracy` and `altitude` are non-nullable doubles in
  /// geolocator, and the platform uses impossible values to mean *absent* —
  /// iOS reports `-1` for a speed it does not have, and some devices report
  /// `0.0` for an accuracy they do not have. Those are read in the ladder and
  /// not here, so the rule lives in exactly one place (ADR-037).
  static GeoFix _fixOf(Position position, {required bool withKinematics}) =>
      GeoFix(
        lat: position.latitude,
        lon: position.longitude,
        speed: withKinematics ? position.speed : null,
        speedAccuracy: withKinematics ? position.speedAccuracy : null,
        altitude: withKinematics ? position.altitude : null,
      );

  /// geolocator's permission, as the one `domain` knows about.
  ///
  /// Exhaustive with no `default:` — CLAUDE.md §4.1 — so a new
  /// [LocationPermission] arrives as a compile error rather than as a silent
  /// refusal.
  static LocationPermissionOutcome _outcomeOf(
    LocationPermission permission,
  ) => switch (permission) {
    LocationPermission.always ||
    LocationPermission.whileInUse => LocationPermissionOutcome.granted,
    LocationPermission.denied => LocationPermissionOutcome.denied,
    LocationPermission.deniedForever => LocationPermissionOutcome.deniedForever,
    // The platform could not answer. Not a refusal the user made, but the
    // app has spent its one ask either way (ADR-041).
    LocationPermission.unableToDetermine => LocationPermissionOutcome.denied,
  };
}
