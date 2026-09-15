// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The weather service the app runs on.
///
/// Unimplemented on purpose, for the reason `chitRepositoryProvider` is:
/// `domain` cannot import `data` (ARCHITECTURE.md §1), so the implementation
/// is supplied at the root. M2 supplies a fixed value; M3 supplies
/// `OpenMeteoService` and nothing else changes.

@ProviderFor(weatherService)
final weatherServiceProvider = WeatherServiceProvider._();

/// The weather service the app runs on.
///
/// Unimplemented on purpose, for the reason `chitRepositoryProvider` is:
/// `domain` cannot import `data` (ARCHITECTURE.md §1), so the implementation
/// is supplied at the root. M2 supplies a fixed value; M3 supplies
/// `OpenMeteoService` and nothing else changes.

final class WeatherServiceProvider
    extends $FunctionalProvider<WeatherService, WeatherService, WeatherService>
    with $Provider<WeatherService> {
  /// The weather service the app runs on.
  ///
  /// Unimplemented on purpose, for the reason `chitRepositoryProvider` is:
  /// `domain` cannot import `data` (ARCHITECTURE.md §1), so the implementation
  /// is supplied at the root. M2 supplies a fixed value; M3 supplies
  /// `OpenMeteoService` and nothing else changes.
  WeatherServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weatherServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weatherServiceHash();

  @$internal
  @override
  $ProviderElement<WeatherService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WeatherService create(Ref ref) {
    return weatherService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WeatherService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WeatherService>(value),
    );
  }
}

String _$weatherServiceHash() => r'24bde0e1d05aa96785a7a22268b2ebfecc38f440';
