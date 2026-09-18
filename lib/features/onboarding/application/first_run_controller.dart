import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/services/ambient_signals.dart';
import '../../../domain/services/first_run_store.dart';
import '../../../domain/services/location_service.dart';

part 'first_run_controller.g.dart';

@Riverpod(keepAlive: true)
class FirstRunController extends _$FirstRunController {
  @override
  bool build() => !ref.watch(firstRunStoreProvider).hasRunBefore;

  Future<void> allow() async {
    final LocationPermissionOutcome outcome = await ref
        .read(locationServiceProvider)
        .requestPermission();

    final bool granted = outcome == LocationPermissionOutcome.granted;
    await _finish(permissionSettled: !granted);

    if (!granted) return;

    unawaited(ref.read(ambientSignalsProvider.notifier).prime());
  }

  Future<void> notNow() => _finish(permissionSettled: true);

  Future<void> _finish({required bool permissionSettled}) async {
    await ref
        .read(firstRunStoreProvider)
        .complete(permissionSettled: permissionSettled);

    if (!ref.mounted) return;
    state = false;
  }
}
