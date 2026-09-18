import 'package:flutter/material.dart';

import '../../../../core/extensions.dart';
import '../../../../core/theme/chit_motion.dart';
import '../../../../domain/find/find_axis.dart';
import '../../../../shared/widgets/focus_ring.dart';

/// One word in find's right-hand column.
///
/// **Flush right** (ADR-084): the one place in the app that is not left-
/// aligned, because this column is a set of targets rather than a reading
/// surface, and the right edge is where a right thumb already is.
final class FindWord extends StatelessWidget {
  const FindWord({required this.word, required this.onTap, super.key});

  /// Every row is this tall, which is what [sitsAtBottom] measures with.
  static const double rowHeight = 44;

  final String word;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final motion = context.motion;

    assert(
      rowHeight == context.space.minTouchTarget,
      'a find row is one touch target — the arithmetic in sitsAtBottom '
      'assumes it, and a row shorter than the floor is unreachable anyway',
    );

    return Semantics(
      button: true,
      child: FocusRing(
        onActivate: onTap,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,

          child: SizedBox(
            height: rowHeight,
            child: Align(
              alignment: Alignment.centerRight,
              child: AnimatedDefaultTextStyle(
                duration: motion.fade(ChitPace.routine),
                curve: motion.curve,
                style: context.type.filterWord,
                child: Text(word, textAlign: TextAlign.right),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// find's column of words, bottom-anchored while it fits and scrolling from
/// the top once it does not — ADR-084.
///
/// [above] is drawn over the words when, and only when, they fit: it is the
/// quote, and a screen that has run out of room has run out of room for it.
final class FindList extends StatelessWidget {
  const FindList({required this.rows, this.above, super.key});

  final List<Widget> rows;

  final Widget? above;

  @override
  Widget build(BuildContext context) {
    final space = context.space;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool bottom = sitsAtBottom(
          count: rows.length,
          rowHeight: FindWord.rowHeight,
          height: constraints.maxHeight - space.s6,
        );

        final EdgeInsets padding = EdgeInsets.fromLTRB(
          space.gutter,
          space.s5,
          space.gutter,
          space.s6,
        );

        if (!bottom) {
          return ListView.builder(
            padding: padding,
            itemCount: rows.length,
            itemBuilder: (BuildContext context, int index) => rows[index],
          );
        }

        return Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              ?above,
              const Spacer(),
              ...rows,
            ],
          ),
        );
      },
    );
  }
}
