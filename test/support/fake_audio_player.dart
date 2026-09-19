import 'dart:async';

import 'package:chitt/domain/services/audio_player.dart';

final class FakeAudioPlayer implements AudioPlayer {
  final Set<String> missing = <String>{};

  final List<String> asked = <String>[];

  final StreamController<Playback> _out =
      StreamController<Playback>.broadcast();

  Playback _now = Playback.silent;

  Playback get now => _now;

  @override
  Stream<Playback> get playback async* {
    yield _now;
    yield* _out.stream;
  }

  @override
  Future<void> play({required String id, required String path}) async {
    asked.add(id);
    if (missing.contains(path)) return _emit(Playback.silent);

    _emit(
      Playback(
        id: id,
        position: _now.holds(id) ? _now.position : Duration.zero,
        playing: true,
      ),
    );
  }

  @override
  Future<void> pause() async {
    if (_now.id == null) return;
    _emit(Playback(id: _now.id, position: _now.position, playing: false));
  }

  @override
  Future<void> stopIf(String id) async {
    if (!_now.holds(id)) return;
    _emit(Playback.silent);
  }

  void advanceTo(Duration at) {
    if (_now.id == null) return;
    _emit(Playback(id: _now.id, position: at, playing: _now.playing));
  }

  void finish() => _emit(Playback.silent);

  void _emit(Playback next) {
    _now = next;
    if (!_out.isClosed) _out.add(next);
  }

  Future<void> dispose() => _out.close();
}
