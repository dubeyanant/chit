// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outline_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(outlineSource)
final outlineSourceProvider = OutlineSourceProvider._();

final class OutlineSourceProvider
    extends
        $FunctionalProvider<
          AsyncValue<OutlineSource>,
          OutlineSource,
          FutureOr<OutlineSource>
        >
    with $FutureModifier<OutlineSource>, $FutureProvider<OutlineSource> {
  OutlineSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'outlineSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$outlineSourceHash();

  @$internal
  @override
  $FutureProviderElement<OutlineSource> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<OutlineSource> create(Ref ref) {
    return outlineSource(ref);
  }
}

String _$outlineSourceHash() => r'ad0129ac25ded2da791d67847aba9d350527cb35';
