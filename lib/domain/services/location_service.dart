import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_service.g.dart';

/// A position fix: both halves or neither.
///
/// A record rather than two nullable doubles, because `AmbientStamp` asserts
/// that a coordinate is whole and half a fix is not a place. Making it one
/// value is what stops that assert ever having to fire — CLAUDE.md §4.1
/// prefers a type that cannot be wrong to a validation that runs.
typedef GeoFix = ({double lat, double lon});

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
  Future<GeoFix?> currentFix();
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
