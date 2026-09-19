import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions.dart';
import '../../../../core/haptics.dart';
import '../../../../core/theme/chit_space.dart';
import '../../../../domain/models/chit.dart';
import '../../application/timeline_provider.dart';

class Timeline extends ConsumerStatefulWidget {
  const Timeline({super.key});

  static const double markSize = 7;

  static const double nowStroke = 1.5;

  static const double nowHeight = 12;

  static const double boundaryHeight = nowHeight;

  static const double boundaryStroke = nowStroke;

  static double lineTopFor(ChitSpace space) => space.s4 + (nowHeight - 1) / 2;

  @override
  ConsumerState<Timeline> createState() => _TimelineState();
}

class _TimelineState extends ConsumerState<Timeline> {
  final ScrollController _scroll = ScrollController();

  int? _dayUnderCentre;

  bool _settling = false;

  bool _rested = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);

    _restAtNow();
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

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
      ChitHaptics.selected();
    }
    _dayUnderCentre = day;
  }

  double _restingOffset(ScrollPosition position) {
    final double content =
        position.viewportDimension + position.maxScrollExtent;
    final double? fraction = ref
        .read(timelineWindowProvider)
        .fractionOf(ref.read(timelineNowProvider));

    if (fraction == null) return position.maxScrollExtent;

    return (fraction * content - position.viewportDimension / 2).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
  }

  void _restAtNow() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (!_rested) setState(() => _rested = true);
      if (!_scroll.hasClients) return;

      final double target = _restingOffset(_scroll.position);

      _settling = true;
      _dayUnderCentre = null;

      _scroll.jumpTo(target);

      _settling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final space = context.space;
    final TimelineWindow window = ref.watch(timelineWindowProvider);
    final DateTime now = ref.watch(timelineNowProvider);

    ref.listen(timelineChitsProvider, (
      AsyncValue<List<Chit>>? _,
      AsyncValue<List<Chit>> _,
    ) {
      _restAtNow();
    });

    final List<Chit> chits = switch (ref.watch(timelineChitsProvider)) {
      AsyncData<List<Chit>>(:final List<Chit> value) => value,
      _ => const <Chit>[],
    };

    return Semantics(
      label: 'When chits were written, over the last three days',
      child: ExcludeSemantics(
        child: SizedBox(
          height:
              Timeline.lineTopFor(space) +
              1 +
              Timeline.boundaryHeight +
              space.s2,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double content = constraints.maxWidth * window.dayCount;

              return Opacity(
                opacity: _rested ? 1 : 0,
                child: SingleChildScrollView(
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

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

    final double lineTop = Timeline.lineTopFor(space);
    final double lineCentre = lineTop + 0.5;

    double? x(DateTime at) {
      final double? fraction = window.fractionOf(at);
      return fraction == null ? null : fraction * width;
    }

    final double? nowX = x(now);

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned(
          left: 0,
          right: 0,
          top: lineTop,
          height: 1,
          child: ColoredBox(color: colors.hair),
        ),

        for (final DateTime boundary in window.dayBoundaries)
          if (x(boundary) case final double at)
            Positioned(
              left: at - Timeline.boundaryStroke / 2,
              top: lineCentre,
              width: Timeline.boundaryStroke,
              height: Timeline.boundaryHeight,
              child: ColoredBox(color: colors.inkFaint),
            ),

        for (final Chit chit in chits)
          if (x(chit.createdAt) case final double at)
            Positioned(
              left: at - Timeline.markSize / 2,
              top: lineCentre - Timeline.markSize / 2,
              child: const _Mark(),
            ),

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

class _Mark extends StatelessWidget {
  const _Mark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Timeline.markSize,
      height: Timeline.markSize,
      decoration: BoxDecoration(
        color: context.colors.inkFaint,

        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}

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
