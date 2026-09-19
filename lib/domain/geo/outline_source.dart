import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'geo_point.dart';
import 'outline_shape.dart';

part 'outline_source.g.dart';

abstract interface class OutlineSource {
  List<OutlineShape> shapesIn(GeoBox box);

  OutlineShape? cityAt(GeoPoint point);
}

@Riverpod(keepAlive: true)
Future<OutlineSource> outlineSource(Ref ref) => throw UnimplementedError(
  'outlineSourceProvider is overridden at the root — see main.dart',
);
