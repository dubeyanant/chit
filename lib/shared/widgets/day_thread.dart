import 'package:flutter/material.dart';

import '../../core/extensions.dart';
import '../../domain/models/chit.dart';
import 'ambient_stamp_row.dart';
import 'thread_rail.dart';

/// A day's chits, hanging off one rail — README §2, BEHAVIOUR.md §4.1.
///
/// *A day reads as one continuous thing*, which is why the rail is drawn once
/// behind every row rather than as a mark beside each. [ThreadRail] draws the
/// line; this places the rows over it and gives each one its [ThreadNode].
///
/// **An empty day has no rail and no rows** — not a placeholder row, not a
/// stub of a line. §4.1: an empty day looks empty. The note that stands there
/// instead belongs to the screen, because Today's wording and the archive's
/// differ (*"Nothing written yet today."* against *"Nothing written that
/// day."*) while everything here is the same on both.
///
/// *It lived under `today/` until M4's archive became the second screen that
/// wanted it*, which is the moment ARCHITECTURE.md §2 says a widget moves
/// here. BEHAVIOUR.md §4.2 asks for *the same thread treatment as Today* in
/// as many words, and the way to make that true is one widget, not two that
/// look alike.
class DayThread extends StatelessWidget {
  /// The thread for [chits], newest first.
  const DayThread({required this.chits, super.key});

  /// The day's chits, in the order the repository returns them.
  final List<Chit> chits;

  @override
  Widget build(BuildContext context) {
    if (chits.isEmpty) return const SizedBox.shrink();

    return ThreadRail(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[for (final Chit chit in chits) ChitRow(chit: chit)],
      ),
    );
  }
}

/// One saved chit in the thread: its mark, its stamp, and its words.
///
/// BEHAVIOUR.md §3.6 — the stamp is the `.saved` one, so it is `--ink-faint`
/// and **carries no pin**. A pin under every chit in the thread is ten
/// identical marks distinguishing nothing; on the open chit it means *this is
/// being noted, now*.
///
/// A past chit is a record and not a control. Nothing opens yet
/// (OPEN-QUESTIONS.md §8.1 settled *that* saved chits are editable, not where
/// the editor lives), so nothing here claims it does — no tap target, no
/// chevron, no ripple.
class ChitRow extends StatelessWidget {
  /// The row for [chit].
  const ChitRow({required this.chit, super.key});

  /// The chit this row shows.
  final Chit chit;

  /// How far the mark hangs left of the thread's own edge.
  ///
  /// Exactly its halo, so the 7px mark sits centred on the rail and the paper
  /// around it overhangs into the page gutter — paper on paper, invisible.
  /// Derived from the two figures DESIGN-SYSTEM.md §6.3 already names rather
  /// than being a third.
  static const double _overhang = ThreadRail.centre - ThreadNode.size / 2;

  @override
  Widget build(BuildContext context) {
    final space = context.space;
    final double inset = ThreadRail.contentInset(context);

    return Padding(
      // 12 / 8 / 16 / 0 in the prototype, and all four are already steps.
      padding: EdgeInsets.fromLTRB(0, space.s3, space.s2, space.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            // The mark centres on the line its stamp is on, which is what
            // makes it *this chit's* mark rather than a bullet at the top of a
            // block. *The prototype places it 7px below the row's content and
            // this lands 3px higher; the offset there is absolute and stops
            // being right the moment the stamp's type size changes.*
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: inset,
                height: ThreadNode.size,
                child: Transform.translate(
                  offset: const Offset(_overhang, 0),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: ThreadNode(),
                  ),
                ),
              ),
              Expanded(child: AmbientStampRow.saved(stamp: chit.stamp)),
            ],
          ),
          if (chit.hasText)
            Padding(
              // 5px under the stamp in the prototype, and `s1` here — a gap is
              // a relationship and §6.3 keeps those on the scale.
              padding: EdgeInsets.only(left: inset, top: space.s1),
              child: Text(chit.text!, style: context.type.chitText),
            ),
        ],
      ),
    );
  }
}
