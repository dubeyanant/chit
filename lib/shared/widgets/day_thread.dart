import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/extensions.dart';
import '../../core/theme/chit_colors.dart';
import '../../domain/models/chit.dart';
import 'ambient_stamp_row.dart';
import 'audio_pill.dart';
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
/// **Holding the row opens the editor** — ADR-061, and the affordance M2 and
/// M4 held back because until M6 a press had nowhere to go. It is one widget,
/// so Today and the archive gain it in the same change and cannot drift apart.
/// No chevron: the row *is* the target, and a marker pointing at a target
/// that large would be saying what the wash already says.
///
/// **A tap does nothing, and there is no swipe.** The thread is a reading
/// surface: a tap that opened the editor was a scroll's glancing touch away
/// from leaving the page, and the one tap the row does answer is the pill's.
/// Delete lives in the editor (ADR-062), not a thumb's width from a scroll.
class ChitRow extends StatefulWidget {
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
  State<ChitRow> createState() => _ChitRowState();
}

class _ChitRowState extends State<ChitRow> {
  bool _pressed = false;

  void _press({required bool down}) {
    // The hold pushes the editor while the finger is still down, so the
    // release can land after the row has gone — a chit deleted from the
    // screen it opened.
    if (mounted) setState(() => _pressed = down);
  }

  @override
  Widget build(BuildContext context) {
    final Chit chit = widget.chit;

    return Semantics(
      button: true,
      label: 'Chit, ${chit.hasText ? chit.text! : 'a recording'}',
      hint: 'Hold to open the chit',
      onLongPress: () => _open(context),
      // `excludeSemantics` so a screen reader is offered the row and not also
      // the stamp, the words and the pill inside it — one target, one thing
      // to say about it. The pill is the exception it costs: its own control
      // is unreachable from here, and a chit's recording is reached from the
      // editor instead.
      excludeSemantics: true,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: (bool on) => _press(down: on),
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (ActivateIntent _) {
              _open(context);
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          // The wash arrives with the finger and leaves with a scroll, so the
          // half-second before the hold is recognised is not a dead row. No
          // `onTap`: the pill inside keeps its own, and nothing else here
          // answers one.
          onLongPressDown: (LongPressDownDetails _) => _press(down: true),
          onLongPressCancel: () => _press(down: false),
          // The strip's tick, at the moment the hold is recognised — the only
          // thing that moves is the screen, and a thumb wants telling first.
          onLongPressStart: (LongPressStartDetails _) =>
              unawaited(HapticFeedback.selectionClick()),
          onLongPress: () => _open(context),
          onLongPressEnd: (LongPressEndDetails _) => _press(down: false),
          child: _Body(chit: chit, pressed: _pressed),
        ),
      ),
    );
  }

  void _open(BuildContext context) => context.pushNamed(
    editorRouteName,
    pathParameters: <String, String>{editorIdParameter: widget.chit.id},
  );
}

/// What the row draws, pressed or not.
///
/// Split out so the press state above has one child to rebuild rather than a
/// tree of gesture wrappers.
class _Body extends StatelessWidget {
  const _Body({required this.chit, required this.pressed});

  final Chit chit;
  final bool pressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final double inset = ThreadRail.contentInset(context);

    final Widget row = Padding(
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
                  offset: const Offset(ChitRow._overhang, 0),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: ThreadNode(),
                  ),
                ),
              ),
              Expanded(
                child: AmbientStampRow.saved(
                  stamp: chit.stamp,
                  lifted: pressed,
                ),
              ),
            ],
          ),
          if (chit.hasText)
            Padding(
              // 5px under the stamp in the prototype, and `s1` here — a gap is
              // a relationship and §6.3 keeps those on the scale.
              padding: EdgeInsets.only(left: inset, top: space.s1),
              // **This becomes a `Text.rich` when `@person` and `#hashtag`
              // arrive** (OPEN-QUESTIONS.md §9 item 8) and nothing here has to
              // move for it: a `TapGestureRecognizer` on a span wins the
              // gesture arena against the row's hold, so a name can lead
              // somewhere else while the rest of the row still opens the chit.
              child: Text(chit.text!, style: context.type.chitText),
            ),
          // **A chit with audio and no words is a recording, not an empty
          // chit** — BEHAVIOUR.md §3.5, and what closed open item 31. The pill
          // is the whole of what such a chit says.
          if (chit.hasAudio)
            Padding(
              padding: EdgeInsets.only(left: inset, top: space.s2),
              child: AudioPill(
                id: chit.id,
                path: chit.audioPath!,
                duration: chit.audioDuration ?? Duration.zero,
              ),
            ),
        ],
      ),
    );

    if (!pressed) return row;

    // **6% ink, the quietest wash there is** (DESIGN-SYSTEM.md §6.1) — and it
    // is why the stamp above lifts: at 6% `--ink-faint` measures 4.42:1 and
    // fails §6.4's floor, where `--ink-muted` measures 5.65:1 and clears it.
    // The wash is drawn under the row's own padding rather than inside it, so
    // what lights up is the target the finger actually hit.
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.inkWash(colors.paper, opacity: ChitColors.rowPressedWash),
        borderRadius: BorderRadius.circular(space.radius),
      ),
      child: row,
    );
  }
}
