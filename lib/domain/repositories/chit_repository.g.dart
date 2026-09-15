// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chit_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The repository the app runs on.
///
/// Unimplemented on purpose. `domain` cannot import `data` (ARCHITECTURE.md
/// §1), so the implementation is supplied where the two layers are allowed to
/// meet: the `ProviderScope` at the root, in `main.dart`, and a
/// `ProviderContainer` in a test.

@ProviderFor(chitRepository)
final chitRepositoryProvider = ChitRepositoryProvider._();

/// The repository the app runs on.
///
/// Unimplemented on purpose. `domain` cannot import `data` (ARCHITECTURE.md
/// §1), so the implementation is supplied where the two layers are allowed to
/// meet: the `ProviderScope` at the root, in `main.dart`, and a
/// `ProviderContainer` in a test.

final class ChitRepositoryProvider
    extends $FunctionalProvider<ChitRepository, ChitRepository, ChitRepository>
    with $Provider<ChitRepository> {
  /// The repository the app runs on.
  ///
  /// Unimplemented on purpose. `domain` cannot import `data` (ARCHITECTURE.md
  /// §1), so the implementation is supplied where the two layers are allowed to
  /// meet: the `ProviderScope` at the root, in `main.dart`, and a
  /// `ProviderContainer` in a test.
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

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChitRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChitRepository>(value),
    );
  }
}

String _$chitRepositoryHash() => r'0f3f676449e332479773dc2d32f18769881428cf';
