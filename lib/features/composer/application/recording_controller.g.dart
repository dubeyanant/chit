// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recording_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The recording sheet's state — BEHAVIOUR.md §3.4, ARCHITECTURE.md §4.4.
///
/// **Two services, one take** (TASKS.md D1). The recogniser takes no file and
/// no stream, so the only way to keep the audio *and* have words is to run
/// both at once; this is the thing that runs them, and neither knows the other
/// exists. Whether a phone will let them share the microphone is open item 32
/// and nothing here can settle it.
///
/// **It hands the result to `ComposerController` rather than returning it**,
/// because the sheet is a modal and not a route (ADR-011): there is nothing
/// downstream of it to give a value to. That also keeps every §3.4 and §3.5
/// rule in a controller, where a test can reach it without a widget (ADR-031).

@ProviderFor(RecordingController)
final recordingControllerProvider = RecordingControllerProvider._();

/// The recording sheet's state — BEHAVIOUR.md §3.4, ARCHITECTURE.md §4.4.
///
/// **Two services, one take** (TASKS.md D1). The recogniser takes no file and
/// no stream, so the only way to keep the audio *and* have words is to run
/// both at once; this is the thing that runs them, and neither knows the other
/// exists. Whether a phone will let them share the microphone is open item 32
/// and nothing here can settle it.
///
/// **It hands the result to `ComposerController` rather than returning it**,
/// because the sheet is a modal and not a route (ADR-011): there is nothing
/// downstream of it to give a value to. That also keeps every §3.4 and §3.5
/// rule in a controller, where a test can reach it without a widget (ADR-031).
final class RecordingControllerProvider
    extends $NotifierProvider<RecordingController, RecordingState> {
  /// The recording sheet's state — BEHAVIOUR.md §3.4, ARCHITECTURE.md §4.4.
  ///
  /// **Two services, one take** (TASKS.md D1). The recogniser takes no file and
  /// no stream, so the only way to keep the audio *and* have words is to run
  /// both at once; this is the thing that runs them, and neither knows the other
  /// exists. Whether a phone will let them share the microphone is open item 32
  /// and nothing here can settle it.
  ///
  /// **It hands the result to `ComposerController` rather than returning it**,
  /// because the sheet is a modal and not a route (ADR-011): there is nothing
  /// downstream of it to give a value to. That also keeps every §3.4 and §3.5
  /// rule in a controller, where a test can reach it without a widget (ADR-031).
  RecordingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recordingControllerProvider',
        isAutoDispose: true,
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
    r'e74c5fd1b4e9181294e5a10bef7d4d3a3262bd31';

/// The recording sheet's state — BEHAVIOUR.md §3.4, ARCHITECTURE.md §4.4.
///
/// **Two services, one take** (TASKS.md D1). The recogniser takes no file and
/// no stream, so the only way to keep the audio *and* have words is to run
/// both at once; this is the thing that runs them, and neither knows the other
/// exists. Whether a phone will let them share the microphone is open item 32
/// and nothing here can settle it.
///
/// **It hands the result to `ComposerController` rather than returning it**,
/// because the sheet is a modal and not a route (ADR-011): there is nothing
/// downstream of it to give a value to. That also keeps every §3.4 and §3.5
/// rule in a controller, where a test can reach it without a widget (ADR-031).

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
