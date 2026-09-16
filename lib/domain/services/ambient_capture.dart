import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/motion_state.dart';
import '../models/weather_condition.dart';
import '../motion/motion_ladder.dart';
import 'ambient_signals.dart';
import 'location_service.dart';
import 'weather_service.dart';

part 'ambient_capture.g.dart';

/// One reading of the two ambient services — ADR-007.
///
/// The whole of that record is here: the two signals go out **in parallel**,
/// each under a short timeout, and **whatever has not come back is `null`**.
/// Nothing here can block a screen, show a spinner or fail a save. README §1
/// is the reason — *opening the app costs nothing* — and a journal has to work
/// on a train.
///
/// **It answers what, and `AmbientSignals` decides when** (ADR-042). *This
/// class used to hold the time as well, in an `open()`/`settle()` pair the
/// composer drove on every chit open.* Both halves of that moved: the clock is
/// read where a time is actually used, and the decision to ask at all belongs
/// to the thing that knows there are only two moments worth asking in — launch,
/// and save.
///
/// It lives in `domain` because every line of it is a product rule rather than
/// a network detail. What changes underneath is which implementations
/// `weatherServiceProvider` and `locationServiceProvider` resolve to; this
/// class does not move.
final class AmbientCapture {
  /// Captures from the two services.
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
    required WeatherService weather,
    required LocationService location,
    this.timeout = defaultTimeout,
  }) : _weather = weather,
       _location = location;

  /// **2 seconds.** ARCHITECTURE.md §4.2's working figure, and it is a ceiling
  /// rather than a budget: nothing waits for it in the ordinary case, because
  /// both signals are already back or already `null`.
  static const Duration defaultTimeout = Duration(seconds: 2);

  /// How long either signal has before it counts as absent.
  final Duration timeout;

  final WeatherService _weather;
  final LocationService _location;

  /// Both services, asked **together**, each under [timeout].
  ///
  /// Whatever has not come back is `null`. **Never throws** — a reading is
  /// three nullable fields, and there is no failure it can report that a
  /// caller could do anything about.
  ///
  /// Nobody awaits this on a path a user is waiting on: at launch it is fired
  /// after the first frame, and at save it runs behind a row that has already
  /// been written (ADR-040, ADR-042).
  Future<AmbientReading> read() async {
    final (WeatherCondition? weather, GeoFix? fix) = await (
      _bestEffort(_weather.currentCondition()),
      _bestEffort(_location.currentFix()),
    ).wait;

    return (
      weather: weather,
      lat: fix?.lat,
      lon: fix?.lon,
      motion: _motionOf(fix),
    );
  }

  /// What the phone was doing, read off [fix] — ADR-037.
  ///
  /// **The same call answers the place and the movement**, so this is not a
  /// third signal and ADR-007's shape is untouched: two calls go out, and one
  /// of them now yields two facts. A fix that did not arrive is no motion,
  /// which is the same `null` the pin gets and is not drawn either.
  ///
  /// The thresholds are not here. They are a product decision and they live in
  /// [MotionLadder], where they can be tested as arithmetic — this method is
  /// only the wiring between one fix and one pure function.
  static MotionState? _motionOf(GeoFix? fix) => fix == null
      ? null
      : MotionLadder.from(
          speed: fix.speed,
          speedAccuracy: fix.speedAccuracy,
          altitude: fix.altitude,
        );

  /// [signal], or `null` if it was slow or it threw.
  ///
  /// **A thrown error is not louder than a timeout here**, which is the one
  /// place this codebase's *fail loudly in development* rule is deliberately
  /// not applied: ADR-007 says any signal that does not arrive is `null`, and
  /// to a screen that must not stall there is no useful difference between
  /// no network, no permission and a service that fell over.
  Future<T?> _bestEffort<T>(Future<T?> signal) => signal
      .timeout(timeout, onTimeout: () => null)
      .onError((Object _, StackTrace _) => null);
}

/// The capture behind `AmbientSignals`.
@Riverpod(keepAlive: true)
AmbientCapture ambientCapture(Ref ref) => AmbientCapture(
  weather: ref.watch(weatherServiceProvider),
  location: ref.watch(locationServiceProvider),
);
