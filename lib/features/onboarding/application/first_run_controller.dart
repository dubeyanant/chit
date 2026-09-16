import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/services/ambient_signals.dart';
import '../../../domain/services/first_run_store.dart';
import '../../../domain/services/location_service.dart';

part 'first_run_controller.g.dart';

/// Whether the first-run screen is still owed, and the two ways out of it —
/// **ADR-041**.
///
/// **One notifier rather than a state and a separate actions object**, because
/// the two things it does both end the same way: the screen is dismissed and
/// never shown again. A controller whose only job was to call another
/// controller would be ceremony.
///
/// The state is a plain `bool` rather than an `AsyncValue` because the answer
/// has to be available *before* the first route is chosen. `main()` loads the
/// preferences and overrides `firstRunStoreProvider` before `runApp`, so by the
/// time the router's `redirect` reads this there is nothing to wait for — the
/// alternative opens on Today and jumps to the first-run screen a frame later.
@Riverpod(keepAlive: true)
class FirstRunController extends _$FirstRunController {
  /// `true` when the first-run screen has not been shown yet.
  @override
  bool build() => !ref.watch(firstRunStoreProvider).hasRunBefore;

  /// **Allow** — raises the system dialog, then lets the app in.
  ///
  /// The outcome changes nothing the user sees. A refusal is not an error
  /// state and there is no second screen apologising for it: the app runs with
  /// fewer signals and ADR-007's `null` is not drawn. That is the whole of the
  /// failure handling, on purpose.
  ///
  /// **Settled means never ask again.** Anything but a grant settles it —
  /// `deniedForever` says so outright, a disabled service is not a refusal and
  /// asking again would not fix it, and a plain `denied` is settled because the
  /// app has spent its one ask (ADR-016 forbids coming back for a second).
  Future<void> allow() async {
    final LocationPermissionOutcome outcome = await ref
        .read(locationServiceProvider)
        .requestPermission();

    final bool granted = outcome == LocationPermissionOutcome.granted;
    await _finish(permissionSettled: !granted);

    if (!granted) return;

    // The launch capture, now that it can actually answer. Not awaited —
    // ADR-042, and the user is already looking at Today.
    unawaited(ref.read(ambientSignalsProvider.notifier).prime());
  }

  /// **Not now** — no dialog, and the app never asks again.
  ///
  /// The stronger of the two promises, and the reason the control exists: a
  /// screen whose quiet option still raises a system prompt is a dark pattern,
  /// and one that asks again next launch is the nagging ADR-016 rules out.
  Future<void> notNow() => _finish(permissionSettled: true);

  Future<void> _finish({required bool permissionSettled}) async {
    await ref
        .read(firstRunStoreProvider)
        .complete(permissionSettled: permissionSettled);

    if (!ref.mounted) return;
    state = false;
  }
}
