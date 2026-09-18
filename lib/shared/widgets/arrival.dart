import 'package:flutter/material.dart';

import '../../core/extensions.dart';
import '../../core/theme/chit_motion.dart';

/// Something arriving from where it came from — DESIGN-SYSTEM.md §6.3.
///
/// The house rule for the two moments in the app with any authorship: **a
/// saved chit falls *down* into the thread**, because the composer sits above
/// it, and **a kept recording rises *up* into the open chit**, because the
/// recording sheet sits below. [from] is the offset it starts at and it always
/// settles at nothing.
///
/// **Under reduced motion it fades and goes nowhere** (§6.4): the offset is
/// dropped and [ChitMotion.fade] keeps the arrival at 220ms, because an
/// arrival that simply appeared would take the event away along with the
/// movement.
///
/// **[play] is read once, when this mounts, and never again.** A widget that
/// arrived is a widget that has arrived; re-reading the flag would replay an
/// entrance on an unrelated rebuild. The wrapper stays in the tree either way
/// — taking it out when it finished would change the shape of the tree and
/// rebuild everything under it, which is the bug ADR-070 is mostly about.
final class Arrival extends StatefulWidget {
  /// Brings [child] in from [from], if [play].
  const Arrival({
    required this.child,
    required this.from,
    this.play = true,
    super.key,
  });

  /// What is arriving.
  final Widget child;

  /// Where it starts, relative to where it ends. Negative Y falls in from
  /// above; positive Y rises in from below.
  final Offset from;

  /// Whether to animate at all. False draws [child] and starts no ticker —
  /// what a row already on screen when the page was built wants, since the
  /// page's own entrance has already carried it in.
  final bool play;

  @override
  State<Arrival> createState() => _ArrivalState();
}

class _ArrivalState extends State<Arrival> with SingleTickerProviderStateMixin {
  AnimationController? _run;
  bool _done = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_done || _run != null) return;
    if (!widget.play) {
      _done = true;
      return;
    }

    _run =
        AnimationController(
          vsync: this,
          duration: context.motion.fade(ChitPace.arrival),
        )..addStatusListener((AnimationStatus status) {
          if (status != AnimationStatus.completed || !mounted) return;
          setState(() => _done = true);
        });
    _run!.forward();
  }

  @override
  void dispose() {
    _run?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AnimationController? run = _run;
    if (_done || run == null) return widget.child;

    final motion = context.motion;
    final Offset from = motion.reduceMotion ? Offset.zero : widget.from;
    final Curve curve = motion.curve;

    return AnimatedBuilder(
      animation: run,
      child: widget.child,
      builder: (BuildContext _, Widget? built) {
        final double t = curve.transform(run.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: from * (1 - t), child: built),
        );
      },
    );
  }
}
