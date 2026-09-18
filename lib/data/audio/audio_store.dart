import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_store.g.dart';

final class AudioStore {
  const AudioStore(this._documents);

  factory AudioStore.appDocuments() =>
      AudioStore(getApplicationDocumentsDirectory());

  static const String folder = 'audio';

  static const String _extension = '.m4a';

  final Future<Directory> _documents;

  Future<String> keep({
    required String tempPath,
    required String chitId,
  }) async {
    final Directory dir = await _audioDirectory();
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }

    final String relative = p.posix.join(folder, '$chitId$_extension');
    final String target = p.join(dir.path, '$chitId$_extension');
    final File temp = File(tempPath);

    try {
      await temp.rename(target);
    } on FileSystemException {
      await temp.copy(target);
      await temp.delete();
    }

    return relative;
  }

  Future<void> discardTemp(String tempPath) async {
    final File file = File(tempPath);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  Future<void> delete(String relativePath) async {
    final File file = await resolve(relativePath);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  Future<File> resolve(String relativePath) async => File(
    p.joinAll(<String>[
      (await _documents).path,
      ...p.posix.split(relativePath),
    ]),
  );

  Future<void> sweep(Iterable<String> claimed) async {
    final Directory dir = await _audioDirectory();
    if (!dir.existsSync()) return;

    final Set<String> keep = claimed.toSet();
    await for (final FileSystemEntity entity in dir.list()) {
      if (entity is! File) continue;
      if (!keep.contains(p.posix.join(folder, p.basename(entity.path)))) {
        await entity.delete();
      }
    }
  }

  Future<Directory> _audioDirectory() async =>
      Directory(p.join((await _documents).path, folder));
}

@Riverpod(keepAlive: true)
AudioStore audioStore(Ref ref) => AudioStore.appDocuments();
