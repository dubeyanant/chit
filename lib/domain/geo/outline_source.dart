import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'geo_point.dart';
import 'outline_shape.dart';

part 'outline_source.g.dart';

/// Where the outlines come from — the seam a test stands a handful of shapes in
/// front of, rather than the megabyte the app ships (ADR-089).
abstract interface class OutlineSource {
  /// Every shape whose bounds meet [box].
  ///
  /// Cheap by construction: the atlas is cut on a grid, so this reads the few
  /// cells the box touches and not the world. A shape may straddle the edge and
  /// come back with points outside [box] — clipping is the painter's job, and
  /// at these spans it is the GPU's.
  List<OutlineShape> shapesIn(GeoBox box);

  /// The built-up area [point] stands in, or null where nobody has built.
  OutlineShape? cityAt(GeoPoint point);
}

/// **Loaded when find is first opened, not at startup.** The atlas is a
/// megabyte that only one screen reads, and ADR-009's promise is that the app
/// opens instantly; a tab a person may never visit does not get to spend that.
@Riverpod(keepAlive: true)
Future<OutlineSource> outlineSource(Ref ref) => throw UnimplementedError(
  'outlineSourceProvider is overridden at the root — see main.dart',
);
