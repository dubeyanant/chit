import 'package:flutter/material.dart';

import '../../core/extensions.dart';
import '../../domain/tags/chit_tags.dart';

/// A saved chit's words, with its tags drawn as tags — BEHAVIOUR.md §3.7.
///
/// **A person loses its `@` and a topic keeps its `#`** (ADR-082): italic is
/// difference enough for a name, while a topic's only other difference would
/// be colour, which §6.4 forbids a signal to rest on alone.
///
/// Nothing here is tappable. The thread's one tap belongs to the pill (§4.1),
/// and a `TapGestureRecognizer` would take it — so this stays a `TextSpan`
/// tree and the row stays the target.
final class ChitBody extends StatelessWidget {
  const ChitBody(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final type = context.type;

    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          for (final ChitSpan span in ChitTags.parse(text))
            switch (span) {
              PlainSpan(:final String text) => TextSpan(text: text),

              TagSpan(kind: TagKind.person, :final String label) => TextSpan(
                text: label,
                style: type.chitPerson,
              ),

              TagSpan(kind: TagKind.topic, :final String label) => TextSpan(
                text: '#$label',
                style: type.chitTopic,
              ),
            },
        ],
      ),
      style: type.chitText,
    );
  }
}
