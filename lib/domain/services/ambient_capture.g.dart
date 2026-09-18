// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ambient_capture.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ambientCapture)
final ambientCaptureProvider = AmbientCaptureProvider._();

final class AmbientCaptureProvider
    extends $FunctionalProvider<AmbientCapture, AmbientCapture, AmbientCapture>
    with $Provider<AmbientCapture> {
  AmbientCaptureProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ambientCaptureProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ambientCaptureHash();

  @$internal
  @override
  $ProviderElement<AmbientCapture> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AmbientCapture create(Ref ref) {
    return ambientCapture(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AmbientCapture value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AmbientCapture>(value),
    );
  }
}

String _$ambientCaptureHash() => r'8cad0626ddb1e9612e71da6c39abc1f80bf0b079';
