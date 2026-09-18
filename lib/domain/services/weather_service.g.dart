// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(weatherService)
final weatherServiceProvider = WeatherServiceProvider._();

final class WeatherServiceProvider
    extends $FunctionalProvider<WeatherService, WeatherService, WeatherService>
    with $Provider<WeatherService> {
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
