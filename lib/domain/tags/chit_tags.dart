enum TagKind { person, topic }

sealed class ChitSpan {
  const ChitSpan._();
}

final class PlainSpan extends ChitSpan {
  const PlainSpan(this.text) : super._();

  final String text;

  @override
  bool operator ==(Object other) => other is PlainSpan && other.text == text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'PlainSpan($text)';
}

final class TagSpan extends ChitSpan {
  const TagSpan({required this.kind, required this.label}) : super._();

  final TagKind kind;

  final String label;

  String get key => '${kind.name}:$label';

  @override
  bool operator ==(Object other) =>
      other is TagSpan && other.kind == kind && other.label == label;

  @override
  int get hashCode => Object.hash(kind, label);

  @override
  String toString() => 'TagSpan(${kind.name}, $label)';
}

abstract final class ChitTags {
  static final RegExp _tag = RegExp(
    r'(?<![\p{L}\p{N}\p{M}_])([@#])'
    r'([\p{L}\p{N}](?:[\p{L}\p{N}\p{M}_]*[\p{L}\p{N}\p{M}])?)',
    unicode: true,
  );

  static final RegExp _underscores = RegExp('_+');

  static List<ChitSpan> parse(String text) {
    final List<ChitSpan> spans = <ChitSpan>[];
    int plainFrom = 0;

    for (final RegExpMatch match in _tag.allMatches(text)) {
      if (match.start > plainFrom) {
        spans.add(PlainSpan(text.substring(plainFrom, match.start)));
      }

      spans.add(
        TagSpan(
          kind: match.group(1) == '@' ? TagKind.person : TagKind.topic,
          label: match.group(2)!.replaceAll(_underscores, ' ').toLowerCase(),
        ),
      );

      plainFrom = match.end;
    }

    if (plainFrom < text.length) {
      spans.add(PlainSpan(text.substring(plainFrom)));
    }

    return spans;
  }

  static String spoken(String text) => parse(text)
      .map(
        (ChitSpan span) => switch (span) {
          PlainSpan(:final String text) => text,
          TagSpan(kind: TagKind.person, :final String label) => label,
          TagSpan(kind: TagKind.topic, :final String label) => '#$label',
        },
      )
      .join();

  static List<TagSpan> tagsIn(String text) {
    final Map<String, TagSpan> found = <String, TagSpan>{};

    for (final ChitSpan span in parse(text)) {
      if (span is TagSpan) found.putIfAbsent(span.key, () => span);
    }

    return found.values.toList(growable: false);
  }
}
