import 'dart:async';

import 'package:chitta/data/weather/open_meteo_service.dart';
import 'package:chitta/domain/models/weather_condition.dart';
import 'package:chitta/domain/services/location_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  String body({int? code = 0, int? isDay = 1, double? wind = 0}) =>
      '{"current":{'
      '${code == null ? '' : '"weather_code":$code,'}'
      '${isDay == null ? '' : '"is_day":$isDay,'}'
      '${wind == null ? '' : '"wind_speed_10m":$wind,'}'
      '"interval":900}}';

  OpenMeteoService serviceOf(
    http.Client client, {
    GeoFix? fix = const GeoFix(lat: 19.076, lon: 72.8777),
  }) => OpenMeteoService(location: _Location(fix), client: client);

  group('the happy path', () {
    test('a code becomes a word', () async {
      final WeatherCondition? word = await serviceOf(_Ok(body(code: 61)))
          .currentCondition();

      expect(word, WeatherCondition.raining);
    });

    test('is_day picks between the two clear skies', () async {
      expect(
        await serviceOf(_Ok(body(isDay: 1))).currentCondition(),
        WeatherCondition.clear,
      );
      expect(
        await serviceOf(_Ok(body(isDay: 0))).currentCondition(),
        WeatherCondition.clearNight,
      );
    });

    test('the wind is read in metres per second, as asked for', () async {
      expect(
        await serviceOf(_Ok(body(wind: 8))).currentCondition(),
        WeatherCondition.windy,
      );
    });
  });

  group('the request', () {
    test(
      'it asks for metres per second and the three fields it maps',
      () async {
        final _Recording client = _Recording(body());

        await serviceOf(client).currentCondition();

        final Uri asked = client.asked!;
        expect(asked.host, OpenMeteoService.host);
        expect(asked.path, OpenMeteoService.path);
        expect(
          asked.queryParameters['wind_speed_unit'],
          'ms',
          reason: 'domain speaks m/s throughout — ADR-037, WmoMapping',
        );
        expect(asked.queryParameters['current'], contains('weather_code'));
        expect(asked.queryParameters['current'], contains('is_day'));
        expect(asked.queryParameters['current'], contains('wind_speed_10m'));
      },
    );

    test('it sends the last known fix, not a fresh one', () async {
      final _Location location = _Location(const GeoFix(lat: 1, lon: 2));
      await OpenMeteoService(
        location: location,
        client: _Ok(body()),
      ).currentCondition();

      expect(location.lastKnownCalls, 1);
      expect(location.currentCalls, 0);
    });

    test('no fix means no call at all', () async {
      final _Recording client = _Recording(body());

      final WeatherCondition? word = await serviceOf(
        client,
        fix: null,
      ).currentCondition();

      expect(word, isNull);
      expect(client.asked, isNull, reason: 'nothing to ask about');
    });
  });

  group('every failure is the same absence — ADR-007', () {
    test('a status that is not 200', () async {
      for (final int status in <int>[400, 429, 500, 503]) {
        expect(
          await serviceOf(_Status(status)).currentCondition(),
          isNull,
          reason: 'HTTP $status',
        );
      }
    });

    test('a body that is not JSON', () async {
      expect(
        await serviceOf(_Ok('<html>nope</html>')).currentCondition(),
        isNull,
      );
    });

    test('JSON of the wrong shape', () async {
      for (final String malformed in <String>[
        '[]',
        '{}',
        '{"current":null}',
        '{"current":[]}',
        '{"current":{}}',
      ]) {
        expect(
          await serviceOf(_Ok(malformed)).currentCondition(),
          isNull,
          reason: malformed,
        );
      }
    });

    test('a client that throws — offline, DNS, TLS', () async {
      expect(await serviceOf(_Throws()).currentCondition(), isNull);
    });

    test('a client that never comes back', () async {
      expect(await serviceOf(_Hangs()).currentCondition(), isNull);
    });

    test('a location service that throws is not this service\'s problem', () {
      expect(
        OpenMeteoService(
          location: _ThrowingLocation(),
          client: _Ok(body()),
        ).currentCondition(),
        completion(isNull),
      );
    });
  });

  group('the fields are read independently', () {
    test('a missing is_day still reports rain', () async {
      expect(
        await serviceOf(_Ok(body(code: 61, isDay: null))).currentCondition(),
        WeatherCondition.raining,
      );
    });

    test('a missing is_day silences a clear sky', () async {
      expect(
        await serviceOf(_Ok(body(code: 0, isDay: null))).currentCondition(),
        isNull,
      );
    });

    test('a missing wind is simply not wind', () async {
      expect(
        await serviceOf(_Ok(body(code: 3, wind: null))).currentCondition(),
        WeatherCondition.overcast,
      );
    });

    test('a code outside the table is null, not a guess', () async {
      expect(await serviceOf(_Ok(body(code: 4242))).currentCondition(), isNull);
    });
  });
}

final class _Location implements LocationService {
  _Location(this.fix);

  final GeoFix? fix;
  int lastKnownCalls = 0;
  int currentCalls = 0;

  @override
  Future<GeoFix?> lastKnownFix() async {
    lastKnownCalls++;
    return fix;
  }

  @override
  Future<GeoFix?> currentFix() async {
    currentCalls++;
    return fix;
  }

  @override
  Future<LocationPermissionOutcome> requestPermission() async =>
      LocationPermissionOutcome.granted;
}

final class _ThrowingLocation implements LocationService {
  @override
  Future<GeoFix?> lastKnownFix() async => throw const _Failure();

  @override
  Future<GeoFix?> currentFix() async => throw const _Failure();

  @override
  Future<LocationPermissionOutcome> requestPermission() async =>
      LocationPermissionOutcome.granted;
}

class _Ok extends http.BaseClient {
  _Ok(this.payload);

  final String payload;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      http.StreamedResponse(Stream<List<int>>.value(payload.codeUnits), 200);
}

class _Recording extends http.BaseClient {
  _Recording(this.payload);

  final String payload;
  Uri? asked;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    asked = request.url;
    return http.StreamedResponse(
      Stream<List<int>>.value(payload.codeUnits),
      200,
    );
  }
}

class _Status extends http.BaseClient {
  _Status(this.status);

  final int status;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      http.StreamedResponse(const Stream<List<int>>.empty(), status);
}

class _Throws extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      throw const _Failure();
}

class _Hangs extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      Completer<http.StreamedResponse>().future;
}

final class _Failure implements Exception {
  const _Failure();
}
