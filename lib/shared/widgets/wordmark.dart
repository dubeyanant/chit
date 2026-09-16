import 'package:flutter/material.dart';

import '../../core/extensions.dart';

/// "chit" in Newsreader, चित्त in Noto Serif Devanagari.
///
/// Baseline-aligned. The two are one mark — the Sanskrit is not a subtitle —
/// so they share a baseline rather than a centre line.
///
/// The gap is `s2`. The prototype sets 7px; every gap in this app comes off
/// the 4px scale (DESIGN-SYSTEM.md §6.3), and a 1px departure on a
/// baseline-aligned pair is not a departure anybody can see.
///
/// *It was private to the shell until the first-run screen needed it*, which
/// is the moment `shared/widgets` is for: the app's name is one piece of
/// knowledge, and two copies of it is how one of them ends up in the wrong
/// face.
final class Wordmark extends StatelessWidget {
  /// The mark.
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
