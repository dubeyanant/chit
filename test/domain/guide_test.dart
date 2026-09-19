import 'package:chitta/domain/guide.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('the guide teaches what nothing else does — ADR-110', () {
    test('it holds the two gestures a chit cannot teach itself', () {
      final String all = Guide.entries
          .map((GuideEntry e) => '${e.title} ${e.words}')
          .join(' ');

      expect(all, contains('Hold'), reason: 'ADR-061, item 44');
      expect(all, contains('@'), reason: 'ADR-082, item 44');
      expect(all, contains('#'), reason: 'ADR-082, item 44');
    });

    test('every entry says something, and says it once', () {
      expect(Guide.entries, isNotEmpty);

      for (final GuideEntry entry in Guide.entries) {
        expect(entry.title.trim(), isNotEmpty);
        expect(entry.words.trim(), isNotEmpty);
      }

      expect(
        Guide.entries.map((GuideEntry e) => e.title).toSet(),
        hasLength(Guide.entries.length),
      );
    });

    test('a title stays one line on a narrow phone', () {
      for (final GuideEntry entry in Guide.entries) {
        expect(
          entry.title.length,
          lessThanOrEqualTo(Guide.longestTitle),
          reason: '"${entry.title}" wraps, and a heading that wraps reads as two',
        );
      }
    });

    test('and an entry stays short enough to be read, not studied', () {
      for (final GuideEntry entry in Guide.entries) {
        expect(
          entry.words.length,
          lessThanOrEqualTo(Guide.longestWords),
          reason: '"${entry.title}" has grown into documentation',
        );
      }
    });

    test('it is prose, not a keyboard shortcut list', () {
      for (final GuideEntry entry in Guide.entries) {
        expect(entry.words.trim(), endsWith('.'));
      }
    });
  });
}
