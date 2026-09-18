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
/// may delay the composer, so `build` does not wait for anything: it shows the
/// time at once and whatever ambience the app is already holding. A
/// `FutureOr<ComposerState> build()` would give the open chit a loading state,
/// and a loading state is a spinner whether or not one is drawn.
///
/// **This screen captures nothing** (ADR-042). *It used to drive an
/// `open()`/`settle()` pair on every chit open, which meant four taps of
/// Discard made four network calls.* Capture now happens twice in the life of
/// the app — at launch and at save — and what the slip draws is whatever
/// `AmbientSignals` is holding.
///
/// **The stamp on screen is a preview** (ADR-040). The row is stamped when
/// [save] runs, from a fresh clock read and a fresh capture, so a chit sat on
/// for twenty minutes lands in the thread carrying a later time than the slip
/// showed.
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
/// may delay the composer, so `build` does not wait for anything: it shows the
/// time at once and whatever ambience the app is already holding. A
/// `FutureOr<ComposerState> build()` would give the open chit a loading state,
/// and a loading state is a spinner whether or not one is drawn.
///
/// **This screen captures nothing** (ADR-042). *It used to drive an
/// `open()`/`settle()` pair on every chit open, which meant four taps of
/// Discard made four network calls.* Capture now happens twice in the life of
/// the app — at launch and at save — and what the slip draws is whatever
/// `AmbientSignals` is holding.
///
/// **The stamp on screen is a preview** (ADR-040). The row is stamped when
/// [save] runs, from a fresh clock read and a fresh capture, so a chit sat on
/// for twenty minutes lands in the thread carrying a later time than the slip
/// showed.
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
  /// may delay the composer, so `build` does not wait for anything: it shows the
  /// time at once and whatever ambience the app is already holding. A
  /// `FutureOr<ComposerState> build()` would give the open chit a loading state,
  /// and a loading state is a spinner whether or not one is drawn.
  ///
  /// **This screen captures nothing** (ADR-042). *It used to drive an
  /// `open()`/`settle()` pair on every chit open, which meant four taps of
  /// Discard made four network calls.* Capture now happens twice in the life of
  /// the app — at launch and at save — and what the slip draws is whatever
  /// `AmbientSignals` is holding.
  ///
  /// **The stamp on screen is a preview** (ADR-040). The row is stamped when
  /// [save] runs, from a fresh clock read and a fresh capture, so a chit sat on
  /// for twenty minutes lands in the thread carrying a later time than the slip
  /// showed.
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
    r'ab76a8c9a819514bb2fa19cdda4c044d4385dd85';

/// The open chit's state.
///
/// **Synchronous by construction.** ADR-007 says nothing about ambient capture
/// may delay the composer, so `build` does not wait for anything: it shows the
/// time at once and whatever ambience the app is already holding. A
/// `FutureOr<ComposerState> build()` would give the open chit a loading state,
/// and a loading state is a spinner whether or not one is drawn.
///
/// **This screen captures nothing** (ADR-042). *It used to drive an
/// `open()`/`settle()` pair on every chit open, which meant four taps of
/// Discard made four network calls.* Capture now happens twice in the life of
/// the app — at launch and at save — and what the slip draws is whatever
/// `AmbientSignals` is holding.
///
/// **The stamp on screen is a preview** (ADR-040). The row is stamped when
/// [save] runs, from a fresh clock read and a fresh capture, so a chit sat on
/// for twenty minutes lands in the thread carrying a later time than the slip
/// showed.
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
