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
///
/// **This function must run exactly once.** Everything it depends on is read
/// with `ref.read` or `ref.listen`, never `ref.watch` — a watch here would
/// rebuild the provider, and rebuilding it constructs a second `GoRouter` that
/// starts with empty navigation stacks. Anything that needs to change the
/// router's behaviour later goes through a listenable, as the first-run gate
/// below does.

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
///
/// **This function must run exactly once.** Everything it depends on is read
/// with `ref.read` or `ref.listen`, never `ref.watch` — a watch here would
/// rebuild the provider, and rebuilding it constructs a second `GoRouter` that
/// starts with empty navigation stacks. Anything that needs to change the
/// router's behaviour later goes through a listenable, as the first-run gate
/// below does.

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
  ///
  /// **This function must run exactly once.** Everything it depends on is read
  /// with `ref.read` or `ref.listen`, never `ref.watch` — a watch here would
  /// rebuild the provider, and rebuilding it constructs a second `GoRouter` that
  /// starts with empty navigation stacks. Anything that needs to change the
  /// router's behaviour later goes through a listenable, as the first-run gate
  /// below does.
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

String _$routerHash() => r'0ee72412cd772277273b7a881b466c0a84ec9984';
