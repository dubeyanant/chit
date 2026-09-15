import '../../domain/services/location_service.dart';

/// One fix, always, and no permission prompt. **M2 only.**
///
/// It exists so that M2's open chit can draw the pin of BEHAVIOUR.md §3.6
/// before M3 writes `GeolocatorLocationService`. Only `hasLocation` is ever
/// read by a screen — the coordinate is stored and never displayed — so the
/// value matters to nothing except that it is whole.
///
/// **M3 deletes this file.**
final class FixedLocationService implements LocationService {
  /// Always answers [fix].
  const FixedLocationService({this.fix = greenwich});

  /// The Royal Observatory, Greenwich — 0° longitude.
  ///
  /// A landmark rather than a plausible address, and chosen to be recognisable
  /// as a stand-in the moment anyone reads a row: nothing about M2's rows
  /// should look like a place a person was. `(0, 0)` would have done the same
  /// job and reads as a bug instead of as a placeholder.
  static const GeoFix greenwich = (lat: 51.4769, lon: -0.0005);

  /// Where it says the device is.
  final GeoFix? fix;

  @override
  Future<GeoFix?> currentFix() async => fix;
}
