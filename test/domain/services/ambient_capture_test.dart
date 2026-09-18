import 'dart:async';

import 'package:chit/domain/models/motion_state.dart';
import 'package:chit/domain/models/weather_condition.dart';
import 'package:chit/domain/services/ambient_capture.dart';
import 'package:chit/domain/services/ambient_signals.dart';
import 'package:chit/domain/services/location_service.dart';
import 'package:chit/domain/services/weather_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
      expect(AmbientCapture.defaultTimeout, const Duration(seconds: 12));
    });
  });

  group('a signal that does not arrive is null', () {
    test('weather that says nothing', () async {
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
      final AmbientReading reading = await capture(
        weather: _SlowWeather(),
        location: _ThrowingLocation(),
      ).read();

      expect(reading, AmbientSignals.nothing);
    });
  });

  group('nothing here can block whoever called it', () {
    test('the two go out in parallel, not one after the other', () async {
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
      final AmbientReading reading = await capture(
        weather: const _Weather(null),
        location: const _Location(GeoFix(lat: 1, lon: 2)),
      ).read();

      expect(reading.lat, 1);
      expect(reading.motion, isNull);
    });

    test('no fix is no motion, the same null the pin gets', () async {
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

mixin _Grants implements LocationService {
  @override
  Future<LocationPermissionOutcome> requestPermission() async =>
      LocationPermissionOutcome.granted;

  @override
  Future<GeoFix?> lastKnownFix() async => null;
}

final class _Weather implements WeatherService {
  const _Weather(this.condition);

  final WeatherCondition? condition;

  @override
  Future<WeatherCondition?> currentCondition() async => condition;
}

final class _Location with _Grants implements LocationService {
  const _Location(this.fix);

  final GeoFix? fix;

  @override
  Future<GeoFix?> currentFix() async => fix;
}

final class _SlowWeather implements WeatherService {
  @override
  Future<WeatherCondition?> currentCondition() =>
      Completer<WeatherCondition?>().future;

  @override
  String toString() => 'weather that hangs';
}

final class _SlowLocation with _Grants implements LocationService {
  @override
  Future<GeoFix?> currentFix() => Completer<GeoFix?>().future;

  @override
  String toString() => 'location that hangs';
}

final class _ThrowingWeather implements WeatherService {
  @override
  Future<WeatherCondition?> currentCondition() async => throw const _Failure();

  @override
  String toString() => 'weather that throws';
}

final class _ThrowingLocation with _Grants implements LocationService {
  @override
  Future<GeoFix?> currentFix() async => throw const _Failure();

  @override
  String toString() => 'location that throws';
}

final class _Failure implements Exception {
  const _Failure();
}

final class _Order {
  bool weatherAnswered = false;
  bool locationAskedBeforeWeatherAnswered = false;
}

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

final class _OrderedLocation with _Grants implements LocationService {
  _OrderedLocation(this.order);

  final _Order order;

  @override
  Future<GeoFix?> currentFix() async {
    order.locationAskedBeforeWeatherAnswered = !order.weatherAnswered;
    return const GeoFix(lat: 1, lon: 2);
  }
}
