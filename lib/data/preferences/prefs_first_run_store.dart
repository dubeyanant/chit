import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/services/first_run_store.dart';

final class PrefsFirstRunStore implements FirstRunStore {
  const PrefsFirstRunStore(this._prefs);

  static const String hasRunBeforeKey = 'chit.firstRun.done';

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
