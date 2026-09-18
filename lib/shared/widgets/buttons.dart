/// The two button weights of DESIGN-SYSTEM.md §6.1, in one place.
///
/// *They were private to the composer until the first-run screen needed the
/// same pair.* Three controls ranked by **weight rather than by colour**
/// (ADR-022): the bright one carries a border and a faint ink wash, the quiet
/// one has no outline at all. v5 made the bright one a solid `--seal` bar,
/// which became the loudest thing on the screen the instant it appeared.
///
/// Both clear §6.4's 44px floor at `s4` padding, and neither carries a colour
/// of its own beyond the wash — which is the rule that keeps a second accent
/// from appearing the next time somebody adds a screen.
library;

import 'package:flutter/material.dart';

import '../../core/extensions.dart';
import '../../core/theme/chit_colors.dart';
import 'focus_ring.dart';

/// The brighter of the two: a border, an ink wash, and still not a fill.
final class PrimaryButton extends StatelessWidget {
  /// A button reading [label], filling its width.
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  /// What it says.
  final String label;

  /// What it does. Asynchronous, and nothing here waits on it: the state the
  /// button is drawn from changes when the work returns.
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;

    return Semantics(
      button: true,
      child: FocusRing(
        onActivate: onPressed,
        child: GestureDetector(
          onTap: onPressed,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.inkWash(colors.slip, opacity: ChitColors.saveWash),
              border: Border.all(color: colors.inkMuted),
              borderRadius: BorderRadius.circular(space.radius),
            ),
            child: Padding(
              // `s4` top and bottom takes the label to 49px, clear of §6.4's
              // 44px floor.
              padding: EdgeInsets.symmetric(vertical: space.s4),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: context.type.button.copyWith(color: colors.ink),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The quietest: no outline, and no colour of its own.
final class QuietButton extends StatelessWidget {
  /// A button reading [label], sized to its text.
  const QuietButton({required this.label, required this.onPressed, super.key});

  /// What it says.
  final String label;

  /// What it does.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;

    return Semantics(
      button: true,
      child: FocusRing(
        onActivate: onPressed,
        child: GestureDetector(
          onTap: onPressed,
          child: Padding(
            // 14px by 16px in the prototype; both are `s4`. A padding is a
            // relationship and DESIGN-SYSTEM.md §6.3 keeps those on the scale.
            // At 16px the control measures 49px, clear of §6.4's 44px floor.
            padding: EdgeInsets.all(space.s4),
            child: Text(
              label,
              // `--ink-faint`, and it stays there: with no pressed wash under
              // it (ADR-071) there is no surface for a lift to be against. On
              // a bare chit the label measures 4.56:1.
              style: context.type.button.copyWith(color: colors.inkFaint),
            ),
          ),
        ),
      ),
    );
  }
}
