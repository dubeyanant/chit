import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions.dart';
import '../../../domain/models/recording_state.dart';
import '../../../shared/widgets/audio_pill.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/perforated_edge.dart';
import '../application/recording_controller.dart';

Future<void> showRecordingSheet(BuildContext context, WidgetRef ref) async {
  final bool kept =
      await showModalBottomSheet<bool>(
        context: context,

        backgroundColor: Colors.transparent,
        barrierColor: context.colors.scrim,

        isScrollControlled: true,
        useSafeArea: true,
        builder: (BuildContext _) => const RecordingSheet(),
      ) ??
      false;

  if (!kept) await ref.read(recordingControllerProvider.notifier).cancel();
}

final class RecordingSheet extends ConsumerWidget {
  const RecordingSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final space = context.space;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.slip,
        border: Border(top: BorderSide(color: colors.hair)),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(space.sheetRadius),
        ),
      ),
      child: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: space.s6,
              left: space.gutter,
              right: space.gutter,
              bottom: space.s5,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const _StateLine(),
                SizedBox(height: space.s2),
                const _Elapsed(),
                SizedBox(height: space.s4),
                const LiveWave(),
                SizedBox(height: space.s5),
                const _Actions(),
              ],
            ),
          ),

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

class _StateLine extends StatelessWidget {
  const _StateLine();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const _RecordDot(),
        SizedBox(width: context.space.s2),
        Text('LISTENING', style: context.type.sheetState),
      ],
    );
  }
}

class _RecordDot extends StatefulWidget {
  const _RecordDot();

  static const double size = 7;

  static const double dimmest = 0.25;

  @override
  State<_RecordDot> createState() => _RecordDotState();
}

class _RecordDotState extends State<_RecordDot>
    with SingleTickerProviderStateMixin {
  AnimationController? _breath;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final Duration period = context.motion.loop(
      const Duration(milliseconds: 1200),
    );
    if (period == Duration.zero) {
      _breath?.dispose();
      _breath = null;
      return;
    }
    _breath ??= AnimationController(vsync: this, duration: period)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breath?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget dot = DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.seal,
        shape: BoxShape.circle,
      ),
      child: const SizedBox.square(dimension: _RecordDot.size),
    );

    final AnimationController? breath = _breath;
    if (breath == null) return dot;

    return FadeTransition(
      opacity: Tween<double>(
        begin: 1,
        end: _RecordDot.dimmest,
      ).animate(CurvedAnimation(parent: breath, curve: context.motion.curve)),
      child: dot,
    );
  }
}

class _Elapsed extends ConsumerWidget {
  const _Elapsed();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Duration elapsed = ref.watch(
      recordingControllerProvider.select((RecordingState s) => s.elapsed),
    );

    return Text(AudioPill.figureFor(elapsed), style: context.type.sheetTime);
  }
}

class LiveWave extends ConsumerWidget {
  const LiveWave({super.key});

  static const double height = 38;

  static const double barWidth = 2;

  static const double floor = 0.12;

  static const List<double> atRest = <double>[
    0.18,
    0.55,
    0.30,
    0.67,
    0.42,
    0.79,
    0.54,
    0.29,
    0.66,
    0.41,
    0.78,
    0.53,
    0.28,
    0.65,
    0.40,
    0.77,
    0.52,
    0.27,
    0.64,
    0.39,
  ];

  static List<double> barsFor(List<double> levels, {required int window}) {
    final List<double> recent = levels.length <= window
        ? levels
        : levels.sublist(levels.length - window);

    return <double>[
      for (int i = recent.length; i < window; i++) floor,
      for (final double level in recent)
        floor + (1 - floor) * level.clamp(0, 1),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<double> levels = ref.watch(
      recordingControllerProvider.select((RecordingState s) => s.levels),
    );

    final List<double> bars = context.motion.reduceMotion
        ? atRest
        : barsFor(levels, window: RecordingController.levelWindow);

    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          for (final double bar in bars)
            DecoratedBox(
              decoration: BoxDecoration(
                color: context.colors.seal.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(barWidth / 2),
              ),
              child: SizedBox(width: barWidth, height: height * bar),
            ),
        ],
      ),
    );
  }
}

class _Actions extends ConsumerWidget {
  const _Actions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: <Widget>[
        QuietButton(
          label: 'Discard',

          onPressed: () => Navigator.of(context).pop(false),
        ),
        SizedBox(width: context.space.s2),
        Expanded(
          child: PrimaryButton(
            label: 'Stop & keep',
            onPressed: () => _keep(context, ref),
          ),
        ),
      ],
    );
  }

  Future<void> _keep(BuildContext context, WidgetRef ref) async {
    final NavigatorState navigator = Navigator.of(context);
    await ref.read(recordingControllerProvider.notifier).stopAndKeep();
    navigator.pop(true);
  }
}
