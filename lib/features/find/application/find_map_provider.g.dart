// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_map_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Where the newest chit that knew where it was, was — ADR-089.
///
/// **Read off the stream find already watches**, so the map behind the first
/// screen costs no query, no index and no schema change. Null until the chits
/// arrive and null when not one of them carries a fix — a phone that refused
/// location forever draws no map at all (ADR-007, ADR-085).
///
/// The newest is found by comparing, not by trusting the order the rows came
/// back in: this is the only thing that reads them this way, and an ordering
/// changed elsewhere would move the map without anybody touching it.

@ProviderFor(LatestFix)
final latestFixProvider = LatestFixProvider._();

/// Where the newest chit that knew where it was, was — ADR-089.
///
/// **Read off the stream find already watches**, so the map behind the first
/// screen costs no query, no index and no schema change. Null until the chits
/// arrive and null when not one of them carries a fix — a phone that refused
/// location forever draws no map at all (ADR-007, ADR-085).
///
/// The newest is found by comparing, not by trusting the order the rows came
/// back in: this is the only thing that reads them this way, and an ordering
/// changed elsewhere would move the map without anybody touching it.
final class LatestFixProvider extends $NotifierProvider<LatestFix, GeoPoint?> {
  /// Where the newest chit that knew where it was, was — ADR-089.
  ///
  /// **Read off the stream find already watches**, so the map behind the first
  /// screen costs no query, no index and no schema change. Null until the chits
  /// arrive and null when not one of them carries a fix — a phone that refused
  /// location forever draws no map at all (ADR-007, ADR-085).
  ///
  /// The newest is found by comparing, not by trusting the order the rows came
  /// back in: this is the only thing that reads them this way, and an ordering
  /// changed elsewhere would move the map without anybody touching it.
  LatestFixProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'latestFixProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$latestFixHash();

  @$internal
  @override
  LatestFix create() => LatestFix();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeoPoint? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeoPoint?>(value),
    );
  }
}

String _$latestFixHash() => r'fed6c24c4594adb7ee7df5767af96398108ea6c3';

/// Where the newest chit that knew where it was, was — ADR-089.
///
/// **Read off the stream find already watches**, so the map behind the first
/// screen costs no query, no index and no schema change. Null until the chits
/// arrive and null when not one of them carries a fix — a phone that refused
/// location forever draws no map at all (ADR-007, ADR-085).
///
/// The newest is found by comparing, not by trusting the order the rows came
/// back in: this is the only thing that reads them this way, and an ordering
/// changed elsewhere would move the map without anybody touching it.

abstract class _$LatestFix extends $Notifier<GeoPoint?> {
  GeoPoint? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<GeoPoint?, GeoPoint?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GeoPoint?, GeoPoint?>,
              GeoPoint?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
