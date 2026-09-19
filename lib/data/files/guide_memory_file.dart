import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/services/guide_memory.dart';

final class GuideMemoryFile implements GuideMemory {
  const GuideMemoryFile(this._documents);

  factory GuideMemoryFile.appDocuments() =>
      GuideMemoryFile(getApplicationDocumentsDirectory());

  static const String name = 'guide-read';

  final Future<Directory> _documents;

  @override
  Future<bool> hasBeenRead() async {
    try {
      return (await _mark()).existsSync();
    } on Object {
      return true;
    }
  }

  @override
  Future<void> remember() async {
    try {
      final File mark = await _mark();
      if (!mark.existsSync()) await mark.create(recursive: true);
    } on Object {}
  }

  Future<File> _mark() async => File(p.join((await _documents).path, name));
}
