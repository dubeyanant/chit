import 'package:flutter/material.dart';

import 'chit_colors.dart';

@immutable
final class ChitType extends ThemeExtension<ChitType> {
  const ChitType({
    required this.wordmark,
    required this.closingMark,
    required this.weekday,
    required this.date,
    required this.timelineLabel,
    required this.timelineNow,
    required this.ambientStamp,
    required this.chitMeta,
    required this.chitText,
    required this.composerBody,
    required this.composerGhost,
    required this.failNote,
    required this.sectionLabel,
    required this.sectionCount,
    required this.emptyNote,
    required this.button,
    required this.audioDuration,
    required this.tabLabel,
    required this.sheetState,
    required this.sheetTime,
    required this.calendarDay,
    required this.calendarWeekday,
    required this.monthSummary,
    required this.monthSummaryStrong,
    required this.dayHeading,
  });

  factory ChitType.tokens(ChitColors colors) {
    return ChitType(
      wordmark: _serif(
        size: 16.5,
        weight: 400,
        color: colors.inkMuted,
        height: 1,
      ),
      closingMark: _deva(
        size: 13,
        color: colors.inkFaint.withValues(alpha: closingMarkStrength),
        height: 1,
      ),

      weekday: _serif(
        size: 26,
        weight: 300,
        color: colors.inkFaint,
        height: 1.15,
        italic: true,
        letterSpacingEm: -0.015,
      ),
      date: _serif(
        size: 26,
        weight: 300,
        color: colors.ink,
        height: 1.15,
        letterSpacingEm: -0.015,
      ),

      timelineLabel: _sans(
        size: 11.5,
        weight: 400,
        color: colors.inkFaint,
        letterSpacingEm: 0.02,
      ),
      timelineNow: _sans(
        size: 11.5,
        weight: 500,
        color: colors.sealInk,
        letterSpacingEm: 0.02,
      ),

      ambientStamp: _sans(
        size: 11.5,
        weight: 500,
        color: colors.inkMuted,
        letterSpacingEm: 0.02,
        tabularFigures: true,
      ),

      chitMeta: _sans(
        size: 11.5,
        weight: 500,
        color: colors.inkFaint,
        letterSpacingEm: 0.02,
        tabularFigures: true,
      ),
      chitText: _serif(size: 16.5, weight: 400, color: colors.ink, height: 1.5),

      composerBody: _serif(
        size: 17.5,
        weight: 400,
        color: colors.ink,
        height: 1.62,
      ),
      composerGhost: _serif(
        size: 17.5,
        weight: 400,
        color: colors.inkFaint,
        height: 1.62,
      ),

      failNote: _serif(
        size: 16.5,
        weight: 400,
        color: colors.inkFaint,
        height: 1.5,
        italic: true,
      ),

      sectionLabel: _serif(
        size: 16.5,
        weight: 400,
        color: colors.inkMuted,
        italic: true,
        letterSpacingEm: 0.01,
      ),
      sectionCount: _sans(
        size: 11.5,
        weight: 400,
        color: colors.inkFaint,
        letterSpacingEm: 0.03,
      ),

      emptyNote: _serif(
        size: 15,
        weight: 400,
        color: colors.inkFaint,
        italic: true,
      ),

      button: _sans(size: 13, weight: 600, letterSpacingEm: 0.04),

      audioDuration: _sans(
        size: 11.5,
        weight: 600,
        color: colors.inkMuted,
        letterSpacingEm: 0.05,
        tabularFigures: true,
      ),

      tabLabel: _serif(size: 16.5, weight: 400, color: colors.inkFaint),

      sheetState: _sans(
        size: 11.5,
        weight: 600,
        color: colors.sealInk,
        letterSpacingEm: 0.12,
      ),
      sheetTime: _serif(
        size: 30,
        weight: 300,
        color: colors.ink,
        letterSpacingEm: -0.01,
        tabularFigures: true,
      ),

      calendarDay: _serif(
        size: 16.5,
        weight: 400,
        color: colors.ink,
        height: 1,
      ),
      calendarWeekday: _sans(
        size: 11.5,
        weight: 500,
        color: colors.inkFaint,
        letterSpacingEm: 0.04,
      ),
      monthSummary: _serif(
        size: 15,
        weight: 400,
        color: colors.inkMuted,
        italic: true,
      ),

      monthSummaryStrong: _serif(
        size: 15,
        weight: 500,
        color: colors.ink,
        tabularFigures: true,
      ),

      dayHeading: _serif(size: 16.5, weight: 400, color: colors.ink, height: 1),
    );
  }

  static const double closingMarkStrength = 0.5;

  static const String serifFamily = 'Newsreader';

  static const String sansFamily = 'Hanken Grotesk';

  static const String devanagariFamily = 'Noto Serif Devanagari';

  static const List<String> _serifFallback = <String>[
    'Georgia',
    'Times New Roman',
  ];
  static const List<String> _sansFallback = <String>['Helvetica Neue', 'Arial'];
  static const List<String> _devanagariFallback = <String>[serifFamily];

  static const double _minOpticalSize = 6;
  static const double _maxOpticalSize = 72;

  static TextStyle _serif({
    required double size,
    required int weight,
    Color? color,
    double? height,
    bool italic = false,
    double letterSpacingEm = 0,
    bool tabularFigures = false,
  }) {
    return TextStyle(
      fontFamily: serifFamily,
      fontFamilyFallback: _serifFallback,
      fontSize: size,
      color: color,
      height: height,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      fontWeight: _weightOf(weight),
      fontVariations: <FontVariation>[
        FontVariation('wght', weight.toDouble()),
        FontVariation('opsz', _opticalSizeFor(size)),
      ],
      letterSpacing: letterSpacingEm == 0 ? null : letterSpacingEm * size,
      fontFeatures: tabularFigures
          ? const <FontFeature>[FontFeature.tabularFigures()]
          : null,
    );
  }

  static TextStyle _sans({
    required double size,
    required int weight,
    Color? color,
    double? height,
    double letterSpacingEm = 0,
    bool tabularFigures = false,
  }) {
    return TextStyle(
      fontFamily: sansFamily,
      fontFamilyFallback: _sansFallback,
      fontSize: size,
      color: color,
      height: height,
      fontWeight: _weightOf(weight),
      fontVariations: <FontVariation>[FontVariation('wght', weight.toDouble())],
      letterSpacing: letterSpacingEm == 0 ? null : letterSpacingEm * size,
      fontFeatures: tabularFigures
          ? const <FontFeature>[FontFeature.tabularFigures()]
          : null,
    );
  }

  static TextStyle _deva({
    required double size,
    Color? color,
    double? height,
    int weight = 400,
  }) {
    return TextStyle(
      fontFamily: devanagariFamily,
      fontFamilyFallback: _devanagariFallback,
      fontSize: size,
      color: color,
      height: height,
      fontWeight: _weightOf(weight),
      fontVariations: <FontVariation>[FontVariation('wght', weight.toDouble())],
    );
  }

  static double _opticalSizeFor(double size) =>
      (size * 0.75).clamp(_minOpticalSize, _maxOpticalSize);

  static FontWeight _weightOf(int weight) =>
      FontWeight.values[(weight ~/ 100 - 1).clamp(
        0,
        FontWeight.values.length - 1,
      )];

  final TextStyle wordmark;

  final TextStyle closingMark;

  final TextStyle weekday;

  final TextStyle date;

  final TextStyle timelineLabel;

  final TextStyle timelineNow;

  final TextStyle ambientStamp;

  final TextStyle chitMeta;

  final TextStyle chitText;

  final TextStyle composerBody;

  final TextStyle composerGhost;

  final TextStyle failNote;

  final TextStyle sectionLabel;

  final TextStyle sectionCount;

  final TextStyle emptyNote;

  final TextStyle button;

  final TextStyle audioDuration;

  final TextStyle tabLabel;

  final TextStyle sheetState;

  final TextStyle sheetTime;

  final TextStyle calendarDay;

  final TextStyle calendarWeekday;

  final TextStyle monthSummary;

  final TextStyle monthSummaryStrong;

  final TextStyle dayHeading;

  Iterable<TextStyle> get styles => <TextStyle>[
    wordmark,
    closingMark,
    weekday,
    date,
    timelineLabel,
    timelineNow,
    ambientStamp,
    chitMeta,
    chitText,
    composerBody,
    composerGhost,
    failNote,
    sectionLabel,
    sectionCount,
    emptyNote,
    button,
    audioDuration,
    tabLabel,
    sheetState,
    sheetTime,
    calendarDay,
    calendarWeekday,
    monthSummary,
    monthSummaryStrong,
    dayHeading,
  ];

  @override
  ChitType copyWith({
    TextStyle? wordmark,
    TextStyle? closingMark,
    TextStyle? weekday,
    TextStyle? date,
    TextStyle? timelineLabel,
    TextStyle? timelineNow,
    TextStyle? ambientStamp,
    TextStyle? chitMeta,
    TextStyle? chitText,
    TextStyle? composerBody,
    TextStyle? composerGhost,
    TextStyle? failNote,
    TextStyle? sectionLabel,
    TextStyle? sectionCount,
    TextStyle? emptyNote,
    TextStyle? button,
    TextStyle? audioDuration,
    TextStyle? tabLabel,
    TextStyle? sheetState,
    TextStyle? sheetTime,
    TextStyle? calendarDay,
    TextStyle? calendarWeekday,
    TextStyle? monthSummary,
    TextStyle? monthSummaryStrong,
    TextStyle? dayHeading,
  }) {
    return ChitType(
      wordmark: wordmark ?? this.wordmark,
      closingMark: closingMark ?? this.closingMark,
      weekday: weekday ?? this.weekday,
      date: date ?? this.date,
      timelineLabel: timelineLabel ?? this.timelineLabel,
      timelineNow: timelineNow ?? this.timelineNow,
      ambientStamp: ambientStamp ?? this.ambientStamp,
      chitMeta: chitMeta ?? this.chitMeta,
      chitText: chitText ?? this.chitText,
      composerBody: composerBody ?? this.composerBody,
      composerGhost: composerGhost ?? this.composerGhost,
      failNote: failNote ?? this.failNote,
      sectionLabel: sectionLabel ?? this.sectionLabel,
      sectionCount: sectionCount ?? this.sectionCount,
      emptyNote: emptyNote ?? this.emptyNote,
      button: button ?? this.button,
      audioDuration: audioDuration ?? this.audioDuration,
      tabLabel: tabLabel ?? this.tabLabel,
      sheetState: sheetState ?? this.sheetState,
      sheetTime: sheetTime ?? this.sheetTime,
      calendarDay: calendarDay ?? this.calendarDay,
      calendarWeekday: calendarWeekday ?? this.calendarWeekday,
      monthSummary: monthSummary ?? this.monthSummary,
      monthSummaryStrong: monthSummaryStrong ?? this.monthSummaryStrong,
      dayHeading: dayHeading ?? this.dayHeading,
    );
  }

  @override
  ChitType lerp(ChitType? other, double t) {
    if (other == null) return this;
    return ChitType(
      wordmark: TextStyle.lerp(wordmark, other.wordmark, t)!,
      closingMark: TextStyle.lerp(closingMark, other.closingMark, t)!,
      weekday: TextStyle.lerp(weekday, other.weekday, t)!,
      date: TextStyle.lerp(date, other.date, t)!,
      timelineLabel: TextStyle.lerp(timelineLabel, other.timelineLabel, t)!,
      timelineNow: TextStyle.lerp(timelineNow, other.timelineNow, t)!,
      ambientStamp: TextStyle.lerp(ambientStamp, other.ambientStamp, t)!,
      chitMeta: TextStyle.lerp(chitMeta, other.chitMeta, t)!,
      chitText: TextStyle.lerp(chitText, other.chitText, t)!,
      composerBody: TextStyle.lerp(composerBody, other.composerBody, t)!,
      composerGhost: TextStyle.lerp(composerGhost, other.composerGhost, t)!,
      failNote: TextStyle.lerp(failNote, other.failNote, t)!,
      sectionLabel: TextStyle.lerp(sectionLabel, other.sectionLabel, t)!,
      sectionCount: TextStyle.lerp(sectionCount, other.sectionCount, t)!,
      emptyNote: TextStyle.lerp(emptyNote, other.emptyNote, t)!,
      button: TextStyle.lerp(button, other.button, t)!,
      audioDuration: TextStyle.lerp(audioDuration, other.audioDuration, t)!,
      tabLabel: TextStyle.lerp(tabLabel, other.tabLabel, t)!,
      sheetState: TextStyle.lerp(sheetState, other.sheetState, t)!,
      sheetTime: TextStyle.lerp(sheetTime, other.sheetTime, t)!,
      calendarDay: TextStyle.lerp(calendarDay, other.calendarDay, t)!,
      calendarWeekday: TextStyle.lerp(
        calendarWeekday,
        other.calendarWeekday,
        t,
      )!,
      monthSummary: TextStyle.lerp(monthSummary, other.monthSummary, t)!,
      monthSummaryStrong: TextStyle.lerp(
        monthSummaryStrong,
        other.monthSummaryStrong,
        t,
      )!,
      dayHeading: TextStyle.lerp(dayHeading, other.dayHeading, t)!,
    );
  }
}
