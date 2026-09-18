import 'dart:async';

import 'package:chit/domain/services/audio_player.dart';

/// An [AudioPlayer] driven by hand — CLAUDE.md §4.1's Liskov rule.
///
/// **It refuses the way the real one refuses, which is silently.** A file that
/// has vanished leaves `JustAudioPlayer` back at [Playback.silent] with no
/// error, so [missing] does exactly that and there is no exception to inject.
///
/// One player, so loading a second pill replaces the first. That is the whole
/// reason the interface exists, and it is what this fake has to get right.
final class FakeAudioPlayer implements AudioPlayer {
  /// Paths that are not there. Playing one of them keeps the player silent.
  final Set<String> missing = <String>{};

  /// Every `play` this has been asked for, in order.
  final List<String> asked = <String>[];

  final StreamController<Playback> _out =
      StreamController<Playback>.broadcast();

  Playback _now = Playback.silent;

  /// What the player is currently reporting.
  Playback get now => _now;

  @override
  Stream<Playback> get playback => _out.stream;

  @override
  Future<void> play({required String id, required String path}) async {
    asked.add(id);
    if (missing.contains(path)) return _emit(Playback.silent);

    // A different pill replaces the one loaded; the same one resumes where it
    // was paused.
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

  /// The playhead has reached [at].
  void advanceTo(Duration at) {
    if (_now.id == null) return;
    _emit(Playback(id: _now.id, position: at, playing: _now.playing));
  }

  /// The recording ran out. The real player stops rather than resting on a
  /// full playhead.
  void finish() => _emit(Playback.silent);

  void _emit(Playback next) {
    _now = next;
    if (!_out.isClosed) _out.add(next);
  }

  /// Closes the stream. Call it from a `tearDown`.
  Future<void> dispose() => _out.close();
}
