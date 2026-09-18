import 'package:flutter/material.dart';

import '../../core/extensions.dart';

/// A control's keyboard focus, and the one way it is drawn — §6.4.
///
/// **Only on keyboard or switch focus, never on touch.** That is
/// `FocusableActionDetector`'s own distinction, not one this re-derives: a
/// finger leaves no focus behind, so on a phone this draws nothing and costs
/// nothing. It matters for switch access, which is the case §6.4's floor is
/// actually about.
///
/// It also gives the control **Enter and Space**, through [onActivate]. A
/// control reachable by keyboard that could not then be used by one would be a
/// focus ring around nothing.
///
/// **The ring is painted over the child, not around it** — a foreground
/// decoration takes no layout, so nothing moves when focus arrives, and the
/// box is in the tree whether or not it is drawn. A border that came and went
/// would change the shape of the tree and rebuild everything under it, which
/// is the mistake ADR-070 was written about.
final class FocusRing extends StatefulWidget {
  /// Wraps [child], which [onActivate] runs when a keyboard presses it.
  const FocusRing({
    required this.child,
    required this.onActivate,
    this.radius,
    super.key,
  });

  /// **1.5px — the app's one stroke.** The caret is drawn at it and so is the
  /// tick at now; a focus ring at some other weight would be a second
  /// vocabulary for a line.
  static const double thickness = 1.5;

  /// The control.
  final Widget child;

  /// What Enter and Space do. The same thing a tap does.
  final VoidCallback onActivate;

  /// The corner the ring follows. `ChitSpace.radius` unless the control is
  /// rounder than the paper it sits on, which only the sheet's is.
  final double? radius;

  @override
  State<FocusRing> createState() => _FocusRingState();
}

class _FocusRingState extends State<FocusRing> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowFocusHighlight: (bool on) {
        if (on == _focused || !mounted) return;
        setState(() => _focused = on);
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (ActivateIntent _) {
            widget.onActivate();
            return null;
          },
        ),
      },
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          border: Border.all(
            color: _focused ? colors.seal : Colors.transparent,
            width: FocusRing.thickness,
          ),
          borderRadius: BorderRadius.circular(
            widget.radius ?? context.space.radius,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
