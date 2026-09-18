// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recording_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RecordingController)
final recordingControllerProvider = RecordingControllerProvider._();

final class RecordingControllerProvider
    extends $NotifierProvider<RecordingController, RecordingState> {
  RecordingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recordingControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recordingControllerHash();

  @$internal
  @override
  RecordingController create() => RecordingController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecordingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecordingState>(value),
    );
  }
}

String _$recordingControllerHash() =>
    r'b54f184671ed1b72162466484a47a21765ee7baa';

abstract class _$RecordingController extends $Notifier<RecordingState> {
  RecordingState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RecordingState, RecordingState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RecordingState, RecordingState>,
              RecordingState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
