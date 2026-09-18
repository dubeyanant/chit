import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_player.g.dart';

/// What the one player is doing — BEHAVIOUR.md §3.4's playback.
@immutable
final class Playback {
  /// The player at [position] in [id], playing or not.
  const Playback({
    this.id,
    this.position = Duration.zero,
    this.playing = false,
  });

  /// Nothing is playing. Where every take starts and ends.
  static const Playback silent = Playback();

  /// The id the open chit's kept take plays under.
  ///
  /// It has no row yet and may never get one, but the player still has to be
  /// able to say *this pill and not that one* — and the composer has to be
  /// able to name it when Save or Remove takes the file away.
  static const String openChit = 'open-chit';

  /// Which pill this is about, or `null` when none is loaded.
  ///
  /// A chit's id, and the open chit's take has one of its own — it is an
  /// identity for *which pill*, not a row that has to exist.
  final String? id;

  /// How far in. The playhead, and the figure the pill shows while playing.
  final Duration position;

  /// Whether sound is coming out. `false` with an [id] is paused, which is a
  /// pill that keeps its playhead.
  final bool playing;

  /// Whether [pill] is the one loaded — playing or paused.
  bool holds(String pill) => id == pill;

  @override
  bool operator ==(Object other) =>
      other is Playback &&
      other.id == id &&
      other.position == position &&
      other.playing == playing;

  @override
  int get hashCode => Object.hash(id, position, playing);

  @override
  String toString() => 'Playback($id, $position, playing: $playing)';
}

/// Plays a chit's recording back — ADR-008, ADR-014.
///
/// **One player for the whole app**, so two pills can never sound at once. It
/// is a `keepAlive` provider for that reason and no other: a player per pill
/// would be a thread that plays three recordings over each other.
///
/// **It never throws.** A file that has vanished, a codec the platform will
/// not open and a path that resolves to nothing all leave the player silent,
/// because a recording that has gone is a loss rather than a corruption and
/// the chit still renders (ARCHITECTURE.md §6).
abstract interface class AudioPlayer {
  /// What is playing, as it changes.
  ///
  /// **Every listener is given the current state first**, before anything
  /// changes. A pill is built long after a recording started sounding — the
  /// archive is rebuilt on every tab change — and a stream that only carried
  /// *changes* left those pills drawn as though nothing were playing, so the
  /// one control that could stop the sound was a play button that did nothing.
  Stream<Playback> get playback;

  /// Plays the recording at [path], reported under [id].
  ///
  /// Playing a different [id] replaces whatever was sounding. Playing the one
  /// already loaded resumes it from where it was paused.
  ///
  /// [path] is **relative to the documents directory for a saved chit and
  /// absolute for a take not yet saved** — ADR-008 stores relative paths, so
  /// an absolute one is by construction a temp file. Resolving the difference
  /// is the implementation's job; `features` has no filesystem.
  Future<void> play({required String id, required String path});

  /// Stops, keeping the playhead where it is.
  Future<void> pause();

  /// Stops and unloads, but **only if [id] is the pill that is loaded**.
  ///
  /// The open chit's take is what this exists for. Save moves that file out of
  /// the cache and Remove deletes it, and either way the pill playing it
  /// stops being drawn a frame later — a player left running would go on
  /// sounding a recording with no control anywhere able to stop it. The
  /// `if` matters: a chit saved while a *thread* pill is playing must not
  /// silence it.
  Future<void> stopIf(String id);
}

/// The player the app runs on.
///
/// Unimplemented on purpose, for the reason `audioRecorderProvider` is:
/// `domain` cannot import `data` (ARCHITECTURE.md §1), so `main.dart` supplies
/// `JustAudioPlayer` and tests supply a fake.
@Riverpod(keepAlive: true)
AudioPlayer audioPlayer(Ref ref) => throw UnimplementedError(
  'audioPlayerProvider is overridden at the root — see main.dart',
);

/// What the one player is doing, for whatever pill is asking.
///
/// A single stream every pill watches, rather than a player each: which pill
/// is lit is a property of the app, not of a row.
@riverpod
Stream<Playback> playback(Ref ref) => ref.watch(audioPlayerProvider).playback;
