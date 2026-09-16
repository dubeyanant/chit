import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/services/first_run_store.dart';

/// The `FirstRunStore` of `domain`, over `shared_preferences` — ADR-041.
///
/// **It is constructed with the preferences already loaded**, rather than
/// loading them itself, because the first route the app picks depends on what
/// is in here: `main()` awaits `SharedPreferences.getInstance()` once and hands
/// it in. An implementation that loaded lazily would make `hasRunBefore` a
/// `Future`, and a router that awaits opens on Today and jumps to the first-run
/// screen a frame later — which is worse than a few milliseconds of local disk.
///
/// The two keys are prefixed and spelled out here and nowhere else. They are
/// the app's only persisted state outside the database, and a typo in one is a
/// first-run screen that shows every launch.
final class PrefsFirstRunStore implements FirstRunStore {
  /// Wraps an already-loaded `SharedPreferences`.
  const PrefsFirstRunStore(this._prefs);

  /// Whether the first-run screen has been dismissed, however it was dismissed.
  static const String hasRunBeforeKey = 'chit.firstRun.done';

  /// Whether to stop asking for location — ADR-016 forbids nagging.
  static const String permissionSettledKey = 'chit.firstRun.permissionSettled';

  final SharedPreferences _prefs;

  @override
  bool get hasRunBefore => _prefs.getBool(hasRunBeforeKey) ?? false;

  @override
  bool get permissionSettled => _prefs.getBool(permissionSettledKey) ?? false;

  @override
  Future<void> complete({required bool permissionSettled}) async {
    await _prefs.setBool(hasRunBeforeKey, true);
    if (permissionSettled) {
      await _prefs.setBool(permissionSettledKey, true);
    }
  }
}
