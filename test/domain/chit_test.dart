import 'package:chit/domain/models/chit.dart';
import 'package:chit/domain/models/weather_condition.dart';
import 'package:flutter_test/flutter_test.dart';

/// The first of the three places the invariant of README §5 is held
/// (DATA-MODEL.md §2), and the only one that fails at the moment the wrong
/// object is built rather than at the moment it is written.
///
/// An assert is compiled out of a release build, which is why there are two
/// other places. It is still the one worth having: a chit that cannot be
/// constructed wrongly cannot be passed around wrongly either.
void main() {
  final DateTime when = DateTime(2026, 9, 15, 15, 42);

  Chit chit({
    String? text = 'Train 20 late.',
    TextOrigin? textOrigin = TextOrigin.typed,
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
    textOrigin: textOrigin,
    audioPath: audioPath,
    audioDuration: audioDuration,
    lat: lat,
    lon: lon,
  );

  group('the four legal shapes of DATA-MODEL.md §2', () {
    test('typed', () {
      final Chit c = chit();
      expect(c.hasText, isTrue);
      expect(c.hasAudio, isFalse);
    });

    test('recorded and transcribed', () {
      final Chit c = chit(
        textOrigin: TextOrigin.transcript,
        audioPath: 'audio/a.m4a',
        audioDuration: const Duration(seconds: 9),
      );
      expect(c.hasText, isTrue);
      expect(c.hasAudio, isTrue);
    });

    test('recorded, transcript corrected', () {
      final Chit c = chit(
        textOrigin: TextOrigin.transcriptEdited,
        audioPath: 'audio/a.m4a',
        audioDuration: const Duration(seconds: 9),
      );
      expect(c.textOrigin, TextOrigin.transcriptEdited);
      expect(c.hasAudio, isTrue);
    });

    test('recorded, nothing recognised — BEHAVIOUR.md §3.5', () {
      final Chit c = chit(
        text: null,
        textOrigin: null,
        audioPath: 'audio/a.m4a',
        audioDuration: const Duration(seconds: 9),
      );
      expect(c.hasText, isFalse);
      expect(c.hasAudio, isTrue);
    });
  });

  group('what cannot be built', () {
    test('neither text nor audio is not a chit', () {
      expect(
        () => chit(text: null, textOrigin: null),
        throwsA(isA<AssertionError>()),
      );
    });

    test('text without an origin', () {
      expect(() => chit(textOrigin: null), throwsA(isA<AssertionError>()));
    });

    test('an origin without text', () {
      expect(
        () => chit(
          text: null,
          audioPath: 'audio/a.m4a',
          audioDuration: Duration.zero,
        ),
        throwsA(isA<AssertionError>()),
      );
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
