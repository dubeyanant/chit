import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photo_source.g.dart';

enum PhotoOrigin { camera, library }

abstract interface class PhotoSource {
  Future<String?> take(PhotoOrigin from);
}

@Riverpod(keepAlive: true)
PhotoSource photoSource(Ref ref) => throw UnimplementedError(
  'photoSourceProvider is overridden at the root — see main.dart',
);
