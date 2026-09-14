import 'package:flutter/material.dart';

/// The spacing and shape tokens of README §6.3.
///
/// The step names match the prototype's `--s1` … `--s8` deliberately. Porting a
/// rule out of `design/chit-app-v5.html` should be a rename and nothing more;
/// a second vocabulary here would mean translating every measurement twice and
/// getting one of them wrong.
@immutable
final class ChitSpace extends ThemeExtension<ChitSpace> {
  /// Every step, given explicitly. [ChitSpace.tokens] is the scale.
  const ChitSpace({
    required this.s1,
    required this.s2,
    required this.s3,
    required this.s4,
    required this.s5,
    required this.s6,
    required this.s7,
    required this.s8,
    required this.gutter,
    required this.radius,
    required this.sheetRadius,
    required this.minTouchTarget,
  });

  /// The scale exactly as README §6.3 sets it.
  const ChitSpace.tokens()
    : s1 = 4,
      s2 = 8,
      s3 = 12,
      s4 = 16,
      s5 = 24,
      s6 = 32,
      s7 = 48,
      s8 = 72,
      gutter = 26,
      radius = 2,
      sheetRadius = 14,
      minTouchTarget = 44;

  /// 4px.
  final double s1;

  /// 8px.
  final double s2;

  /// 12px.
  final double s3;

  /// 16px.
  final double s4;

  /// 24px.
  final double s5;

  /// 32px.
  final double s6;

  /// 48px.
  final double s7;

  /// 72px.
  final double s8;

  /// The page gutter, 26px.
  final double gutter;

  /// 2px, almost everywhere. Paper has cut edges.
  final double radius;

  /// 14px — the recording sheet's top corners, the one exception to [radius].
  final double sheetRadius;

  /// 44px. README §6.4: touch targets clear this with no exceptions, and the
  /// microphone's does not shrink when the field has text in it.
  final double minTouchTarget;

  /// Horizontal page padding. The gutter is a page-level decision, so it is
  /// spelled once here rather than at every screen.
  EdgeInsets get pagePadding => EdgeInsets.symmetric(horizontal: gutter);

  @override
  ChitSpace copyWith({
    double? s1,
    double? s2,
    double? s3,
    double? s4,
    double? s5,
    double? s6,
    double? s7,
    double? s8,
    double? gutter,
    double? radius,
    double? sheetRadius,
    double? minTouchTarget,
  }) {
    return ChitSpace(
      s1: s1 ?? this.s1,
      s2: s2 ?? this.s2,
      s3: s3 ?? this.s3,
      s4: s4 ?? this.s4,
      s5: s5 ?? this.s5,
      s6: s6 ?? this.s6,
      s7: s7 ?? this.s7,
      s8: s8 ?? this.s8,
      gutter: gutter ?? this.gutter,
      radius: radius ?? this.radius,
      sheetRadius: sheetRadius ?? this.sheetRadius,
      minTouchTarget: minTouchTarget ?? this.minTouchTarget,
    );
  }

  @override
  ChitSpace lerp(ChitSpace? other, double t) {
    if (other == null) return this;
    return ChitSpace(
      s1: _lerpDouble(s1, other.s1, t),
      s2: _lerpDouble(s2, other.s2, t),
      s3: _lerpDouble(s3, other.s3, t),
      s4: _lerpDouble(s4, other.s4, t),
      s5: _lerpDouble(s5, other.s5, t),
      s6: _lerpDouble(s6, other.s6, t),
      s7: _lerpDouble(s7, other.s7, t),
      s8: _lerpDouble(s8, other.s8, t),
      gutter: _lerpDouble(gutter, other.gutter, t),
      radius: _lerpDouble(radius, other.radius, t),
      sheetRadius: _lerpDouble(sheetRadius, other.sheetRadius, t),
      minTouchTarget: _lerpDouble(minTouchTarget, other.minTouchTarget, t),
    );
  }

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
