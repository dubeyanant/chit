import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions.dart';
import '../../../../core/theme/chit_motion.dart';
import '../../../../domain/models/chit.dart';
import '../../application/timeline_provider.dart';
import '../../application/today_controller.dart';

/// The strip under the date: three days, a mark per chit, a ring at now.
///
/// BEHAVIOUR.md §4.1 and ADR-024. It runs **midnight to midnight** across
/// today and the two days before it, scrolls horizontally, and rests at now.
/// A chit's mark sits where its time actually falls, so four chits in an hour
/// look like a burst — because they are one.
///
/// **One day is one screen** (ADR-032). The strip is as many viewports wide as
/// the window has days, so a day occupies exactly the width the reader is
/// looking at and scrolling back a screen is scrolling back a day. That is the
/// rule the whole widget rests on, and it is what makes *rests at now*
/// computable rather than a guess.
///
/// The window is **at most** three days and often fewer: leading days with
/// nothing written in them are not drawn at all (ADR-035), so a first run is
/// one screen that does not scroll. Crossing a day while scrolling is a small
/// haptic and nothing visual — ADR-034.
///
/// It draws no rule of its own above or below: BEHAVIOUR.md §4.1 makes this
/// line the divider between the header and the content, which is why the date
/// above it carries none.
///
/// Nothing on the strip animates. The ring at now used to breathe and does not
/// exist any more (ADR-036), so `ChitMotion.loop` has no caller here.
class Timeline extends ConsumerStatefulWidget {
  /// Creates the timeline.
  const Timeline({super.key});

  /// A chit's mark, 7px square. DESIGN-SYSTEM.md §6.3 names this dimension —
  /// it is the same 7px the thread's node is, because they are the same mark
  /// in two places.
  static const double markSize = 7;

  /// How wide the tick at now is drawn. A hairline and a half — enough to hold
  /// the accent at arm's length, thin enough to stay a position rather than
  /// becoming an object. The same weight the field's caret is.
  static const double nowStroke = 1.5;

  /// How tall the tick at now is: `s3`, spelled here because a painter needs it
  /// before there is a `BuildContext`.
  ///
  /// It straddles the line, where a day boundary hangs below it. That is the
  /// whole of the difference in shape between *what is happening* and *where a
  /// day ended*, and the rest of the difference is the colour.
  static const double nowHeight = 12;

  @override
  ConsumerState<Timeline> createState() => _TimelineState();
}

class _TimelineState extends ConsumerState<Timeline> {
  final ScrollController _scroll = ScrollController();

  /// Which day of the window the middle of the viewport was last in.
  ///
  /// Null means *not established yet* — after the window changes shape there is
  /// no previous day to have crossed a boundary from, and a haptic then would
  /// be the app buzzing at something the reader did not do.
  int? _dayUnderCentre;

  /// True while the strip is moving itself rather than being moved.
  ///
  /// The haptic is feedback for a gesture (ADR-034). A save scrolling back to
  /// now can cross a boundary on the way, and buzzing then would be the app
  /// reporting its own movement.
  bool _settling = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    // The strip takes its resting position before the query has answered; the
    // width does not depend on the marks, only on how many days are drawn.
    _restAtNow(animated: false);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  /// A small haptic each time a day passes under the middle of the viewport.
  ///
  /// ADR-034. Keyed to the **middle** rather than to an edge because the middle
  /// is what the reader is looking at, and because an edge would fire twice for
  /// one boundary — once as it enters and once as it leaves.
  void _onScroll() {
    if (_settling || !_scroll.hasClients) return;

    final ScrollPosition position = _scroll.position;
    final double content =
        position.viewportDimension + position.maxScrollExtent;
    if (content <= 0) return;

    final double centre =
        (position.pixels + position.viewportDimension / 2) / content;
    final int day = ref
        .read(timelineWindowProvider)
        .dayAt(centre.clamp(0.0, 1.0));

    if (_dayUnderCentre != null && day != _dayUnderCentre) {
      // `selectionClick` and not `lightImpact`: this is a detent being passed,
      // the same thing a picker does, and it should feel like one.
      unawaited(HapticFeedback.selectionClick());
    }
    _dayUnderCentre = day;
  }

  /// Where the strip should sit so that now is on screen.
  ///
  /// Now is put in the **middle of the viewport and then clamped**, which gives
  /// the right answer at both ends of the day without either being a special
  /// case. For most of the day the clamp wins and the viewport is today, with
  /// now wherever it falls in it. In the small hours it does not: at 00:20
  /// centring pulls the strip back to show yesterday evening beside this
  /// morning, which is exactly the stretch ADR-006 works hardest to protect
  /// and the stretch the old day arc could not draw at all.
  double _restingOffset(ScrollPosition position) {
    final double content =
        position.viewportDimension + position.maxScrollExtent;
    final double? fraction = ref
        .read(timelineWindowProvider)
        .fractionOf(ref.read(todayProvider));

    if (fraction == null) return position.maxScrollExtent;

    return (fraction * content - position.viewportDimension / 2).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
  }

  /// Puts now back on screen, after the frame that changed what is on it.
  ///
  /// Post-frame because the resting offset is a function of the viewport, and
  /// there is no viewport until the strip has been laid out once.
  void _restAtNow({required bool animated}) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !_scroll.hasClients) return;

      final double target = _restingOffset(_scroll.position);
      // An authored arrival, so reduced motion makes it a jump rather than a
      // slower slide — DESIGN-SYSTEM.md §6.4, and `travel` is what knows that.
      final Duration travel = context.motion.travel(ChitPace.arrival);

      // The window may have changed shape under it, so where the centre was is
      // no longer a day anybody scrolled past.
      _settling = true;
      _dayUnderCentre = null;

      if (!animated || travel == Duration.zero) {
        _scroll.jumpTo(target);
      } else {
        await _scroll.animateTo(
          target,
          duration: travel,
          curve: context.motion.curve,
        );
      }

      _settling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final space = context.space;
    final TimelineWindow window = ref.watch(timelineWindowProvider);
    final DateTime now = ref.watch(todayProvider);

    // §4.1: saving puts a mark at the current time and the strip scrolls
    // smoothly to it. Watching the rows arrive rather than listening for a
    // save keeps this widget ignorant of the composer — it reacts to the thing
    // it actually draws.
    ref.listen(timelineChitsProvider, (
      AsyncValue<List<Chit>>? previous,
      AsyncValue<List<Chit>> next,
    ) {
      final int? before = switch (previous) {
        AsyncData<List<Chit>>(:final List<Chit> value) => value.length,
        _ => null,
      };
      final int after = switch (next) {
        AsyncData<List<Chit>>(:final List<Chit> value) => value.length,
        _ => 0,
      };

      // The first answer is the strip filling in, not a chit arriving: it
      // takes its resting position rather than travelling to it.
      _restAtNow(animated: before != null && after > before);
    });

    // Nothing is drawn until the database answers. An empty three days while
    // the query is in flight is a wrong answer rather than a slow one — the
    // same reading of ADR-007 the thread takes.
    final List<Chit> chits = switch (ref.watch(timelineChitsProvider)) {
      AsyncData<List<Chit>>(:final List<Chit> value) => value,
      _ => const <Chit>[],
    };

    return Semantics(
      label: 'When chits were written, over the last three days',
      child: ExcludeSemantics(
        child: SizedBox(
          height: space.s4 + Timeline.nowHeight + space.s2,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              // One day is one screen, so the strip is as many screens wide
              // as the window has days — one, two or three (ADR-032, ADR-035).
              final double content = constraints.maxWidth * window.dayCount;

              return SingleChildScrollView(
                controller: _scroll,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: SizedBox(
                  width: content,
                  child: _Strip(
                    window: window,
                    now: now,
                    chits: chits,
                    width: content,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Everything drawn on the strip, at its full three-day width.
class _Strip extends StatelessWidget {
  const _Strip({
    required this.window,
    required this.now,
    required this.chits,
    required this.width,
  });

  final TimelineWindow window;
  final DateTime now;
  final List<Chit> chits;
  final double width;

  @override
  Widget build(BuildContext context) {
    final space = context.space;
    final colors = context.colors;

    // The cap sits above the line and the tick straddles it, so the line's own
    // y is the cap's band plus half a tick. Derived rather than declared: the
    // tick is the tallest thing centred on the line, and if it changes height
    // the line should stay through its middle.
    final double lineTop = space.s4 + (Timeline.nowHeight - 1) / 2;
    final double lineCentre = lineTop + 0.5;

    double? x(DateTime at) {
      final double? fraction = window.fractionOf(at);
      return fraction == null ? null : fraction * width;
    }

    final double? nowX = x(now);

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        // The line itself, the full width of the window.
        Positioned(
          left: 0,
          right: 0,
          top: lineTop,
          height: 1,
          child: ColoredBox(color: colors.hair),
        ),

        // Where one day ends and the next begins — unlabelled, on purpose.
        // §4.1: it is there to be noticed, not read. Naming each day would
        // turn a rhythm signal into a second calendar, and §4.2 is already
        // that.
        for (final DateTime boundary in window.dayBoundaries)
          if (x(boundary) case final double at)
            Positioned(
              left: at,
              top: lineCentre,
              width: 1,
              height: space.s1,
              child: ColoredBox(color: colors.inkFaint),
            ),

        // A mark per chit, where its time actually falls.
        for (final Chit chit in chits)
          if (x(chit.createdAt) case final double at)
            Positioned(
              left: at - Timeline.markSize / 2,
              top: lineCentre - Timeline.markSize / 2,
              child: const _Mark(),
            ),

        // Now: the ring, and the cap over it.
        if (nowX != null) ...<Widget>[
          Positioned(
            left: nowX - Timeline.nowStroke / 2,
            top: lineCentre - Timeline.nowHeight / 2,
            child: const _NowMarker(),
          ),
          Positioned(
            left: nowX,
            top: 0,
            child: FractionalTranslation(
              translation: const Offset(-0.5, 0),
              child: Text('now', style: context.type.timelineNow),
            ),
          ),
        ],
      ],
    );
  }
}

/// One chit, as it appears on the strip.
///
/// **Ink, not accent.** A row of `--seal` marks made every past moment look as
/// live as the present one, which is the failure ADR-022 was written about; a
/// record is ink and only now is the seal.
class _Mark extends StatelessWidget {
  const _Mark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Timeline.markSize,
      height: Timeline.markSize,
      decoration: BoxDecoration(
        color: context.colors.inkFaint,
        // 1px, not a circle. A square with its corners taken off reads as a
        // mark made by a pen; a dot reads as a bullet.
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}

/// Now: a short vertical tick through the line, in `--seal`.
///
/// ADR-036. *v6 draws an outline ring here and this was a filled disc for one
/// build* — both read as an object sitting on the strip rather than as a
/// position on it, and the disc was the loudest thing on a quiet screen. A tick
/// is the same kind of thing as the day boundary below the line: a place, not a
/// dot.
///
/// It is the only thing on the strip in the accent, which is ADR-022 exactly —
/// the marks are records and this is what is happening.
///
/// **Nothing about it moves.** The ring it replaced carried the pulse that was
/// `ChitMotion.loop`'s only caller; there is no longer anything here to
/// breathe, and a tick that pulsed would be the attention the ring was removed
/// for. `loop` stays — ADR-027 is about where a period lives — and M5's record
/// dot is its first caller again.
class _NowMarker extends StatelessWidget {
  const _NowMarker();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Timeline.nowStroke,
      height: Timeline.nowHeight,
      child: ColoredBox(color: context.colors.seal),
    );
  }
}
