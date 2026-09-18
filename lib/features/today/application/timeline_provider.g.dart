// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(timelineQueryWindow)
final timelineQueryWindowProvider = TimelineQueryWindowProvider._();

final class TimelineQueryWindowProvider
    extends $FunctionalProvider<TimelineWindow, TimelineWindow, TimelineWindow>
    with $Provider<TimelineWindow> {
  TimelineQueryWindowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timelineQueryWindowProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timelineQueryWindowHash();

  @$internal
  @override
  $ProviderElement<TimelineWindow> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TimelineWindow create(Ref ref) {
    return timelineQueryWindow(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TimelineWindow value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TimelineWindow>(value),
    );
  }
}

String _$timelineQueryWindowHash() =>
    r'ce531ecba0b6f6d164b7bbd5152836ead610b68f';

@ProviderFor(timelineNow)
final timelineNowProvider = TimelineNowProvider._();

final class TimelineNowProvider
    extends $FunctionalProvider<DateTime, DateTime, DateTime>
    with $Provider<DateTime> {
  TimelineNowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timelineNowProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timelineNowHash();

  @$internal
  @override
  $ProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateTime create(Ref ref) {
    return timelineNow(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$timelineNowHash() => r'bcb59f5876eed8c85129e8a57a244513fe3f5306';

@ProviderFor(timelineChits)
final timelineChitsProvider = TimelineChitsProvider._();

final class TimelineChitsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Chit>>,
          List<Chit>,
          Stream<List<Chit>>
        >
    with $FutureModifier<List<Chit>>, $StreamProvider<List<Chit>> {
  TimelineChitsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timelineChitsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timelineChitsHash();

  @$internal
  @override
  $StreamProviderElement<List<Chit>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Chit>> create(Ref ref) {
    return timelineChits(ref);
  }
}

String _$timelineChitsHash() => r'89437c0eac1feede18f93335c5e6604c2d1ced0e';

@ProviderFor(timelineWindow)
final timelineWindowProvider = TimelineWindowProvider._();

final class TimelineWindowProvider
    extends $FunctionalProvider<TimelineWindow, TimelineWindow, TimelineWindow>
    with $Provider<TimelineWindow> {
  TimelineWindowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timelineWindowProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timelineWindowHash();

  @$internal
  @override
  $ProviderElement<TimelineWindow> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TimelineWindow create(Ref ref) {
    return timelineWindow(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TimelineWindow value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TimelineWindow>(value),
    );
  }
}

String _$timelineWindowHash() => r'07c495711a4316139838756c6fa86176aed7cdac';
