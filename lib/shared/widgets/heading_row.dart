import 'package:flutter/material.dart';

import '../../core/extensions.dart';

final class HeadingRow extends StatelessWidget {
  const HeadingRow({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.space.minTouchTarget,
      child: Align(alignment: Alignment.centerLeft, child: child),
    );
  }
}
