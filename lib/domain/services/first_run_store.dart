import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'first_run_store.g.dart';

abstract interface class FirstRunStore {
  bool get hasRunBefore;

  bool get permissionSettled;

  Future<void> complete({required bool permissionSettled});
}

@Riverpod(keepAlive: true)
FirstRunStore firstRunStore(Ref ref) => throw UnimplementedError(
  'firstRunStoreProvider is overridden at the root — see main.dart',
);
