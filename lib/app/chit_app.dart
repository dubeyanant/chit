import 'package:flutter/material.dart';

import '../core/extensions.dart';
import '../core/theme/chit_theme.dart';

/// The application root.
///
/// M0b gives it the theme and the masthead. The router, the tab shell and
/// Today arrive in M2; until then the masthead sits on the ground it will keep
/// sitting on, which is the honest way to look at whether the palette and the
/// three faces are right.
class ChitApp extends StatelessWidget {
  /// Creates the application root.
  const ChitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'chit',
      debugShowCheckedModeBanner: false,
      theme: ChitTheme.theme,
      home: const _Masthead(),
    );
  }
}

/// "chit चित्त" on the ground, in the page gutter.
///
/// The wordmark itself will move into Today's header in M2 — this widget is
/// the scaffolding around it, not the mark.
class _Masthead extends StatelessWidget {
  const _Masthead();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: context.space.pagePadding.copyWith(top: context.space.s5),
          child: const Align(
            alignment: Alignment.topLeft,
            child: ChitWordmark(),
          ),
        ),
      ),
    );
  }
}

/// The masthead: "chit" in Newsreader, चित्त in Noto Serif Devanagari.
///
/// Baseline-aligned. The two are one mark — the Sanskrit is not a subtitle —
/// so they share a baseline rather than a centre line.
///
/// The gap is `s2`. The prototype sets 7px; every gap in this app comes off
/// the 4px scale (DESIGN-SYSTEM.md §6.3), and a 1px departure on a
/// baseline-aligned pair is not a departure anybody can see.
class ChitWordmark extends StatelessWidget {
  /// Creates the masthead.
  const ChitWordmark({super.key});

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
