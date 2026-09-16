import 'package:flutter/material.dart';

/// What kind of movement is being asked for, from DESIGN-SYSTEM.md §6.3's pace table.
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
  /// of BEHAVIOUR.md §3.3 — a prompt that fades in slowly is an offer.
  prompt,

  /// 140ms. Exits are always quicker than entrances; a slow dismissal reads
  /// as lag.
  exit,
}

/// The motion tokens of DESIGN-SYSTEM.md §6.3, and the reduced-motion rule of §6.4.
///
/// **Movement collapses and feedback does not.** [travel] is for anything that
/// moves or zooms and [loop] for anything that repeats; both collapse to
/// nothing when the user has asked for reduced motion. [fade] is for opacity
/// and colour, and it survives —
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

  /// The pace table exactly as DESIGN-SYSTEM.md §6.3 sets it, with movement enabled.
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
  /// are where DESIGN-SYSTEM.md §6.4's rule lives.
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

  /// How long something that *moves* should take: travel, zoom or scale.
  ///
  /// An ambient loop takes its period from [loop] rather than from the pace
  /// table — ADR-027.
  ///
  /// [Duration.zero] under reduced motion, which stops the animation outright
  /// rather than speeding it up.
  Duration travel(ChitPace pace) =>
      reduceMotion ? Duration.zero : durations[pace]!;

  /// How long one cycle of an **ambient loop** takes — the pulse at now, the
  /// breathing record dot, the live waveform (§6.4).
  ///
  /// [Duration.zero] under reduced motion, exactly as [travel]: a loop stops
  /// outright rather than slowing down, and a caller that gets zero should
  /// draw the thing at rest and start no ticker at all.
  ///
  /// **[period] is the loop's own and belongs to the component that loops**,
  /// which is why this takes a duration where [travel] takes a [ChitPace]. A
  /// loop has a period rather than a duration; periods are not comparable to
  /// transitions or to each other, and the pulse at now runs at 5.2s — putting
  /// that in the pace table would make §6.3's *"the prompt is the slowest
  /// thing in the app"* false for no gain. §6.3 says the same about dimensions
  /// that belong to one component, for the same reason.
  Duration loop(Duration period) => reduceMotion ? Duration.zero : period;

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
