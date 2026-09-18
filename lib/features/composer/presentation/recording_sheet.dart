import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions.dart';
import '../../../domain/models/recording_state.dart';
import '../../../shared/widgets/audio_pill.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/perforated_edge.dart';
import '../application/recording_controller.dart';

/// Raises the recording sheet and keeps or cancels the take — §3.4, ADR-011.
///
/// **A modal sheet, not a route.** Dismissing it is not a back navigation and
/// nothing about it belongs in `ChitRoute`; it is the one deliberate exception
/// to go_router owning navigation (ARCHITECTURE.md §3).
///
/// Every way out that is not **Stop & keep** — the drag, the scrim, the back
/// gesture, **Discard** — is a cancel, which is why the result is read here
/// rather than in each control: a dismissal the widget never hears about would
/// otherwise leave a microphone running.
Future<void> showRecordingSheet(BuildContext context, WidgetRef ref) async {
  final bool kept =
      await showModalBottomSheet<bool>(
        context: context,
        // The sheet draws its own surface, its own corners and its own tear
        // edge; Material's would be a second one under it.
        backgroundColor: Colors.transparent,
        barrierColor: context.colors.scrim,
        // v6 lets the sheet grow to 88% of the screen, which it cannot do
        // inside the default half-height constraint.
        isScrollControlled: true,
        useSafeArea: true,
        builder: (BuildContext _) => const RecordingSheet(),
      ) ??
      false;

  if (!kept) await ref.read(recordingControllerProvider.notifier).cancel();
}

/// The recording sheet — BEHAVIOUR.md §4.3, and §3.4 for what it does.
///
/// Slip-coloured, cornered at `sheetRadius`, and carrying the same perforated
/// edge as a chit: what is being written here is a chit, and the sheet is the
/// same paper arriving from below.
final class RecordingSheet extends ConsumerWidget {
  /// The sheet, drawn from `recordingControllerProvider`.
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
          // The same tear edge as a chit, `s2` in from each end and sitting on
          // the border rather than under it.
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

/// The record dot and the one uppercase word in the app — DESIGN-SYSTEM.md
/// §6.2.
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

/// The breathing dot — `ChitMotion.loop`'s first caller, which closes open
/// item 17.
///
/// **1.2s, and the period belongs to the dot** (ADR-027, DESIGN-SYSTEM.md
/// §6.3). v6's CSS says 1.6s; §6.3's table says 1.2s and it is the authority
/// for a pace, so the prototype is the one that is out of date here.
///
/// Under reduced motion `loop` returns zero, there is no ticker, and the dot
/// is drawn at full strength — at rest rather than absent, because the dot is
/// what says the microphone is open (§6.4).
class _RecordDot extends StatefulWidget {
  const _RecordDot();

  /// 7px. One component's geometry, like the perforation's hole radius.
  static const double size = 7;

  /// How far it fades at the bottom of a breath — v6's `breathe` keyframe.
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

/// How long the take has run, in tabular figures so the digits do not shuffle.
///
/// **The same formatter the pill uses.** The sheet's figure becomes the pill's
/// the instant a take is kept, so two that disagreed would read as the
/// recording changing length on its way out of the sheet.
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

/// The live wave — twenty thin strokes, drawn from the microphone.
///
/// **The bars are the levels** (ADR-054 as amended): one bar per reading,
/// newest at the right, so the wave is the shape of what was just said rather
/// than one loudness split twenty ways. *v6 animates twenty fixed heights on
/// their own loops, which is what a prototype with no microphone can do.*
///
/// Under reduced motion it draws [atRest] — v6's own answer, and the reason
/// it is a ragged row rather than a flat one: every bar at the same height
/// reads as broken (§6.4).
class LiveWave extends ConsumerWidget {
  /// The wave, drawn from `recordingControllerProvider`.
  const LiveWave({super.key});

  /// 38px. One component's geometry, off the scale by DESIGN-SYSTEM.md §6.3's
  /// dimension rule.
  static const double height = 38;

  /// Each stroke, and the reason there are twenty of them rather than forty:
  /// an equaliser is the most conventional thing a recording screen can do,
  /// and this only has to say that it is hearing you.
  static const double barWidth = 2;

  /// The shortest a bar is drawn, as a fraction of [height] — v6's `bob`
  /// keyframe floor. Silence is a row of ticks, not an empty box.
  static const double floor = 0.12;

  /// The fixed heights of v6's twenty bars, `18 + (i * 37) % 62` per cent.
  ///
  /// Drawn under reduced motion, and before the first reading arrives.
  static const List<double> atRest = <double>[
    0.18, 0.55, 0.30, 0.67, 0.42, 0.79, 0.54, 0.29, 0.66, 0.41, //
    0.78, 0.53, 0.28, 0.65, 0.40, 0.77, 0.52, 0.27, 0.64, 0.39,
  ];

  /// The bar heights for [levels], as fractions of [height].
  ///
  /// Padded at the **left** with the floor, so a take that has just begun
  /// fills from the right the way it will go on doing.
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

    // Reduced motion takes the fixed row and nothing else — no ticker, and no
    // response to the microphone either, since a wave that moves with a voice
    // is still a wave that moves.
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
                // A mark, not words — so `seal` and not `sealInk` (ADR-022).
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

/// **Discard** and **Stop & keep** — the same two weights as the open chit.
///
/// Two controls rather than the one TASKS.md group D listed: v6 draws both,
/// and a sheet whose only way out is the one that commits leaves the drag
/// gesture carrying a decision by itself.
class _Actions extends ConsumerWidget {
  const _Actions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: <Widget>[
        QuietButton(
          label: 'Discard',
          // Closing without a `true` is what cancels — `showRecordingSheet`
          // treats every other way out the same way, so this control does not
          // need to know how to end a take.
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

  /// Stops the recorder, then closes.
  Future<void> _keep(BuildContext context, WidgetRef ref) async {
    final NavigatorState navigator = Navigator.of(context);
    await ref.read(recordingControllerProvider.notifier).stopAndKeep();
    navigator.pop(true);
  }
}
