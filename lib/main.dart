import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/chit_app.dart';
import 'core/clock.dart';
import 'data/audio/audio_store.dart';
import 'data/db/app_database.dart';
import 'data/location/fixed_location_service.dart';
import 'data/repositories/chit_repository_impl.dart';
import 'data/weather/fixed_weather_service.dart';
import 'domain/repositories/chit_repository.dart';
import 'domain/services/location_service.dart';
import 'domain/services/weather_service.dart';

/// The root, and the one place `domain` and `data` are allowed to meet.
///
/// `chitRepositoryProvider` is declared beside its interface and left
/// unimplemented, because `domain` cannot import `data` (ARCHITECTURE.md §1).
/// Here is where the implementation is supplied — and the same seam is what a
/// test overrides to run against a database in memory.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final ProviderContainer container = ProviderContainer(
    overrides: [
      chitRepositoryProvider.overrideWith(
        (Ref ref) => ChitRepositoryImpl(
          dao: ref.watch(appDatabaseProvider).chitDao,
          audio: ref.watch(audioStoreProvider),
          clock: ref.watch(clockProvider),
        ),
      ),
      // Ambient capture, faked for M2 (TASKS.md group D). The interfaces and
      // the assembly are real; only these two lines are not, and M3 replaces
      // them with `OpenMeteoService` and `GeolocatorLocationService` without
      // anything above this file noticing.
      weatherServiceProvider.overrideWith(
        (Ref ref) => const FixedWeatherService(),
      ),
      locationServiceProvider.overrideWith(
        (Ref ref) => const FixedLocationService(),
      ),
    ],
  );

  // Recordings that no chit claims, collected once and off the critical path
  // (ADR-008). Nothing waits for it: an orphan costs disk, and the first paint
  // costs the user (README §1).
  unawaited(container.read(chitRepositoryProvider).reconcileAudio());

  runApp(
    UncontrolledProviderScope(container: container, child: const ChitApp()),
  );
}
