import 'package:flutter/material.dart';

/// The colour tokens of DESIGN-SYSTEM.md §6.1.
///
/// One palette, dark, one accent.
///
/// **The accent marks what is live, and nothing else** (ADR-022): the ring at
/// now, the caret, the record dot, today on the calendar, and an audio pill
/// while it is playing. Everything that is a record rather than a happening is
/// ink. Hierarchy that a more liberal palette would take from colour comes
/// from weight instead — see [inkWash].
///
/// The accent exists in two weights and which one to use is decided by the
/// job, not by taste: [seal] is for marks, fills, borders and icons — anything
/// read as a shape — and [sealInk] is the same stamp wherever it has to carry
/// words, because [seal] measures 4.09:1 on [slip] and text has to clear
/// 4.5:1.
///
/// Every value here is verified against that floor by
/// `test/core/theme/contrast_test.dart`, composited. A new colour without a
/// line in that test is a colour nobody has checked.
@immutable
final class ChitColors extends ThemeExtension<ChitColors> {
  /// Every token, given explicitly. [ChitColors.tokens] is the palette.
  const ChitColors({
    required this.paper,
    required this.slip,
    required this.slipUnder,
    required this.ink,
    required this.inkMuted,
    required this.inkFaint,
    required this.hair,
    required this.hairSoft,
    required this.seal,
    required this.sealInk,
    required this.scrim,
  });

  /// The palette exactly as DESIGN-SYSTEM.md §6.1 sets it.
  const ChitColors.tokens()
    : paper = const Color(0xFF191714),
      slip = const Color(0xFF24211C),
      slipUnder = const Color(0xFF141210),
      ink = const Color(0xFFEDE7DC),
      inkMuted = const Color(0xFFA39B8B),
      inkFaint = const Color(0xFF8F8879),
      hair = const Color(0xFF2E2A25),
      hairSoft = const Color(0xFF252220),
      seal = const Color(0xFFC4664E),
      sealInk = const Color(0xFFD2725A),
      scrim = const Color(0xB8080706);

  /// The ground.
  final Color paper;

  /// A chit's surface.
  ///
  /// Four points brighter than [paper], which is what lets a chit read as a
  /// surface rather than as a rectangle described by its border. Every ratio
  /// measured against a chit moved when it did, so changing this means
  /// rechecking all of them — the contrast test is what does that.
  final Color slip;

  /// The pad beneath the open chit.
  final Color slipUnder;

  /// Primary text.
  final Color ink;

  /// Secondary text.
  final Color inkMuted;

  /// Metadata.
  final Color inkFaint;

  /// Borders and rules.
  final Color hair;

  /// Inner dividers — **on [paper] only**, where it measures 1.13:1.
  ///
  /// It measures 1.0145:1 on [slip] and would not be seen. v6 brightened the
  /// chit surface onto it; nothing draws this pair any more, and the one place
  /// that did — Discard's pressed background — has no wash at all since
  /// ADR-071 took the app's press feedback off.
  final Color hairSoft;

  /// The one accent, as a mark — and only on what is live (ADR-022): the ring
  /// at now on the day arc, the caret in the field, the record dot on the
  /// recording sheet, the ring around today, and an audio pill while it is
  /// playing.
  ///
  /// It is **not** the day-arc marks, the calendar's density, the tab pip, a
  /// pill at rest, the microphone or Save. Those were all accent in v5, and
  /// spread that wide the colour stopped meaning anything.
  ///
  /// Never used for text. See [sealInk].
  final Color seal;

  /// The accent lifted until it clears 4.5:1 as text, on [paper] and [slip]
  /// alike. The `listening` label on the recording sheet and the `now` cap on
  /// the day arc.
  final Color sealInk;

  /// What the recording sheet lays over the app behind it — `#080706` at 72%.
  ///
  /// **Darker than [paper] and not a tint of it.** A scrim in the app's own
  /// ground would read as another surface; this one reads as the page going
  /// away, which is what a modal is for. The one translucent colour in the
  /// palette, and the only one that is not measured for contrast — nothing is
  /// ever read through it.
  final Color scrim;

  /// [ink] laid over [surface] at [opacity], flattened to an opaque colour.
  ///
  /// Every raised surface in the app is this: ink at a stated alpha over the
  /// ground it sits on. It is how v6 gets hierarchy out of weight rather than
  /// colour (ADR-022), and it replaced a wash of [seal] that made the audio
  /// pill the loudest thing in a thread.
  ///
  /// DESIGN-SYSTEM.md §6.4 is explicit that a translucent surface counts as
  /// its own surface: even at [pillWash] the lift is enough to fail
  /// [inkFaint], which is why an audio pill's duration is set in [inkMuted].
  /// Flattening here rather than at each call site is what lets the contrast
  /// test check the colour that is actually drawn.
  Color inkWash(Color surface, {required double opacity}) =>
      Color.alphaBlend(ink.withValues(alpha: opacity), surface);

  /// An audio pill at rest — 3.5%.
  static const double pillWash = 0.035;

  /// An audio pill under a finger — 8%.

  /// **Save chit** — 7%, over a border in [inkMuted]. The brightest of the
  /// three controls at the foot of the open chit, and still not a fill.
  static const double saveWash = 0.07;

  /// The microphone under a finger — 10%.

  /// The calendar's four density steps, faintest first — 6, 12, 20 and 30%.
  ///
  /// How much ink went down on a day. The *mapping* from a chit count to one
  /// of these lives in the presentation layer, because it is a design scale
  /// rather than a fact about the data (ARCHITECTURE.md §4.6); the values are
  /// design tokens and live here.
  ///
  /// A numeral over any of them is [ink], which clears the floor on all four —
  /// 12.66:1 down to 5.99:1. That is why v6 has no near-white numeral and no
  /// token for one.
  static const List<double> densitySteps = <double>[0.06, 0.12, 0.20, 0.30];

  // There are no hover washes here on purpose. The prototype is a browser and
  // carries them for Save and the microphone; a finger gets no hover, and
  // pressure is the only feedback touch has — the design log is explicit.
  // Web comes after v1 (ADR-019), and that is when they get added and measured.

  @override
  ChitColors copyWith({
    Color? paper,
    Color? slip,
    Color? slipUnder,
    Color? ink,
    Color? inkMuted,
    Color? inkFaint,
    Color? hair,
    Color? hairSoft,
    Color? seal,
    Color? sealInk,
    Color? scrim,
  }) {
    return ChitColors(
      paper: paper ?? this.paper,
      slip: slip ?? this.slip,
      slipUnder: slipUnder ?? this.slipUnder,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      inkFaint: inkFaint ?? this.inkFaint,
      hair: hair ?? this.hair,
      hairSoft: hairSoft ?? this.hairSoft,
      seal: seal ?? this.seal,
      sealInk: sealInk ?? this.sealInk,
      scrim: scrim ?? this.scrim,
    );
  }

  @override
  ChitColors lerp(ChitColors? other, double t) {
    if (other == null) return this;
    return ChitColors(
      paper: Color.lerp(paper, other.paper, t)!,
      slip: Color.lerp(slip, other.slip, t)!,
      slipUnder: Color.lerp(slipUnder, other.slipUnder, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      inkFaint: Color.lerp(inkFaint, other.inkFaint, t)!,
      hair: Color.lerp(hair, other.hair, t)!,
      hairSoft: Color.lerp(hairSoft, other.hairSoft, t)!,
      seal: Color.lerp(seal, other.seal, t)!,
      sealInk: Color.lerp(sealInk, other.sealInk, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
    );
  }
}
