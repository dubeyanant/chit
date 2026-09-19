library;

import 'package:flutter/material.dart';

import '../../core/extensions.dart';
import '../../core/theme/chit_colors.dart';
import 'focus_ring.dart';

final class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;

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
              padding: EdgeInsets.symmetric(
                vertical: space.s4,
                horizontal: space.s4,
              ),
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

final class QuietButton extends StatelessWidget {
  const QuietButton({
    required this.label,
    required this.onPressed,
    this.wide = false,
    super.key,
  });

  final String label;

  final VoidCallback onPressed;

  final bool wide;

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
            padding: EdgeInsets.all(space.s4),
            child: Text(
              label,
              textAlign: wide ? TextAlign.center : TextAlign.start,
              style: context.type.button.copyWith(color: colors.inkFaint),
            ),
          ),
        ),
      ),
    );
  }
}
