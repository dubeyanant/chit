part of 'archive_provider.dart';

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

@ProviderFor(ArchivePages)
final archivePagesProvider = ArchivePagesProvider._();

final class ArchivePagesProvider extends $NotifierProvider<ArchivePages, int> {
  ArchivePagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'archivePagesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$archivePagesHash();

  @$internal
  @override
  ArchivePages create() => ArchivePages();

  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$archivePagesHash() => r'd50a8e349b3238de55f7cffd4a827122a5216323';

abstract class _$ArchivePages extends $Notifier<int> {
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

@ProviderFor(archiveLimit)
final archiveLimitProvider = ArchiveLimitProvider._();

final class ArchiveLimitProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  ArchiveLimitProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'archiveLimitProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$archiveLimitHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return archiveLimit(ref);
  }

  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$archiveLimitHash() => r'1a0d943d66caf4f29f0bc1ac9331a962d3d561f7';

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

String _$archiveChitsHash() => r'd845f20195730b5072c5bd64feeee0a6b51c0372';

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
