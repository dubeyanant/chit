import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/extensions.dart';
import '../../core/theme/chit_colors.dart';
import '../../domain/services/audio_player.dart';
import 'buttons.dart';
import 'focus_ring.dart';

final class AudioPill extends ConsumerStatefulWidget {
  const AudioPill({
    required this.id,
    required this.path,
    required this.duration,
    this.onRemove,
    super.key,
  });

  final String id;

  final String path;

  final Duration duration;

  final VoidCallback? onRemove;

  static const List<int> wave = <int>[
    3,
    6,
    4,
    9,
    14,
    8,
    5,
    11,
    16,
    12,
    7,
    4,
    9,
    13,
    6,
    3,
    8,
    15,
    10,
    5,
    7,
    12,
    6,
    4,
    9,
    5,
    3,
  ];

  static String figureFor(Duration length) {
    final int seconds = length.inSeconds;
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  static int barsLitAt(Duration position, {required Duration of}) {
    if (of <= Duration.zero || position <= Duration.zero) return 0;
    final double through = position.inMilliseconds / of.inMilliseconds;
    return (through.clamp(0, 1) * wave.length).floor();
  }

  @override
  ConsumerState<AudioPill> createState() => _AudioPillState();
}

const double _waveHeight = 18;

const double _barWidth = 2;

const double _floor = 0.12;

const double _restingBars = 0.45;

const double _unplayedBars = 0.22;

class _AudioPillState extends ConsumerState<AudioPill> {
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

    final Widget pill = Semantics(
      button: true,
      label: sounding
          ? 'Pause recording, ${AudioPill.figureFor(widget.duration)}'
          : 'Play recording, ${AudioPill.figureFor(widget.duration)}',
      child: FocusRing(
        onActivate: () => _toggle(sounding: sounding),
        child: GestureDetector(
          onTap: () => _toggle(sounding: sounding),

          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: space.minTouchTarget),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.inkWash(
                  colors.slip,
                  opacity: ChitColors.pillWash,
                ),

                border: Border.all(color: mine ? colors.seal : colors.hair),
                borderRadius: BorderRadius.circular(space.radius),
              ),
              child: Padding(
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
        ),
      ),
    );

    final VoidCallback? remove = widget.onRemove;
    if (remove == null) return pill;

    return Row(
      children: <Widget>[
        Expanded(child: pill),
        SizedBox(width: space.s2),
        QuietButton(label: 'Remove', onPressed: remove),
      ],
    );
  }

  Future<void> _toggle({required bool sounding}) async {
    final AudioPlayer player = ref.read(audioPlayerProvider);
    if (sounding) return player.pause();
    return player.play(id: widget.id, path: widget.path);
  }
}

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

class _PlayGlyph extends StatelessWidget {
  const _PlayGlyph({required this.sounding, required this.lit});

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
