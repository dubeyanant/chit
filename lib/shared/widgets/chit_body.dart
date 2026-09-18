import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/extensions.dart';
import '../../domain/find/find_axis.dart';
import '../../domain/tags/chit_tags.dart';

/// A saved chit's words, with its tags drawn as tags and reached as tags —
/// BEHAVIOUR.md §3.7.
///
/// **A person loses its `@` and a topic keeps its `#`** (ADR-082): italic is
/// difference enough for a name, while a topic's only other difference would
/// be colour, which §6.4 forbids a signal to rest on alone.
///
/// **A tag is tapped and the row is held** (ADR-086). It navigates itself
/// rather than taking a callback every caller would pass identically, which
/// is the argument ADR-061 made for `ChitRow`.
final class ChitBody extends StatefulWidget {
  const ChitBody(this.text, {super.key});

  final String text;

  @override
  State<ChitBody> createState() => _ChitBodyState();
}

class _ChitBodyState extends State<ChitBody> {
  /// One recognizer per tag, kept so they can be disposed.
  ///
  /// A `TapGestureRecognizer` owns a pointer subscription; building one inside
  /// `build` leaks one per frame.
  List<TapGestureRecognizer> _taps = const <TapGestureRecognizer>[];

  List<ChitSpan> _spans = const <ChitSpan>[];

  @override
  void initState() {
    super.initState();
    _read();
  }

  @override
  void didUpdateWidget(ChitBody old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text) _read();
  }

  @override
  void dispose() {
    _disposeTaps();
    super.dispose();
  }

  void _read() {
    _disposeTaps();
    _spans = ChitTags.parse(widget.text);

    _taps = <TapGestureRecognizer>[
      for (final ChitSpan span in _spans)
        if (span is TagSpan)
          TapGestureRecognizer()..onTap = () => _open(span),
    ];
  }

  void _disposeTaps() {
    for (final TapGestureRecognizer tap in _taps) {
      tap.dispose();
    }
    _taps = const <TapGestureRecognizer>[];
  }

  /// **Unwinds and re-enters** rather than pushing (ADR-086): `go` rebuilds
  /// find's stack as root → axis → value, so back always walks the real path
  /// up and tapping tag after tag never piles one.
  void _open(TagSpan tag) {
    final FindAxis axis = FindAxis.ofTag(tag.kind);

    context.go(
      GoRouter.of(context).namedLocation(
        findValueRouteName,
        pathParameters: <String, String>{
          findAxisParameter: axis.slug,
          findValueParameter: tag.slug,
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    int tap = 0;

    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          for (final ChitSpan span in _spans)
            switch (span) {
              PlainSpan(:final String text) => TextSpan(text: text),

              TagSpan(kind: TagKind.person, :final String label) => TextSpan(
                text: label,
                style: type.chitPerson,
                recognizer: _taps[tap++],
              ),

              TagSpan(kind: TagKind.topic, :final String label) => TextSpan(
                text: '#$label',
                style: type.chitTopic,
                recognizer: _taps[tap++],
              ),
            },
        ],
      ),
      style: type.chitText,
    );
  }
}
