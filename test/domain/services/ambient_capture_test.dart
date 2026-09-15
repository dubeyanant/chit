import 'dart:async';

import 'package:chit/domain/models/ambient_stamp.dart';
import 'package:chit/domain/models/weather_condition.dart';
import 'package:chit/domain/services/ambient_capture.dart';
import 'package:chit/domain/services/location_service.dart';
import 'package:chit/domain/services/weather_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';

/// ADR-007, as a test rather than as an intention.
///
/// *Time, weather and location are gathered when the open chit is created, in
/// parallel, each under a short timeout. Any signal that does not arrive is
/// null.* Every clause of that is checkable and every one of them is checked
/// here — including the two ways a signal fails to arrive, because a service
/// that throws and a service that hangs have to look identical from the
/// composer, and only one of them is obvious.
///
/// The fakes are honest, which is CLAUDE.md §4.1's Liskov rule: a fake that
/// "fails" fails the way the real thing does. [_SlowWeather] does not return a
/// fast `null` pretending to be a timeout — it actually never completes, so
/// the timeout is what produces the `null` and the test would notice if it
/// stopped doing so.
void main() {
  final DateTime openedAt = DateTime(2026, 9, 16, 15, 42);

  /// Short enough that the slow cases cost milliseconds, long enough that the
  /// fast ones are never a race. The product figure is
  /// [AmbientCapture.defaultTimeout].
  const Duration timeout = Duration(milliseconds: 20);

  AmbientCapture capture({
    required WeatherService weather,
    required LocationService location,
  }) => AmbientCapture(
    clock: FakeClock(openedAt),
    weather: weather,
    location: location,
    timeout: timeout,
  );

  group('both signals arrive', () {
    test('the stamp carries the time, the word and the fix', () async {
      final AmbientStamp stamp = await capture(
        weather: const _Weather(WeatherCondition.overcast),
        location: const _Location((lat: 51.4769, lon: -0.0005)),
      ).capture();

      expect(stamp.capturedAt, openedAt);
      expect(stamp.weather, WeatherCondition.overcast);
      expect(stamp.lat, 51.4769);
      expect(stamp.lon, -0.0005);
      expect(stamp.hasLocation, isTrue);
    });

    test('the default timeout is ARCHITECTURE.md §4.2\'s two seconds', () {
      expect(AmbientCapture.defaultTimeout, const Duration(seconds: 2));
    });
  });

  group('a signal that does not arrive is null', () {
    test('weather that says nothing', () async {
      // The ordinary offline answer, and the one the real service gives.
      final AmbientStamp stamp = await capture(
        weather: const _Weather(null),
        location: const _Location((lat: 1.0, lon: 2.0)),
      ).capture();

      expect(stamp.weather, isNull);
      expect(
        stamp.hasLocation,
        isTrue,
        reason: 'the other signal is untouched',
      );
    });

    test('weather that hangs — the timeout is what makes it null', () async {
      final AmbientStamp stamp = await capture(
        weather: _SlowWeather(),
        location: const _Location((lat: 1.0, lon: 2.0)),
      ).capture();

      expect(stamp.weather, isNull);
      expect(stamp.hasLocation, isTrue);
    });

    test('weather that throws looks exactly the same', () async {
      // A service that fell over and a service that is merely offline are the
      // same event to a composer that must not stall (ADR-007).
      final AmbientStamp stamp = await capture(
        weather: _ThrowingWeather(),
        location: const _Location((lat: 1.0, lon: 2.0)),
      ).capture();

      expect(stamp.weather, isNull);
    });

    test('a refused permission is no fix, and no half of one', () async {
      final AmbientStamp stamp = await capture(
        weather: const _Weather(WeatherCondition.clear),
        location: const _Location(null),
      ).capture();

      expect(stamp.hasLocation, isFalse);
      expect(stamp.lat, isNull);
      expect(stamp.lon, isNull);
      expect(stamp.weather, WeatherCondition.clear);
    });

    test('location that hangs, and location that throws', () async {
      for (final LocationService service in <LocationService>[
        _SlowLocation(),
        _ThrowingLocation(),
      ]) {
        final AmbientStamp stamp = await capture(
          weather: const _Weather(WeatherCondition.windy),
          location: service,
        ).capture();

        expect(stamp.hasLocation, isFalse, reason: '$service');
        expect(stamp.weather, WeatherCondition.windy);
      }
    });

    test('nothing arrives at all, and a stamp is still a stamp', () async {
      // The state a phone in flight mode with location off is actually in.
      // BEHAVIOUR.md §3.6's line is then one fact long, and that is correct
      // behaviour rather than a gap to fill with a placeholder.
      final AmbientStamp stamp = await capture(
        weather: _SlowWeather(),
        location: _ThrowingLocation(),
      ).capture();

      expect(stamp.capturedAt, openedAt);
      expect(stamp.weather, isNull);
      expect(stamp.hasLocation, isFalse);
    });
  });

  group('nothing here can block the composer', () {
    test('the two go out in parallel, not one after the other', () async {
      // The claim is worth a test because the sequential version passes every
      // other test in this file: two 20ms timeouts in a row still produce the
      // same empty stamp, just twice as slowly. Each fake records whether the
      // other had already been asked when it was.
      final _Order order = _Order();

      await capture(
        weather: _OrderedWeather(order),
        location: _OrderedLocation(order),
      ).capture();

      expect(
        order.locationAskedBeforeWeatherAnswered,
        isTrue,
        reason: 'location was still waiting on weather to come back',
      );
    });

    test('both hanging costs one timeout, not two', () async {
      final Stopwatch clock = Stopwatch()..start();

      await capture(
        weather: _SlowWeather(),
        location: _SlowLocation(),
      ).capture();

      clock.stop();
      expect(
        clock.elapsed,
        lessThan(timeout * 2),
        reason: 'the timeouts ran side by side',
      );
    });
  });

  group('ADR-021: the chit is stamped when it is opened', () {
    test('the time is read before the signals are asked for', () async {
      // capturedAt becomes the chit's createdAt, which decides where it falls
      // in the thread and on the timeline. A clock read after a slow network
      // came back would put the chit two seconds after the moment it belongs
      // to — here, a whole timeout late.
      final FakeClock clock = FakeClock(openedAt);
      final AmbientCapture ambient = AmbientCapture(
        clock: clock,
        weather: _SlowWeather(),
        location: _SlowLocation(),
        timeout: timeout,
      );

      final AmbientStamp stamp = await ambient.capture();

      expect(stamp.capturedAt, openedAt);
      expect(clock.reads, 1, reason: 'read once, at the top, and never again');
    });
  });
}

/// A service that answers [condition], which may be `null`.
final class _Weather implements WeatherService {
  const _Weather(this.condition);

  final WeatherCondition? condition;

  @override
  Future<WeatherCondition?> currentCondition() async => condition;
}

/// A service that answers [fix], which may be `null`.
final class _Location implements LocationService {
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
final class _SlowLocation implements LocationService {
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
final class _ThrowingLocation implements LocationService {
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
final class _OrderedLocation implements LocationService {
  _OrderedLocation(this.order);

  final _Order order;

  @override
  Future<GeoFix?> currentFix() async {
    order.locationAskedBeforeWeatherAnswered = !order.weatherAnswered;
    return (lat: 1.0, lon: 2.0);
  }
}
