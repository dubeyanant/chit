import 'dart:async';
import 'dart:io';

import 'package:just_audio/just_audio.dart' as plugin;
import 'package:path/path.dart' as p;

import '../../domain/services/audio_player.dart';
import 'audio_store.dart';

/// [AudioPlayer] over `just_audio` — ADR-008.
///
/// **One instance, so one recording sounds at a time.** Loading a second file
/// replaces the first, which is the behaviour a thread with three pills in it
/// needs and is why this is not a player per pill.
///
/// **It never throws.** A missing file, an unreadable one and a platform that
/// would not open it all leave the player silent and the stream back at
/// [Playback.silent]; the chit renders without its pill (ARCHITECTURE.md §6).
final class JustAudioPlayer implements AudioPlayer {
  /// A player resolving stored paths through [_store].
  JustAudioPlayer(this._store) {
    _player.playerStateStream.listen(_onPlayerState);
    _player.positionStream.listen(_onPosition);
  }

  final AudioStore _store;
  final plugin.AudioPlayer _player = plugin.AudioPlayer();
  final StreamController<Playback> _out =
      StreamController<Playback>.broadcast();

  Playback _now = Playback.silent;

  @override
  Stream<Playback> get playback => _out.stream;

  @override
  Future<void> play({required String id, required String path}) async {
    try {
      if (!_now.holds(id)) {
        final File file = await _fileFor(path);
        if (!file.existsSync()) return _report(Playback.silent);

        await _player.setFilePath(file.path);
        _now = Playback(id: id);
      }

      // A pill pressed again at the end starts over rather than sitting on a
      // finished playhead doing nothing.
      if (_player.processingState == plugin.ProcessingState.completed) {
        await _player.seek(Duration.zero);
      }

      // Deliberately not awaited: `play` does not return until the audio ends.
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
    } on Object {
      // Nothing to tell. The state stream reports whatever actually happened.
    }
  }

  /// A stored path is relative and a take is absolute — ADR-008, and the one
  /// place that difference is resolved.
  Future<File> _fileFor(String path) async =>
      p.isAbsolute(path) ? File(path) : _store.resolve(path);

  void _onPlayerState(plugin.PlayerState state) {
    if (state.processingState == plugin.ProcessingState.completed) {
      // The end is silence, not a paused pill with a full playhead: the wave
      // clears and the label goes back to the take's length.
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
    if (_now.id == null) return;
    _report(_now = Playback(id: _now.id, position: at, playing: _now.playing));
  }

  void _report(Playback next) {
    if (!_out.isClosed) _out.add(next);
  }

  Future<void> _stopQuietly() async {
    try {
      await _player.stop();
    } on Object {
      // The player is being put down; there is nothing to recover.
    }
  }

  /// Releases the platform player. The root owns one of these for the life of
  /// the app, so this runs at teardown and in tests.
  Future<void> dispose() async {
    await _out.close();
    await _player.dispose();
  }
}
