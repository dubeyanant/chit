// ignore_for_file: prefer_initializing_formals
//
// A named parameter cannot be private, and the field behind it should be —
// the house pattern, same as `ChitRepositoryImpl`.

import 'dart:async';

import 'package:chit/core/clock.dart';
import 'package:chit/domain/models/ambient_stamp.dart';
import 'package:chit/domain/models/chit.dart';
import 'package:chit/domain/models/day_summary.dart';
import 'package:chit/domain/repositories/chit_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// A [ChitRepository] that keeps its chits in a list.
///
/// **Why a widget test does not get the real one.** `flutter_test` runs a
/// `testWidgets` body inside a fake-async zone, and real I/O never completes
/// in it — not a Drift query, not even `Directory.systemTemp.createTemp()`.
/// Reaching for `tester.runAsync` around every await gets a screen test back,
/// but it also puts the screen's rebuilds on the real event loop, which is
/// exactly the thing `pump` exists to make deterministic. CLAUDE.md §4.2
/// carries the rule and the exception.
///
/// **It is a fake and not a stub**, which is the Liskov rule of CLAUDE.md
/// §4.1: it really stores, it really re-emits to everything watching, and it
/// **refuses what the real one refuses** — blank text is normalised to `null`
/// before anything sees it, and an illegal chit throws here the same way it
/// throws there. A fake that accepts what the database would reject is a test
/// that passes for a screen that cannot work.
///
/// What it does not do is persist to disk or move an audio file. Those are
/// `ChitRepositoryImpl`'s, and `test/data/chit_repository_test.dart` holds
/// them against real Drift and a real filesystem.
final class FakeChitRepository implements ChitRepository {
  /// A repository with nothing in it, stamping `updatedAt` from [clock].
  FakeChitRepository({required Clock clock}) : _clock = clock {
    addTearDown(_changed.close);
  }

  final Clock _clock;
  final List<Chit> _rows = <Chit>[];
  final StreamController<void> _changed = StreamController<void>.broadcast();

  /// Everything saved so far, newest first — for a test that wants to look at
  /// the row rather than at the widget that drew it.
  List<Chit> get rows => List<Chit>.unmodifiable(_sorted(_rows));

  static List<Chit> _sorted(Iterable<Chit> chits) =>
      chits.toList()
        ..sort((Chit a, Chit b) => b.createdAt.compareTo(a.createdAt));

  Stream<T> _watch<T>(T Function() read) async* {
    yield read();
    yield* _changed.stream.map((void _) => read());
  }

  @override
  Future<Chit> save({
    required AmbientStamp stamp,
    String? text,
    TextOrigin? textOrigin,
    String? audioTempPath,
    Duration? audioDuration,
  }) async {
    // The same normalisation the real one does: an untouched field and a field
    // of spaces are the same nothing, and §3.1 refuses to save either alone.
    final String? words = switch (text?.trim()) {
      null || '' => null,
      final String trimmed => trimmed,
    };

    // Chit's own asserts are the rest of the refusal, and they are the same
    // asserts the real repository's result has to pass.
    final Chit chit = Chit(
      id: 'chit-${_rows.length + 1}',
      createdAt: stamp.capturedAt,
      localDay: Chit.localDayOf(stamp.capturedAt),
      updatedAt: _clock.now(),
      text: words,
      textOrigin: words == null ? null : textOrigin,
      audioPath: audioTempPath,
      audioDuration: audioDuration,
      weather: stamp.weather,
      lat: stamp.lat,
      lon: stamp.lon,
    );

    _rows.add(chit);
    _changed.add(null);
    return chit;
  }

  @override
  Future<void> updateText({
    required String id,
    required String text,
    required TextOrigin textOrigin,
  }) async {
    final int at = _rows.indexWhere((Chit c) => c.id == id);
    if (at < 0) throw StateError('no chit with id $id');

    _rows[at] = _rows[at].copyWith(
      text: text,
      textOrigin: textOrigin,
      updatedAt: _clock.now(),
    );
    _changed.add(null);
  }

  @override
  Future<Chit?> byId(String id) async =>
      _rows.where((Chit c) => c.id == id).firstOrNull;

  @override
  Stream<List<Chit>> watchDay(int localDay) =>
      _watch(() => _sorted(_rows.where((Chit c) => c.localDay == localDay)));

  @override
  Stream<List<DaySummary>> watchDaySummaries({
    required int fromDay,
    required int toDay,
  }) => _watch(() {
    final Map<int, int> counts = <int, int>{};
    for (final Chit chit in _rows) {
      if (chit.localDay < fromDay || chit.localDay > toDay) continue;
      counts[chit.localDay] = (counts[chit.localDay] ?? 0) + 1;
    }
    return <DaySummary>[
      for (final MapEntry<int, int> day in counts.entries)
        DaySummary(localDay: day.key, count: day.value),
    ]..sort((DaySummary a, DaySummary b) => a.localDay.compareTo(b.localDay));
  });

  @override
  Stream<List<Chit>> watchArchive({required int limit, int offset = 0}) =>
      _watch(() => _sorted(_rows).skip(offset).take(limit).toList());

  @override
  Future<void> reconcileAudio() async {}
}
