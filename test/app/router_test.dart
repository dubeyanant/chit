import 'package:chitta/app/router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('which tabs are drawn — ADR-109', () {
    test('find is not one of them until a tag exists', () {
      expect(ChitRoute.drawnWhen(tagged: false), <ChitRoute>[
        ChitRoute.today,
        ChitRoute.past,
      ]);
    });

    test('and is once one does', () {
      expect(ChitRoute.drawnWhen(tagged: true), ChitRoute.values);
    });

    test('the order never changes, so find arrives on the right', () {
      expect(
        ChitRoute.drawnWhen(tagged: true).take(2),
        ChitRoute.drawnWhen(tagged: false),
      );
    });

    test('a branch keeps its index whether or not it is drawn', () {
      expect(ChitRoute.find.index, 2, reason: 'goBranch reads the enum index');
      expect(
        ChitRoute.drawnWhen(tagged: false).map((ChitRoute r) => r.index),
        <int>[0, 1],
      );
    });
  });
}
