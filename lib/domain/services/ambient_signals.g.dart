// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ambient_signals.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The three best-effort signals, held for the life of the process —
/// **ADR-042**, as amended by **ADR-045**.
///
/// **Captured at launch, and at a save that is holding something stale.** Once
/// after the first frame, and again when a chit is saved more than
/// `freshFor` after the last reading came back. There is no timer, no refresh
/// on resume, and no capture at all on a chit that is merely opened.
///
/// *The app used to ask both services on every chit open*, which meant four
/// taps of **Discard** made four network calls. *And then it asked on every
/// save*, which meant a burst of chits in one sitting paid for a GPS fix each.
/// Neither is true now: a save inside the window writes what is already in
/// hand.
///
/// **What is held here is the preview; what a saved chit carries is the
/// record.** They can differ, and the staleness lives on the screen rather
/// than in the data.
///
/// **It holds a clock, and only to timestamp itself.** `readAt` is what makes
/// ADR-045's window checkable; no chit ever takes its time from here, because
/// a chit is stamped where it is saved (ADR-040).

@ProviderFor(AmbientSignals)
final ambientSignalsProvider = AmbientSignalsProvider._();

/// The three best-effort signals, held for the life of the process —
/// **ADR-042**, as amended by **ADR-045**.
///
/// **Captured at launch, and at a save that is holding something stale.** Once
/// after the first frame, and again when a chit is saved more than
/// `freshFor` after the last reading came back. There is no timer, no refresh
/// on resume, and no capture at all on a chit that is merely opened.
///
/// *The app used to ask both services on every chit open*, which meant four
/// taps of **Discard** made four network calls. *And then it asked on every
/// save*, which meant a burst of chits in one sitting paid for a GPS fix each.
/// Neither is true now: a save inside the window writes what is already in
/// hand.
///
/// **What is held here is the preview; what a saved chit carries is the
/// record.** They can differ, and the staleness lives on the screen rather
/// than in the data.
///
/// **It holds a clock, and only to timestamp itself.** `readAt` is what makes
/// ADR-045's window checkable; no chit ever takes its time from here, because
/// a chit is stamped where it is saved (ADR-040).
final class AmbientSignalsProvider
    extends $NotifierProvider<AmbientSignals, AmbientReading> {
  /// The three best-effort signals, held for the life of the process —
  /// **ADR-042**, as amended by **ADR-045**.
  ///
  /// **Captured at launch, and at a save that is holding something stale.** Once
  /// after the first frame, and again when a chit is saved more than
  /// `freshFor` after the last reading came back. There is no timer, no refresh
  /// on resume, and no capture at all on a chit that is merely opened.
  ///
  /// *The app used to ask both services on every chit open*, which meant four
  /// taps of **Discard** made four network calls. *And then it asked on every
  /// save*, which meant a burst of chits in one sitting paid for a GPS fix each.
  /// Neither is true now: a save inside the window writes what is already in
  /// hand.
  ///
  /// **What is held here is the preview; what a saved chit carries is the
  /// record.** They can differ, and the staleness lives on the screen rather
  /// than in the data.
  ///
  /// **It holds a clock, and only to timestamp itself.** `readAt` is what makes
  /// ADR-045's window checkable; no chit ever takes its time from here, because
  /// a chit is stamped where it is saved (ADR-040).
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

String _$ambientSignalsHash() => r'9032b35e07861f42fd33958fed2e6e01a727da70';

/// The three best-effort signals, held for the life of the process —
/// **ADR-042**, as amended by **ADR-045**.
///
/// **Captured at launch, and at a save that is holding something stale.** Once
/// after the first frame, and again when a chit is saved more than
/// `freshFor` after the last reading came back. There is no timer, no refresh
/// on resume, and no capture at all on a chit that is merely opened.
///
/// *The app used to ask both services on every chit open*, which meant four
/// taps of **Discard** made four network calls. *And then it asked on every
/// save*, which meant a burst of chits in one sitting paid for a GPS fix each.
/// Neither is true now: a save inside the window writes what is already in
/// hand.
///
/// **What is held here is the preview; what a saved chit carries is the
/// record.** They can differ, and the staleness lives on the screen rather
/// than in the data.
///
/// **It holds a clock, and only to timestamp itself.** `readAt` is what makes
/// ADR-045's window checkable; no chit ever takes its time from here, because
/// a chit is stamped where it is saved (ADR-040).

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
