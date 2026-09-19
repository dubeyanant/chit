import 'package:flutter/material.dart';

@immutable
final class ChitColors extends ThemeExtension<ChitColors> {
  const ChitColors({
    required this.paper,
    required this.slip,
    required this.slipUnder,
    required this.ink,
    required this.inkMuted,
    required this.inkFaint,
    required this.inkDisabled,
    required this.hair,
    required this.hairSoft,
    required this.seal,
    required this.sealInk,
    required this.scrim,
  });

  const ChitColors.tokens()
    : paper = const Color(0xFF191714),
      slip = const Color(0xFF24211C),
      slipUnder = const Color(0xFF141210),
      ink = const Color(0xFFEDE7DC),
      inkMuted = const Color(0xFFA39B8B),
      inkFaint = const Color(0xFF8F8879),
      inkDisabled = const Color(0xFF5A554C),
      hair = const Color(0xFF2E2A25),
      hairSoft = const Color(0xFF252220),
      seal = const Color(0xFFC4664E),
      sealInk = const Color(0xFFD2725A),
      scrim = const Color(0xB8080706);

  final Color paper;

  final Color slip;

  final Color slipUnder;

  final Color ink;

  final Color inkMuted;

  final Color inkFaint;

  /// A control that is drawn and cannot be used — 2.4:1 on paper (ADR-088).
  ///
  /// **Deliberately under §6.4's 3:1 component floor**: it must read as
  /// present and not as available, and a disabled control meeting the floor
  /// set for a live one would be lying about what it does.
  final Color inkDisabled;

  final Color hair;

  final Color hairSoft;

  final Color seal;

  final Color sealInk;

  final Color scrim;

  Color inkWash(Color surface, {required double opacity}) =>
      Color.alphaBlend(ink.withValues(alpha: opacity), surface);

  static const double pillWash = 0.035;

  static const double saveWash = 0.07;

  static const List<double> densitySteps = <double>[0.06, 0.12, 0.20, 0.30];

  /// The map behind find's first screen — ADR-089, drawn with [inkWash] on
  /// `--paper` so that overlapping shapes never compound into a surface nobody
  /// measured.
  ///
  /// **[mapHost] is the ceiling, and it is set by the text above it**, not by
  /// taste: it is the lightest thing a word can come to rest on, and §6.4 holds
  /// the quote and the column to 4.5:1 against it. `contrast_test.dart` asserts
  /// both, and that nothing here is brighter.
  static const double mapLine = 0.07;
  static const double mapWater = 0.10;
  static const double mapFill = 0.10;
  static const double mapHost = 0.13;

  /// The fix itself, on its own disc of `--paper` — so the one bright mark on
  /// the screen reads the same whether it falls on the city or off it.
  static const double mapPin = 0.42;

  @override
  ChitColors copyWith({
    Color? paper,
    Color? slip,
    Color? slipUnder,
    Color? ink,
    Color? inkMuted,
    Color? inkFaint,
    Color? inkDisabled,
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
      inkDisabled: inkDisabled ?? this.inkDisabled,
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
      inkDisabled: Color.lerp(inkDisabled, other.inkDisabled, t)!,
      hair: Color.lerp(hair, other.hair, t)!,
      hairSoft: Color.lerp(hairSoft, other.hairSoft, t)!,
      seal: Color.lerp(seal, other.seal, t)!,
      sealInk: Color.lerp(sealInk, other.sealInk, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
    );
  }
}
