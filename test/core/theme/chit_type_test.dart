import 'package:chitt/core/theme/chit_colors.dart';
import 'package:chitt/core/theme/chit_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ChitColors colors = ChitColors.tokens();
  final ChitType type = ChitType.tokens(colors);

  double? axis(TextStyle style, String name) {
    for (final FontVariation variation in style.fontVariations!) {
      if (variation.axis == name) return variation.value;
    }
    return null;
  }

  group('every style carries the axes it needs', () {
    test('all of them set a weight variation, not just fontWeight', () {
      for (final TextStyle style in type.styles) {
        expect(
          style.fontVariations,
          isNotNull,
          reason: 'a style with no fontVariations renders at weight 400',
        );
        expect(axis(style, 'wght'), isNotNull);
      }
    });

    test('fontWeight agrees with the wght variation it sits beside', () {
      for (final TextStyle style in type.styles) {
        final double? weight = axis(style, 'wght');
        expect(
          style.fontWeight!.value,
          closeTo(weight!, 100),
          reason:
              'fontWeight is the fallback face and the semantic weight; it '
              'should not disagree with what is actually drawn',
        );
      }
    });

    test('Newsreader styles set opsz, and the others do not', () {
      for (final TextStyle style in type.styles) {
        final bool isSerif = style.fontFamily == ChitType.serifFamily;
        expect(
          axis(style, 'opsz'),
          isSerif ? isNotNull : isNull,
          reason:
              '${style.fontFamily} at ${style.fontSize}px: only Newsreader '
              'carries an optical-size axis',
        );
      }
    });

    test('opsz tracks the size the text is drawn at, in points', () {
      for (final TextStyle style in type.styles) {
        if (style.fontFamily != ChitType.serifFamily) continue;
        expect(
          axis(style, 'opsz'),
          closeTo((style.fontSize! * 0.75).clamp(6.0, 72.0), 0.001),
        );
      }
    });

    test('every style names a family, so none of them inherits one', () {
      for (final TextStyle style in type.styles) {
        expect(style.fontFamily, isNotNull);
        expect(style.fontSize, isNotNull);
      }
    });
  });

  group('the three faces of DESIGN-SYSTEM.md §6.2', () {
    test('are the only families used', () {
      const Set<String> faces = <String>{
        ChitType.serifFamily,
        ChitType.sansFamily,
        ChitType.devanagariFamily,
      };
      for (final TextStyle style in type.styles) {
        expect(faces, contains(style.fontFamily));
      }
    });

    test('चित्त is the only word set in Devanagari', () {
      final Iterable<TextStyle> deva = type.styles.where(
        (TextStyle s) => s.fontFamily == ChitType.devanagariFamily,
      );
      expect(
        deva,
        unorderedEquals(<TextStyle>[type.wordmark, type.closingMark]),
      );
    });

    test('the closing mark is drawn at part strength', () {
      expect(type.closingMark.color!.a, lessThan(colors.inkFaint.a));
    });
  });

  group('DESIGN-SYSTEM.md §6.2, the specifics it commits to', () {
    test('anything that counts or keeps time is set in tabular figures', () {
      final List<TextStyle> counters = <TextStyle>[
        type.ambientStamp,
        type.chitMeta,
        type.sheetTime,
        type.audioDuration,
        type.monthSummaryStrong,
      ];
      for (final TextStyle style in counters) {
        expect(
          style.fontFeatures,
          contains(const FontFeature.tabularFigures()),
        );
      }
    });

    test('display-to-body is 1.58x', () {
      expect(
        type.date.fontSize! / type.chitText.fontSize!,
        closeTo(1.58, 0.01),
      );
    });

    test('the weekday sets as one phrase with the date beside it', () {
      expect(type.weekday.fontSize, type.date.fontSize);
      expect(type.weekday.fontWeight, type.date.fontWeight);
      expect(type.weekday.fontStyle, FontStyle.italic);
      expect(type.date.fontStyle, FontStyle.normal);
    });

    test('the open chit and the thread speak one dialect', () {
      expect(type.ambientStamp.fontSize, type.chitMeta.fontSize);
      expect(type.ambientStamp.fontWeight, type.chitMeta.fontWeight);
      expect(type.ambientStamp.letterSpacing, type.chitMeta.letterSpacing);
      expect(type.ambientStamp.color, colors.inkMuted);
      expect(type.chitMeta.color, colors.inkFaint);
    });

    test('functional text starts at 11.5px', () {
      for (final TextStyle style in type.styles) {
        expect(style.fontSize, greaterThanOrEqualTo(11.5));
      }
    });

    test('the accent carries words only at its text weight', () {
      for (final TextStyle style in type.styles) {
        expect(style.color, isNot(colors.seal));
      }
    });

    group('a tag is the body text, differing in one way each — §6.4', () {
      test('a person differs by slope, which colour cannot be blamed for', () {
        expect(type.chitPerson.fontStyle, FontStyle.italic);
        expect(type.chitText.fontStyle, FontStyle.normal);

        expect(type.chitPerson.color, type.chitText.color);
        expect(type.chitPerson.fontSize, type.chitText.fontSize);
        expect(type.chitPerson.fontWeight, type.chitText.fontWeight);
      });

      test('a topic differs by colour alone, so its sigil is drawn', () {
        expect(type.chitTopic.color, colors.inkFaint);
        expect(type.chitTopic.color, isNot(type.chitText.color));

        expect(
          type.chitTopic.fontStyle,
          type.chitText.fontStyle,
          reason: 'the # is the second difference — ChitBody draws it',
        );
        expect(type.chitTopic.fontSize, type.chitText.fontSize);
        expect(type.chitTopic.fontWeight, type.chitText.fontWeight);
      });

      test('both sit on the line the body text sits on', () {
        expect(type.chitPerson.height, type.chitText.height);
        expect(type.chitTopic.height, type.chitText.height);
      });
    });
  });
}
