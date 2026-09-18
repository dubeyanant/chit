import 'package:flutter/material.dart';

import '../../core/extensions.dart';

final class ThreadRail extends StatelessWidget {
  const ThreadRail({required this.child, super.key});

  static const double centre = ThreadNode.markSize / 2;

  static const double thickness = 1;

  final Widget child;

  static double contentInset(BuildContext context) => context.space.s5;

  @override
  Widget build(BuildContext context) {
    final space = context.space;

    return Stack(
      children: <Widget>[
        Positioned(
          left: centre - thickness / 2,
          top: space.s3,
          bottom: space.s3,
          width: thickness,
          child: ColoredBox(color: context.colors.hair),
        ),
        child,
      ],
    );
  }
}

final class ThreadNode extends StatelessWidget {
  const ThreadNode({super.key});

  static const double markSize = 7;

  static const double markRadius = 1;

  static const double halo = 4;

  static const double size = markSize + 2 * halo;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.paper,
          borderRadius: BorderRadius.circular(markRadius + halo),
        ),
        child: Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.inkFaint,
              borderRadius: BorderRadius.circular(markRadius),
            ),
            child: const SizedBox.square(dimension: markSize),
          ),
        ),
      ),
    );
  }
}
