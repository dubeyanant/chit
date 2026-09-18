part of 'ambient_capture.dart';

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

  Override overrideWithValue(AmbientCapture value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AmbientCapture>(value),
    );
  }
}

String _$ambientCaptureHash() => r'8cad0626ddb1e9612e71da6c39abc1f80bf0b079';
