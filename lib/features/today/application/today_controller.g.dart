part of 'today_controller.dart';

@ProviderFor(today)
final todayProvider = TodayProvider._();

final class TodayProvider
    extends $FunctionalProvider<DateTime, DateTime, DateTime>
    with $Provider<DateTime> {
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

  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$todayHash() => r'c32ca666fb7b6bce884b37e811094ef0a76e689c';

@ProviderFor(todayLocalDay)
final todayLocalDayProvider = TodayLocalDayProvider._();

final class TodayLocalDayProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
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

  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$todayLocalDayHash() => r'45c6203813b619b46bbc3c2c47252cd8bee4acaa';

@ProviderFor(todayChits)
final todayChitsProvider = TodayChitsProvider._();

final class TodayChitsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Chit>>,
          List<Chit>,
          Stream<List<Chit>>
        >
    with $FutureModifier<List<Chit>>, $StreamProvider<List<Chit>> {
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
