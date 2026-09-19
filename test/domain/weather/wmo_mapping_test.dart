import 'package:chitt/domain/models/weather_condition.dart';
import 'package:chitt/domain/weather/wmo_mapping.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  WeatherCondition? at(int? code, {bool? isDay = true, double? wind = 0}) =>
      WmoMapping.from(code: code, isDay: isDay, windSpeed: wind);

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
      for (final int code in clearish) {
        expect(at(code), WeatherCondition.clear, reason: 'code $code');
      }
    });

    test('every known code resolves to a word', () {
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
      expect(at(3, wind: 12), WeatherCondition.windy);
      expect(at(45, wind: 12), WeatherCondition.windy);
    });

    test('an unrecognised code in a gale is still windy', () {
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
      for (final int code in clearish) {
        expect(at(code, isDay: null), isNull, reason: 'code $code');
      }
    });

    test('nothing else needs the flag', () {
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

  group('what is measured beats what is summarised — ADR-078', () {
    WeatherCondition? measured(
      int code, {
      double? rain,
      double? cloud,
      bool? isDay = true,
    }) => WmoMapping.from(
      code: code,
      isDay: isDay,
      windSpeed: 0,
      precipitation: rain,
      cloudCover: cloud,
    );

    test('a rain code with no rain under it is not raining', () {
      for (final int code in <int>[...drizzle, ...rain, ...showers]) {
        expect(
          measured(code, rain: 0, cloud: 90),
          WeatherCondition.overcast,
          reason: 'code $code fired on a forecast, not on a drop',
        );
      }
    });

    test('rain measured under a clear code is still rain', () {
      expect(measured(0, rain: 0.4, cloud: 10), WeatherCondition.raining);
    });

    test('the floor is a tenth of a millimetre', () {
      expect(
        measured(61, rain: WmoMapping.rainFloor),
        WeatherCondition.raining,
      );
      expect(
        measured(61, rain: WmoMapping.rainFloor - 0.01, cloud: 10),
        WeatherCondition.clear,
      );
    });

    test('cloud cover decides clear against overcast — open item 28', () {
      expect(measured(2, rain: 0, cloud: 85), WeatherCondition.overcast);
      expect(measured(2, rain: 0, cloud: 20), WeatherCondition.clear);
      expect(
        measured(2, rain: 0, cloud: 20, isDay: false),
        WeatherCondition.clearNight,
      );
    });

    test('fog and snow close the sky whatever the cloud cover says', () {
      for (final int code in <int>[...fog, ...snow]) {
        expect(
          measured(code, rain: 0, cloud: 0),
          WeatherCondition.overcast,
          reason: 'code $code',
        );
      }
    });

    test('with neither quantity it falls back to the code', () {
      expect(at(3), WeatherCondition.overcast);
      for (final int code in clearish) {
        expect(at(code), WeatherCondition.clear, reason: 'code $code');
      }
    });
  });
}
