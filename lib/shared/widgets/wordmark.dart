import 'package:flutter/material.dart';

import '../../core/extensions.dart';

final class Wordmark extends StatelessWidget {
  const Wordmark({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: 'Chitta',
      excludeSemantics: true,
      child: Text('चित्त', style: context.type.wordmark),
    );
  }
}
