import 'package:flutter/services.dart';

import 'outline_atlas.dart';

const String outlineAtlasAsset = 'assets/geo/outline.bin';

Future<OutlineAtlas> loadOutlineAtlas([AssetBundle? bundle]) async {
  final ByteData data = await (bundle ?? rootBundle).load(outlineAtlasAsset);

  return OutlineAtlas.decode(
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
  );
}
