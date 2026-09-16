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
      child: GestureDetector(
        onTap: onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.inkWash(colors.slip, opacity: ChitColors.saveWash),
            border: Border.all(color: colors.inkMuted),
            borderRadius: BorderRadius.circular(space.radius),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: space.s4),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: context.type.button.copyWith(color: colors.ink),
            ),
          ),
        ),
      ),
    );
  }
}

/// The quietest: no outline, and no colour of its own.
final class QuietButton extends StatefulWidget {
  /// A button reading [label], sized to its text.
  const QuietButton({required this.label, required this.onPressed, super.key});

  /// What it says.
  final String label;

  /// What it does.
  final VoidCallback onPressed;

  @override
  State<QuietButton> createState() => _QuietButtonState();
}

class _QuietButtonState extends State<QuietButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;

    return Semantics(
      button: true,
      child: GestureDetector(
        onTapDown: (TapDownDetails _) => setState(() => _pressed = true),
        onTapUp: (TapUpDetails _) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(
            // v6 pressed this in `--hair-soft`, which measures 1.0145:1 on a
            // chit and is in practice not drawn at all; an ink wash measures
            // 1.17:1. Under reduced motion, where the depress is gone (§6.4),
            // this wash is the *only* acknowledgement the press produces.
            color: _pressed
                ? colors.inkWash(
                    colors.slip,
                    opacity: ChitColors.discardPressedWash,
                  )
                : null,
            borderRadius: BorderRadius.circular(space.radius),
          ),
          child: Padding(
            // 14px by 16px in the prototype; both are `s4`. A padding is a
            // relationship and DESIGN-SYSTEM.md §6.3 keeps those on the scale.
            // At 16px the control measures 49px, clear of §6.4's 44px floor.
            padding: EdgeInsets.all(space.s4),
            child: Text(
              widget.label,
              // The label lifts to `--ink` while it is held. `--ink-faint`
              // clears the floor on a bare chit at 4.56:1 and falls under it
              // on any wash at all — 4.12:1 at even 4%. DESIGN-SYSTEM.md §6.1.
              style: context.type.button.copyWith(
                color: _pressed ? colors.ink : colors.inkFaint,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
