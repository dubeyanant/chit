import 'dart:io';

import 'package:chitta/data/files/file_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory root;
  late Directory documents;
  late Directory cache;
  late FileStore store;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('chit-audio-test');
    documents = await Directory(p.join(root.path, 'documents')).create();
    cache = await Directory(p.join(root.path, 'cache')).create();
    store = FileStore(
      Future<Directory>.value(documents),
      folder: 'audio',
      extension: '.m4a',
    );
  });

  tearDown(() async {
    if (root.existsSync()) await root.delete(recursive: true);
  });

  Future<String> aRecording(String name) async {
    final File file = File(p.join(cache.path, '$name.m4a'));
    await file.writeAsString('pretend this is aac');
    return file.path;
  }

  File kept(String chitId) =>
      File(p.join(documents.path, store.folder, '$chitId.m4a'));

  group('keeping a recording', () {
    test('moves it, rather than leaving a second copy behind', () async {
      final String temp = await aRecording('recording-1');

      await store.keep(tempPath: temp, chitId: 'chit-1');

      expect(File(temp).existsSync(), isFalse, reason: 'the temp file moved');
      expect(kept('chit-1').existsSync(), isTrue);
      expect(kept('chit-1').readAsStringSync(), 'pretend this is aac');
    });

    test('creates the audio directory the first time', () async {
      expect(
        Directory(p.join(documents.path, store.folder)).existsSync(),
        isFalse,
      );

      await store.keep(tempPath: await aRecording('r'), chitId: 'chit-1');

      expect(
        Directory(p.join(documents.path, store.folder)).existsSync(),
        isTrue,
      );
    });

    test('returns a relative path, with forward slashes', () async {
      final String path = await store.keep(
        tempPath: await aRecording('r'),
        chitId: 'chit-1',
      );

      expect(path, 'audio/chit-1.m4a');
      expect(p.isAbsolute(path), isFalse);
      expect(path, isNot(contains(r'\')));
    });

    test('the returned path is what resolves back to the file', () async {
      final String path = await store.keep(
        tempPath: await aRecording('r'),
        chitId: 'chit-1',
      );

      expect((await store.resolve(path)).existsSync(), isTrue);
    });
  });

  group('discarding', () {
    test('deletes the temp file', () async {
      final String temp = await aRecording('recording-1');

      await store.discardTemp(temp);

      expect(File(temp).existsSync(), isFalse);
    });

    test('a temp file that has already gone is not a failure', () async {
      final String temp = await aRecording('recording-1');
      await store.discardTemp(temp);

      await expectLater(store.discardTemp(temp), completes);
    });
  });

  group('the orphan sweep', () {
    test('deletes a recording no chit claims', () async {
      await store.keep(tempPath: await aRecording('a'), chitId: 'claimed');
      await store.keep(tempPath: await aRecording('b'), chitId: 'orphan');

      await store.sweep(<String>['audio/claimed.m4a']);

      expect(kept('claimed').existsSync(), isTrue);
      expect(kept('orphan').existsSync(), isFalse);
    });

    test('does nothing when nothing has ever been recorded', () async {
      await expectLater(store.sweep(const <String>[]), completes);
    });

    test('a chit whose file has vanished needs nothing done to it', () async {
      final File missing = await store.resolve('audio/gone.m4a');

      expect(missing.existsSync(), isFalse);
      await expectLater(store.sweep(<String>['audio/gone.m4a']), completes);
    });
  });
}
