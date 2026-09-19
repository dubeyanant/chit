import 'dart:io';

import 'package:chitt/data/files/guide_memory_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory root;
  late GuideMemoryFile memory;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('chit-guide-test');
    memory = GuideMemoryFile(Future<Directory>.value(root));
  });

  tearDown(() async {
    if (root.existsSync()) await root.delete(recursive: true);
  });

  group('the guide shows itself once an install — ADR-111', () {
    test('a fresh install has not read it', () async {
      expect(await memory.hasBeenRead(), isFalse);
    });

    test('and has once it is remembered', () async {
      await memory.remember();
      expect(await memory.hasBeenRead(), isTrue);
    });

    test('remembering twice is remembering once', () async {
      await memory.remember();
      await memory.remember();

      expect(await memory.hasBeenRead(), isTrue);
      expect(
        root.listSync().whereType<File>().length,
        1,
        reason: 'the mark is a mark, not a log',
      );
    });

    test('the mark lives beside the chits, so an uninstall takes it', () async {
      await memory.remember();

      expect(
        File(p.join(root.path, GuideMemoryFile.name)).existsSync(),
        isTrue,
        reason: 'app documents is what the OS wipes, and 100 never backs up',
      );
    });

    test('a documents directory that is not there reads as unread', () async {
      final GuideMemoryFile gone = GuideMemoryFile(
        Future<Directory>.value(Directory(p.join(root.path, 'nowhere'))),
      );

      expect(await gone.hasBeenRead(), isFalse);
    });

    test('a store that cannot be reached never nags', () async {
      final GuideMemoryFile broken = GuideMemoryFile(
        Future<Directory>.error(const FileSystemException('no documents')),
      );

      expect(
        await broken.hasBeenRead(),
        isTrue,
        reason: 'a sheet on every launch is worse than a sheet never shown',
      );
      await expectLater(broken.remember(), completes);
    });
  });
}
