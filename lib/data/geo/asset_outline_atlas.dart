import 'package:flutter/services.dart';

import 'outline_atlas.dart';

/// Where the atlas lives in the bundle. Declared in pubspec.yaml, built by
/// tool/pack_outlines.mjs.
const String outlineAtlasAsset = 'assets/geo/outline.bin';

/// Reads the atlas out of the bundle.
///
/// Only the header and the index are parsed here; the shapes stay as bytes
/// until a cell is asked for, which is what makes this cheap enough to do on
/// the frame that opens find.
Future<OutlineAtlas> loadOutlineAtlas([AssetBundle? bundle]) async {
  final ByteData data = await (bundle ?? rootBundle).load(outlineAtlasAsset);

  return OutlineAtlas.decode(
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
  );
}
