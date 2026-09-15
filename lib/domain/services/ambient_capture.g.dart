// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ambient_capture.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The capture the composer opens a chit with.

@ProviderFor(ambientCapture)
final ambientCaptureProvider = AmbientCaptureProvider._();

/// The capture the composer opens a chit with.

final class AmbientCaptureProvider
    extends $FunctionalProvider<AmbientCapture, AmbientCapture, AmbientCapture>
    with $Provider<AmbientCapture> {
  /// The capture the composer opens a chit with.
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

String _$ambientCaptureHash() => r'0b65e3cf28d70d7df53a6b4c75815a6ad1b22eb3';
