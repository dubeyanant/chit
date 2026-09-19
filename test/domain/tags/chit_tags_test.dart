import 'package:chitta/domain/tags/chit_tags.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('a chit with no tags in it is one plain run', () {
    test('ordinary words', () {
      expect(ChitTags.parse('Train 20 late.'), <ChitSpan>[
        const PlainSpan('Train 20 late.'),
      ]);
    });

    test('nothing at all is nothing to draw', () {
      expect(ChitTags.parse(''), isEmpty);
    });
  });

  group('the two kinds', () {
    test('a person loses the sigil and keeps the word', () {
      expect(ChitTags.parse('@anant'), <ChitSpan>[
        const TagSpan(kind: TagKind.person, label: 'anant'),
      ]);
    });

    test('a topic is the same shape, differently kinded', () {
      expect(ChitTags.parse('#morning'), <ChitSpan>[
        const TagSpan(kind: TagKind.topic, label: 'morning'),
      ]);
    });

    test('and they sit in the words around them', () {
      expect(ChitTags.parse('Called @anant about #rent today.'), <ChitSpan>[
        const PlainSpan('Called '),
        const TagSpan(kind: TagKind.person, label: 'anant'),
        const PlainSpan(' about '),
        const TagSpan(kind: TagKind.topic, label: 'rent'),
        const PlainSpan(' today.'),
      ]);
    });
  });

  group('an underscore is a space that survives the writing', () {
    test('one becomes one', () {
      expect(ChitTags.parse('@anant_dubey'), <ChitSpan>[
        const TagSpan(kind: TagKind.person, label: 'anant dubey'),
      ]);
    });

    test('a run becomes one, not a run of spaces nobody can see', () {
      expect(ChitTags.parse('#morning__pages'), <ChitSpan>[
        const TagSpan(kind: TagKind.topic, label: 'morning pages'),
      ]);
    });

    test('a trailing one is left outside the tag', () {
      expect(ChitTags.parse('@anant_'), <ChitSpan>[
        const TagSpan(kind: TagKind.person, label: 'anant'),
        const PlainSpan('_'),
      ]);
    });

    test('a leading one is not a tag at all', () {
      expect(ChitTags.parse('@_anant'), <ChitSpan>[const PlainSpan('@_anant')]);
    });
  });

  group('where a tag stops', () {
    test('a full stop ends it and stays text', () {
      expect(ChitTags.parse('Saw @anant.'), <ChitSpan>[
        const PlainSpan('Saw '),
        const TagSpan(kind: TagKind.person, label: 'anant'),
        const PlainSpan('.'),
      ]);
    });

    test("a possessive ends it — the 's is not part of the name", () {
      expect(ChitTags.parse("@anant's desk"), <ChitSpan>[
        const TagSpan(kind: TagKind.person, label: 'anant'),
        const PlainSpan("'s desk"),
      ]);
    });

    test('digits are part of a tag', () {
      expect(ChitTags.parse('#week40'), <ChitSpan>[
        const TagSpan(kind: TagKind.topic, label: 'week40'),
      ]);
    });

    test('a sigil alone is not a tag', () {
      expect(ChitTags.parse('me @ 5'), <ChitSpan>[const PlainSpan('me @ 5')]);
    });
  });

  group('a sigil inside a word is not a sigil', () {
    test('an email address carries no tag', () {
      expect(ChitTags.parse('work@example.com'), <ChitSpan>[
        const PlainSpan('work@example.com'),
      ]);
    });

    test('nor does a word with a hash in the middle of it', () {
      expect(ChitTags.parse('C#'), <ChitSpan>[const PlainSpan('C#')]);
    });

    test('but a sigil after a bracket or a newline is one', () {
      expect(ChitTags.parse('(@anant)\n#rent'), <ChitSpan>[
        const PlainSpan('('),
        const TagSpan(kind: TagKind.person, label: 'anant'),
        const PlainSpan(')\n'),
        const TagSpan(kind: TagKind.topic, label: 'rent'),
      ]);
    });
  });

  group('any script, because the app is named in one', () {
    test('Devanagari tags', () {
      expect(ChitTags.parse('#चित्त'), <ChitSpan>[
        const TagSpan(kind: TagKind.topic, label: 'चित्त'),
      ]);
    });
  });

  group('what is spoken is what is drawn', () {
    test('a person without its sigil, a topic with one', () {
      expect(
        ChitTags.spoken('Told @anant_dubey about #morning_pages.'),
        'Told anant dubey about #morning pages.',
      );
    });

    test('words with nothing in them come back unchanged', () {
      expect(ChitTags.spoken('Train 20 late.'), 'Train 20 late.');
    });

    test('an underscore outside a tag is left alone', () {
      expect(ChitTags.spoken('the file is a_b.txt'), 'the file is a_b.txt');
    });
  });

  group('the whole thing counts as one — the key', () {
    test('case does not make a second person', () {
      expect(
        ChitTags.tagsIn('@anant_dubey').single.key,
        ChitTags.tagsIn('@Anant_Dubey').single.key,
      );
    });

    test('an underscore and a space reach the same key', () {
      expect(
        ChitTags.tagsIn('@anant_dubey').single.key,
        const TagSpan(kind: TagKind.person, label: 'anant dubey').key,
      );
    });

    test('the kind is part of it — a person is not a topic', () {
      const TagSpan person = TagSpan(kind: TagKind.person, label: 'rent');
      const TagSpan topic = TagSpan(kind: TagKind.topic, label: 'rent');

      expect(person.key, isNot(topic.key));
    });

    test('one chit naming somebody twice names them once', () {
      final List<TagSpan> tags = ChitTags.tagsIn('@Anant and @anant again');

      expect(tags, hasLength(1));
      expect(tags.single.label, 'anant');
    });

    test('and the order is the order they were written', () {
      expect(
        ChitTags.tagsIn('Told @anant about #rent and #rent again, then @mira')
            .map((TagSpan t) => t.key),
        <String>['person:anant', 'topic:rent', 'person:mira'],
      );
    });
  });

  group('a tag is drawn in lower case, however it was typed — ADR-092', () {
    test('a person is folded', () {
      expect(_labels('Saw @Anant_Dubey'), <String>['anant dubey']);
    });

    test('a topic is folded', () {
      expect(_labels('#MorningPages and #RENT'), <String>[
        'morningpages',
        'rent',
      ]);
    });

    test('the words around a tag keep the case they were written in', () {
      expect(
        ChitTags.parse('Told @Mira about Tuesday')
            .whereType<PlainSpan>()
            .map((PlainSpan s) => s.text),
        <String>['Told ', ' about Tuesday'],
      );
    });

    test('what is spoken is folded too, being what is drawn', () {
      expect(
        ChitTags.spoken('Saw @Anant about #Rent'),
        'Saw anant about #rent',
      );
    });

    test('a script with no case is left as it is', () {
      expect(_labels('#चित्त'), <String>['चित्त']);
    });

    test('the fold is the parse, so nothing downstream has to repeat it', () {
      for (final String written in <String>[
        '@ANANT',
        '@Anant',
        '@anant',
        '@AnAnT',
      ]) {
        final TagSpan tag = ChitTags.tagsIn(written).single;

        expect(tag.label, 'anant');
        expect(tag.key, 'person:anant');
      }
    });
  });
}

List<String> _labels(String text) => <String>[
  for (final TagSpan tag in ChitTags.tagsIn(text)) tag.label,
];
