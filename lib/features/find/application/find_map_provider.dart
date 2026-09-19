import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/geo/geo_point.dart';
import '../../../domain/models/chit.dart';
import 'find_providers.dart';

part 'find_map_provider.g.dart';

@riverpod
class LatestFix extends _$LatestFix {
  @override
  GeoPoint? build() => switch (ref.watch(everyChitProvider)) {
    AsyncData<List<Chit>>(:final List<Chit> value) => _newestOf(value),
    _ => stateOrNull,
  };

  static GeoPoint? _newestOf(List<Chit> chits) {
    Chit? newest;
    for (final Chit chit in chits) {
      if (chit.lat == null) continue;
      if (newest == null || chit.createdAt.isAfter(newest.createdAt)) {
        newest = chit;
      }
    }
    return newest == null ? null : GeoPoint(newest.lat!, newest.lon!);
  }
}
