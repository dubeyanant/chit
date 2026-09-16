// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ambient_signals.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The three best-effort signals, held for the life of the process —
/// **ADR-042**.
///
/// **They are captured twice and never in between**: once at launch, and again
/// when a chit is saved. There is no timer, no time-to-live, and no refresh
/// when the app returns to the foreground.
///
/// *The app used to ask both services on every chit open*, which meant four
/// taps of **Discard** made four network calls. The record that governed
/// Discard asked for an implementation "as unbothered by that as the fakes
/// are" without saying how; this is how. Nothing is asked unless a chit is
/// actually written.
///
/// **What is held here is the preview; what a saved chit carries is the
/// record.** They are different values on purpose. The stamp on the open chit
/// draws whatever landed at launch, and on a phone that has been open all day
/// that can be hours old. The staleness is confined to the screen: [refresh]
/// runs before a row is written (ADR-040), so no chit is ever *recorded* with
/// a signal from launch.
///
/// **It holds no clock.** The time on a stamp is read where it is used — by
/// the composer for what it shows, and by `save` for what it writes — because
/// a time held here would be the one thing in the app that went stale
/// dangerously rather than harmlessly.

@ProviderFor(AmbientSignals)
final ambientSignalsProvider = AmbientSignalsProvider._();

/// The three best-effort signals, held for the life of the process —
/// **ADR-042**.
///
/// **They are captured twice and never in between**: once at launch, and again
/// when a chit is saved. There is no timer, no time-to-live, and no refresh
/// when the app returns to the foreground.
///
/// *The app used to ask both services on every chit open*, which meant four
/// taps of **Discard** made four network calls. The record that governed
/// Discard asked for an implementation "as unbothered by that as the fakes
/// are" without saying how; this is how. Nothing is asked unless a chit is
/// actually written.
///
/// **What is held here is the preview; what a saved chit carries is the
/// record.** They are different values on purpose. The stamp on the open chit
/// draws whatever landed at launch, and on a phone that has been open all day
/// that can be hours old. The staleness is confined to the screen: [refresh]
/// runs before a row is written (ADR-040), so no chit is ever *recorded* with
/// a signal from launch.
///
/// **It holds no clock.** The time on a stamp is read where it is used — by
/// the composer for what it shows, and by `save` for what it writes — because
/// a time held here would be the one thing in the app that went stale
/// dangerously rather than harmlessly.
final class AmbientSignalsProvider
    extends $NotifierProvider<AmbientSignals, AmbientReading> {
  /// The three best-effort signals, held for the life of the process —
  /// **ADR-042**.
  ///
  /// **They are captured twice and never in between**: once at launch, and again
  /// when a chit is saved. There is no timer, no time-to-live, and no refresh
  /// when the app returns to the foreground.
  ///
  /// *The app used to ask both services on every chit open*, which meant four
  /// taps of **Discard** made four network calls. The record that governed
  /// Discard asked for an implementation "as unbothered by that as the fakes
  /// are" without saying how; this is how. Nothing is asked unless a chit is
  /// actually written.
  ///
  /// **What is held here is the preview; what a saved chit carries is the
  /// record.** They are different values on purpose. The stamp on the open chit
  /// draws whatever landed at launch, and on a phone that has been open all day
  /// that can be hours old. The staleness is confined to the screen: [refresh]
  /// runs before a row is written (ADR-040), so no chit is ever *recorded* with
  /// a signal from launch.
  ///
  /// **It holds no clock.** The time on a stamp is read where it is used — by
  /// the composer for what it shows, and by `save` for what it writes — because
  /// a time held here would be the one thing in the app that went stale
  /// dangerously rather than harmlessly.
  AmbientSignalsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ambientSignalsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ambientSignalsHash();

  @$internal
  @override
  AmbientSignals create() => AmbientSignals();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AmbientReading value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AmbientReading>(value),
    );
  }
}

String _$ambientSignalsHash() => r'd3b099e133c81f57be238d0b81b8af616cd6442b';

/// The three best-effort signals, held for the life of the process —
/// **ADR-042**.
///
/// **They are captured twice and never in between**: once at launch, and again
/// when a chit is saved. There is no timer, no time-to-live, and no refresh
/// when the app returns to the foreground.
///
/// *The app used to ask both services on every chit open*, which meant four
/// taps of **Discard** made four network calls. The record that governed
/// Discard asked for an implementation "as unbothered by that as the fakes
/// are" without saying how; this is how. Nothing is asked unless a chit is
/// actually written.
///
/// **What is held here is the preview; what a saved chit carries is the
/// record.** They are different values on purpose. The stamp on the open chit
/// draws whatever landed at launch, and on a phone that has been open all day
/// that can be hours old. The staleness is confined to the screen: [refresh]
/// runs before a row is written (ADR-040), so no chit is ever *recorded* with
/// a signal from launch.
///
/// **It holds no clock.** The time on a stamp is read where it is used — by
/// the composer for what it shows, and by `save` for what it writes — because
/// a time held here would be the one thing in the app that went stale
/// dangerously rather than harmlessly.

abstract class _$AmbientSignals extends $Notifier<AmbientReading> {
  AmbientReading build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AmbientReading, AmbientReading>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AmbientReading, AmbientReading>,
              AmbientReading,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
