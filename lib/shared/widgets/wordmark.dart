import 'package:flutter/material.dart';

import '../../core/extensions.dart';

final class Wordmark extends StatelessWidget {
  const Wordmark({super.key});

  @override
  Widget build(BuildContext context) {
    final type = context.type;

    return Semantics(
      header: true,
      label: 'chit',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Text('chit', style: type.wordmark),
          SizedBox(width: context.space.s2),
          Text('चित्त', style: type.devanagariMark),
        ],
      ),
    );
  }
}
