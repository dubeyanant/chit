import 'dart:math' as math;
import 'dart:ui';

/// WCAG 2.x contrast arithmetic.
///
/// Test-only: the app never computes a contrast ratio at runtime, it only has
/// to have been checked. Kept in one place so that every check in the suite
/// uses the same maths.

/// The relative luminance of an opaque [color], per WCAG 2.1.
double relativeLuminance(Color color) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();

  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

/// The contrast ratio between [foreground] and [background], 1.0 to 21.0.
///
/// Both must be opaque. Composite a translucent surface with [composite]
/// first — DESIGN-SYSTEM.md §6.4 is explicit that a translucent surface counts as its
/// own surface, and checking against the colour underneath it is exactly the
/// mistake that caught the audio pill out.
double contrastRatio(Color foreground, Color background) {
  assert(foreground.a == 1.0, 'foreground must be opaque; composite it first');
  assert(background.a == 1.0, 'background must be opaque; composite it first');

  final double a = relativeLuminance(foreground);
  final double b = relativeLuminance(background);
  final double lighter = math.max(a, b);
  final double darker = math.min(a, b);
  return (lighter + 0.05) / (darker + 0.05);
}

/// [over] laid on [under] at [opacity], flattened to an opaque colour.
Color composite(Color over, Color under, {required double opacity}) =>
    Color.alphaBlend(over.withValues(alpha: opacity), under);
