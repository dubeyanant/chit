// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The moment Today is drawn for.
///
/// **The clock is read here and nowhere else on this screen.** The date line
/// and the thread are two readings of one instant, so a provider rather than a
/// `clock.now()` in each: two reads a millisecond apart are two different
/// answers at midnight, and the screen would show one day above a thread of
/// another. It also keeps the read count honest, which is what ADR-021's test
/// counts.

@ProviderFor(today)
final todayProvider = TodayProvider._();

/// The moment Today is drawn for.
///
/// **The clock is read here and nowhere else on this screen.** The date line
/// and the thread are two readings of one instant, so a provider rather than a
/// `clock.now()` in each: two reads a millisecond apart are two different
/// answers at midnight, and the screen would show one day above a thread of
/// another. It also keeps the read count honest, which is what ADR-021's test
/// counts.

final class TodayProvider
    extends $FunctionalProvider<DateTime, DateTime, DateTime>
    with $Provider<DateTime> {
  /// The moment Today is drawn for.
  ///
  /// **The clock is read here and nowhere else on this screen.** The date line
  /// and the thread are two readings of one instant, so a provider rather than a
  /// `clock.now()` in each: two reads a millisecond apart are two different
  /// answers at midnight, and the screen would show one day above a thread of
  /// another. It also keeps the read count honest, which is what ADR-021's test
  /// counts.
  TodayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayHash();

  @$internal
  @override
  $ProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateTime create(Ref ref) {
    return today(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$todayHash() => r'0a84e972b397da46c700afe99242799c1828a51b';

/// The local day Today is showing, as `yyyymmdd`.
///
/// ADR-006's one conversion, off [today] so it cannot disagree with the date
/// line above it.

@ProviderFor(todayLocalDay)
final todayLocalDayProvider = TodayLocalDayProvider._();

/// The local day Today is showing, as `yyyymmdd`.
///
/// ADR-006's one conversion, off [today] so it cannot disagree with the date
/// line above it.

final class TodayLocalDayProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// The local day Today is showing, as `yyyymmdd`.
  ///
  /// ADR-006's one conversion, off [today] so it cannot disagree with the date
  /// line above it.
  TodayLocalDayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayLocalDayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayLocalDayHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return todayLocalDay(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$todayLocalDayHash() => r'45c6203813b619b46bbc3c2c47252cd8bee4acaa';

/// Today's chits, newest first — BEHAVIOUR.md §4.1.
///
/// A stream off the repository rather than a fetch, which is what makes
/// DESIGN-SYSTEM.md §7's *the two tabs never disagree* true by construction:
/// saving writes one row and every reader of that row re-emits. Nothing here
/// keeps anything in step, because nothing here has a copy to keep.

@ProviderFor(todayChits)
final todayChitsProvider = TodayChitsProvider._();

/// Today's chits, newest first — BEHAVIOUR.md §4.1.
///
/// A stream off the repository rather than a fetch, which is what makes
/// DESIGN-SYSTEM.md §7's *the two tabs never disagree* true by construction:
/// saving writes one row and every reader of that row re-emits. Nothing here
/// keeps anything in step, because nothing here has a copy to keep.

final class TodayChitsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Chit>>,
          List<Chit>,
          Stream<List<Chit>>
        >
    with $FutureModifier<List<Chit>>, $StreamProvider<List<Chit>> {
  /// Today's chits, newest first — BEHAVIOUR.md §4.1.
  ///
  /// A stream off the repository rather than a fetch, which is what makes
  /// DESIGN-SYSTEM.md §7's *the two tabs never disagree* true by construction:
  /// saving writes one row and every reader of that row re-emits. Nothing here
  /// keeps anything in step, because nothing here has a copy to keep.
  TodayChitsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayChitsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayChitsHash();

  @$internal
  @override
  $StreamProviderElement<List<Chit>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Chit>> create(Ref ref) {
    return todayChits(ref);
  }
}

String _$todayChitsHash() => r'1a90bb40da5a6220e53aecd785ff87f3ab293655';
