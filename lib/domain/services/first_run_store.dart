import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'first_run_store.g.dart';

/// The two things the app remembers between launches — **ADR-041**.
///
/// Both are about the first-run screen and nothing else. They are separate
/// flags rather than one tri-state because they answer different questions and
/// change at different moments: [hasRunBefore] is set the first time the screen
/// is dismissed however it was dismissed, and [permissionSettled] is set only
/// when the system has told us the answer will not change.
///
/// **Reading these is the one thing that happens before the first frame.**
/// `main()` awaits it, because the alternative is opening on Today and jumping
/// to the first-run screen a frame later, which is worse than a few
/// milliseconds of local disk.
abstract interface class FirstRunStore {
  /// Whether the first-run screen has been shown and dismissed.
  ///
  /// `true` after **Allow** *and* after **Not now** — the screen is shown once
  /// in the life of an install, and which button ended it is not this flag's
  /// business.
  bool get hasRunBefore;

  /// Whether the location permission has been settled for good.
  ///
  /// `true` when the system reported `deniedForever`, or when the user chose
  /// **Not now**. ADR-016 forbids nagging, so this is what stops the app ever
  /// asking a second time. It is deliberately **not** set by an ordinary
  /// denial that the system would still let us re-ask about — that case simply
  /// never comes up, because the app only ever asks once anyway.
  bool get permissionSettled;

  /// Records that the first-run screen is done, and whether to stop asking.
  Future<void> complete({required bool permissionSettled});
}

/// The store the app runs on.
///
/// Unimplemented on purpose, for the reason `chitRepositoryProvider` is:
/// `domain` cannot import `data` (ARCHITECTURE.md §1), so the implementation is
/// supplied at the root — and a test overrides it with a fake in memory.
@Riverpod(keepAlive: true)
FirstRunStore firstRunStore(Ref ref) => throw UnimplementedError(
  'firstRunStoreProvider is overridden at the root — see main.dart',
);
