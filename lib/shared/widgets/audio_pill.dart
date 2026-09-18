import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/extensions.dart';
import '../../core/theme/chit_colors.dart';
import '../../domain/services/audio_player.dart';

/// A chit's recording, and the control that plays it — BEHAVIOUR.md §3.4.
///
/// **Ink at rest and accent only while it sounds** (ADR-022). *A thread with
/// three recordings in it ran orange down its whole left side* when the pill
/// carried the accent at rest; it is a record like every other until it is the
/// one making a noise.
///
/// It draws itself from `playbackProvider`, so the pill that is lit is decided
/// by the one player rather than by each pill holding its own idea.
final class AudioPill extends ConsumerStatefulWidget {
  /// A pill for the recording at [path], [duration] long, known as [id].
  ///
  /// [id] is a chit's id for a saved chit and [Playback.openChit] for the one on
  /// the open chit — it is which pill, not which row.
  const AudioPill({
    required this.id,
    required this.path,
    required this.duration,
    super.key,
  });

  /// Which pill this is.
  final String id;

  /// Where the recording is — relative for a saved chit, absolute for a take
  /// (ADR-008). Neither this widget nor anything else in `features` opens it.
  final String path;

  /// How long it runs. The figure at rest, and what the playhead is measured
  /// against.
  final Duration duration;

  /// The bar heights of v6's wave, in its own units — `max(12, h × 6)` per
  /// cent of the pill's wave height.
  ///
  /// **A shape, not this recording.** Drawing the real envelope would mean
  /// decoding the file to draw a control that is 18px tall, and a chit written
  /// before anyone thought to store levels would have no envelope to draw. It
  /// is the same drawing on every pill and it is honest about being one: what
  /// it carries is the playhead.
  static const List<int> wave = <int>[
    3, 6, 4, 9, 14, 8, 5, 11, 16, 12, 7, 4, 9, //
    13, 6, 3, 8, 15, 10, 5, 7, 12, 6, 4, 9, 5, 3,
  ];

  /// `0:22` — **the one way a recording's length is written.**
  ///
  /// The recording sheet's running clock is this too, because the sheet's
  /// figure becomes this pill's the instant the take is kept: two formatters
  /// that drifted apart would read as the recording changing length on its way
  /// out of the sheet. Rounded down, so it never shows a second that has not
  /// passed.
  static String figureFor(Duration length) {
    final int seconds = length.inSeconds;
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  /// How many of [wave]'s bars are behind the playhead at [position].
  ///
  /// Zero when nothing is playing and when the take has no length — a division
  /// nobody guards is a crash on a corrupt row.
  static int barsLitAt(Duration position, {required Duration of}) {
    if (of <= Duration.zero || position <= Duration.zero) return 0;
    final double through = position.inMilliseconds / of.inMilliseconds;
    return (through.clamp(0, 1) * wave.length).floor();
  }

  @override
  ConsumerState<AudioPill> createState() => _AudioPillState();
}

/// 18px — the wave's height inside the pill. One component's geometry, off the
/// scale by DESIGN-SYSTEM.md §6.3's dimension rule, like the microphone's 54.
const double _waveHeight = 18;

/// Each stroke, 2px, as v6 sets it.
const double _barWidth = 2;

/// The shortest a bar is drawn, as a fraction of [_waveHeight].
const double _floor = 0.12;

/// What a pill at rest draws its bars at — v6's 45%.
const double _restingBars = 0.45;

/// What an unplayed bar fades to while the pill is sounding — v6's 22%.
const double _unplayedBars = 0.22;

class _AudioPillState extends ConsumerState<AudioPill> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;

    final Playback playback =
        ref.watch(playbackProvider).value ?? Playback.silent;
    final bool mine = playback.holds(widget.id);
    final bool sounding = mine && playback.playing;

    final int lit = mine
        ? AudioPill.barsLitAt(playback.position, of: widget.duration)
        : 0;

    return Semantics(
      button: true,
      label: sounding
          ? 'Pause recording, ${AudioPill.figureFor(widget.duration)}'
          : 'Play recording, ${AudioPill.figureFor(widget.duration)}',
      child: GestureDetector(
        onTapDown: (TapDownDetails _) => setState(() => _pressed = true),
        onTapUp: (TapUpDetails _) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () => _toggle(sounding: sounding),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.inkWash(
              colors.slip,
              opacity: _pressed
                  ? ChitColors.pillPressedWash
                  : ChitColors.pillWash,
            ),
            // The border is the only thing that changes colour, and only while
            // it sounds. Everything else on a thread stays ink.
            border: Border.all(color: mine ? colors.seal : colors.hair),
            borderRadius: BorderRadius.circular(space.radius),
          ),
          child: Padding(
            // 13px by 12px in v6; both are `s3`, since a padding is a
            // relationship (DESIGN-SYSTEM.md §6.3). At `s3` the pill measures
            // 44px, exactly §6.4's floor.
            padding: EdgeInsets.all(space.s3),
            child: Row(
              children: <Widget>[
                _PlayGlyph(sounding: sounding, lit: mine),
                SizedBox(width: space.s3),
                Expanded(
                  child: SizedBox(
                    height: _waveHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        for (int i = 0; i < AudioPill.wave.length; i++)
                          _Bar(
                            height:
                                _waveHeight *
                                (AudioPill.wave[i] * 0.06).clamp(_floor, 1),
                            colour: mine ? colors.seal : colors.inkMuted,
                            opacity: mine
                                ? (i < lit ? 1 : _unplayedBars)
                                : _restingBars,
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: space.s3),
                Text(
                  AudioPill.figureFor(
                    mine ? playback.position : widget.duration,
                  ),
                  style: context.type.audioDuration.copyWith(
                    color: mine ? colors.sealInk : colors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggle({required bool sounding}) async {
    final AudioPlayer player = ref.read(audioPlayerProvider);
    if (sounding) return player.pause();
    return player.play(id: widget.id, path: widget.path);
  }
}

/// One stroke of the pill's wave.
class _Bar extends StatelessWidget {
  const _Bar({
    required this.height,
    required this.colour,
    required this.opacity,
  });

  final double height;
  final Color colour;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colour.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(_barWidth / 2),
      ),
      child: SizedBox(width: _barWidth, height: height),
    );
  }
}

/// The play and pause triangles, in v6's own 18-unit box.
class _PlayGlyph extends StatelessWidget {
  const _PlayGlyph({required this.sounding, required this.lit});

  /// 16px drawn in an 18-unit box — the same ratio every icon in the app uses.
  static const double size = 16;

  final bool sounding;
  final bool lit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomPaint(
      size: const Size.square(size),
      painter: _PlayPainter(
        colour: lit ? colors.seal : colors.inkMuted,
        paused: !sounding,
      ),
    );
  }
}

/// `M5.5 3.4v11.2L15 9 5.5 3.4Z`, and the two bars that replace it.
class _PlayPainter extends CustomPainter {
  const _PlayPainter({required this.colour, required this.paused});

  final Color colour;
  final bool paused;

  @override
  void paint(Canvas canvas, Size size) {
    final double unit = size.width / 18;
    final Paint paint = Paint()
      ..color = colour
      ..style = PaintingStyle.fill;

    if (paused) {
      canvas.drawPath(
        Path()
          ..moveTo(5.5 * unit, 3.4 * unit)
          ..lineTo(5.5 * unit, 14.6 * unit)
          ..lineTo(15 * unit, 9 * unit)
          ..close(),
        paint,
      );
      return;
    }

    for (final double x in <double>[4.6, 10.3]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x * unit, 3.4 * unit, 3.1 * unit, 11.2 * unit),
          Radius.circular(0.6 * unit),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_PlayPainter oldDelegate) =>
      oldDelegate.colour != colour || oldDelegate.paused != paused;
}
