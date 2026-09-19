import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'app/ambient_resume.dart';
import 'app/chit_app.dart';
import 'core/clock.dart';
import 'data/audio/just_audio_player.dart';
import 'data/audio/record_audio_recorder.dart';
import 'data/db/app_database.dart';
import 'data/dev/debug_seeder.dart';
import 'data/dev/frame_log.dart';
import 'data/files/file_store.dart';
import 'data/geo/asset_outline_atlas.dart';
import 'data/location/geolocator_location_service.dart';
import 'data/photo/image_picker_photo_source.dart';
import 'data/repositories/chit_repository_impl.dart';
import 'data/weather/open_meteo_service.dart';
import 'domain/geo/outline_source.dart';
import 'domain/repositories/chit_repository.dart';
import 'domain/services/ambient_signals.dart';
import 'domain/services/audio_player.dart';
import 'domain/services/audio_recorder.dart';
import 'domain/services/location_service.dart';
import 'domain/services/photo_source.dart';
import 'domain/services/weather_service.dart';

const String _seedMode = String.fromEnvironment('CHIT_SEED');

const bool _logFrames = bool.fromEnvironment('CHIT_FRAMES');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final ProviderContainer container = ProviderContainer(
    overrides: [
      chitRepositoryProvider.overrideWith(
        (Ref ref) => ChitRepositoryImpl(
          dao: ref.watch(appDatabaseProvider).chitDao,
          audio: ref.watch(audioStoreProvider),
          photos: ref.watch(photoStoreProvider),
          clock: ref.watch(clockProvider),
        ),
      ),
      outlineSourceProvider.overrideWith((Ref ref) => loadOutlineAtlas()),

      locationServiceProvider.overrideWith(
        (Ref ref) => const GeolocatorLocationService(),
      ),
      weatherServiceProvider.overrideWith(
        (Ref ref) => OpenMeteoService(
          location: ref.watch(locationServiceProvider),
          client: http.Client(),
        ),
      ),
      audioRecorderProvider.overrideWith(
        (Ref ref) =>
            RecordAudioRecorder.appCache(clock: ref.watch(clockProvider)),
      ),

      audioPlayerProvider.overrideWith(
        (Ref ref) => JustAudioPlayer(ref.watch(audioStoreProvider)),
      ),

      photoSourceProvider.overrideWith((Ref ref) => ImagePickerPhotoSource()),
    ],
  );

  unawaited(container.read(chitRepositoryProvider).reconcileAudio());
  unawaited(container.read(chitRepositoryProvider).reconcilePhotos());

  if (_seedMode.isNotEmpty) {
    final DebugSeeder seeder = DebugSeeder(
      dao: container.read(appDatabaseProvider).chitDao,
      audio: container.read(audioStoreProvider),
      clock: container.read(clockProvider),
      temp: getTemporaryDirectory(),
    );
    unawaited(seeder.apply(_seedMode).then(debugPrint));
  }

  if (_logFrames) FrameLog(report: debugPrint).watch();

  WidgetsBinding.instance.addPostFrameCallback((Duration _) {
    unawaited(container.read(ambientSignalsProvider.notifier).prime());
    container.read(ambientResumeProvider);
  });

  runApp(
    UncontrolledProviderScope(container: container, child: const ChitApp()),
  );
}
