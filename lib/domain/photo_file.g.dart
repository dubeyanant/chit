// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_file.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(photoFile)
final photoFileProvider = PhotoFileFamily._();

final class PhotoFileProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  PhotoFileProvider._({
    required PhotoFileFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'photoFileProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$photoFileHash();

  @override
  String toString() {
    return r'photoFileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as String;
    return photoFile(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PhotoFileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$photoFileHash() => r'7026739a870af6342bf4e22fee05e6750cd7aeb2';

final class PhotoFileFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, String> {
  PhotoFileFamily._()
    : super(
        retry: null,
        name: r'photoFileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PhotoFileProvider call(String path) =>
      PhotoFileProvider._(argument: path, from: this);

  @override
  String toString() => r'photoFileProvider';
}
