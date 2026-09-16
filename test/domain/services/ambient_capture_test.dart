import 'dart:async';

import 'package:chit/domain/models/motion_state.dart';
import 'package:chit/domain/models/weather_condition.dart';
import 'package:chit/domain/services/ambient_capture.dart';
import 'package:chit/domain/services/ambient_signals.dart';
import 'package:chit/domain/services/location_service.dart';
import 'package:chit/domain/services/weather_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// ADR-007, as a test rather than as an intention.
///
/// *Weather and location are gathered in parallel, each under a short timeout.
/// Any signal that does not arrive is null.* Every clause of that is checkable
/// and every one of them is checked here — including the two ways a signal
/// fails to arrive, because a service that throws and a service that hangs
/// have to look identical to the caller, and only one of them is obvious.
///
/// **The time is not here any more.** Under ADR-040 a chit is stamped when it
/// is saved, and the clock is read where a time is used rather than inside a
/// capture; ADR-042 moved the *when* of capture to `AmbientSignals`. What is
/// left in this class is the *what*, which is the part with the failure modes.
///
/// The fakes are honest, which is CLAUDE.md §4.1's Liskov rule: a fake that
/// "fails" fails the way the real thing does. [_SlowWeather] does not return a
/// fast `null` pretending to be a timeout — it actually never completes, so
/// the timeout is what produces the `null` and the test would notice if it
/// stopped doing so.
void main() {
  /// Short enough that the slow cases cost milliseconds, long enough that the
  /// fast ones are never a race. The product figure is
  /// [AmbientCapture.defaultTimeout].
  const Duration timeout = Duration(milliseconds: 20);

  AmbientCapture capture({
    required WeatherService weather,
    required LocationService location,
  }) => AmbientCapture(weather: weather, location: location, timeout: timeout);

  group('both signals arrive', () {
    test('the reading carries the word and the fix', () async {
      final AmbientReading reading = await capture(
        weather: const _Weather(WeatherCondition.overcast),
        location: const _Location(GeoFix(lat: 51.4769, lon: -0.0005)),
      ).read();

      expect(reading.weather, WeatherCondition.overcast);
      expect(reading.lat, 51.4769);
      expect(reading.lon, -0.0005);
    });

    test("the default budget is ADR-044's twelve seconds", () {
      // Twelve, not ADR-007's original two. Nothing waits on a capture since
      // ADR-042, and two seconds is not long enough for a GPS fix — which is
      // exactly how the pin came to be missing on a handset.
      expect(AmbientCapture.defaultTimeout, const Duration(seconds: 12));
    });
  });

  group('a signal that does not arrive is null', () {
    test('weather that says nothing', () async {
      // The ordinary offline answer, and the one the real service gives.
      final AmbientReading reading = await capture(
        weather: const _Weather(null),
        location: const _Location(GeoFix(lat: 1, lon: 2)),
      ).read();

      expect(reading.weather, isNull);
      expect(reading.lat, 1, reason: 'the other signal is untouched');
    });

    test('weather that hangs — the timeout is what makes it null', () async {
      final AmbientReading reading = await capture(
        weather: _SlowWeather(),
        location: const _Location(GeoFix(lat: 1, lon: 2)),
      ).read();

      expect(reading.weather, isNull);
      expect(reading.lat, 1);
    });

    test('weather that throws looks exactly the same', () async {
      // A service that fell over and a service that is merely offline are the
      // same event to a screen that must not stall (ADR-007).
      final AmbientReading reading = await capture(
        weather: _ThrowingWeather(),
        location: const _Location(GeoFix(lat: 1, lon: 2)),
      ).read();

      expect(reading.weather, isNull);
    });

    test('a refused permission is no fix, and no half of one', () async {
      final AmbientReading reading = await capture(
        weather: const _Weather(WeatherCondition.clear),
        location: const _Location(null),
      ).read();

      expect(reading.lat, isNull);
      expect(reading.lon, isNull);
      expect(
        reading.weather,
        WeatherCondition.clear,
        reason: 'ADR-025: the two signals fail independently',
      );
    });

    test('location that hangs, and location that throws', () async {
      for (final LocationService service in <LocationService>[
        _SlowLocation(),
        _ThrowingLocation(),
      ]) {
        final AmbientReading reading = await capture(
          weather: const _Weather(WeatherCondition.windy),
          location: service,
        ).read();

        expect(reading.lat, isNull, reason: '$service');
        expect(reading.weather, WeatherCondition.windy);
      }
    });

    test('nothing arrives at all, and that is a legal reading', () async {
      // The state a phone in flight mode with location off is actually in.
      // BEHAVIOUR.md §3.6's line is then one fact long, and that is correct
      // behaviour rather than a gap to fill with a placeholder.
      final AmbientReading reading = await capture(
        weather: _SlowWeather(),
        location: _ThrowingLocation(),
      ).read();

      expect(reading, AmbientSignals.nothing);
    });
  });

  group('nothing here can block whoever called it', () {
    test('the two go out in parallel, not one after the other', () async {
      // The claim is worth a test because the sequential version passes every
      // other test in this file: two 20ms timeouts in a row still produce the
      // same empty reading, just twice as slowly. Each fake records whether
      // the other had already been asked when it was.
      final _Order order = _Order();

      await capture(
        weather: _OrderedWeather(order),
        location: _OrderedLocation(order),
      ).read();

      expect(
        order.locationAskedBeforeWeatherAnswered,
        isTrue,
        reason: 'location was still waiting on weather to come back',
      );
    });

    test('both hanging costs one timeout, not two', () async {
      final Stopwatch clock = Stopwatch()..start();

      await capture(weather: _SlowWeather(), location: _SlowLocation()).read();

      clock.stop();
      expect(
        clock.elapsed,
        lessThan(timeout * 2),
        reason: 'the timeouts ran side by side',
      );
    });
  });

  group('ADR-037: motion rides in on the fix, and costs no second call', () {
    test('a moving fix becomes a motion state', () async {
      final AmbientReading reading = await capture(
        weather: const _Weather(null),
        location: const _Location(
          GeoFix(lat: 1, lon: 2, speed: 20, speedAccuracy: 1),
        ),
      ).read();

      expect(reading.motion, MotionState.traveling);
    });

    test('a still fix is stationary, stored and never drawn', () async {
      final AmbientReading reading = await capture(
        weather: const _Weather(null),
        location: const _Location(
          GeoFix(lat: 1, lon: 2, speed: 0.1, speedAccuracy: 0.5),
        ),
      ).read();

      expect(reading.motion, MotionState.stationary);
    });

    test('a fix with no speed carries a place and no motion', () async {
      // The ordinary indoor case: the pin is drawn and nothing else is.
      final AmbientReading reading = await capture(
        weather: const _Weather(null),
        location: const _Location(GeoFix(lat: 1, lon: 2)),
      ).read();

      expect(reading.lat, 1);
      expect(reading.motion, isNull);
    });

    test('no fix is no motion, the same null the pin gets', () async {
      // A refused permission costs the pin and the motion together, because
      // they are one signal. ADR-025 is why it does not also cost the weather.
      for (final LocationService service in <LocationService>[
        const _Location(null),
        _SlowLocation(),
        _ThrowingLocation(),
      ]) {
        final AmbientReading reading = await capture(
          weather: const _Weather(WeatherCondition.clear),
          location: service,
        ).read();

        expect(reading.motion, isNull, reason: '$service');
        expect(reading.lat, isNull, reason: '$service');
        expect(reading.weather, WeatherCondition.clear);
      }
    });
  });
}

/// Grants, because none of these fakes is about the permission flow.
///
/// A fake that refused while still answering `currentFix` would be the Liskov
/// violation CLAUDE.md §4.1 warns about, so the two always agree here.
/// `first_run_controller_test.dart` is where refusal is exercised.
mixin _Grants implements LocationService {
  @override
  Future<LocationPermissionOutcome> requestPermission() async =>
      LocationPermissionOutcome.granted;

  /// Not read here: `AmbientCapture` asks for the current fix, never the
  /// cached one. Only the weather service reads that (ADR-025).
  @override
  Future<GeoFix?> lastKnownFix() async => null;
}

/// A service that answers [condition], which may be `null`.
final class _Weather implements WeatherService {
  const _Weather(this.condition);

  final WeatherCondition? condition;

  @override
  Future<WeatherCondition?> currentCondition() async => condition;
}

/// A service that answers [fix], which may be `null`.
final class _Location with _Grants implements LocationService {
  const _Location(this.fix);

  final GeoFix? fix;

  @override
  Future<GeoFix?> currentFix() async => fix;
}

/// Never comes back. The timeout is what has to produce the `null`.
final class _SlowWeather implements WeatherService {
  @override
  Future<WeatherCondition?> currentCondition() =>
      Completer<WeatherCondition?>().future;

  @override
  String toString() => 'weather that hangs';
}

/// Never comes back.
final class _SlowLocation with _Grants implements LocationService {
  @override
  Future<GeoFix?> currentFix() => Completer<GeoFix?>().future;

  @override
  String toString() => 'location that hangs';
}

/// Fails the way a service that is down fails.
final class _ThrowingWeather implements WeatherService {
  @override
  Future<WeatherCondition?> currentCondition() async => throw const _Failure();

  @override
  String toString() => 'weather that throws';
}

/// Fails the way a refused permission used to, before ADR-007.
final class _ThrowingLocation with _Grants implements LocationService {
  @override
  Future<GeoFix?> currentFix() async => throw const _Failure();

  @override
  String toString() => 'location that throws';
}

/// Stands in for whatever `http` and `geolocator` actually throw. What matters
/// is that it is not an `Error` — a bug in our own code should still crash.
final class _Failure implements Exception {
  // A failure from the outside world.
  const _Failure();
}

/// Which service was asked, and when, across one capture.
final class _Order {
  bool weatherAnswered = false;
  bool locationAskedBeforeWeatherAnswered = false;
}

/// Answers after a turn of the event loop, so that a sequential
/// implementation would have to wait for it before asking for the other.
final class _OrderedWeather implements WeatherService {
  _OrderedWeather(this.order);

  final _Order order;

  @override
  Future<WeatherCondition?> currentCondition() async {
    await Future<void>.delayed(Duration.zero);
    order.weatherAnswered = true;
    return WeatherCondition.raining;
  }
}

/// Records whether the weather had already come back when it was asked.
final class _OrderedLocation with _Grants implements LocationService {
  _OrderedLocation(this.order);

  final _Order order;

  @override
  Future<GeoFix?> currentFix() async {
    order.locationAskedBeforeWeatherAnswered = !order.weatherAnswered;
    return const GeoFix(lat: 1, lon: 2);
  }
}
