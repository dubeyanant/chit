import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'app/chit_app.dart';
import 'core/clock.dart';
import 'data/audio/audio_store.dart';
import 'data/db/app_database.dart';
import 'data/dev/debug_seeder.dart';
import 'data/location/geolocator_location_service.dart';
import 'data/preferences/prefs_first_run_store.dart';
import 'data/repositories/chit_repository_impl.dart';
import 'data/weather/open_meteo_service.dart';
import 'domain/repositories/chit_repository.dart';
import 'domain/services/ambient_signals.dart';
import 'domain/services/first_run_store.dart';
import 'domain/services/location_service.dart';
import 'domain/services/weather_service.dart';
import 'features/onboarding/application/first_run_controller.dart';

/// `--dart-define=CHIT_SEED=seed` writes DATA-MODEL.md §7's fixture and
/// `=clear` removes it. Empty, which is the default, does nothing at all.
///
/// Read at compile time, so a build that was not given the flag does not carry
/// so much as a string comparison for it.
const String _seedMode = String.fromEnvironment('CHIT_SEED');

/// The root, and the one place `domain` and `data` are allowed to meet.
///
/// `chitRepositoryProvider` is declared beside its interface and left
/// unimplemented, because `domain` cannot import `data` (ARCHITECTURE.md §1).
/// Here is where the implementation is supplied — and the same seam is what a
/// test overrides to run against a database in memory.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // **The one thing awaited before the first frame** — ADR-041. Which screen
  // is correct depends on what is in here, and a router that discovers it a
  // frame later opens on Today and jumps. It is a local read of two booleans;
  // the database and both ambient services stay lazy behind it.
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final ProviderContainer container = ProviderContainer(
    overrides: [
      chitRepositoryProvider.overrideWith(
        (Ref ref) => ChitRepositoryImpl(
          dao: ref.watch(appDatabaseProvider).chitDao,
          audio: ref.watch(audioStoreProvider),
          clock: ref.watch(clockProvider),
        ),
      ),
      firstRunStoreProvider.overrideWith(
        (Ref ref) => PrefsFirstRunStore(prefs),
      ),
      // **Ambient capture, for real** — M3 group J. *These two lines held
      // `FixedWeatherService` and `FixedLocationService` from M2 until now, and
      // nothing above this file changed when they came out.* That was the whole
      // point of putting the interfaces in `domain` and the assembly in
      // `AmbientCapture`.
      //
      // The order matters and is the one seam ADR-025 warned about: weather
      // reads its position from the location service, so it is constructed
      // with it rather than beside it.
      locationServiceProvider.overrideWith(
        (Ref ref) => const GeolocatorLocationService(),
      ),
      weatherServiceProvider.overrideWith(
        (Ref ref) => OpenMeteoService(
          location: ref.watch(locationServiceProvider),
          client: http.Client(),
        ),
      ),
    ],
  );

  // Recordings that no chit claims, collected once and off the critical path
  // (ADR-008). Nothing waits for it: an orphan costs disk, and the first paint
  // costs the user (README §1).
  unawaited(container.read(chitRepositoryProvider).reconcileAudio());

  // **The seeder**, debug builds only and only when asked for — DATA-MODEL.md
  // §7. Off the critical path like the sweep above it: every screen is a
  // stream off the one table, so the rows appear as they land and nothing
  // waits for them. `kDebugMode` is a compile-time constant, so the branch
  // and the seeder behind it are not in a release build at all.
  if (kDebugMode && _seedMode.isNotEmpty) {
    final DebugSeeder seeder = DebugSeeder(
      dao: container.read(appDatabaseProvider).chitDao,
      audio: container.read(audioStoreProvider),
      clock: container.read(clockProvider),
    );
    unawaited(seeder.apply(_seedMode).then(debugPrint));
  }

  // **The launch capture** — ADR-042 — fired after the first frame and never
  // awaited, for the same reason. It is skipped on a fresh install: there is
  // nothing to ask until somebody has answered the first-run screen, and asking
  // first is how a system dialog appears before the screen explaining it.
  // `FirstRunController.allow` primes it instead.
  if (!container.read(firstRunControllerProvider)) {
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      unawaited(container.read(ambientSignalsProvider.notifier).prime());
    });
  }

  runApp(
    UncontrolledProviderScope(container: container, child: const ChitApp()),
  );
}
