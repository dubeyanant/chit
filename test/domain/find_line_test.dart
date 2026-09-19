import 'package:chitt/domain/find_line.dart';
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

  group('one line a visit, held for the whole visit — ADR-093', () {
    test('the same visit gives the same line', () {
      expect(FindLine.forVisit(4117), FindLine.forVisit(4117));
    });

    test('the next visit gives a different one', () {
      for (int visit = 0; visit < 200; visit++) {
        expect(
          FindLine.forVisit(visit),
          isNot(FindLine.forVisit(visit + 1)),
          reason: 'visit $visit and the one after it draw the same line',
        );
      }
    });

    test('a long run of visits lands inside one of the books', () {
      for (int visit = 0; visit < 2000; visit++) {
        expect(FindLine.all, contains(FindLine.forVisit(visit)));
      }
    });

    test('the day it is seeded with cannot take it out of range', () {
      for (final int seed in <int>[0, -1, 20260919, -20260919]) {
        expect(FindLine.all, contains(FindLine.forVisit(seed)));
      }
    });
  });

  group('one visit in four explains something — ADR-086', () {
    test('a visit divisible by four draws a hint', () {
      expect(FindLine.hints, contains(FindLine.forVisit(20260920)));
      expect(FindLine.quotes, isNot(contains(FindLine.forVisit(20260920))));
    });

    test('the visits between it draw quotes', () {
      for (final int visit in <int>[20260917, 20260918, 20260919]) {
        expect(
          FindLine.quotes,
          contains(FindLine.forVisit(visit)),
          reason: '$visit is not a multiple of four',
        );
      }
    });

    test('a run of visits is about a quarter hints', () {
      final int hints = <int>[
        for (int visit = 20260901; visit <= 20260930; visit++)
          if (FindLine.hints.contains(FindLine.forVisit(visit))) visit,
      ].length;

      expect(hints, greaterThanOrEqualTo(6));
      expect(hints, lessThanOrEqualTo(9));
    });

    test('every hint is reachable, none stranded in the book', () {
      final Set<String> seen = <String>{
        for (int visit = 0; visit < 2000; visit++) FindLine.forVisit(visit),
      };

      for (final String hint in FindLine.hints) {
        expect(seen, contains(hint), reason: '"$hint" never comes round');
      }
    });
  });
}
