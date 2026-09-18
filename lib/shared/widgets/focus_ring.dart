import 'package:flutter/material.dart';

import '../../core/extensions.dart';

final class FocusRing extends StatefulWidget {
  const FocusRing({
    required this.child,
    required this.onActivate,
    this.radius,
    super.key,
  });

  static const double thickness = 1.5;

  final Widget child;

  final VoidCallback onActivate;

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
