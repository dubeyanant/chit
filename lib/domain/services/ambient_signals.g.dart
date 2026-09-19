// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ambient_signals.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AmbientSignals)
final ambientSignalsProvider = AmbientSignalsProvider._();

final class AmbientSignalsProvider
    extends $NotifierProvider<AmbientSignals, AmbientReading> {
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

String _$ambientSignalsHash() => r'a7b9f9dcecbec1203cfbd51462a52103958a2f1e';

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
