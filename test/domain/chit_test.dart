import 'package:chitta/domain/models/chit.dart';
import 'package:chitta/domain/models/weather_condition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime when = DateTime(2026, 9, 15, 15, 42);

  Chit chit({
    String? text = 'Train 20 late.',
    String? audioPath,
    Duration? audioDuration,
    double? lat,
    double? lon,
  }) => Chit(
    id: 'a',
    createdAt: when,
    localDay: Chit.localDayOf(when),
    updatedAt: when,
    text: text,
    audioPath: audioPath,
    audioDuration: audioDuration,
    lat: lat,
    lon: lon,
  );

  group('the three legal shapes of DATA-MODEL.md §2', () {
    test('words alone', () {
      final Chit c = chit();
      expect(c.hasText, isTrue);
      expect(c.hasAudio, isFalse);
    });

    test('words and a recording', () {
      final Chit c = chit(
        audioPath: 'audio/a.m4a',
        audioDuration: const Duration(seconds: 9),
      );
      expect(c.hasText, isTrue);
      expect(c.hasAudio, isTrue);
    });

    test('a recording alone', () {
      final Chit c = chit(
        text: null,
        audioPath: 'audio/a.m4a',
        audioDuration: const Duration(seconds: 9),
      );
      expect(c.hasText, isFalse);
      expect(c.hasAudio, isTrue);
    });
  });

  group('what cannot be built', () {
    test('neither text nor audio is not a chit', () {
      expect(() => chit(text: null), throwsA(isA<AssertionError>()));
    });

    test('empty text is no text — it is the chit §3.1 refuses to save', () {
      expect(() => chit(text: ''), throwsA(isA<AssertionError>()));
    });

    test('a recording without a length', () {
      expect(
        () => chit(audioPath: 'audio/a.m4a'),
        throwsA(isA<AssertionError>()),
      );
    });

    test('half a coordinate is not a place', () {
      expect(() => chit(lat: 19.07), throwsA(isA<AssertionError>()));
    });
  });

  group('the local day (ADR-006)', () {
    test('is yyyymmdd in the zone the wall clock was read in', () {
      expect(Chit.localDayOf(DateTime(2026, 9, 15, 15, 42)), 20260915);
      expect(Chit.localDayOf(DateTime(2026, 1, 1)), 20260101);
      expect(Chit.localDayOf(DateTime(2026, 12, 31, 23, 59, 59)), 20261231);
    });

    test('a minute either side of midnight is two days', () {
      expect(Chit.localDayOf(DateTime(2026, 9, 14, 23, 59)), 20260914);
      expect(Chit.localDayOf(DateTime(2026, 9, 15, 0, 1)), 20260915);
    });

    test('sorts in the same order as the days it stands for', () {
      expect(
        Chit.localDayOf(DateTime(2026, 9, 30)),
        lessThan(Chit.localDayOf(DateTime(2026, 10, 1))),
      );
    });
  });

  group('the boundaries of a day (ADR-006)', () {
    test('is midnight at the start of the day the moment belongs to', () {
      expect(
        Chit.startOfLocalDay(DateTime(2026, 9, 16, 15, 42, 7, 8, 9)),
        DateTime(2026, 9, 16),
      );
    });

    test('agrees with localDayOf, which is the whole reason it is here', () {
      for (final DateTime when in <DateTime>[
        DateTime(2026, 9, 16, 0, 0),
        DateTime(2026, 9, 16, 12),
        DateTime(2026, 9, 16, 23, 59, 59, 999),
      ]) {
        expect(
          Chit.localDayOf(Chit.startOfLocalDay(when)),
          Chit.localDayOf(when),
          reason: 'the boundary of a day must belong to that day',
        );
      }
    });

    test(
      'is the *first* instant of the day, not the last of the one before',
      () {
        final DateTime midnight = Chit.startOfLocalDay(
          DateTime(2026, 9, 16, 4),
        );
        expect(Chit.localDayOf(midnight), 20260916);
        expect(
          Chit.localDayOf(midnight.subtract(const Duration(microseconds: 1))),
          20260915,
        );
      },
    );

    group('offsetDays counts whole local days, not 24-hour blocks', () {
      test('across a month', () {
        expect(
          Chit.startOfLocalDay(DateTime(2026, 10, 1, 9), offsetDays: -2),
          DateTime(2026, 9, 29),
        );
      });

      test('across a year', () {
        expect(
          Chit.startOfLocalDay(DateTime(2027, 1, 1, 9), offsetDays: -2),
          DateTime(2026, 12, 30),
        );
        expect(
          Chit.startOfLocalDay(DateTime(2026, 12, 31, 9), offsetDays: 1),
          DateTime(2027),
        );
      });

      test('across a leap day', () {
        expect(
          Chit.startOfLocalDay(DateTime(2028, 3, 1, 9), offsetDays: -1),
          DateTime(2028, 2, 29),
        );
      });

      test('an offset of zero is the plain boundary', () {
        final DateTime when = DateTime(2026, 9, 16, 15, 42);
        expect(
          Chit.startOfLocalDay(when, offsetDays: 0),
          Chit.startOfLocalDay(when),
        );
      });
    });
  });

  test(
    'the stamp is the three signals of §3.6 as the one row they are drawn as',
    () {
      final Chit c = chit(
        lat: 19.07,
        lon: 72.87,
      ).copyWith(weather: WeatherCondition.raining);
      expect(c.stamp.capturedAt, c.createdAt);
      expect(c.stamp.weather, WeatherCondition.raining);
      expect(c.stamp.hasLocation, isTrue);
    },
  );

  test('a chit with no fix has no location, and nothing to draw', () {
    expect(chit().stamp.hasLocation, isFalse);
  });
}
