import 'package:flutter/material.dart';

import 'chit_colors.dart';
import 'chit_motion.dart';
import 'chit_space.dart';
import 'chit_type.dart';

abstract final class ChitTheme {
  const ChitTheme._();

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

      fontFamily: ChitType.serifFamily,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      extensions: <ThemeExtension<dynamic>>[colors, type, space, motion],
    );
  }
}
