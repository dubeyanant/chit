/// What a tag is, which is also how it is drawn — BEHAVIOUR.md §3.7.
enum TagKind {
  /// `@somebody`, written without its sigil and set in italic.
  person,

  /// `#something`, keeping its sigil and set in `--ink-faint`.
  topic,
}

/// One run of a chit's words: either plain text, or a tag.
sealed class ChitSpan {
  const ChitSpan._();
}

/// Words with nothing in them the reader is meant to see differently.
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

/// A `@person` or a `#topic`, and the one thing it refers to.
final class TagSpan extends ChitSpan {
  const TagSpan({required this.kind, required this.label}) : super._();

  final TagKind kind;

  /// The words as they are read, underscores already spaces.
  final String label;

  /// What two spellings have to agree on to be the same tag.
  ///
  /// `@Anant_Dubey` and `@anant_dubey` are one person; `@morning` and
  /// `#morning` are not one anything, so the kind is part of it.
  String get key => '${kind.name}:${label.toLowerCase()}';

  @override
  bool operator ==(Object other) =>
      other is TagSpan && other.kind == kind && other.label == label;

  @override
  int get hashCode => Object.hash(kind, label);

  @override
  String toString() => 'TagSpan(${kind.name}, $label)';
}

/// Reads the tags out of a chit's words.
abstract final class ChitTags {
  /// A sigil at a word start, then letters, digits and inner underscores.
  ///
  /// The lookbehind is what keeps `work@example.com` from carrying a tag. The
  /// label must *end* on a letter, a digit or a mark, so a trailing underscore
  /// stays outside the tag rather than drawing as a space nobody can see.
  ///
  /// **`\p{M}` is why `#चित्त` is one tag and not `#च`** — a Devanagari vowel
  /// sign is a combining mark, not a letter, so a class of `\p{L}\p{N}` alone
  /// cuts every Indic word at its first matra. A mark may not *start* a label,
  /// having nothing to combine with.
  static final RegExp _tag = RegExp(
    r'(?<![\p{L}\p{N}\p{M}_])([@#])'
    r'([\p{L}\p{N}](?:[\p{L}\p{N}\p{M}_]*[\p{L}\p{N}\p{M}])?)',
    unicode: true,
  );

  static final RegExp _underscores = RegExp('_+');

  /// Splits [text] into the runs a chit is drawn from.
  ///
  /// Adjacent plain runs are never emitted separately, and an empty string
  /// gives an empty list — so a caller can draw the spans without checking.
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
          label: match.group(2)!.replaceAll(_underscores, ' '),
        ),
      );

      plainFrom = match.end;
    }

    if (plainFrom < text.length) {
      spans.add(PlainSpan(text.substring(plainFrom)));
    }

    return spans;
  }

  /// [text] as it is drawn, flattened back to one string.
  ///
  /// This is what a screen reader is given, so that what is heard and what is
  /// on the slip are the same words: underscores already spaces, a person
  /// without its sigil, a topic with one.
  static String spoken(String text) => parse(text)
      .map(
        (ChitSpan span) => switch (span) {
          PlainSpan(:final String text) => text,
          TagSpan(kind: TagKind.person, :final String label) => label,
          TagSpan(kind: TagKind.topic, :final String label) => '#$label',
        },
      )
      .join();

  /// Every distinct tag in [text], in the order it first appears.
  ///
  /// Distinct by [TagSpan.key], so one chit naming `@Anant` twice names one
  /// person once.
  static List<TagSpan> tagsIn(String text) {
    final Map<String, TagSpan> found = <String, TagSpan>{};

    for (final ChitSpan span in parse(text)) {
      if (span is TagSpan) found.putIfAbsent(span.key, () => span);
    }

    return found.values.toList(growable: false);
  }
}
