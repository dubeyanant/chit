// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The router: a shell holding two tabs that keep their own state (ADR-011).
///
/// **Held by Riverpod rather than by a widget.** ADR-001 makes Riverpod the
/// only state mechanism in the app, and a `GoRouter` is state — it owns the
/// navigation stack of every branch. Parking it in a `StatefulWidget` would
/// put the one thing that must outlive a rebuild in the one place that does
/// not, and would keep it out of reach of anything that later needs to
/// redirect on what a provider knows.
///
/// `keepAlive` because it outlives every screen. Disposed with the container,
/// so a test gets a fresh router per `ProviderScope` and two tests cannot leak
/// navigation state into each other.

@ProviderFor(router)
final routerProvider = RouterProvider._();

/// The router: a shell holding two tabs that keep their own state (ADR-011).
///
/// **Held by Riverpod rather than by a widget.** ADR-001 makes Riverpod the
/// only state mechanism in the app, and a `GoRouter` is state — it owns the
/// navigation stack of every branch. Parking it in a `StatefulWidget` would
/// put the one thing that must outlive a rebuild in the one place that does
/// not, and would keep it out of reach of anything that later needs to
/// redirect on what a provider knows.
///
/// `keepAlive` because it outlives every screen. Disposed with the container,
/// so a test gets a fresh router per `ProviderScope` and two tests cannot leak
/// navigation state into each other.

final class RouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The router: a shell holding two tabs that keep their own state (ADR-011).
  ///
  /// **Held by Riverpod rather than by a widget.** ADR-001 makes Riverpod the
  /// only state mechanism in the app, and a `GoRouter` is state — it owns the
  /// navigation stack of every branch. Parking it in a `StatefulWidget` would
  /// put the one thing that must outlive a rebuild in the one place that does
  /// not, and would keep it out of reach of anything that later needs to
  /// redirect on what a provider knows.
  ///
  /// `keepAlive` because it outlives every screen. Disposed with the container,
  /// so a test gets a fresh router per `ProviderScope` and two tests cannot leak
  /// navigation state into each other.
  RouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routerHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return router(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$routerHash() => r'5a385e05806f9b51b63ed2f49e3388c02bb4f9da';
