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

  /// True while [play] is swapping one recording for another.
  ///
  /// **The position stream goes on reporting the file that is leaving.** It is
  /// a timer interpolating from the last event the platform sent, so while the
  /// next file loads it still answers with the old one's playhead — and that
  /// figure, attributed to the pill arriving, is a playhead that starts
  /// halfway. `_onPosition`'s guard then holds it there until the new
  /// recording catches up to it. *Seen on a handset: play one pill, play
  /// another, come back to the first, and its wave is frozen where it was left
  /// while the sound runs from the start underneath it.*
  bool _switching = false;

  @override
  Stream<Playback> get playback async* {
    // The current state first, then the changes — a pill built while something
    // is already sounding has to know that before it draws itself.
    yield _now;
    yield* _out.stream;
  }

  @override
  Future<void> play({required String id, required String path}) async {
    try {
      if (!_now.holds(id)) {
        final File file = await _fileFor(path);
        if (!file.existsSync()) {
          // The pill that was loaded is no longer the one being asked for, so
          // leaving `_now` on it would light a pill nothing is playing.
          _now = Playback.silent;
          await _stopQuietly();
          return _report(_now);
        }

        // **Whatever was sounding is paused before the next file loads.** The
        // plugin carries `playing` across a source change and its `play()`
        // returns early while it is set, so a pill tapped while another one
        // sounded was loaded and heard but never reported *playing* under its
        // own id: the border lit, the glyph stayed a triangle, and the next
        // tap did nothing. `_now` moves first, so the pause is reported under
        // the new pill rather than as the old one stopping.
        //
        // **`pause` and not `stop`.** Both clear the flag; `stop` also tears
        // the native player down and the next `setFilePath` builds a new one,
        // which cost the first tap after launch its sound on a handset and
        // no test could see — the plugin re-inits so quietly that a fake
        // platform answers either way. `_platformInits` in the test is what
        // holds the difference now.
        // Nothing the old file has left to say is about this one.
        _switching = true;
        try {
          _now = Playback(id: id);
          await _pauseQuietly();
          await _player.setFilePath(file.path);
        } finally {
          _switching = false;
        }
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

  @override
  Future<void> stopIf(String id) async {
    if (!_now.holds(id)) return;
    _now = Playback.silent;
    await _stopQuietly();
    _report(_now);
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
    if (_now.id == null || _switching) return;
    // **A playhead never goes backwards while a take plays.** Nothing here
    // seeks mid-play — a finished take is reloaded, not rewound — so a
    // position lower than the last one is the platform correcting itself, not
    // the recording starting over. *Seen on a handset on 18 September 2026 on
    // two-second takes: the wave ran for about a second, snapped back to the
    // start and ran again.* Whether the sound did the same is open item 39;
    // holding the higher figure keeps the pill honest either way, at the cost
    // of the bars pausing for a beat if the platform's real position is behind.
    if (at < _now.position) return;
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

  /// Clears the plugin's `playing` flag without releasing the native player.
  ///
  /// The difference from [_stopQuietly] is the whole of the fix above: a stop
  /// releases the decoder, a pause does not.
  Future<void> _pauseQuietly() async {
    try {
      await _player.pause();
    } on Object {
      // Nothing to tell. The state stream reports whatever happened.
    }
  }

  /// Releases the platform player. The root owns one of these for the life of
  /// the app, so this runs at teardown and in tests.
  Future<void> dispose() async {
    await _out.close();
    await _player.dispose();
  }
}
