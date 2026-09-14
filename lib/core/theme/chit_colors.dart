import 'package:flutter/material.dart';

/// The colour tokens of DESIGN-SYSTEM.md §6.1.
///
/// One palette, dark, one accent. The accent exists in two weights and which
/// one to use is decided by the job, not by taste: [seal] is for marks, fills,
/// borders and icons — anything read as a shape — and [sealInk] is the same
/// stamp wherever it has to carry words, because [seal] measures 4.23:1 on
/// [slip] and text has to clear 4.5:1.
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
  });

  /// The palette exactly as DESIGN-SYSTEM.md §6.1 sets it.
  const ChitColors.tokens()
    : paper = const Color(0xFF191714),
      slip = const Color(0xFF211E1A),
      slipUnder = const Color(0xFF141210),
      ink = const Color(0xFFEDE7DC),
      inkMuted = const Color(0xFFA39B8B),
      inkFaint = const Color(0xFF8F8879),
      hair = const Color(0xFF2E2A25),
      hairSoft = const Color(0xFF252220),
      seal = const Color(0xFFC4664E),
      sealInk = const Color(0xFFD2725A);

  /// The ground.
  final Color paper;

  /// A chit's surface.
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

  /// Inner dividers.
  final Color hairSoft;

  /// The one accent, as a mark: fills, borders, icons, the caret, the day-arc
  /// marks, the calendar heat, the microphone, the Save button.
  ///
  /// Never used for text. See [sealInk].
  final Color seal;

  /// The accent lifted until it clears 4.5:1 as text, on [paper] and [slip]
  /// alike. The `listening` label on the recording sheet and the `now` cap on
  /// the day arc.
  final Color sealInk;

  /// [seal] laid over [surface] at [opacity], flattened to an opaque colour.
  ///
  /// The audio pill is a 7% wash of the accent, and DESIGN-SYSTEM.md §6.4 is explicit
  /// that a translucent surface counts as its own surface: the wash lifts the
  /// ground under it enough to fail [inkFaint], which is why the pill's
  /// duration is set in [inkMuted]. Flattening here rather than at each call
  /// site means the contrast test can check the colour that is actually drawn.
  Color sealWash(Color surface, {required double opacity}) =>
      Color.alphaBlend(seal.withValues(alpha: opacity), surface);

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
    );
  }
}
