import 'dart:async';
import 'dart:io';

import 'package:just_audio/just_audio.dart' as plugin;
import 'package:path/path.dart' as p;

import '../../domain/services/audio_player.dart';
import 'audio_store.dart';

final class JustAudioPlayer implements AudioPlayer {
  JustAudioPlayer(this._store) {
    _player.playerStateStream.listen(_onPlayerState);
    _player.positionStream.listen(_onPosition);
  }

  final AudioStore _store;
  final plugin.AudioPlayer _player = plugin.AudioPlayer();
  final StreamController<Playback> _out =
      StreamController<Playback>.broadcast();

  Playback _now = Playback.silent;

  bool _switching = false;

  @override
  Stream<Playback> get playback async* {
    yield _now;
    yield* _out.stream;
  }

  @override
  Future<void> play({required String id, required String path}) async {
    try {
      if (!_now.holds(id)) {
        final File file = await _fileFor(path);
        if (!file.existsSync()) {
          _now = Playback.silent;
          await _stopQuietly();
          return _report(_now);
        }

        _switching = true;
        try {
          _now = Playback(id: id);
          await _pauseQuietly();
          await _player.setFilePath(file.path);
        } finally {
          _switching = false;
        }
      }

      if (_player.processingState == plugin.ProcessingState.completed) {
        await _player.seek(Duration.zero);
      }

      unawaited(_player.play());
    } on Object {
      _now = Playback.silent;
      await _stopQuietly();
      _report(Playback.silent);
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _player.pause();
    } on Object {}
  }

  @override
  Future<void> stopIf(String id) async {
    if (!_now.holds(id)) return;
    _now = Playback.silent;
    await _stopQuietly();
    _report(_now);
  }

  Future<File> _fileFor(String path) async =>
      p.isAbsolute(path) ? File(path) : _store.resolve(path);

  void _onPlayerState(plugin.PlayerState state) {
    if (state.processingState == plugin.ProcessingState.completed) {
      unawaited(_stopQuietly());
      _now = Playback.silent;
      _report(_now);
      return;
    }
    _report(
      _now = Playback(
        id: _now.id,
        position: _now.position,
        playing: state.playing,
      ),
    );
  }

  void _onPosition(Duration at) {
    if (_now.id == null || _switching) return;

    if (at < _now.position) return;
    _report(_now = Playback(id: _now.id, position: at, playing: _now.playing));
  }

  void _report(Playback next) {
    if (!_out.isClosed) _out.add(next);
  }

  Future<void> _stopQuietly() async {
    try {
      await _player.stop();
    } on Object {}
  }

  Future<void> _pauseQuietly() async {
    try {
      await _player.pause();
    } on Object {}
  }

  Future<void> dispose() async {
    await _out.close();
    await _player.dispose();
  }
}
