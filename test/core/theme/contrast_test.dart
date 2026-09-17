import 'dart:ui';

import 'package:chit/core/theme/chit_colors.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/contrast.dart';

/// DESIGN-SYSTEM.md §6.4's contrast floor, as a test rather than as an intention.
///
/// Every text colour clears 4.5:1 against the surface it actually sits on,
/// composited. The negative cases are here too, and they matter as much: they
/// are the reason `--seal-ink` exists and the reason the audio pill's duration
/// is set in `--ink-muted`. Lighten `--seal` and the first of them fails,
/// which is the test telling you that the token you just made redundant is
/// still being used.
///
/// Every surface in v6 that is not a flat token is ink at a stated alpha over
/// one that is (ADR-022), so most of this file measures composites. The alphas
/// come from [ChitColors] rather than from literals here — a design value
/// spelled twice is a design value that will disagree with itself.
void main() {
  const ChitColors colors = ChitColors.tokens();
  const double floor = 4.5;

  /// An audio pill at rest, flattened. It sits on a chit in the open composer
  /// and on the ground in the thread, so both are checked.
  final Color pillOnSlip = colors.inkWash(
    colors.slip,
    opacity: ChitColors.pillWash,
  );
  final Color pillOnPaper = colors.inkWash(
    colors.paper,
    opacity: ChitColors.pillWash,
  );

  /// **Save chit**, flattened. It only ever sits on the open chit.
  final Color save = colors.inkWash(colors.slip, opacity: ChitColors.saveWash);

  /// The four density steps of the month grid, faintest first. They sit on the
  /// ground; the calendar has no slip under it.
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
      // 4.17:1. The wash changed from 7% seal to 3.5% ink in v6 and the
      // verdict did not, which is the whole argument for measuring composites
      // rather than reasoning about how faint a background looks.
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

  group('the controls at the foot of the open chit', () {
    test('Save carries its label in ink, and clearly', () {
      // 10.85:1. Save is the brightest of the three and is still a wash and a
      // border rather than a fill — ADR-022. A solid accent bar was what made
      // the microphone beside it look like somebody else's control.
      final double ratio = contrastRatio(colors.ink, save);
      expect(ratio, greaterThanOrEqualTo(floor));
      expect(ratio, closeTo(10.85, 0.01));
    });

    test('its border is visible against the chit it sits on', () {
      // A border is a non-text component, so the floor is 3:1, not 4.5:1.
      expect(contrastRatio(colors.inkMuted, colors.slip), greaterThan(3));
    });
  });

  group('the month grid is legible at every density', () {
    test('a numeral clears the floor on all four steps', () {
      // 12.66, 10.69, 8.31, 5.99. This is what removed the near-white numeral
      // v5 needed over a strong accent fill — and with it, a colour that had
      // no token and no other use (ADR-022).
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
      // A ring is a non-text UI component and needs 3:1. *This test used to
      // assert the failure* — --seal on the three- and four-chit washes
      // measured 2.61:1 and 1.88:1, and PROGRESS.md item 12 carried it for
      // two milestones. ADR-046 moved the ring off the tile: it frames the
      // tile at its edge with a strip of paper inside it, so both edges of
      // the ring meet --paper whatever density today carries, and the only
      // pair that matters is this one.
      const double componentFloor = 3;
      final double onPaper = contrastRatio(colors.seal, colors.paper);
      expect(onPaper, greaterThan(componentFloor));
      expect(onPaper, closeTo(4.56, 0.01));
    });

    test('and why it had to move: on the tile it fails from three chits', () {
      // Kept as the record of the reason, not as a floor anything is held
      // to. If a future design puts the ring back on the wash, these are the
      // numbers it is choosing.
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
    // These lock the prose to the arithmetic in both directions: change a
    // token and the test fails, so DESIGN-SYSTEM.md §6.1 gets corrected in the same
    // change rather than drifting. Every figure against `slip` moved when v6
    // brightened it from #211E1A to #24211C — which is exactly the kind of
    // change that looks local and is not.
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
    // Not a WCAG floor — hairlines are structure, not text, and DESIGN-SYSTEM.md §6.3
    // says hairlines carry the structure of the whole app. The floor below is
    // a collapse detector: enough headroom over the measured values to catch a
    // token being tuned until it disappears into the surface it is meant to
    // divide. It has earned its keep once already — see the last test here.
    const double visible = 1.03;

    test('a hairline is visible on the surface it divides', () {
      // hair rules both grounds: 1.26 on paper, 1.13 on a chit.
      expect(contrastRatio(colors.hair, colors.paper), greaterThan(visible));
      expect(contrastRatio(colors.hair, colors.slip), greaterThan(visible));
      // hair-soft divides on paper only — the archive's day heading. 1.13.
      expect(
        contrastRatio(colors.hairSoft, colors.paper),
        greaterThan(visible),
      );
    });

    test('a chit reads as a surface, not only as a border', () {
      // What v6 brightening --slip was for. The border and the shadow were
      // doing the separating alone at 1.08:1; they now have help.
      expect(
        contrastRatio(colors.slip, colors.paper),
        greaterThan(1.1),
        reason: 'v5 measured 1.0778:1 here and v6 measures 1.1153:1',
      );
    });

    test('hair-soft is a paper token, because it collapsed on a chit', () {
      // The collapse detector fired here when v6 brightened --slip: the pair
      // went 1.0498:1 to 1.0145:1 and the divider stopped being drawn. It was
      // open item 13 and is closed — hair-soft divides on paper now, and the
      // one place that put it on a chit takes an ink wash instead.
      expect(contrastRatio(colors.hairSoft, colors.slip), lessThan(visible));
      expect(
        contrastRatio(colors.hairSoft, colors.paper),
        greaterThan(visible),
      );
    });
  });

  group('the timeline, which is all non-text components on paper', () {
    // M2 group I. Everything the strip draws is a mark, a line or a tick — a
    // non-text UI component, so the floor is 3:1 rather than 4.5:1 — except the
    // word "now", which is text and takes the higher one. §6.4.
    const double component = 3;

    test('a chit mark is visible as a component, not just as a tint', () {
      // --ink-faint carries the marks and the day boundaries. It already has
      // to clear 4.5:1 as text on two surfaces, so this passes with room; it is
      // here so that tuning the token for text cannot quietly take the strip
      // below the component floor on the way.
      expect(
        contrastRatio(colors.inkFaint, colors.paper),
        greaterThan(component),
      );
    });

    test('the tick at now clears the floor it is held to', () {
      // ADR-036: a non-text component in --seal on --paper. The accent fails as
      // *text* on a chit (4.09:1, which is why --seal-ink exists) and that has
      // nothing to say about it as a mark on the ground.
      expect(contrastRatio(colors.seal, colors.paper), greaterThan(component));
    });

    test('the word "now" is text, and takes the text floor', () {
      // Which is why the cap is --seal-ink and the tick under it is --seal.
      // One is read and the other is seen, and §6.1 keeps the two apart.
      expect(contrastRatio(colors.sealInk, colors.paper), greaterThan(4.5));
    });

    test('the accent does NOT out-contrast ink on paper — so shape carries it', () {
      // Found by writing the opposite assertion and watching it fail, which is
      // the M0b pattern paying for itself again.
      //
      // --seal measures 4.56:1 on --paper and --ink-faint measures 5.08:1. The
      // tick at now is, in pure luminance, *quieter* than the chit marks around
      // it. What separates it is hue, and hue alone is exactly what §6.4 will
      // not let a signal rest on.
      //
      // So the tick is **taller and thinner than a mark** (ADR-036), and that
      // is not a stylistic choice — it is the non-colour difference that makes
      // the accent legible as a distinct thing. A future marker that matched a
      // mark's shape and differed only in colour would pass every ratio in this
      // file and still be wrong.
      expect(
        contrastRatio(colors.seal, colors.paper),
        lessThan(contrastRatio(colors.inkFaint, colors.paper)),
        reason: 'if this ever reverses, the note above is stale — rewrite it',
      );
      expect(contrastRatio(colors.seal, colors.paper), closeTo(4.56, 0.01));
      expect(contrastRatio(colors.inkFaint, colors.paper), closeTo(5.08, 0.01));
    });

    test('the line is a hairline on paper, and stays drawn', () {
      // The strip's line is --hair on --paper and doubles as the rule under the
      // date (§4.1), so it is the one structural line on the screen.
      expect(contrastRatio(colors.hair, colors.paper), greaterThan(1.03));
    });
  });

  group('a press shows, even when the movement does not', () {
    // Under reduced motion the 0.985 depress is gone (§6.4), so a pressed
    // wash is the whole acknowledgement. Each of these has to be visible
    // against the surface it lands on.
    const double visible = 1.03;

    test('Discard is pressed in ink, not in the hairline that collapsed', () {
      final Color pressed = colors.inkWash(
        colors.slip,
        opacity: ChitColors.discardPressedWash,
      );
      expect(contrastRatio(pressed, colors.slip), greaterThan(visible));
      expect(contrastRatio(pressed, colors.slip), closeTo(1.17, 0.01));
      // and it is the quietest of the three, as Discard is the quietest
      // control — DESIGN-SYSTEM.md §6.1.
      expect(
        ChitColors.discardPressedWash,
        lessThan(ChitColors.pillPressedWash),
      );
      expect(ChitColors.pillPressedWash, lessThan(ChitColors.micPressedWash));
    });

    test("Discard's label lifts while it is held, because it has to", () {
      // ink-faint clears the floor on a bare chit and fails on any wash at
      // all — 4.12:1 at 4%, and this wash is 6%. The label goes to ink while
      // pressed; the prototype already does that on hover.
      final Color pressed = colors.inkWash(
        colors.slip,
        opacity: ChitColors.discardPressedWash,
      );
      expect(contrastRatio(colors.inkFaint, colors.slip), greaterThan(floor));
      expect(contrastRatio(colors.inkFaint, pressed), lessThan(floor));
      expect(contrastRatio(colors.ink, pressed), greaterThan(floor));
    });
  });
}
