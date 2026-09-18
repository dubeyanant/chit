import 'package:chitta/domain/find/find_axis.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('the four axes', () {
    test('every slug round-trips, which is what a route needs', () {
      for (final FindAxis axis in FindAxis.values) {
        expect(FindAxis.ofSlug(axis.slug), axis);
      }
    });

    test('a slug nobody wrote is null, not a crash', () {
      expect(FindAxis.ofSlug('vibes'), isNull);
      expect(FindAxis.ofSlug(''), isNull);
    });

    test('the ambient two read alphabetically, the tag two by count', () {
      expect(FindAxis.weather.byFrequency, isFalse);
      expect(FindAxis.motion.byFrequency, isFalse);
      expect(FindAxis.people.byFrequency, isTrue);
      expect(FindAxis.topics.byFrequency, isTrue);
    });

    test('each says something when it has nothing to offer', () {
      for (final FindAxis axis in FindAxis.values) {
        expect(axis.empty, isNotEmpty);
        expect(axis.empty.endsWith('.'), isTrue);
      }
    });
  });

  group('bottom while it fits, top once it does not — ADR-084', () {
    const double row = 44;

    test('four axes sit at the bottom of any handset', () {
      expect(sitsAtBottom(count: 4, rowHeight: row, height: 600), isTrue);
    });

    test('exactly filling the viewport still sits at the bottom', () {
      expect(sitsAtBottom(count: 10, rowHeight: row, height: 440), isTrue);
    });

    test('one row over and it goes to the top', () {
      expect(sitsAtBottom(count: 11, rowHeight: row, height: 440), isFalse);
    });

    test('a year of tags never sits at the bottom', () {
      expect(sitsAtBottom(count: 200, rowHeight: row, height: 800), isFalse);
    });

    test('nothing at all fits anywhere', () {
      expect(sitsAtBottom(count: 0, rowHeight: row, height: 1), isTrue);
    });

    test('a short handset moves the boundary, which is why it is measured', () {
      expect(sitsAtBottom(count: 12, rowHeight: row, height: 560), isTrue);
      expect(sitsAtBottom(count: 12, rowHeight: row, height: 400), isFalse);
    });
  });
}
