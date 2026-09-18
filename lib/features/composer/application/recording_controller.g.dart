// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recording_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The recording sheet's state — BEHAVIOUR.md §3.4, ARCHITECTURE.md §4.4.
///
/// **It hands the result to a [RecordingSink] rather than returning it**,
/// because the sheet is a modal and not a route (ADR-011): there is nothing
/// downstream of it to give a value to. That also keeps every §3.4 rule in a
/// controller, where a test can reach it without a widget (ADR-031). *The sink
/// was `ComposerController` by name until M6's editor became the second screen
/// to record* (ADR-065); now whoever taps the microphone owns the take.
///
/// **`keepAlive`, and it is the only screen-state controller that is** —
/// ADR-057. A take begins before the sheet exists and finishes after it has
/// gone, so for the length of the permission round-trip there is nothing
/// watching this at all; auto-disposed, it was thrown away mid-`start`, and
/// the microphone opened and shut without a sheet ever appearing. Nothing here
/// leaks in exchange: [start] resets the state, and both ways out of a take
/// reset it again.

@ProviderFor(RecordingController)
final recordingControllerProvider = RecordingControllerProvider._();

/// The recording sheet's state — BEHAVIOUR.md §3.4, ARCHITECTURE.md §4.4.
///
/// **It hands the result to a [RecordingSink] rather than returning it**,
/// because the sheet is a modal and not a route (ADR-011): there is nothing
/// downstream of it to give a value to. That also keeps every §3.4 rule in a
/// controller, where a test can reach it without a widget (ADR-031). *The sink
/// was `ComposerController` by name until M6's editor became the second screen
/// to record* (ADR-065); now whoever taps the microphone owns the take.
///
/// **`keepAlive`, and it is the only screen-state controller that is** —
/// ADR-057. A take begins before the sheet exists and finishes after it has
/// gone, so for the length of the permission round-trip there is nothing
/// watching this at all; auto-disposed, it was thrown away mid-`start`, and
/// the microphone opened and shut without a sheet ever appearing. Nothing here
/// leaks in exchange: [start] resets the state, and both ways out of a take
/// reset it again.
final class RecordingControllerProvider
    extends $NotifierProvider<RecordingController, RecordingState> {
  /// The recording sheet's state — BEHAVIOUR.md §3.4, ARCHITECTURE.md §4.4.
  ///
  /// **It hands the result to a [RecordingSink] rather than returning it**,
  /// because the sheet is a modal and not a route (ADR-011): there is nothing
  /// downstream of it to give a value to. That also keeps every §3.4 rule in a
  /// controller, where a test can reach it without a widget (ADR-031). *The sink
  /// was `ComposerController` by name until M6's editor became the second screen
  /// to record* (ADR-065); now whoever taps the microphone owns the take.
  ///
  /// **`keepAlive`, and it is the only screen-state controller that is** —
  /// ADR-057. A take begins before the sheet exists and finishes after it has
  /// gone, so for the length of the permission round-trip there is nothing
  /// watching this at all; auto-disposed, it was thrown away mid-`start`, and
  /// the microphone opened and shut without a sheet ever appearing. Nothing here
  /// leaks in exchange: [start] resets the state, and both ways out of a take
  /// reset it again.
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

/// The recording sheet's state — BEHAVIOUR.md §3.4, ARCHITECTURE.md §4.4.
///
/// **It hands the result to a [RecordingSink] rather than returning it**,
/// because the sheet is a modal and not a route (ADR-011): there is nothing
/// downstream of it to give a value to. That also keeps every §3.4 rule in a
/// controller, where a test can reach it without a widget (ADR-031). *The sink
/// was `ComposerController` by name until M6's editor became the second screen
/// to record* (ADR-065); now whoever taps the microphone owns the take.
///
/// **`keepAlive`, and it is the only screen-state controller that is** —
/// ADR-057. A take begins before the sheet exists and finishes after it has
/// gone, so for the length of the permission round-trip there is nothing
/// watching this at all; auto-disposed, it was thrown away mid-`start`, and
/// the microphone opened and shut without a sheet ever appearing. Nothing here
/// leaks in exchange: [start] resets the state, and both ways out of a take
/// reset it again.

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
