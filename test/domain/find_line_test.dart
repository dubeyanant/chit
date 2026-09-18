import 'package:chitta/domain/find_line.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('every line in both books obeys the same rules', () {
    test('the quotes are the size the screen was built for', () {
      expect(FindLine.quotes.length, greaterThanOrEqualTo(40));
    });

    test('no line outruns the two the screen has room for', () {
      for (final String line in FindLine.all) {
        expect(
          line.length,
          lessThanOrEqualTo(FindLine.longest),
          reason: '"$line" is ${line.length} characters',
        );
      }
    });

    test('every line is a line — trimmed, ending in a stop', () {
      for (final String line in FindLine.all) {
        expect(line, line.trim());
        expect(line, isNotEmpty);
        expect(
          RegExp(r'[.?!]$').hasMatch(line),
          isTrue,
          reason: '"$line" does not end in a full stop',
        );
      }
    });

    test('nothing is attributed — a dash would be a claim about a person', () {
      for (final String line in FindLine.all) {
        expect(line.contains('—'), isFalse, reason: line);
        expect(line.contains(' -- '), isFalse, reason: line);
      }
    });

    test('no line is written twice, across both books', () {
      expect(FindLine.all.toSet(), hasLength(FindLine.all.length));
    });
  });

  group('one line a day, the same all day', () {
    test('the same day gives the same line', () {
      expect(FindLine.forDay(20260919), FindLine.forDay(20260919));
    });

    test('every day of a year lands inside one of the books', () {
      for (int day = 20260101; day <= 20261231; day++) {
        expect(FindLine.all, contains(FindLine.forDay(day)));
      }
    });
  });

  group('one day in four explains something — ADR-086', () {
    test('a day divisible by four draws a hint', () {
      expect(FindLine.hints, contains(FindLine.forDay(20260920)));
      expect(FindLine.quotes, isNot(contains(FindLine.forDay(20260920))));
    });

    test('the days between it draw quotes', () {
      for (final int day in <int>[20260917, 20260918, 20260919]) {
        expect(
          FindLine.quotes,
          contains(FindLine.forDay(day)),
          reason: '$day is not a multiple of four',
        );
      }
    });

    test('a month of days is about a quarter hints', () {
      final int hints = <int>[
        for (int day = 20260901; day <= 20260930; day++)
          if (FindLine.hints.contains(FindLine.forDay(day))) day,
      ].length;

      expect(hints, greaterThanOrEqualTo(6));
      expect(hints, lessThanOrEqualTo(9));
    });

    test('every hint is reachable, none stranded in the book', () {
      final Set<String> seen = <String>{
        for (int day = 20260101; day <= 20271231; day++) FindLine.forDay(day),
      };

      for (final String hint in FindLine.hints) {
        expect(seen, contains(hint), reason: '"$hint" never comes round');
      }
    });
  });
}
