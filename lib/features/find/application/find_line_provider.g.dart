// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_line_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FindVisit)
final findVisitProvider = FindVisitProvider._();

final class FindVisitProvider extends $NotifierProvider<FindVisit, int> {
  FindVisitProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'findVisitProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$findVisitHash();

  @$internal
  @override
  FindVisit create() => FindVisit();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$findVisitHash() => r'838fc151f4f5cd41497260b6dc897938828b4b84';

abstract class _$FindVisit extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(findLine)
final findLineProvider = FindLineProvider._();

final class FindLineProvider extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  FindLineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'findLineProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$findLineHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return findLine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$findLineHash() => r'd916e8a6a07966a979d3200d34011115a25bb92f';
