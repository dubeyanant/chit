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
    extends $NotifierProvider<ArchiveDays, List<ArchiveDay>?> {
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
  Override overrideWithValue(List<ArchiveDay>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ArchiveDay>?>(value),
    );
  }
}

String _$archiveDaysHash() => r'a547e67c2330a9c39d6884d987d01ccc6a294871';

abstract class _$ArchiveDays extends $Notifier<List<ArchiveDay>?> {
  List<ArchiveDay>? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<ArchiveDay>?, List<ArchiveDay>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<ArchiveDay>?, List<ArchiveDay>?>,
              List<ArchiveDay>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
