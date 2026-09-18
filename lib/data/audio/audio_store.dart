import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_store.g.dart';

/// Where recordings live, and the only thing that moves them. ADR-008.
///
/// A recording is written to a temporary file while the sheet is up, moved
/// into `<app documents>/audio/<chit-id>.m4a` when the chit is saved, and
/// deleted when it is discarded. The database stores the **relative** path
/// only — an absolute iOS container path saved today is dead after the next
/// app update.
///
/// The documents directory arrives as a [Future] rather than a [Directory] so
/// that constructing this costs nothing and startup stays synchronous
/// (ARCHITECTURE.md §3). Tests hand it a temporary directory.
final class AudioStore {
  /// A store under the documents directory, once that future resolves.
  const AudioStore(this._documents);

  /// The store as it exists on a handset.
  factory AudioStore.appDocuments() =>
      AudioStore(getApplicationDocumentsDirectory());

  /// The one directory recordings are kept in, relative to the documents
  /// directory.
  static const String folder = 'audio';

  static const String _extension = '.m4a';

  final Future<Directory> _documents;

  /// Moves the recording at [tempPath] to the chit's permanent path and
  /// returns that path, relative and with forward slashes.
  ///
  /// The move happens before the row is written, so a failed move never leaves
  /// a row pointing at nothing. The other order of failure — a moved file and
  /// no row — is an orphan, and [sweep] is what collects it.
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
      // A rename cannot cross devices, and the cache and the documents
      // directory are not promised to be on the same one.
      await temp.copy(target);
      await temp.delete();
    }

    return relative;
  }

  /// Deletes a recording that was never kept — the recording sheet's
  /// **Discard**, and **Remove** on the open chit's pill (BEHAVIOUR.md §3.2).
  ///
  /// A temp file that has already gone is not an error — discarding twice, or
  /// discarding after the OS has swept its own cache, is the same outcome.
  Future<void> discardTemp(String tempPath) async {
    final File file = File(tempPath);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  /// The file behind a stored path, for playback.
  ///
  /// It may not exist: a recording that has vanished is a loss, not a
  /// corruption, and the chit still renders without its pill (ADR-008).
  Future<File> resolve(String relativePath) async => File(
    p.joinAll(<String>[
      (await _documents).path,
      ...p.posix.split(relativePath),
    ]),
  );

  /// Deletes every recording that no row claims.
  ///
  /// Half of the reconciliation of ADR-008 — the half that needs a filesystem.
  /// The other half, a row whose file has vanished, needs nothing done to it.
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

/// The audio store the app runs on. Overridden in tests.
@Riverpod(keepAlive: true)
AudioStore audioStore(Ref ref) => AudioStore.appDocuments();
