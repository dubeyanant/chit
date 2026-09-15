import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/clock.dart';
import '../models/ambient_stamp.dart';
import '../models/weather_condition.dart';
import 'location_service.dart';
import 'weather_service.dart';

part 'ambient_capture.g.dart';

/// Assembles the [AmbientStamp] a chit is opened with — ADR-007.
///
/// One method, and the whole of that record is in it: the two signals go out
/// **in parallel**, each under a short timeout, and **whatever has not come
/// back is `null`**. Nothing here can block the composer, show a spinner or
/// fail a save. README §1 is the reason — *opening the app costs nothing* —
/// and a journal has to work on a train.
///
/// **The time is read before either signal is asked for.** ADR-021 says a chit
/// is stamped when it is *opened*, and [AmbientStamp.capturedAt] becomes its
/// `createdAt`; a clock read after the network came back would put the chit
/// two seconds later in the thread than the moment it belongs to.
///
/// It lives in `domain` because every line of it is a product rule rather than
/// a network detail. What M3 changes is which implementations
/// `weatherServiceProvider` and `locationServiceProvider` resolve to; this
/// class does not move.
final class AmbientCapture {
  /// Captures from [clock] and the two services.
  ///
  /// [timeout] is ADR-007's short one and defaults to [defaultTimeout]. It is
  /// a parameter so that the shape can be tested in milliseconds rather than
  /// in seconds — not so that a screen can choose its own patience.
  ///
  // The fields are assigned rather than declared as initialising formals
  // because a named parameter cannot be private: `prefer_initializing_formals`
  // asks for a spelling the language does not allow. Same as
  // `ChitRepositoryImpl`.
  // ignore_for_file: prefer_initializing_formals
  const AmbientCapture({
    required Clock clock,
    required WeatherService weather,
    required LocationService location,
    this.timeout = defaultTimeout,
  }) : _clock = clock,
       _weather = weather,
       _location = location;

  /// **2 seconds.** ARCHITECTURE.md §4.2's working figure, and it is a ceiling
  /// rather than a budget: nothing waits for it in the ordinary case, because
  /// both signals are already back or already `null`.
  static const Duration defaultTimeout = Duration(seconds: 2);

  /// How long either signal has before it counts as absent.
  final Duration timeout;

  final Clock _clock;
  final WeatherService _weather;
  final LocationService _location;

  /// The stamp for a chit opened now.
  ///
  /// Never throws and never returns a partial failure: a stamp always has its
  /// time, and the other two fields are present or they are not.
  Future<AmbientStamp> capture() async {
    // Before the awaits, not after. See ADR-021 above.
    final DateTime capturedAt = _clock.now();

    final (WeatherCondition? weather, GeoFix? fix) = await (
      _bestEffort(_weather.currentCondition()),
      _bestEffort(_location.currentFix()),
    ).wait;

    return AmbientStamp(
      capturedAt: capturedAt,
      weather: weather,
      lat: fix?.lat,
      lon: fix?.lon,
    );
  }

  /// [signal], or `null` if it was slow or it threw.
  ///
  /// **A thrown error is not louder than a timeout here**, which is the one
  /// place this codebase's *fail loudly in development* rule is deliberately
  /// not applied: ADR-007 says any signal that does not arrive is `null`, and
  /// to a composer that must not stall there is no useful difference between
  /// no network, no permission and a service that fell over.
  Future<T?> _bestEffort<T>(Future<T?> signal) => signal
      .timeout(timeout, onTimeout: () => null)
      .onError((Object _, StackTrace _) => null);
}

/// The capture the composer opens a chit with.
@Riverpod(keepAlive: true)
AmbientCapture ambientCapture(Ref ref) => AmbientCapture(
  clock: ref.watch(clockProvider),
  weather: ref.watch(weatherServiceProvider),
  location: ref.watch(locationServiceProvider),
);
