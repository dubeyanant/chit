import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no file under lib/ or test/ carries a comment — ADR-095', () {
    final List<String> offences = <String>[];

    for (final String root in <String>['lib', 'test']) {
      for (final FileSystemEntity entity in Directory(
        root,
      ).listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;

        final String path = entity.path.replaceAll(r'\', '/');

        if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) {
          continue;
        }
        if (path.endsWith('no_comments_test.dart')) continue;

        offences.addAll(commentsIn(path, entity.readAsStringSync()));
      }
    }

    expect(
      offences,
      isEmpty,
      reason:
          'chit has no comments in its source — CLAUDE.md §4.2 and ADR-095.\n\n'
          'The code says what it does and the documents say why. If a line '
          'needs explaining, either the name is wrong and it wants renaming, '
          'or the reason is a decision and belongs in docs/DECISIONS.md with '
          'the record naming the file.\n\n${offences.join('\n')}',
    );
  });
}

List<String> commentsIn(String path, String source) {
  final List<String> found = <String>[];

  int line = 1;
  int i = 0;

  final List<_Held> held = <_Held>[];
  bool inString = false;
  String quote = '';
  bool triple = false;
  bool raw = false;
  int braces = 0;

  void count(int from, int to) {
    for (int at = from; at < to; at++) {
      if (source[at] == '\n') line++;
    }
  }

  while (i < source.length) {
    final String c = source[i];
    final String d = i + 1 < source.length ? source[i + 1] : '';

    if (!inString) {
      if (c == '/' && (d == '/' || d == '*')) {
        found.add('$path:$line  ${d == '/' ? '//' : '/* */'}');
        final int was = i;
        if (d == '/') {
          while (i < source.length && source[i] != '\n') {
            i++;
          }
        } else {
          i += 2;
          while (i < source.length &&
              !(source[i] == '*' &&
                  i + 1 < source.length &&
                  source[i + 1] == '/')) {
            i++;
          }
          i += 2;
        }
        count(was, i.clamp(0, source.length));
        continue;
      }

      if (c == '}' && held.isNotEmpty && braces == 0) {
        final _Held back = held.removeLast();
        inString = true;
        quote = back.quote;
        triple = back.triple;
        raw = back.raw;
        braces = back.braces;
        i++;
        continue;
      }

      if (c == '{') braces++;
      if (c == '}') braces--;

      if (c == "'" || c == '"') {
        raw = i > 0 && source[i - 1] == 'r';
        quote = c;
        triple = d == c && i + 2 < source.length && source[i + 2] == c;
        i += triple ? 3 : 1;
        inString = true;
        continue;
      }

      if (c == '\n') line++;
      i++;
      continue;
    }

    if (!raw && c == r'\') {
      if (source[i] == '\n') line++;
      i += 2;
      continue;
    }

    if (!raw && c == r'$' && d == '{') {
      held.add(_Held(quote, triple: triple, raw: raw, braces: braces));
      inString = false;
      braces = 0;
      i += 2;
      continue;
    }

    if (c == quote) {
      if (!triple) {
        inString = false;
        i++;
        continue;
      }
      if (d == quote && i + 2 < source.length && source[i + 2] == quote) {
        inString = false;
        i += 3;
        continue;
      }
    }

    if (c == '\n') line++;
    i++;
  }

  return found;
}

final class _Held {
  const _Held(
    this.quote, {
    required this.triple,
    required this.raw,
    required this.braces,
  });

  final String quote;
  final bool triple;
  final bool raw;
  final int braces;
}
