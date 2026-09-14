import 'package:flutter/material.dart';

import 'chit_colors.dart';
import 'chit_motion.dart';
import 'chit_space.dart';
import 'chit_type.dart';

/// Assembles [ThemeData] from the four extensions of DESIGN-SYSTEM.md §6.
///
/// The extensions are the design system; what [ThemeData] itself carries is
/// only what Flutter's own widgets need in order not to contradict them.
abstract final class ChitTheme {
  const ChitTheme._();

  /// chit has one theme. DESIGN-SYSTEM.md §6: dark, single palette.
  static ThemeData get theme {
    const colors = ChitColors.tokens();
    final type = ChitType.tokens(colors);
    const space = ChitSpace.tokens();
    const motion = ChitMotion.tokens();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.paper,
      canvasColor: colors.paper,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.seal,
        brightness: Brightness.dark,
        surface: colors.paper,
        onSurface: colors.ink,
        primary: colors.seal,
      ),
      // Newsreader is the writing voice, so it is what anything unstyled
      // inherits. A widget should still take its style from ChitType; this is
      // the floor, not the intent.
      fontFamily: ChitType.serifFamily,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      extensions: <ThemeExtension<dynamic>>[colors, type, space, motion],
    );
  }
}
