part of 'chit_repository.dart';

@ProviderFor(chitRepository)
final chitRepositoryProvider = ChitRepositoryProvider._();

final class ChitRepositoryProvider
    extends $FunctionalProvider<ChitRepository, ChitRepository, ChitRepository>
    with $Provider<ChitRepository> {
  ChitRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chitRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chitRepositoryHash();

  @$internal
  @override
  $ProviderElement<ChitRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ChitRepository create(Ref ref) {
    return chitRepository(ref);
  }

  Override overrideWithValue(ChitRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChitRepository>(value),
    );
  }
}

String _$chitRepositoryHash() => r'0f3f676449e332479773dc2d32f18769881428cf';
