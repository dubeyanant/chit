// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'composer_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The open chit's state.
///
/// **Synchronous by construction.** ADR-007 says nothing about ambient capture
/// may delay the composer, so `build` does not wait for anything: it takes the
/// instant half of the stamp from [AmbientCapture.open] and hands the slow half
/// to [AmbientCapture.settle], which lands whenever it lands. A
/// `FutureOr<ComposerState> build()` would give the open chit a loading state,
/// and a loading state is a spinner whether or not one is drawn.
///
/// **The stamp is captured once and held** (ADR-021). Nothing in here re-reads
/// the clock, and [save] passes `state.stamp` rather than capturing again —
/// that is the whole decision, and it fails silently if it is got wrong,
/// because a re-captured stamp is still a perfectly plausible time.
///
/// **The five-second prompt's timer lives here, not in the widget**
/// (ARCHITECTURE.md §4.3), so that a rebuild does not restart it. A field that
/// is laid out again — a keyboard arriving, the action row growing by two
/// controls — has not been idle for any less time than it was a frame ago.

@ProviderFor(ComposerController)
final composerControllerProvider = ComposerControllerProvider._();

/// The open chit's state.
///
/// **Synchronous by construction.** ADR-007 says nothing about ambient capture
/// may delay the composer, so `build` does not wait for anything: it takes the
/// instant half of the stamp from [AmbientCapture.open] and hands the slow half
/// to [AmbientCapture.settle], which lands whenever it lands. A
/// `FutureOr<ComposerState> build()` would give the open chit a loading state,
/// and a loading state is a spinner whether or not one is drawn.
///
/// **The stamp is captured once and held** (ADR-021). Nothing in here re-reads
/// the clock, and [save] passes `state.stamp` rather than capturing again —
/// that is the whole decision, and it fails silently if it is got wrong,
/// because a re-captured stamp is still a perfectly plausible time.
///
/// **The five-second prompt's timer lives here, not in the widget**
/// (ARCHITECTURE.md §4.3), so that a rebuild does not restart it. A field that
/// is laid out again — a keyboard arriving, the action row growing by two
/// controls — has not been idle for any less time than it was a frame ago.
final class ComposerControllerProvider
    extends $NotifierProvider<ComposerController, ComposerState> {
  /// The open chit's state.
  ///
  /// **Synchronous by construction.** ADR-007 says nothing about ambient capture
  /// may delay the composer, so `build` does not wait for anything: it takes the
  /// instant half of the stamp from [AmbientCapture.open] and hands the slow half
  /// to [AmbientCapture.settle], which lands whenever it lands. A
  /// `FutureOr<ComposerState> build()` would give the open chit a loading state,
  /// and a loading state is a spinner whether or not one is drawn.
  ///
  /// **The stamp is captured once and held** (ADR-021). Nothing in here re-reads
  /// the clock, and [save] passes `state.stamp` rather than capturing again —
  /// that is the whole decision, and it fails silently if it is got wrong,
  /// because a re-captured stamp is still a perfectly plausible time.
  ///
  /// **The five-second prompt's timer lives here, not in the widget**
  /// (ARCHITECTURE.md §4.3), so that a rebuild does not restart it. A field that
  /// is laid out again — a keyboard arriving, the action row growing by two
  /// controls — has not been idle for any less time than it was a frame ago.
  ComposerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'composerControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$composerControllerHash();

  @$internal
  @override
  ComposerController create() => ComposerController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ComposerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ComposerState>(value),
    );
  }
}

String _$composerControllerHash() =>
    r'7986d2da038f05abefc442d2cdf9e3ec779ebdc7';

/// The open chit's state.
///
/// **Synchronous by construction.** ADR-007 says nothing about ambient capture
/// may delay the composer, so `build` does not wait for anything: it takes the
/// instant half of the stamp from [AmbientCapture.open] and hands the slow half
/// to [AmbientCapture.settle], which lands whenever it lands. A
/// `FutureOr<ComposerState> build()` would give the open chit a loading state,
/// and a loading state is a spinner whether or not one is drawn.
///
/// **The stamp is captured once and held** (ADR-021). Nothing in here re-reads
/// the clock, and [save] passes `state.stamp` rather than capturing again —
/// that is the whole decision, and it fails silently if it is got wrong,
/// because a re-captured stamp is still a perfectly plausible time.
///
/// **The five-second prompt's timer lives here, not in the widget**
/// (ARCHITECTURE.md §4.3), so that a rebuild does not restart it. A field that
/// is laid out again — a keyboard arriving, the action row growing by two
/// controls — has not been idle for any less time than it was a frame ago.

abstract class _$ComposerController extends $Notifier<ComposerState> {
  ComposerState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ComposerState, ComposerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ComposerState, ComposerState>,
              ComposerState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
