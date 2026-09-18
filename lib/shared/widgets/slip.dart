import 'package:flutter/material.dart';

import '../../core/extensions.dart';
import 'perforated_edge.dart';

final class Slip extends StatelessWidget {
  const Slip({required this.child, super.key});

  static const List<BoxShadow> shadow = <BoxShadow>[
    BoxShadow(color: Color(0x59000000), offset: Offset(0, 1), blurRadius: 3),
  ];

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final space = context.space;

    final double offset = space.s1;

    return Padding(
      padding: EdgeInsets.only(right: offset, bottom: offset),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
            left: offset,
            top: offset,
            right: -offset,
            bottom: -offset,
            child: const _Pad(),
          ),

          SizedBox(
            width: double.infinity,
            child: _Surface(child: child),
          ),
        ],
      ),
    );
  }
}

class _Pad extends StatelessWidget {
  const _Pad();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.slipUnder,
        border: Border.all(color: colors.hair),
        borderRadius: BorderRadius.circular(context.space.radius),
      ),
    );
  }
}

class _Surface extends StatelessWidget {
  const _Surface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.slip,
        border: Border.all(color: colors.hair),
        borderRadius: BorderRadius.circular(space.radius),
        boxShadow: Slip.shadow,
      ),
      child: Stack(
        children: <Widget>[
          Padding(padding: EdgeInsets.all(space.s4), child: child),

          Positioned(
            top: 0,
            left: space.s2,
            right: space.s2,
            child: const PerforatedEdge(),
          ),
        ],
      ),
    );
  }
}
