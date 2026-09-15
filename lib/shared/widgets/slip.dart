import 'package:flutter/material.dart';

import '../../core/extensions.dart';
import 'perforated_edge.dart';

/// A chit surface: the slip itself, its tear edge, and the pad behind it.
///
/// Three things in one widget because they are one object. BEHAVIOUR.md §4.1:
/// *the open chit rests on a visible second slip, offset behind it — a pad you
/// tear from.* A slip without the pad is a rectangle; a slip without the
/// [PerforatedEdge] was never torn from anything.
///
/// **The hairline carries the structure and the shadow only seats it.**
/// DESIGN-SYSTEM.md §6.3: `--slip` is four points brighter than the ground in
/// v6, bright enough to read as a surface on its own, so the one faint shadow
/// is no longer doing the separating.
///
/// The widget reserves room for the pad rather than overflowing into its
/// neighbour: its own size is the slip plus `s1` on the right and
/// bottom, which is exactly where the pad shows.
final class Slip extends StatelessWidget {
  /// A slip holding [child], padded by `s4` on all four sides.
  const Slip({required this.child, super.key});

  /// The one faint shadow of DESIGN-SYSTEM.md §6.3.
  ///
  /// `0 1px 3px rgba(0,0,0,.35)` in the prototype. CSS measures blur as twice
  /// the Gaussian's sigma and Flutter does not, so the two are within a
  /// fraction of a pixel of each other rather than identical — at this weight
  /// that is a difference nobody can see, and matching the number is worth
  /// more than matching the maths.
  static const List<BoxShadow> shadow = <BoxShadow>[
    BoxShadow(color: Color(0x59000000), offset: Offset(0, 1), blurRadius: 3),
  ];

  /// What the chit holds — the stamp row, the field, the action row.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final space = context.space;

    // The prototype offsets the pad by 5px across and 6px down. Both snap to
    // `s1`: an offset between two surfaces is a *relationship*, and
    // DESIGN-SYSTEM.md §6.3 keeps every one of those on the scale. It is the
    // same call the wordmark's 7px gap got, for the same reason.
    final double offset = space.s1;

    return Padding(
      // Room for the pad, so the slip does not paint over what follows it.
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
          // A chit is as wide as the page gives it. Without this the slip
          // would shrink to whatever is written on it — which is a note, not
          // a slip, and an empty one would have no width at all.
          SizedBox(
            width: double.infinity,
            child: _Surface(child: child),
          ),
        ],
      ),
    );
  }
}

/// The second slip, showing at the right and bottom of the first.
///
/// It is the pad, so it is the colour a hole in the tear edge reveals —
/// `--slip-under`, the same token, which is what makes the perforation read as
/// a tear rather than as decoration.
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

/// The slip a chit is written on.
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
          // Across the top, `s2` in from each side, and sitting on the border
          // rather than under it — the holes cut the hairline, which is what
          // makes them holes.
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
