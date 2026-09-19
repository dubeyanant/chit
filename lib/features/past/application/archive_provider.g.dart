// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'archive_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedDay)
final selectedDayProvider = SelectedDayProvider._();

final class SelectedDayProvider extends $NotifierProvider<SelectedDay, int?> {
  SelectedDayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedDayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedDayHash();

  @$internal
  @override
  SelectedDay create() => SelectedDay();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$selectedDayHash() => r'3e86df8c2a445ee14a6ad68b2748fe47913d038d';

abstract class _$SelectedDay extends $Notifier<int?> {
  int? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int?, int?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int?, int?>,
              int?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(archiveChits)
final archiveChitsProvider = ArchiveChitsProvider._();

final class ArchiveChitsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Chit>>,
          List<Chit>,
          Stream<List<Chit>>
        >
    with $FutureModifier<List<Chit>>, $StreamProvider<List<Chit>> {
  ArchiveChitsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'archiveChitsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$archiveChitsHash();

  @$internal
  @override
  $StreamProviderElement<List<Chit>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Chit>> create(Ref ref) {
    return archiveChits(ref);
  }
}

String _$archiveChitsHash() => r'49d2c4107881a5f42754ed3f7bf51e14d344257a';

@ProviderFor(ArchiveDays)
final archiveDaysProvider = ArchiveDaysProvider._();

final class ArchiveDaysProvider
    extends $NotifierProvider<ArchiveDays, List<DayGroup>?> {
  ArchiveDaysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'archiveDaysProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$archiveDaysHash();

  @$internal
  @override
  ArchiveDays create() => ArchiveDays();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<DayGroup>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<DayGroup>?>(value),
    );
  }
}

String _$archiveDaysHash() => r'97bf1df8d0008f5a47cf11f027f65fa437178e41';

abstract class _$ArchiveDays extends $Notifier<List<DayGroup>?> {
  List<DayGroup>? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<DayGroup>?, List<DayGroup>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<DayGroup>?, List<DayGroup>?>,
              List<DayGroup>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
