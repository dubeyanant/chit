import 'package:flutter/material.dart';

import '../../../../core/extensions.dart';
import '../../../../core/theme/chit_motion.dart';
import '../../../../shared/widgets/focus_ring.dart';

/// One word find can be narrowed by.
///
/// **Chosen is lit *and* framed** — §6.4 refuses to let colour be the only
/// difference, and the frame is the calendar's own selection idiom (ADR-046)
/// rather than a new kind of object.
final class FilterWord extends StatelessWidget {
  const FilterWord({
    required this.word,
    required this.chosen,
    required this.onTap,
    super.key,
  });

  final String word;

  final bool chosen;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final motion = context.motion;

    return Semantics(
      selected: chosen,
      button: true,
      child: FocusRing(
        onActivate: onTap,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,

          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: space.minTouchTarget),
            child: Center(
              widthFactor: 1,
              child: AnimatedContainer(
                duration: motion.fade(ChitPace.routine),
                curve: motion.curve,

                padding: EdgeInsets.symmetric(
                  horizontal: space.s2,
                  vertical: space.s1,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: chosen ? colors.ink : Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(space.tileRadius),
                ),
                child: AnimatedDefaultTextStyle(
                  duration: motion.fade(ChitPace.routine),
                  curve: motion.curve,
                  style: context.type.filterWord.copyWith(
                    color: chosen ? colors.ink : colors.inkFaint,
                  ),
                  child: Text(word),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A named row of [FilterWord]s, drawn only when it has words in it.
final class FilterRow extends StatelessWidget {
  const FilterRow({required this.label, required this.words, super.key});

  final String label;

  final List<Widget> words;

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) return const SizedBox.shrink();

    final space = context.space;

    return Padding(
      padding: EdgeInsets.only(bottom: space.s2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(label, style: context.type.sectionLabel),
          ),
          Wrap(spacing: space.s2, children: words),
        ],
      ),
    );
  }
}
