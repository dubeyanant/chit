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

  group('the three faces of README §6.2', () {
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
      final Iterable<TextStyle> deva = type.styles.where(
        (TextStyle s) => s.fontFamily == ChitType.devanagariFamily,
      );
      expect(deva, hasLength(1));
      expect(deva.single, type.devanagariMark);
    });
  });

  group('README §6.2, the specifics it commits to', () {
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

    test('display-to-body is about 2.3x', () {
      expect(type.date.fontSize! / type.chitText.fontSize!, closeTo(2.3, 0.02));
    });

    test('functional text starts at 11.5px', () {
      for (final TextStyle style in type.styles) {
        expect(style.fontSize, greaterThanOrEqualTo(11.5));
      }
    });

    test('the accent carries words only at its text weight', () {
      // README §6.1: --seal is for marks, --seal-ink for anything read as
      // text. A style coloured in --seal would be a style below the floor.
      for (final TextStyle style in type.styles) {
        expect(style.color, isNot(colors.seal));
      }
    });
  });
}
