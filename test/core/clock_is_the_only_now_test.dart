import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('SystemClock is the only caller of DateTime.now() in lib/', () {
    final Directory lib = Directory('lib');
    expect(lib.existsSync(), isTrue, reason: 'run this from the project root');

    const String sanctioned = 'lib/core/clock.dart';
    final RegExp offender = RegExp(r'DateTime\s*\.\s*now\s*\(');

    final List<String> offences = <String>[];

    for (final FileSystemEntity entity in lib.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;

      final String path = entity.path.replaceAll(r'\', '/');
      if (path == sanctioned) continue;

      if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) continue;

      final List<String> lines = entity.readAsLinesSync();
      for (int i = 0; i < lines.length; i++) {
        if (offender.hasMatch(lines[i])) {
          offences.add('$path:${i + 1}: ${lines[i].trim()}');
        }
      }
    }

    expect(
      offences,
      isEmpty,
      reason:
          'DateTime.now() is banned outside $sanctioned (ADR-012). Inject '
          'Clock and read clockProvider instead.\n${offences.join('\n')}',
    );
  });
}
