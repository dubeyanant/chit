import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/models/weather_condition.dart';
import '../../domain/services/location_service.dart';
import '../../domain/services/weather_service.dart';
import '../../domain/weather/wmo_mapping.dart';

/// [WeatherService] over Open-Meteo — one endpoint, no key, no account.
///
/// **It takes no position, and that is ADR-025.** Where it gets one is its own
/// business on this side of the `domain` boundary: it reads the device's
/// **last known** fix, which is cached and instant, so the weather call never
/// queues behind the slow precise fix `currentFix` asks for. Handing it
/// coordinates would make ADR-007's two parallel signals sequential, and would
/// couple their failures — a refused permission would cost the word as well as
/// the pin.
///
/// **The mapping is not here.** A code, the daylight flag and a wind speed go
/// to `domain/weather/wmo_mapping.dart`, because which code counts as
/// *raining* is a product decision. This class does transport and parsing and
/// stops there.
///
/// **It never throws.** Offline, rate-limited, a 500, malformed JSON, a code
/// outside the table and a device with no fix at all are one answer: `null`,
/// which is not drawn (ADR-007).
final class OpenMeteoService implements WeatherService {
  /// Reads its position from [location] and calls out through [client].
  ///
  // Assigned rather than declared as initialising formals because a named
  // parameter cannot be private — same as `ChitRepositoryImpl`.
  // ignore_for_file: prefer_initializing_formals
  const OpenMeteoService({
    required LocationService location,
    required http.Client client,
  }) : _location = location,
       _client = client;

  /// The current-conditions endpoint.
  static const String host = 'api.open-meteo.com';

  /// The path it lives at.
  static const String path = '/v1/forecast';

  /// How long the call may take before it counts as absent.
  ///
  /// **Inside ADR-044's budget, not equal to it.** `AmbientCapture` bounds the
  /// whole capture; this bounds one leg of it, so a slow network cannot spend
  /// the time the location call is also drawing on. Five seconds is a mobile
  /// data figure rather than a wifi one.
  static const Duration timeout = Duration(seconds: 5);

  final LocationService _location;
  final http.Client _client;

  @override
  Future<WeatherCondition?> currentCondition() async {
    try {
      final GeoFix? fix = await _location.lastKnownFix();

      // **No fix, no weather, and that is ordinary** (ADR-025). On an install
      // that has never taken one this is what the first capture answers — and
      // it heals itself, because the *location* leg of that same capture is
      // what puts a fix in the platform's cache. By the first save there is
      // one, which is the capture that actually writes a row (ADR-042).
      if (fix == null) return null;

      final http.Response response = await _client
          .get(_uriFor(fix))
          .timeout(timeout);

      if (response.statusCode != 200) return null;

      return _conditionOf(response.body);
    } on Object {
      // Offline, DNS, TLS, a timeout, a malformed body. All the same absence.
      return null;
    }
  }

  /// The one request this service makes.
  ///
  /// **`wind_speed_unit=ms` is load-bearing.** Open-Meteo answers in km/h by
  /// default; `domain` speaks metres per second throughout, because
  /// `MotionLadder` and `WmoMapping` both hold thresholds and two units across
  /// two files is a conversion somebody eventually forgets. The unit is pinned
  /// here, at the boundary, rather than converted somewhere downstream.
  static Uri _uriFor(GeoFix fix) => Uri.https(host, path, <String, String>{
    'latitude': fix.lat.toStringAsFixed(4),
    'longitude': fix.lon.toStringAsFixed(4),
    'current': 'weather_code,wind_speed_10m,is_day',
    'wind_speed_unit': 'ms',
  });

  /// The word in [body], or `null` if it does not hold one.
  ///
  /// Every field is read defensively and independently. A response missing
  /// `is_day` still produces `raining` if it is raining — the mapping decides
  /// what a missing field costs, and it is never this method's business to
  /// refuse a whole reading because one number was absent.
  static WeatherCondition? _conditionOf(String body) {
    final Object? decoded = jsonDecode(body);
    if (decoded is! Map<String, Object?>) return null;

    final Object? current = decoded['current'];
    if (current is! Map<String, Object?>) return null;

    return WmoMapping.from(
      code: _intOf(current['weather_code']),
      isDay: switch (_intOf(current['is_day'])) {
        1 => true,
        0 => false,
        // Absent or a value Open-Meteo has never sent. The mapping turns this
        // into "say nothing about a clear sky" rather than a guess.
        _ => null,
      },
      windSpeed: _doubleOf(current['wind_speed_10m']),
    );
  }

  /// [value] as an `int`, or `null` — JSON gives no guarantee which it is.
  static int? _intOf(Object? value) => switch (value) {
    final int i => i,
    final double d => d.round(),
    _ => null,
  };

  /// [value] as a `double`, or `null`.
  static double? _doubleOf(Object? value) => switch (value) {
    final double d => d,
    final int i => i.toDouble(),
    _ => null,
  };
}
