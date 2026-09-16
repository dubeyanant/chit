import 'package:chit/core/theme/chit_colors.dart';
import 'package:chit/core/theme/chit_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// ADR-015, enforced.
///
/// The faces are variable fonts, so a [TextStyle] that sets only `fontWeight`
/// renders at 400 and nothing says so — not the analyzer, not the app, not a
/// screenshot anybody glances at. The whole scale lives in one file precisely
/// so this can be checked in one place.
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

    test('the चित्त mark is the only thing set in Devanagari', () {
      // Two styles, and they are the same mark in the two places
      // BEHAVIOUR.md §4.1 allows it: beside the wordmark, and closing the day
      // at the foot of Today. Nothing else in the app is set in this face.
      final Iterable<TextStyle> deva = type.styles.where(
        (TextStyle s) => s.fontFamily == ChitType.devanagariFamily,
      );
      expect(deva, hasLength(2));
      expect(
        deva,
        unorderedEquals(<TextStyle>[type.devanagariMark, type.closingMark]),
      );
    });

    test('the closing mark is the larger and the quieter of the two', () {
      // It closes the day rather than labelling the app, so it is set at a
      // size you would notice and a strength you would not read — and the
      // prototype marks it `aria-hidden` for the same reason.
      expect(
        type.closingMark.fontSize,
        greaterThan(type.devanagariMark.fontSize!),
      );
      expect(type.closingMark.color!.a, lessThan(type.devanagariMark.color!.a));
    });
  });

  group('DESIGN-SYSTEM.md §6.2, the specifics it commits to', () {
    test('anything that counts or keeps time is set in tabular figures', () {
      final List<TextStyle> counters = <TextStyle>[
        type.ambientStamp,
        type.chitMeta,
        type.sheetTime,
        type.audioDuration,
      ];
      for (final TextStyle style in counters) {
        expect(
          style.fontFeatures,
          contains(const FontFeature.tabularFigures()),
        );
      }
    });

    test('display-to-body is 1.58x', () {
      // v5 ran 2.30x on a 38px date. §6.2: the date is a label, not a
      // masthead, and the biggest thing on a screen should be the thing the
      // screen is for. Measured, not rounded — 26 over 16.5.
      expect(
        type.date.fontSize! / type.chitText.fontSize!,
        closeTo(1.58, 0.01),
      );
    });

    test('the weekday sets as one phrase with the date beside it', () {
      // Not a stacked masthead: same face, same size, same weight. Only the
      // slant and the colour separate them.
      expect(type.weekday.fontSize, type.date.fontSize);
      expect(type.weekday.fontWeight, type.date.fontWeight);
      expect(type.weekday.fontStyle, FontStyle.italic);
      expect(type.date.fontStyle, FontStyle.normal);
    });

    test('the open chit and the thread speak one dialect', () {
      // The stamp on the open chit was 600-weight uppercase at .1em in v5 and
      // the identical facts under a saved chit were not. §6.2: the open chit
      // is distinguished by being brighter, not by being set differently.
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
      // DESIGN-SYSTEM.md §6.1: --seal is for marks, --seal-ink for anything read as
      // text. A style coloured in --seal would be a style below the floor.
      for (final TextStyle style in type.styles) {
        expect(style.color, isNot(colors.seal));
      }
    });
  });
}
