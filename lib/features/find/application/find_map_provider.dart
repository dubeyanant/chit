import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/geo/geo_point.dart';
import '../../../domain/models/chit.dart';
import 'find_providers.dart';

part 'find_map_provider.g.dart';

/// Where the newest chit that knew where it was, was — ADR-089.
///
/// **Read off the stream find already watches**, so the map behind the first
/// screen costs no query, no index and no schema change. Null until the chits
/// arrive and null when not one of them carries a fix — a phone that refused
/// location forever draws no map at all (ADR-007, ADR-085).
///
/// The newest is found by comparing, not by trusting the order the rows came
/// back in: this is the only thing that reads them this way, and an ordering
/// changed elsewhere would move the map without anybody touching it.
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
