import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// README §10 claims to map everything in the repository. This is what makes
/// that true a year from now.
///
/// An index nobody maintains is worse than no index: it is a list that looks
/// complete and is not, and a reader who trusts it stops looking. So the index
/// is maintained by the build rather than by discipline — add a document, a
/// prototype, an ADR or a source directory without a line pointing at it and
/// this fails.
///
/// It checks that a name is *mentioned*, not that the sentence beside it is
/// any good. That part is still a person's job.
void main() {
  final File readme = File('README.md');
  final File decisions = File('docs/DECISIONS.md');

  setUpAll(() {
    expect(
      readme.existsSync(),
      isTrue,
      reason: 'run this from the project root',
    );
  });

  String readmeText() => readme.readAsStringSync();

  test('every document in docs/ is named in README §10', () {
    final List<String> missing = <String>[];
    final String text = readmeText();

    for (final FileSystemEntity entity in Directory('docs').listSync()) {
      if (entity is! File || !entity.path.endsWith('.md')) continue;
      final String name = entity.uri.pathSegments.last;
      if (!text.contains(name)) missing.add('docs/$name');
    }

    expect(
      missing,
      isEmpty,
      reason:
          'README §10.1 is the index of the documents. Add a row for each of '
          'these, saying what question it answers:\n${missing.join('\n')}',
    );
  });

  test('every prototype in design/ is named in README §10', () {
    final List<String> missing = <String>[];
    final String text = readmeText();

    for (final FileSystemEntity entity in Directory('design').listSync()) {
      if (entity is! File) continue;
      final String name = entity.uri.pathSegments.last;
      if (!text.contains(name)) missing.add('design/$name');
    }

    expect(
      missing,
      isEmpty,
      reason:
          'README §10.4 lists the prototypes. A superseded one still gets a '
          'row, saying that it is history:\n${missing.join('\n')}',
    );
  });

  test('every top-level source directory is named in README §10', () {
    final List<String> missing = <String>[];
    final String text = readmeText();

    for (final FileSystemEntity entity in Directory('lib').listSync()) {
      if (entity is! Directory) continue;
      final String name = entity.uri.pathSegments
          .where((String s) => s.isNotEmpty)
          .last;
      if (!text.contains('$name/')) missing.add('lib/$name/');
    }

    expect(
      missing,
      isEmpty,
      reason:
          'README §10.2 sketches the source tree. A new layer belongs in it, '
          'and in ARCHITECTURE.md §2:\n${missing.join('\n')}',
    );
  });

  test('every test suite is named in README §10', () {
    final List<String> missing = <String>[];
    final String text = readmeText();

    for (final FileSystemEntity entity in Directory(
      'test',
    ).listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final String path = entity.path.replaceAll(r'\', '/');
      if (!text.contains(path)) missing.add(path);
    }

    expect(
      missing,
      isEmpty,
      reason:
          'README §10.3 says what each suite guards, which is the only place '
          'the enforced rules are listed together:\n${missing.join('\n')}',
    );
  });

  test('every ADR has a row in the index at the head of DECISIONS.md', () {
    final List<String> lines = decisions.readAsLinesSync();
    final RegExp heading = RegExp(r'^## (ADR-\d+)');

    final List<String> records = <String>[
      for (final String line in lines)
        if (heading.firstMatch(line) case final RegExpMatch m) m.group(1)!,
    ];

    expect(records, isNotEmpty, reason: 'no ADRs found — has the file moved?');

    // A row in the index is a table cell, not the heading it points at.
    final Set<String> indexed = <String>{
      for (final String line in lines)
        if (line.startsWith('| ADR-')) line.split('|')[1].trim(),
    };

    final List<String> missing = records
        .where((String adr) => !indexed.contains(adr))
        .toList();

    expect(
      missing,
      isEmpty,
      reason:
          'Every record needs a row in the index at the head of '
          'DECISIONS.md:\n${missing.join('\n')}',
    );

    final List<String> orphaned = indexed
        .where((String adr) => !records.contains(adr))
        .toList();

    expect(
      orphaned,
      isEmpty,
      reason:
          'The index points at records that do not exist. Superseding an ADR '
          'means adding a new one, never editing or deleting the one it '
          'replaces. A record is only merged away once the thing it decided '
          'no longer exists in the app at all — and then its row goes with '
          'it, its number is retired rather than reused, and the note at the '
          'head of DECISIONS.md says where it went:\n'
          '${orphaned.join('\n')}',
    );
  });

  test('the sections that left the README say where they went', () {
    // §0 promises that a citation resolves from any file. That only holds if
    // the README keeps saying which file owns each number.
    const Map<String, String> owner = <String, String>{
      '§3': 'docs/BEHAVIOUR.md',
      '§4': 'docs/BEHAVIOUR.md',
      '§6': 'docs/DESIGN-SYSTEM.md',
      '§7': 'docs/DESIGN-SYSTEM.md',
      '§8': 'docs/OPEN-QUESTIONS.md',
      '§9': 'docs/OPEN-QUESTIONS.md',
    };
    final String text = readmeText();

    for (final MapEntry<String, String> entry in owner.entries) {
      expect(
        text,
        contains(entry.key),
        reason: '${entry.key} moved to ${entry.value}; README §0 must say so',
      );
      expect(text, contains(entry.value.split('/').last));
    }
  });
}
