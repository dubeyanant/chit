import 'dart:math' as math;
import 'dart:ui';

double relativeLuminance(Color color) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();

  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

double contrastRatio(Color foreground, Color background) {
  assert(foreground.a == 1.0, 'foreground must be opaque; composite it first');
  assert(background.a == 1.0, 'background must be opaque; composite it first');

  final double a = relativeLuminance(foreground);
  final double b = relativeLuminance(background);
  final double lighter = math.max(a, b);
  final double darker = math.min(a, b);
  return (lighter + 0.05) / (darker + 0.05);
}

Color composite(Color over, Color under, {required double opacity}) =>
    Color.alphaBlend(over.withValues(alpha: opacity), under);
