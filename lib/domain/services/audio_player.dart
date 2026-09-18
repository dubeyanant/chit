import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_player.g.dart';

@immutable
final class Playback {
  const Playback({
    this.id,
    this.position = Duration.zero,
    this.playing = false,
  });

  static const Playback silent = Playback();

  static const String openChit = 'open-chit';

  final String? id;

  final Duration position;

  final bool playing;

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

abstract interface class AudioPlayer {
  Stream<Playback> get playback;

  Future<void> play({required String id, required String path});

  Future<void> pause();

  Future<void> stopIf(String id);
}

@Riverpod(keepAlive: true)
AudioPlayer audioPlayer(Ref ref) => throw UnimplementedError(
  'audioPlayerProvider is overridden at the root — see main.dart',
);

@riverpod
Stream<Playback> playback(Ref ref) => ref.watch(audioPlayerProvider).playback;
