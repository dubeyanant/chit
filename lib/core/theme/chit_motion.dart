import 'package:flutter/material.dart';

enum ChitPace { press, routine, arrival, prompt, exit }

@immutable
final class ChitMotion extends ThemeExtension<ChitMotion> {
  const ChitMotion({
    required this.curve,
    required this.reduceMotion,
    required this.durations,
  });

  const ChitMotion.tokens()
    : curve = const Cubic(0.2, 0, 0, 1),
      reduceMotion = false,
      durations = const <ChitPace, Duration>{
        ChitPace.press: Duration(milliseconds: 90),
        ChitPace.routine: Duration(milliseconds: 220),
        ChitPace.arrival: Duration(milliseconds: 400),
        ChitPace.prompt: Duration(milliseconds: 700),
        ChitPace.exit: Duration(milliseconds: 140),
      };

  final Curve curve;

  final bool reduceMotion;

  final Map<ChitPace, Duration> durations;

  static const Duration _reducedFade = Duration(milliseconds: 140);
  static const Duration _reducedArrivalFade = Duration(milliseconds: 220);

  static const Duration staggerStep = Duration(milliseconds: 55);

  Duration stagger() => reduceMotion ? Duration.zero : staggerStep;

  ChitMotion resolve({required bool reduceMotion}) =>
      reduceMotion == this.reduceMotion
      ? this
      : copyWith(reduceMotion: reduceMotion);

  Duration travel(ChitPace pace) =>
      reduceMotion ? Duration.zero : durations[pace]!;

  Duration loop(Duration period) => reduceMotion ? Duration.zero : period;

  Duration fade(ChitPace pace) {
    final Duration full = durations[pace]!;
    if (!reduceMotion) return full;
    final Duration target = pace == ChitPace.arrival
        ? _reducedArrivalFade
        : _reducedFade;
    return full < target ? full : target;
  }

  @override
  ChitMotion copyWith({
    Curve? curve,
    bool? reduceMotion,
    Map<ChitPace, Duration>? durations,
  }) {
    return ChitMotion(
      curve: curve ?? this.curve,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      durations: durations ?? this.durations,
    );
  }

  @override
  ChitMotion lerp(ChitMotion? other, double t) =>
      t < 0.5 ? this : other ?? this;
}
