import 'package:flutter/material.dart';

import 'theme/chit_colors.dart';
import 'theme/chit_motion.dart';
import 'theme/chit_space.dart';
import 'theme/chit_type.dart';

/// Reaches the design system from a widget.
///
/// Four accessors rather than one, so that a widget which needs a colour
/// cannot reach motion. They are separate for the same reason the extensions
/// are separate classes: colour, type, spacing and motion change for different
/// reasons and are read by different code.
///
/// Each of these registers a dependency on the ambient [Theme] — and
/// [motion] on the [MediaQuery] as well — so a widget that reads one rebuilds
/// when it changes.
extension ChitThemeContext on BuildContext {
  /// The colour tokens of DESIGN-SYSTEM.md §6.1.
  ChitColors get colors => Theme.of(this).extension<ChitColors>()!;

  /// The type scale of DESIGN-SYSTEM.md §6.2.
  ChitType get type => Theme.of(this).extension<ChitType>()!;

  /// The spacing and shape tokens of DESIGN-SYSTEM.md §6.3.
  ChitSpace get space => Theme.of(this).extension<ChitSpace>()!;

  /// The motion tokens of DESIGN-SYSTEM.md §6.3, already resolved against the
  /// platform's reduced-motion setting.
  ///
  /// Resolving here rather than at each call site is what makes DESIGN-SYSTEM.md §6.4's
  /// rule — movement collapses, feedback does not — a single decision. Reading
  /// [ChitMotion] off [Theme] directly bypasses it and is always a mistake.
  ChitMotion get motion =>
      Theme.of(this)
          .extension<ChitMotion>()!
          .resolve(reduceMotion: MediaQuery.disableAnimationsOf(this));
}
