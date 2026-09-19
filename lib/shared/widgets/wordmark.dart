import 'package:flutter/material.dart';

import '../../core/extensions.dart';
import 'focus_ring.dart';

final class Wordmark extends StatelessWidget {
  const Wordmark({this.onOpenGuide, super.key});

  final VoidCallback? onOpenGuide;

  @override
  Widget build(BuildContext context) {
    final Widget mark = Text('चित्त', style: context.type.wordmark);

    final VoidCallback? open = onOpenGuide;
    if (open == null) {
      return Semantics(
        header: true,
        label: 'Chitta',
        excludeSemantics: true,
        child: mark,
      );
    }

    return Semantics(
      header: true,
      button: true,
      label: 'Chitta',
      hint: 'How to use Chitta',
      excludeSemantics: true,
      child: FocusRing(
        onActivate: open,
        child: GestureDetector(
          onTap: open,
          behavior: HitTestBehavior.opaque,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: context.space.minTouchTarget,
            ),
            child: Align(alignment: Alignment.centerLeft, child: mark),
          ),
        ),
      ),
    );
  }
}
