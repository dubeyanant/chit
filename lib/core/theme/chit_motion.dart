import 'package:flutter/material.dart';

/// What kind of movement is being asked for, from README §6.3's pace table.
///
/// The caller states intent and [ChitMotion] decides the number. That is what
/// lets reduced motion be one decision made once rather than a condition
/// scattered through every widget.
enum ChitPace {
  /// 90ms. A finger's only acknowledgement on a phone — a 0.985 depress,
  /// 0.99 on the audio pill.
  press,

  /// 220ms, the house pace. Switching tab; Discard and Save arriving once the
  /// chit holds something.
  routine,

  /// 400ms. The two moments in the app with any authorship: a chit falling
  /// down into the thread, a recording rising up into the open chit.
  arrival,

  /// 700ms, deliberately slower than everything else. The five-second prompt
  /// of README §3.3 — a prompt that fades in slowly is an offer.
  prompt,

  /// 140ms. Exits are always quicker than entrances; a slow dismissal reads
  /// as lag.
  exit,
}

/// The motion tokens of README §6.3, and the reduced-motion rule of §6.4.
///
/// **Movement collapses and feedback does not.** [travel] is for anything that
/// moves, zooms or loops, and it collapses to nothing when the user has asked
/// for reduced motion. [fade] is for opacity and colour, and it survives —
/// re-timed, but never removed. Reducing motion should cost a user animation,
/// not confirmation that their action landed.
///
/// Read this through `context.motion`, which resolves the reduced-motion flag
/// from the current `MediaQuery`. Reading it off `Theme` directly gets the
/// unresolved instance and silently ignores the user's setting.
@immutable
final class ChitMotion extends ThemeExtension<ChitMotion> {
  /// Every pace, given explicitly. [ChitMotion.tokens] is the pace table.
  const ChitMotion({
    required this.curve,
    required this.reduceMotion,
    required this.durations,
  });

  /// The pace table exactly as README §6.3 sets it, with movement enabled.
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

  /// `cubic-bezier(.2,0,0,1)`. Things arrive from where they came from, and
  /// settle.
  final Curve curve;

  /// Whether the platform has asked for reduced motion.
  final bool reduceMotion;

  /// The pace table: how long each kind of movement takes when motion is not
  /// reduced. Read it through [travel] or [fade], never directly — those two
  /// are where README §6.4's rule lives.
  final Map<ChitPace, Duration> durations;

  static const Duration _reducedFade = Duration(milliseconds: 140);
  static const Duration _reducedArrivalFade = Duration(milliseconds: 220);

  /// This instance carrying [reduceMotion].
  ///
  /// Returns `this` unchanged when the flag already matches, so the common
  /// case allocates nothing.
  ChitMotion resolve({required bool reduceMotion}) =>
      reduceMotion == this.reduceMotion
      ? this
      : copyWith(reduceMotion: reduceMotion);

  /// How long something that *moves* should take: travel, zoom, scale, or any
  /// ambient loop — the caret blink, the pulse at now, the breathing record
  /// dot, the live waveform.
  ///
  /// [Duration.zero] under reduced motion, which stops the animation outright
  /// rather than speeding it up.
  Duration travel(ChitPace pace) =>
      reduceMotion ? Duration.zero : durations[pace]!;

  /// How long a change in *opacity or colour* should take.
  ///
  /// Survives reduced motion. Arrivals become a plain fade going nowhere at
  /// 220ms and everything else re-times to 140ms — except that a fade already
  /// quicker than its reduced target keeps its own pace, because reducing
  /// motion must never make the app feel slower (ADR-020). Press feedback is
  /// the case that matters: 90ms stays 90ms.
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
