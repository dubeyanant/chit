import 'package:chit/domain/models/weather_condition.dart';
import 'package:chit/domain/weather/wmo_mapping.dart';
import 'package:flutter_test/flutter_test.dart';

/// The WMO mapping — M3 group G, and the whole of the milestone's weather
/// arithmetic.
///
/// The claim the table-driven cases are really making is the one in the class
/// doc: **nothing falls through to `null` because somebody forgot it.** An
/// example-per-case test would pass happily with half the published table
/// unmapped, so the codes are walked rather than sampled.
void main() {
  /// Calm daylight unless a case says otherwise, so a test about codes is not
  /// also a test about wind.
  WeatherCondition? at(int? code, {bool? isDay = true, double? wind = 0}) =>
      WmoMapping.from(code: code, isDay: isDay, windSpeed: wind);

  /// Every code Open-Meteo documents, by group.
  const List<int> drizzle = <int>[51, 53, 55, 56, 57];
  const List<int> rain = <int>[61, 63, 65, 66, 67];
  const List<int> showers = <int>[80, 81, 82];
  const List<int> thunder = <int>[95, 96, 99];
  const List<int> snow = <int>[71, 73, 75, 77, 85, 86];
  const List<int> fog = <int>[45, 48];
  const List<int> clearish = <int>[0, 1, 2];

  group('the published table, walked rather than sampled', () {
    test('everything liquid that falls is raining', () {
      for (final int code in <int>[
        ...drizzle,
        ...rain,
        ...showers,
        ...thunder,
      ]) {
        expect(at(code), WeatherCondition.raining, reason: 'code $code');
      }
    });

    test('a closed sky is overcast — including fog', () {
      for (final int code in <int>[3, ...fog]) {
        expect(at(code), WeatherCondition.overcast, reason: 'code $code');
      }
    });

    test('clear and nearly clear are clear', () {
      // §3.6's word is "clear or nearly clear", so mainly-clear and
      // partly-cloudy belong here. Only a fully overcast sky is closed.
      for (final int code in clearish) {
        expect(at(code), WeatherCondition.clear, reason: 'code $code');
      }
    });

    test('every known code resolves to a word', () {
      // The claim this file exists for. If a code is added to one of the sets
      // and not to a branch, it lands here rather than on a chit.
      for (final int code in WmoMapping.known) {
        expect(at(code), isNotNull, reason: 'code $code fell through');
      }
    });

    test('the sets do not overlap — a code has one meaning', () {
      expect(
        WmoMapping.known.length,
        <int>[
          ...drizzle,
          ...rain,
          ...showers,
          ...thunder,
          ...snow,
          ...fog,
          3,
          ...clearish,
        ].length,
        reason: 'a code claimed by two sets would resolve by branch order',
      );
    });
  });

  group('snow, which §3.6 has no word for', () {
    test('it is overcast rather than raining', () {
      // Of the five words available, `overcast` is the only one that is not
      // actually false while it snows: the sky is closed. `raining` would put
      // a wrong noun in somebody's own journal. OPEN-QUESTIONS.md carries this.
      for (final int code in snow) {
        expect(at(code), WeatherCondition.overcast, reason: 'code $code');
      }
    });
  });

  group('the wind is measured, not categorised', () {
    test('at the floor and above, a clear sky is windy', () {
      for (final double wind in <double>[WmoMapping.windyFloor, 9, 30]) {
        expect(at(0, wind: wind), WeatherCondition.windy, reason: '$wind m/s');
      }
    });

    test('below the floor it says nothing', () {
      for (final double wind in <double>[0, 3, WmoMapping.windyFloor - 0.001]) {
        expect(at(0, wind: wind), WeatherCondition.clear, reason: '$wind m/s');
      }
    });

    test('rain outranks wind — §3.6 says so in as many words', () {
      for (final int code in <int>[...rain, ...thunder]) {
        expect(
          at(code, wind: 40),
          WeatherCondition.raining,
          reason: 'code $code in a gale',
        );
      }
    });

    test('wind outranks a closed sky', () {
      // §3.6 only licensed windy over clear and was silent about overcast.
      // A grey day is a sky's default and a windy one is not, so the wind is
      // the fact worth the slot.
      expect(at(3, wind: 12), WeatherCondition.windy);
      expect(at(45, wind: 12), WeatherCondition.windy);
    });

    test('an unrecognised code in a gale is still windy', () {
      // Wind is a number rather than a category, so it stands on its own.
      expect(at(4242, wind: 12), WeatherCondition.windy);
    });

    test('a missing or malformed wind reading is simply not wind', () {
      for (final double? wind in <double?>[null, double.nan]) {
        expect(at(0, wind: wind), WeatherCondition.clear, reason: '$wind');
      }
    });
  });

  group('is_day, and what happens without it', () {
    test('a clear sky after dark is clear night', () {
      for (final int code in clearish) {
        expect(
          at(code, isDay: false),
          WeatherCondition.clearNight,
          reason: 'code $code',
        );
      }
    });

    test('without the flag, a clear sky says nothing at all', () {
      // `clear` and `clearNight` are the same sky and differ only by the flag.
      // Guessing `clear` at two in the morning is exactly the confident
      // wrongness ADR-007 would rather do without.
      for (final int code in clearish) {
        expect(at(code, isDay: null), isNull, reason: 'code $code');
      }
    });

    test('nothing else needs the flag', () {
      // Rain is rain at midnight, and a closed sky is closed.
      expect(at(61, isDay: null), WeatherCondition.raining);
      expect(at(3, isDay: null), WeatherCondition.overcast);
      expect(at(0, isDay: null, wind: 12), WeatherCondition.windy);
    });
  });

  group('nothing to say', () {
    test('no code and no wind is null', () {
      expect(at(null, wind: null), isNull);
      expect(at(null), isNull);
    });

    test('a code outside the table is null, not a guess', () {
      for (final int code in <int>[-1, 4, 30, 99999]) {
        expect(at(code), isNull, reason: 'code $code');
      }
    });
  });
}
