import 'package:flutter/material.dart';

import '../../core/extensions.dart';
import '../../core/theme/chit_motion.dart';

final class StaggeredEntrance extends StatefulWidget {
  const StaggeredEntrance({
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    super.key,
  });

  static const double rise = 6;

  static const int cap = 8;

  final List<Widget> children;

  final CrossAxisAlignment crossAxisAlignment;

  static Duration delayFor(int index, {required ChitMotion motion}) =>
      motion.stagger() * (index < 0 ? 0 : (index < cap ? index : cap));

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
      if (child is Unstaggered) {
        entering.add(child);
        continue;
      }

      final Duration at = StaggeredEntrance.delayFor(index, motion: motion);
      entering.add(
        _Entering(
          key: child.key,
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

final class Unstaggered extends StatelessWidget {
  const Unstaggered({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

class _Entering extends StatelessWidget {
  _Entering({
    required this.run,
    required double begin,
    required double end,
    required Curve curve,
    required this.rise,
    required this.child,
    super.key,
  }) : _window = Interval(
         begin.clamp(0, 1),

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
