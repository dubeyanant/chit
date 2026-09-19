import 'dart:ui';

import 'package:chitta/core/theme/chit_colors.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/contrast.dart';

void main() {
  const ChitColors colors = ChitColors.tokens();
  const double floor = 4.5;

  final Color pillOnSlip = colors.inkWash(
    colors.slip,
    opacity: ChitColors.pillWash,
  );
  final Color pillOnPaper = colors.inkWash(
    colors.paper,
    opacity: ChitColors.pillWash,
  );

  final Color save = colors.inkWash(colors.slip, opacity: ChitColors.saveWash);

  final List<Color> densityTiles = <Color>[
    for (final double alpha in ChitColors.densitySteps)
      colors.inkWash(colors.paper, opacity: alpha),
  ];

  group('text clears 4.5:1 on the surface it sits on', () {
    final Map<String, Color> surfaces = <String, Color>{
      'paper': colors.paper,
      'slip': colors.slip,
      'slip-under': colors.slipUnder,
    };

    final Map<String, Color> textColors = <String, Color>{
      'ink': colors.ink,
      'ink-muted': colors.inkMuted,
      'ink-faint': colors.inkFaint,
      'seal-ink': colors.sealInk,
    };

    for (final MapEntry<String, Color> text in textColors.entries) {
      for (final MapEntry<String, Color> surface in surfaces.entries) {
        test('${text.key} on ${surface.key}', () {
          final double ratio = contrastRatio(text.value, surface.value);
          expect(
            ratio,
            greaterThanOrEqualTo(floor),
            reason:
                '${text.key} on ${surface.key} is ${ratio.toStringAsFixed(2)}:1',
          );
        });
      }
    }
  });

  group('the audio pill counts as its own surface', () {
    test('ink-muted clears the floor on the pill', () {
      expect(
        contrastRatio(colors.inkMuted, pillOnSlip),
        greaterThanOrEqualTo(floor),
      );
      expect(
        contrastRatio(colors.inkMuted, pillOnPaper),
        greaterThanOrEqualTo(floor),
      );
    });

    test('ink-faint does not, which is why the duration is not set in it', () {
      expect(contrastRatio(colors.inkFaint, pillOnSlip), lessThan(floor));
      expect(
        contrastRatio(colors.inkFaint, pillOnSlip),
        closeTo(4.17, 0.01),
        reason: 'DESIGN-SYSTEM.md §6.4 quotes 4.17:1',
      );
    });

    test('ChitColors.inkWash agrees with the test arithmetic', () {
      expect(
        colors.inkWash(colors.slip, opacity: ChitColors.pillWash),
        composite(colors.ink, colors.slip, opacity: ChitColors.pillWash),
      );
    });
  });

  group('the recording sheet', () {
    final Color behind = Color.alphaBlend(colors.scrim, colors.paper);

    test('the scrim puts the page beyond reading', () {
      final Color inkBehind = Color.alphaBlend(colors.scrim, colors.ink);

      expect(contrastRatio(inkBehind, behind), lessThan(floor));
      expect(contrastRatio(inkBehind, behind), closeTo(2.07, 0.01));
    });

    test('and the sheet still reads as a surface in front of it', () {
      expect(
        relativeLuminance(colors.slip),
        greaterThan(relativeLuminance(behind)),
      );
    });

    test('LISTENING clears the floor, which is why it is not --seal', () {
      expect(
        contrastRatio(colors.sealInk, colors.slip),
        greaterThanOrEqualTo(floor),
      );
      expect(
        contrastRatio(colors.seal, colors.slip),
        lessThan(floor),
        reason: 'ADR-022: the accent carries marks, never words',
      );
    });

    test('the pending word and the engine note sit on a bare chit', () {
      expect(
        contrastRatio(colors.inkFaint, colors.slip),
        greaterThanOrEqualTo(floor),
      );
    });
  });

  group('the controls at the foot of the open chit', () {
    test('Save carries its label in ink, and clearly', () {
      final double ratio = contrastRatio(colors.ink, save);
      expect(ratio, greaterThanOrEqualTo(floor));
      expect(ratio, closeTo(10.85, 0.01));
    });

    test('its border is visible against the chit it sits on', () {
      expect(contrastRatio(colors.inkMuted, colors.slip), greaterThan(3));
    });
  });

  group('the month grid is legible at every density', () {
    test('a numeral clears the floor on all four steps', () {
      const List<double> expected = <double>[12.66, 10.69, 8.31, 5.99];
      for (int i = 0; i < densityTiles.length; i++) {
        final double ratio = contrastRatio(colors.ink, densityTiles[i]);
        expect(
          ratio,
          greaterThanOrEqualTo(floor),
          reason: 'a numeral on density step ${i + 1}',
        );
        expect(ratio, closeTo(expected[i], 0.01));
      }
    });

    test('the steps are ordered, and none of them collapses into the next', () {
      for (int i = 1; i < densityTiles.length; i++) {
        expect(
          contrastRatio(densityTiles[i], colors.paper),
          greaterThan(contrastRatio(densityTiles[i - 1], colors.paper)),
          reason: 'step ${i + 1} must read as more ink than step $i',
        );
      }
    });

    test("today's ring sits on paper, so it clears its floor every day — "
        'ADR-046', () {
      const double componentFloor = 3;
      final double onPaper = contrastRatio(colors.seal, colors.paper);
      expect(onPaper, greaterThan(componentFloor));
      expect(onPaper, closeTo(4.56, 0.01));
    });

    test('and why it had to move: on the tile it fails from three chits', () {
      const double componentFloor = 3;
      expect(contrastRatio(colors.seal, densityTiles[0]), closeTo(3.97, 0.01));
      expect(contrastRatio(colors.seal, densityTiles[1]), closeTo(3.36, 0.01));
      expect(
        contrastRatio(colors.seal, densityTiles[2]),
        lessThan(componentFloor),
        reason: 'three chits: 2.61:1',
      );
      expect(
        contrastRatio(colors.seal, densityTiles[3]),
        closeTo(1.88, 0.01),
        reason: 'four or more: 1.88:1',
      );
    });
  });

  group('the accent has two weights because one of them fails as text', () {
    test('seal falls below the floor on a chit surface', () {
      final double ratio = contrastRatio(colors.seal, colors.slip);
      expect(ratio, lessThan(floor));
      expect(
        ratio,
        closeTo(4.09, 0.01),
        reason: 'DESIGN-SYSTEM.md §6.1 quotes 4.09:1',
      );
    });

    test('seal-ink clears it on both surfaces, which is the whole point', () {
      expect(
        contrastRatio(colors.sealInk, colors.slip),
        greaterThanOrEqualTo(floor),
      );
      expect(
        contrastRatio(colors.sealInk, colors.paper),
        greaterThanOrEqualTo(floor),
      );
    });
  });

  group('the figures DESIGN-SYSTEM.md §6.1 quotes are still true', () {
    test('ink', () {
      expect(contrastRatio(colors.ink, colors.paper), closeTo(14.54, 0.01));
      expect(contrastRatio(colors.ink, colors.slip), closeTo(13.03, 0.01));
    });

    test('ink-muted', () {
      expect(contrastRatio(colors.inkMuted, colors.paper), closeTo(6.49, 0.01));
      expect(contrastRatio(colors.inkMuted, colors.slip), closeTo(5.82, 0.01));
    });

    test('ink-faint, the tightest text token in the palette', () {
      expect(contrastRatio(colors.inkFaint, colors.paper), closeTo(5.08, 0.01));
      expect(contrastRatio(colors.inkFaint, colors.slip), closeTo(4.56, 0.01));
    });
  });

  group('the non-text tokens are still distinguishable', () {
    const double visible = 1.03;

    test('a hairline is visible on the surface it divides', () {
      expect(contrastRatio(colors.hair, colors.paper), greaterThan(visible));
      expect(contrastRatio(colors.hair, colors.slip), greaterThan(visible));

      expect(
        contrastRatio(colors.hairSoft, colors.paper),
        greaterThan(visible),
      );
    });

    test('a chit reads as a surface, not only as a border', () {
      expect(
        contrastRatio(colors.slip, colors.paper),
        greaterThan(1.1),
        reason: 'v5 measured 1.0778:1 here and v6 measures 1.1153:1',
      );
    });

    test('hair-soft is a paper token, because it collapsed on a chit', () {
      expect(contrastRatio(colors.hairSoft, colors.slip), lessThan(visible));
      expect(
        contrastRatio(colors.hairSoft, colors.paper),
        greaterThan(visible),
      );
    });
  });

  group('the timeline, which is all non-text components on paper', () {
    const double component = 3;

    test('a chit mark is visible as a component, not just as a tint', () {
      expect(
        contrastRatio(colors.inkFaint, colors.paper),
        greaterThan(component),
      );
    });

    test('the tick at now clears the floor it is held to', () {
      expect(contrastRatio(colors.seal, colors.paper), greaterThan(component));
    });

    test('the word "now" is text, and takes the text floor', () {
      expect(contrastRatio(colors.sealInk, colors.paper), greaterThan(4.5));
    });

    test(
      'the accent does NOT out-contrast ink on paper — so shape carries it',
      () {
        expect(
          contrastRatio(colors.seal, colors.paper),
          lessThan(contrastRatio(colors.inkFaint, colors.paper)),
          reason: 'if this ever reverses, the note above is stale — rewrite it',
        );
        expect(contrastRatio(colors.seal, colors.paper), closeTo(4.56, 0.01));
        expect(
          contrastRatio(colors.inkFaint, colors.paper),
          closeTo(5.08, 0.01),
        );
      },
    );

    test('the line is a hairline on paper, and stays drawn', () {
      expect(contrastRatio(colors.hair, colors.paper), greaterThan(1.03));
    });
  });

  group('a disabled control is drawn, and is not available — ADR-088', () {
    test('it is plainly visible, not a ghost', () {
      expect(
        contrastRatio(colors.inkDisabled, colors.paper),
        greaterThan(2),
        reason: 'a chevron nobody can see is the hiding ADR-047 used to do',
      );
    });

    test('and deliberately under the 3:1 floor a live control clears', () {
      expect(
        contrastRatio(colors.inkDisabled, colors.paper),
        lessThan(3),
        reason: 'meeting the floor set for a live control would say it works',
      );
    });

    test('it is quieter than the chevron that does something', () {
      expect(
        contrastRatio(colors.inkDisabled, colors.paper),
        lessThan(contrastRatio(colors.inkFaint, colors.paper)),
      );
    });

    test('and louder than the hairline, which is not a control at all', () {
      expect(
        contrastRatio(colors.inkDisabled, colors.paper),
        greaterThan(contrastRatio(colors.hair, colors.paper)),
      );
    });
  });

  group('the map is a surface, and it is measured like one', () {
    final Map<String, double> washes = <String, double>{
      'map-line': ChitColors.mapLine,
      'map-water': ChitColors.mapWater,
      'map-fill': ChitColors.mapFill,
      'map-host': ChitColors.mapHost,
    };

    for (final MapEntry<String, double> wash in washes.entries) {
      final Color surface = colors.inkWash(colors.paper, opacity: wash.value);

      test('the column clears the floor on ${wash.key}', () {
        final double ratio = contrastRatio(colors.ink, surface);
        expect(
          ratio,
          greaterThanOrEqualTo(floor),
          reason: 'filterWord on ${wash.key} is ${ratio.toStringAsFixed(2)}:1',
        );
      });

      test('the quote clears the floor on ${wash.key}', () {
        final double ratio = contrastRatio(colors.inkMuted, surface);
        expect(
          ratio,
          greaterThanOrEqualTo(floor),
          reason: 'the quote on ${wash.key} is ${ratio.toStringAsFixed(2)}:1',
        );
      });
    }

    test('map-host is the ceiling, and nothing on the map is brighter', () {
      expect(
        washes.values.reduce((double a, double b) => a > b ? a : b),
        ChitColors.mapHost,
      );
    });

    test('the quote could not have stayed --ink-faint', () {
      expect(
        contrastRatio(
          colors.inkFaint,
          colors.inkWash(colors.paper, opacity: ChitColors.mapHost),
        ),
        lessThan(floor),
      );
    });

    test('the pin clears the 3:1 a non-text mark is held to', () {
      expect(
        contrastRatio(
          colors.inkWash(colors.paper, opacity: ChitColors.mapPin),
          colors.paper,
        ),
        greaterThanOrEqualTo(3),
      );
    });
  });
}
