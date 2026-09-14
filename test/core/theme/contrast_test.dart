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
void main() {
  const ChitColors colors = ChitColors.tokens();
  const double floor = 4.5;

  /// The 7% accent wash behind an audio pill, flattened.
  final Color pillOnSlip = composite(colors.seal, colors.slip, opacity: 0.07);
  final Color pillOnPaper = composite(colors.seal, colors.paper, opacity: 0.07);

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
    });

    test('ChitColors.sealWash agrees with the test arithmetic', () {
      expect(colors.sealWash(colors.slip, opacity: 0.07), pillOnSlip);
    });
  });

  group('the accent has two weights because one of them fails as text', () {
    test('seal falls below the floor on a chit surface', () {
      final double ratio = contrastRatio(colors.seal, colors.slip);
      expect(ratio, lessThan(floor));
      expect(
        ratio,
        closeTo(4.23, 0.01),
        reason: 'DESIGN-SYSTEM.md §6.1 quotes 4.23:1',
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
    // change rather than drifting. The figures below were measured here and
    // written back into DESIGN-SYSTEM.md §6.1 during M0b, which is why they are exact
    // rather than rounded — the file used to say 6.4, 5.0 and 4.24.
    test('ink-muted', () {
      expect(contrastRatio(colors.inkMuted, colors.paper), closeTo(6.49, 0.01));
      expect(contrastRatio(colors.inkMuted, colors.slip), closeTo(6.02, 0.01));
    });

    test('ink-faint, the tightest text token in the palette', () {
      expect(contrastRatio(colors.inkFaint, colors.paper), closeTo(5.08, 0.01));
      expect(contrastRatio(colors.inkFaint, colors.slip), closeTo(4.72, 0.01));
    });
  });

  group('the non-text tokens are still distinguishable', () {
    // Not a WCAG floor — hairlines are structure, not text, and DESIGN-SYSTEM.md §6.3
    // says hairlines carry the structure of the whole app. The floor below is
    // a collapse detector: enough headroom over the measured values (hair on
    // paper 1.26, hair-soft on slip 1.05) to catch a token being tuned until
    // it disappears into the surface it is meant to divide.
    const double visible = 1.03;

    test('a hairline is visible on the surface it divides', () {
      expect(contrastRatio(colors.hair, colors.paper), greaterThan(visible));
      expect(contrastRatio(colors.hair, colors.slip), greaterThan(visible));
      expect(contrastRatio(colors.hairSoft, colors.slip), greaterThan(visible));
    });
  });
}
