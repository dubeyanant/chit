import 'package:flutter/material.dart';

import '../../core/extensions.dart';
import '../../core/theme/chit_motion.dart';

final class Arrival extends StatefulWidget {
  const Arrival({
    required this.child,
    required this.from,
    this.play = true,
    super.key,
  });

  final Widget child;

  final Offset from;

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
