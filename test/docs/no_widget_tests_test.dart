import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// ADR-031: chit has no widget tests, and this is what keeps it that way.
///
/// A rule written only in CLAUDE.md is a rule that lasts until somebody is in a
/// hurry. The suite ADR-031 removed was not added in one sitting either — it
/// grew one reasonable-looking `testWidgets` at a time, which is exactly how it
/// would come back.
///
/// It reads the test tree as text rather than parsing it. A rule this blunt does
/// not need a syntax tree, and a check nobody can read is a check nobody will
/// trust the day it fails.
void main() {
  /// The APIs whose only purpose is to build a widget and look at it.
  const List<String> forbidden = <String>[
    'testWidgets',
    'pumpWidget',
    'WidgetTester',
  ];

  test('no test under test/ builds a widget — ADR-031', () {
    final List<String> offences = <String>[];

    for (final FileSystemEntity entity in Directory(
      'test',
    ).listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;

      final String path = entity.path.replaceAll(r'\', '/');
      // Written by `drift_dev schema generate`, and not ours to police.
      if (path.contains('/generated/')) continue;
      // This file names the forbidden APIs in order to forbid them.
      if (path.endsWith('no_widget_tests_test.dart')) continue;

      final List<String> lines = entity.readAsLinesSync();
      for (int i = 0; i < lines.length; i++) {
        for (final String api in forbidden) {
          if (lines[i].contains(api)) offences.add('$path:${i + 1}  $api');
        }
      }
    }

    expect(
      offences,
      isEmpty,
      reason:
          'chit has no widget tests — CLAUDE.md §4.2 and ADR-031.\n\n'
          'A claim that can only be checked by pumping a screen is checked on a '
          'device, and what was seen goes in docs/OPEN-QUESTIONS.md. If the claim '
          'feels too important for that, it is usually a sign that the logic '
          'wants to come out of the widget and into something a '
          'ProviderContainer can drive.\n\n${offences.join('\n')}',
    );
  });
}
