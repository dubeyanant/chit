// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The three days the timeline **asks the database for**.
///
/// Off [todayProvider] rather than off the clock, so the strip, the date line
/// above it and the thread below it are three readings of one instant. It
/// therefore slides on its own when the day does: `todayProvider` re-reads the
/// clock at midnight and everything derived from it follows (ADR-033).
///
/// This is always [TimelineWindow.maxDays] wide. What gets **drawn** is
/// [timelineWindowProvider], which can be narrower — and which cannot be the
/// query window, because it depends on the answer.

@ProviderFor(timelineQueryWindow)
final timelineQueryWindowProvider = TimelineQueryWindowProvider._();

/// The three days the timeline **asks the database for**.
///
/// Off [todayProvider] rather than off the clock, so the strip, the date line
/// above it and the thread below it are three readings of one instant. It
/// therefore slides on its own when the day does: `todayProvider` re-reads the
/// clock at midnight and everything derived from it follows (ADR-033).
///
/// This is always [TimelineWindow.maxDays] wide. What gets **drawn** is
/// [timelineWindowProvider], which can be narrower — and which cannot be the
/// query window, because it depends on the answer.

final class TimelineQueryWindowProvider
    extends $FunctionalProvider<TimelineWindow, TimelineWindow, TimelineWindow>
    with $Provider<TimelineWindow> {
  /// The three days the timeline **asks the database for**.
  ///
  /// Off [todayProvider] rather than off the clock, so the strip, the date line
  /// above it and the thread below it are three readings of one instant. It
  /// therefore slides on its own when the day does: `todayProvider` re-reads the
  /// clock at midnight and everything derived from it follows (ADR-033).
  ///
  /// This is always [TimelineWindow.maxDays] wide. What gets **drawn** is
  /// [timelineWindowProvider], which can be narrower — and which cannot be the
  /// query window, because it depends on the answer.
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

/// Where the tick at now is drawn — **re-read on every save** (ADR-066).
///
/// The strip is static by design (§4.1: nothing on it moves), and
/// [todayProvider] is read once per screen and again at midnight (ADR-033) —
/// so a chit saved twenty minutes after launch used to land *ahead* of the
/// tick at now, which then read as a mark in the future. This re-reads the
/// clock whenever the rows under the strip change, which is exactly when §4.1
/// says the strip may change: on a save, and on the day turning.
///
/// **A second clock read on the screen, and the one exception to
/// ARCHITECTURE.md §3's one-read rule.** It cannot disagree with the date line
/// about *which day* — the window it is drawn into still comes off
/// [todayProvider] — only about the minute, which is the point. At the instant
/// after midnight, before the rollover timer fires, it falls outside the window
/// and the tick is simply not drawn for those milliseconds.

@ProviderFor(timelineNow)
final timelineNowProvider = TimelineNowProvider._();

/// Where the tick at now is drawn — **re-read on every save** (ADR-066).
///
/// The strip is static by design (§4.1: nothing on it moves), and
/// [todayProvider] is read once per screen and again at midnight (ADR-033) —
/// so a chit saved twenty minutes after launch used to land *ahead* of the
/// tick at now, which then read as a mark in the future. This re-reads the
/// clock whenever the rows under the strip change, which is exactly when §4.1
/// says the strip may change: on a save, and on the day turning.
///
/// **A second clock read on the screen, and the one exception to
/// ARCHITECTURE.md §3's one-read rule.** It cannot disagree with the date line
/// about *which day* — the window it is drawn into still comes off
/// [todayProvider] — only about the minute, which is the point. At the instant
/// after midnight, before the rollover timer fires, it falls outside the window
/// and the tick is simply not drawn for those milliseconds.

final class TimelineNowProvider
    extends $FunctionalProvider<DateTime, DateTime, DateTime>
    with $Provider<DateTime> {
  /// Where the tick at now is drawn — **re-read on every save** (ADR-066).
  ///
  /// The strip is static by design (§4.1: nothing on it moves), and
  /// [todayProvider] is read once per screen and again at midnight (ADR-033) —
  /// so a chit saved twenty minutes after launch used to land *ahead* of the
  /// tick at now, which then read as a mark in the future. This re-reads the
  /// clock whenever the rows under the strip change, which is exactly when §4.1
  /// says the strip may change: on a save, and on the day turning.
  ///
  /// **A second clock read on the screen, and the one exception to
  /// ARCHITECTURE.md §3's one-read rule.** It cannot disagree with the date line
  /// about *which day* — the window it is drawn into still comes off
  /// [todayProvider] — only about the minute, which is the point. At the instant
  /// after midnight, before the rollover timer fires, it falls outside the window
  /// and the tick is simply not drawn for those milliseconds.
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

/// Every chit in the query window, oldest first — the timeline's marks.
///
/// A second stream over rows the thread already has for one of the three days.
/// ADR-024 lists that as a cost; what it is not is a second source of truth,
/// because both are streams off the same table and a save re-emits on both.

@ProviderFor(timelineChits)
final timelineChitsProvider = TimelineChitsProvider._();

/// Every chit in the query window, oldest first — the timeline's marks.
///
/// A second stream over rows the thread already has for one of the three days.
/// ADR-024 lists that as a cost; what it is not is a second source of truth,
/// because both are streams off the same table and a save re-emits on both.

final class TimelineChitsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Chit>>,
          List<Chit>,
          Stream<List<Chit>>
        >
    with $FutureModifier<List<Chit>>, $StreamProvider<List<Chit>> {
  /// Every chit in the query window, oldest first — the timeline's marks.
  ///
  /// A second stream over rows the thread already has for one of the three days.
  /// ADR-024 lists that as a cost; what it is not is a second source of truth,
  /// because both are streams off the same table and a save re-emits on both.
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

/// The window the strip actually draws — ADR-035.
///
/// The query window with its leading empty days dropped, so a strip never
/// opens on a stretch of days that were never written in. On a first run it is
/// today alone and does not scroll at all; it grows backwards as there is
/// something back there to grow into.
///
/// While the query is in flight there are no chits and this is today, which is
/// the narrowest honest answer — the same reading of ADR-007 the thread takes.

@ProviderFor(timelineWindow)
final timelineWindowProvider = TimelineWindowProvider._();

/// The window the strip actually draws — ADR-035.
///
/// The query window with its leading empty days dropped, so a strip never
/// opens on a stretch of days that were never written in. On a first run it is
/// today alone and does not scroll at all; it grows backwards as there is
/// something back there to grow into.
///
/// While the query is in flight there are no chits and this is today, which is
/// the narrowest honest answer — the same reading of ADR-007 the thread takes.

final class TimelineWindowProvider
    extends $FunctionalProvider<TimelineWindow, TimelineWindow, TimelineWindow>
    with $Provider<TimelineWindow> {
  /// The window the strip actually draws — ADR-035.
  ///
  /// The query window with its leading empty days dropped, so a strip never
  /// opens on a stretch of days that were never written in. On a first run it is
  /// today alone and does not scroll at all; it grows backwards as there is
  /// something back there to grow into.
  ///
  /// While the query is in flight there are no chits and this is today, which is
  /// the narrowest honest answer — the same reading of ADR-007 the thread takes.
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
