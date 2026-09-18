import 'package:chitta/domain/quotes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the book is the size it was asked to be', () {
    expect(Quotes.all.length, greaterThanOrEqualTo(40));
  });

  test('no line outruns the two the screen has room for', () {
    for (final String line in Quotes.all) {
      expect(
        line.length,
        lessThanOrEqualTo(Quotes.longest),
        reason: '"$line" is ${line.length} characters',
      );
    }
  });

  test('every line is a line — trimmed, ending in a stop', () {
    for (final String line in Quotes.all) {
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
    for (final String line in Quotes.all) {
      expect(line.contains('—'), isFalse, reason: line);
      expect(line.contains(' -- '), isFalse, reason: line);
    }
  });

  test('no line is written twice', () {
    expect(Quotes.all.toSet(), hasLength(Quotes.all.length));
  });

  group('one line a day, the same all day', () {
    test('the same day gives the same line', () {
      expect(Quotes.forDay(20260919), Quotes.forDay(20260919));
    });

    test('consecutive days give different lines', () {
      expect(Quotes.forDay(20260919), isNot(Quotes.forDay(20260920)));
    });

    test('every day of a year lands inside the book', () {
      for (int day = 20260101; day <= 20261231; day++) {
        expect(Quotes.all, contains(Quotes.forDay(day)));
      }
    });
  });
}
