import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/extensions.dart';
import '../../domain/models/chit.dart';
import '../../domain/tags/chit_tags.dart';
import 'ambient_stamp_row.dart';
import 'arrival.dart';
import 'audio_pill.dart';
import 'chit_body.dart';
import 'focus_ring.dart';
import 'thread_rail.dart';

class DayThread extends StatefulWidget {
  const DayThread({required this.chits, super.key});

  final List<Chit> chits;

  @override
  State<DayThread> createState() => _DayThreadState();
}

class _DayThreadState extends State<DayThread> {
  late Set<String> _seen = <String>{
    for (final Chit chit in widget.chits) chit.id,
  };

  Set<String> _arriving = const <String>{};

  @override
  void didUpdateWidget(DayThread oldWidget) {
    super.didUpdateWidget(oldWidget);
    final Set<String> now = <String>{
      for (final Chit chit in widget.chits) chit.id,
    };
    _arriving = now.difference(_seen);
    _seen = now;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.chits.isEmpty) return const SizedBox.shrink();

    final Offset from = Offset(0, -context.space.s4);

    return ThreadRail(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final Chit chit in widget.chits)
            Arrival(
              key: ValueKey<String>(chit.id),
              from: from,
              play: _arriving.contains(chit.id),
              child: ChitRow(chit: chit),
            ),
        ],
      ),
    );
  }
}

class ChitRow extends StatelessWidget {
  const ChitRow({required this.chit, super.key});

  final Chit chit;

  static const double _overhang = ThreadRail.centre - ThreadNode.size / 2;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      // The spoken form, not the raw row: a reader hearing "anant underscore
      // dubey" is being read the writing and not the chit.
      label:
          'Chit, '
          '${chit.hasText ? ChitTags.spoken(chit.text!) : 'a recording'}',
      hint: 'Hold to open the chit',
      onLongPress: () => _open(context),

      excludeSemantics: true,
      child: FocusRing(
        onActivate: () => _open(context),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,

          onLongPress: () {
            unawaited(HapticFeedback.selectionClick());
            _open(context);
          },
          child: _Body(chit: chit),
        ),
      ),
    );
  }

  void _open(BuildContext context) => context.pushNamed(
    editorRouteName,
    pathParameters: <String, String>{editorIdParameter: chit.id},
  );
}

class _Body extends StatelessWidget {
  const _Body({required this.chit});

  final Chit chit;

  @override
  Widget build(BuildContext context) {
    final space = context.space;
    final double inset = ThreadRail.contentInset(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(0, space.s3, space.s2, space.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: inset,
                height: ThreadNode.size,
                child: Transform.translate(
                  offset: const Offset(ChitRow._overhang, 0),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: ThreadNode(),
                  ),
                ),
              ),
              Expanded(
                child: AmbientStampRow.saved(
                  stamp: chit.stamp,
                  edited: chit.wasEdited,
                ),
              ),
            ],
          ),
          if (chit.hasText)
            Padding(
              padding: EdgeInsets.only(left: inset, top: space.s1),

              child: ChitBody(chit.text!),
            ),

          if (chit.hasAudio)
            Padding(
              padding: EdgeInsets.only(left: inset, top: space.s2),
              child: AudioPill(
                id: chit.id,
                path: chit.audioPath!,
                duration: chit.audioDuration ?? Duration.zero,
              ),
            ),
        ],
      ),
    );
  }
}
