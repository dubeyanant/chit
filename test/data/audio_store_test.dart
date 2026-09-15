import 'dart:io';

import 'package:chit/data/audio/audio_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// ADR-008: recordings live on the filesystem and the row holds a relative
/// path. This is the file half of that — the half that can lose a recording.
void main() {
  late Directory root;
  late Directory documents;
  late Directory cache;
  late AudioStore store;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('chit-audio-test');
    documents = await Directory(p.join(root.path, 'documents')).create();
    cache = await Directory(p.join(root.path, 'cache')).create();
    store = AudioStore(Future<Directory>.value(documents));
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
      File(p.join(documents.path, AudioStore.folder, '$chitId.m4a'));

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
        Directory(p.join(documents.path, AudioStore.folder)).existsSync(),
        isFalse,
      );

      await store.keep(tempPath: await aRecording('r'), chitId: 'chit-1');

      expect(
        Directory(p.join(documents.path, AudioStore.folder)).existsSync(),
        isTrue,
      );
    });

    test('returns a relative path, with forward slashes', () async {
      final String path = await store.keep(
        tempPath: await aRecording('r'),
        chitId: 'chit-1',
      );

      // An absolute iOS container path saved today is dead after the next app
      // update, and a backslash saved on one platform is a broken path on the
      // other. Neither is visible until it is far too late to fix.
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
      // The other direction of ADR-008's reconciliation. A missing recording
      // is a loss, not a corruption: the chit still renders, without its pill.
      final File missing = await store.resolve('audio/gone.m4a');

      expect(missing.existsSync(), isFalse);
      await expectLater(store.sweep(<String>['audio/gone.m4a']), completes);
    });
  });
}
