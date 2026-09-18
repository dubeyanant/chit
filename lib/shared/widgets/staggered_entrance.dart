import 'package:flutter/material.dart';

import '../../core/extensions.dart';
import '../../core/theme/chit_motion.dart';

/// A page arriving one block at a time — DESIGN-SYSTEM.md §6.3.
///
/// Each child fades in and rises [rise] pixels into place, [ChitMotion.stagger]
/// after the one above it, capped at [cap] so a long thread does not arrive for
/// a second and a half. **It plays once and then sheds itself**: the frame the
/// run finishes, this stops wrapping its children at all and is a [Column].
/// Returning to a tab costs `BranchFade`'s 200ms and nothing more, because
/// Today is opened many times a day and a re-run entrance would turn that into
/// waiting (ADR-011).
///
/// **Under reduced motion it is one fade, together and going nowhere** (§6.4):
/// [ChitMotion.stagger] answers zero and the rise is not drawn, which leaves
/// the fade [ChitMotion.fade] guarantees.
///
/// It takes **blocks, not a column's contents** — a child carries whatever gap
/// belongs above it rather than sitting beside a `SizedBox`, because a spacer
/// in the list would take a turn in the stagger and push every block after it
/// a step late.
///
/// A child wrapped in [Unstaggered] is drawn straight through, keeping its
/// place in the rhythm for the blocks after it. See that class for the one
/// thing that needs it.
final class StaggeredEntrance extends StatefulWidget {
  /// The blocks, in the order they arrive.
  const StaggeredEntrance({
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    super.key,
  });

  /// How far a block travels on its way in — §6.3's 6px. One widget's
  /// geometry, named here where it is drawn.
  static const double rise = 6;

  /// How many steps the stagger takes before every later block arrives with
  /// the last. Past this the wait stops meaning anything and starts costing.
  static const int cap = 8;

  /// The blocks. Each one is given [crossAxisAlignment] by the column.
  final List<Widget> children;

  /// Passed to the column this builds.
  final CrossAxisAlignment crossAxisAlignment;

  /// When the block at [index] starts, counting from the first on the page.
  ///
  /// [cap] steps and no more, so block twenty arrives with block eight rather
  /// than a second later than it.
  static Duration delayFor(int index, {required ChitMotion motion}) =>
      motion.stagger() * (index < 0 ? 0 : (index < cap ? index : cap));

  /// How long an entrance of [count] blocks runs: the last block's start,
  /// plus the arrival it then takes.
  static Duration totalFor(int count, {required ChitMotion motion}) =>
      count <= 0
      ? Duration.zero
      : delayFor(count - 1, motion: motion) + motion.fade(ChitPace.arrival);

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  AnimationController? _run;
  bool _done = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_done || _run != null) return;

    final AnimationController run = _run = AnimationController(
      vsync: this,
      duration: StaggeredEntrance.totalFor(
        widget.children.length,
        motion: context.motion,
      ),
    )..addStatusListener(_onStatus);
    run.forward();
  }

  /// **The shedding.** The controller is not disposed here — disposing one
  /// from inside its own status listener is how a ticker outlives its widget
  /// — it is left completed and inert, and [dispose] puts it down. What stops
  /// is the wrapping: [build] returns the bare column from the next frame.
  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    setState(() => _done = true);
  }

  @override
  void dispose() {
    _run?.dispose();
    super.dispose();
  }

  Widget _column(List<Widget> children) =>
      Column(crossAxisAlignment: widget.crossAxisAlignment, children: children);

  @override
  Widget build(BuildContext context) {
    final AnimationController? run = _run;
    if (_done || run == null || widget.children.isEmpty) {
      return _column(widget.children);
    }

    final motion = context.motion;
    final Duration arrival = motion.fade(ChitPace.arrival);
    final double total = StaggeredEntrance.totalFor(
      widget.children.length,
      motion: motion,
    ).inMicroseconds.toDouble();
    if (total <= 0) return _column(widget.children);

    final List<Widget> entering = <Widget>[];
    for (final (int index, Widget child) in widget.children.indexed) {
      // Drawn straight through, and still taking its turn, so the blocks
      // below it keep the beat they would have had.
      if (child is Unstaggered) {
        entering.add(child);
        continue;
      }

      // A block that arrives after the run was sized — the day's chits land a
      // frame after Today's first — catches whatever is left of the window
      // rather than being held back for a run of its own.
      final Duration at = StaggeredEntrance.delayFor(index, motion: motion);
      entering.add(
        _Entering(
          run: run,
          begin: at.inMicroseconds / total,
          end: (at + arrival).inMicroseconds / total,
          curve: motion.curve,
          rise: motion.reduceMotion ? 0 : StaggeredEntrance.rise,
          child: child,
        ),
      );
    }
    return _column(entering);
  }
}

/// A block that a [StaggeredEntrance] draws straight through — ADR-070.
///
/// **The timeline is the one that needs it, and the reason is that it already
/// has an arrival of its own.** The strip scrolls to now on its first frame
/// and again on every save (ADR-024), so inside the entrance it was fading and
/// rising while it was also scrolling — two authored motions on one widget,
/// which is the glitch the owner saw on the first handset to run it. It also
/// spared the strip an `Opacity` layer over a moving viewport every frame,
/// which is the expensive way to draw a scrollable.
///
/// It keeps its index, so the blocks below it arrive on the beat they would
/// have had.
final class Unstaggered extends StatelessWidget {
  /// Wraps [child], which the entrance will not animate.
  const Unstaggered({required this.child, super.key});

  /// The block to draw as-is.
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// One block on its way in: opacity, and a rise that ends at nothing.
///
/// The window is read off the run with [Interval.transform] rather than by
/// wrapping it in a `CurvedAnimation` — a curved animation is a listener that
/// has to be disposed, and there is one of these per block per rebuild.
class _Entering extends StatelessWidget {
  _Entering({
    required this.run,
    required double begin,
    required double end,
    required Curve curve,
    required this.rise,
    required this.child,
  }) : _window = Interval(
         begin.clamp(0, 1),
         // A block whose window is a point — one that arrived after the run
         // was sized — takes the rest of the run rather than dividing by
         // nothing.
         end.clamp(0, 1) <= begin.clamp(0, 1) ? 1 : end.clamp(0, 1),
         curve: curve,
       );

  final Animation<double> run;
  final Interval _window;
  final double rise;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: run,
      // The child is built once and moved, rather than rebuilt every frame.
      child: child,
      builder: (BuildContext _, Widget? built) {
        final double t = _window.transform(run.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, rise * (1 - t)),
            child: built,
          ),
        );
      },
    );
  }
}
