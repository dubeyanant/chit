// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The location service the app runs on.
///
/// Unimplemented on purpose, for the reason `chitRepositoryProvider` is:
/// `domain` cannot import `data` (ARCHITECTURE.md §1), so the implementation
/// is supplied at the root. M2 supplies a fixed value; M3 supplies
/// `GeolocatorLocationService` and nothing else changes.

@ProviderFor(locationService)
final locationServiceProvider = LocationServiceProvider._();

/// The location service the app runs on.
///
/// Unimplemented on purpose, for the reason `chitRepositoryProvider` is:
/// `domain` cannot import `data` (ARCHITECTURE.md §1), so the implementation
/// is supplied at the root. M2 supplies a fixed value; M3 supplies
/// `GeolocatorLocationService` and nothing else changes.

final class LocationServiceProvider
    extends
        $FunctionalProvider<LocationService, LocationService, LocationService>
    with $Provider<LocationService> {
  /// The location service the app runs on.
  ///
  /// Unimplemented on purpose, for the reason `chitRepositoryProvider` is:
  /// `domain` cannot import `data` (ARCHITECTURE.md §1), so the implementation
  /// is supplied at the root. M2 supplies a fixed value; M3 supplies
  /// `GeolocatorLocationService` and nothing else changes.
  LocationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationServiceHash();

  @$internal
  @override
  $ProviderElement<LocationService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocationService create(Ref ref) {
    return locationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationService>(value),
    );
  }
}

String _$locationServiceHash() => r'b3b041c2acf19974684ad96c3d71848eba32461f';
