import 'package:flutter/material.dart';

import '../../core/extensions.dart';

/// The vertical rail a day's chits hang off.
///
/// README §2: *a day's chits, in order, hanging off a vertical rail. A day
/// reads as one continuous thing.* The rail is what makes it continuous — one
/// line behind every chit rather than a mark beside each — so it is drawn
/// once, here, and the chits are laid out over it.
///
/// It runs the height of what it is given, less `s3` at each end, so it starts
/// and stops inside the thread rather than at its edges. A rail that reached
/// the first and last pixel would read as a border.
///
/// **The chits go over it, not in it.** This widget draws the line and nothing
/// else; the thread's own layout is `features/today/presentation` — its rows
/// sit [contentInset] in from the left and place a [ThreadNode] centred on
/// [centre].
final class ThreadRail extends StatelessWidget {
  /// Draws the rail behind [child].
  const ThreadRail({required this.child, super.key});

  /// The rail's centre, measured from this widget's left edge.
  ///
  /// It is not a dimension of its own: it is derived from the node, whose left
  /// edge sits flush with the thread's. DESIGN-SYSTEM.md §6.3 already names
  /// the 7px mark, and this follows from it rather than adding a fifth
  /// off-scale figure to that list.
  ///
  /// *The prototype puts the rail here and the node 2px to the left of it,
  /// which is a leftover from when the node was offset by the page gutter
  /// rather than by the thread's own inset. A node the rail does not come out
  /// of the middle of is a mark beside a line; this centres them.*
  static const double centre = ThreadNode.markSize / 2;

  /// A hairline. The structure is carried by hairlines everywhere else too —
  /// DESIGN-SYSTEM.md §6.3.
  static const double thickness = 1;

  /// The chits, already inset by [contentInset].
  final Widget child;

  /// How far a chit's words sit from the rail — `s5`.
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

/// The mark one chit hangs off, and the halo that lets the rail run behind it.
///
/// **The halo is paper, not a gap.** The rail is one unbroken line and this is
/// drawn over it, which is why a chit reads as hanging *off* the rail rather
/// than as an item in a list that happens to have a line beside it.
///
/// It is `--ink-faint`, like everything else in a saved chit's metadata: a
/// chit already written is a record, and a record is ink (ADR-022). The accent
/// marks what is live, and nothing in the thread is.
final class ThreadNode extends StatelessWidget {
  /// The mark, centred in its halo.
  const ThreadNode({super.key});

  /// **7px** — one of the four dimensions DESIGN-SYSTEM.md §6.3 allows off the
  /// scale, and the same mark the timeline uses.
  static const double markSize = 7;

  /// 1px. Not `radius`: at 7px a 2px corner is a circle, and this is a mark
  /// made by a pen rather than a tile.
  static const double markRadius = 1;

  /// The halo's thickness, and it is `s1`.
  ///
  /// Spelled here as a constant because [size] has to be usable by a caller
  /// laying out a row, which happens before there is a `BuildContext` to read
  /// the scale from. `test/core/theme/widget_constants_test.dart` asserts that
  /// it still equals `s1`.
  static const double halo = 4;

  /// What the widget actually occupies: the mark plus its halo, both sides.
  static const double size = markSize + 2 * halo;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // Two layers, and the order is the point: paper over the rail, then the
    // mark over the paper.
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        // The halo is drawn, not left blank. It is paper laid over the line,
        // so it works wherever the node falls and the rail never has to know
        // where its chits are. Centred on the rail it overhangs the thread's
        // left edge by [halo] — into the page gutter, paper on paper.
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
