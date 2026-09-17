// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'archive_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The day the archive is filtered to, or null for every day.
///
/// Tapping a tile selects it and tapping it again clears it — BEHAVIOUR.md
/// §4.2. **It resets when the month changes**, by watching the month rather
/// than by anybody remembering to clear it: a selection is a tile on the grid
/// being shown, and once that grid is another month's there is no tile for it
/// to be.

@ProviderFor(SelectedDay)
final selectedDayProvider = SelectedDayProvider._();

/// The day the archive is filtered to, or null for every day.
///
/// Tapping a tile selects it and tapping it again clears it — BEHAVIOUR.md
/// §4.2. **It resets when the month changes**, by watching the month rather
/// than by anybody remembering to clear it: a selection is a tile on the grid
/// being shown, and once that grid is another month's there is no tile for it
/// to be.
final class SelectedDayProvider extends $NotifierProvider<SelectedDay, int?> {
  /// The day the archive is filtered to, or null for every day.
  ///
  /// Tapping a tile selects it and tapping it again clears it — BEHAVIOUR.md
  /// §4.2. **It resets when the month changes**, by watching the month rather
  /// than by anybody remembering to clear it: a selection is a tile on the grid
  /// being shown, and once that grid is another month's there is no tile for it
  /// to be.
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

/// The day the archive is filtered to, or null for every day.
///
/// Tapping a tile selects it and tapping it again clears it — BEHAVIOUR.md
/// §4.2. **It resets when the month changes**, by watching the month rather
/// than by anybody remembering to clear it: a selection is a tile on the grid
/// being shown, and once that grid is another month's there is no tile for it
/// to be.

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

/// How many pages of the archive have been asked for.
///
/// The archive is paged (DATA-MODEL.md §4) and this is the only state paging
/// needs: the screen asks for one more as the reader nears the end, and the
/// query widens. It never narrows again while the tab is open, which is what
/// a reader scrolling back up expects.

@ProviderFor(ArchivePages)
final archivePagesProvider = ArchivePagesProvider._();

/// How many pages of the archive have been asked for.
///
/// The archive is paged (DATA-MODEL.md §4) and this is the only state paging
/// needs: the screen asks for one more as the reader nears the end, and the
/// query widens. It never narrows again while the tab is open, which is what
/// a reader scrolling back up expects.
final class ArchivePagesProvider extends $NotifierProvider<ArchivePages, int> {
  /// How many pages of the archive have been asked for.
  ///
  /// The archive is paged (DATA-MODEL.md §4) and this is the only state paging
  /// needs: the screen asks for one more as the reader nears the end, and the
  /// query widens. It never narrows again while the tab is open, which is what
  /// a reader scrolling back up expects.
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

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$archivePagesHash() => r'd50a8e349b3238de55f7cffd4a827122a5216323';

/// How many pages of the archive have been asked for.
///
/// The archive is paged (DATA-MODEL.md §4) and this is the only state paging
/// needs: the screen asks for one more as the reader nears the end, and the
/// query widens. It never narrows again while the tab is open, which is what
/// a reader scrolling back up expects.

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

/// How many chits the archive is currently asking for.

@ProviderFor(archiveLimit)
final archiveLimitProvider = ArchiveLimitProvider._();

/// How many chits the archive is currently asking for.

final class ArchiveLimitProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// How many chits the archive is currently asking for.
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

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$archiveLimitHash() => r'1a0d943d66caf4f29f0bc1ac9331a962d3d561f7';

/// The archive's chits: every day, paged — or one day, when one is selected.
///
/// Two queries behind one reading, and the selection decides which. A
/// filtered archive is `watchDay`, the same query Today's thread runs, because
/// *one day's chits, newest first* is one question however it was asked.

@ProviderFor(archiveChits)
final archiveChitsProvider = ArchiveChitsProvider._();

/// The archive's chits: every day, paged — or one day, when one is selected.
///
/// Two queries behind one reading, and the selection decides which. A
/// filtered archive is `watchDay`, the same query Today's thread runs, because
/// *one day's chits, newest first* is one question however it was asked.

final class ArchiveChitsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Chit>>,
          List<Chit>,
          Stream<List<Chit>>
        >
    with $FutureModifier<List<Chit>>, $StreamProvider<List<Chit>> {
  /// The archive's chits: every day, paged — or one day, when one is selected.
  ///
  /// Two queries behind one reading, and the selection decides which. A
  /// filtered archive is `watchDay`, the same query Today's thread runs, because
  /// *one day's chits, newest first* is one question however it was asked.
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

/// The archive grouped into days, newest first — null until the query has
/// first answered, and after that **the last answer, held while the next is
/// in flight** (ADR-049), for the reasons [drawnMonthProvider] gives.
///
/// Three things swap the query under this — selecting a tile, clearing it,
/// and changing the month, which clears it — and each of them blanked the
/// archive for the frames the new query took until the hold was added.

@ProviderFor(ArchiveDays)
final archiveDaysProvider = ArchiveDaysProvider._();

/// The archive grouped into days, newest first — null until the query has
/// first answered, and after that **the last answer, held while the next is
/// in flight** (ADR-049), for the reasons [drawnMonthProvider] gives.
///
/// Three things swap the query under this — selecting a tile, clearing it,
/// and changing the month, which clears it — and each of them blanked the
/// archive for the frames the new query took until the hold was added.
final class ArchiveDaysProvider
    extends $NotifierProvider<ArchiveDays, List<ArchiveDay>?> {
  /// The archive grouped into days, newest first — null until the query has
  /// first answered, and after that **the last answer, held while the next is
  /// in flight** (ADR-049), for the reasons [drawnMonthProvider] gives.
  ///
  /// Three things swap the query under this — selecting a tile, clearing it,
  /// and changing the month, which clears it — and each of them blanked the
  /// archive for the frames the new query took until the hold was added.
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

/// The archive grouped into days, newest first — null until the query has
/// first answered, and after that **the last answer, held while the next is
/// in flight** (ADR-049), for the reasons [drawnMonthProvider] gives.
///
/// Three things swap the query under this — selecting a tile, clearing it,
/// and changing the month, which clears it — and each of them blanked the
/// archive for the frames the new query took until the hold was added.

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
