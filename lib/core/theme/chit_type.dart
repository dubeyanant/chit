import 'package:flutter/material.dart';

import 'chit_colors.dart';

/// The three faces of DESIGN-SYSTEM.md §6.2, and every style in the app.
///
/// ## The one rule that matters here
///
/// The faces ship as **variable** fonts (ADR-015). A variable font declared
/// once in `pubspec.yaml` renders at weight 400 no matter what `fontWeight` a
/// [TextStyle] asks for — `fontWeight` alone is silently ignored, and nothing
/// in the analyzer will say so. Weight is applied through [FontVariation] on
/// the `wght` axis, and Newsreader's `opsz` axis is set to match the size the
/// text is actually drawn at.
///
/// Both are set by [_serif], [_sans] and [_deva] below, so no style in this
/// file can forget. **That is the entire reason this file exists and the
/// reason CLAUDE.md §4.2 forbids a bare `TextStyle` anywhere else.** A style
/// defined in a widget will look almost right, which is worse than looking
/// wrong.
@immutable
final class ChitType extends ThemeExtension<ChitType> {
  /// Every style, given explicitly. [ChitType.tokens] is the scale.
  const ChitType({
    required this.wordmark,
    required this.devanagariMark,
    required this.weekday,
    required this.date,
    required this.arcEnd,
    required this.arcNow,
    required this.ambientStamp,
    required this.chitMeta,
    required this.chitText,
    required this.composerBody,
    required this.composerGhost,
    required this.failNote,
    required this.sectionLabel,
    required this.sectionCount,
    required this.button,
    required this.audioDuration,
    required this.tabLabel,
    required this.sheetState,
    required this.sheetTime,
    required this.transcript,
    required this.engineNote,
    required this.calendarDay,
    required this.calendarWeekday,
    required this.legend,
    required this.monthSummary,
  });

  /// The scale of DESIGN-SYSTEM.md §6.2, coloured from [colors].
  ///
  /// Display-to-body runs about 2.3× — [date] at 38px over [chitText] at
  /// 16.5px. Anything that counts or keeps time is set in tabular figures,
  /// because a running timer whose digits change width reads as unstable and a
  /// column of times that does not align reads as careless.
  factory ChitType.tokens(ChitColors colors) {
    return ChitType(
      // The masthead. Serif for the word, Devanagari for the mark beside it.
      wordmark: _serif(
        size: 16,
        weight: 400,
        color: colors.inkMuted,
        height: 1,
      ),
      devanagariMark: _deva(size: 11.5, color: colors.inkFaint, height: 1),

      // The date, above the day arc.
      weekday: _serif(
        size: 16,
        weight: 400,
        color: colors.inkFaint,
        italic: true,
        letterSpacingEm: 0.01,
      ),
      date: _serif(
        size: 38,
        weight: 300,
        color: colors.ink,
        height: 1,
        letterSpacingEm: -0.02,
      ),

      // The day arc: its two ends, and the cap over the ring at now. The cap
      // carries a word, so it is the accent's text weight rather than its mark
      // weight — DESIGN-SYSTEM.md §6.1.
      arcEnd: _sans(
        size: 11.5,
        weight: 400,
        color: colors.inkFaint,
        letterSpacingEm: 0.02,
      ),
      arcNow: _sans(
        size: 11.5,
        weight: 500,
        color: colors.sealInk,
        letterSpacingEm: 0.02,
      ),

      // The ambient stamp on the open chit. The one uppercase in the app,
      // because a stamp should look stamped.
      ambientStamp: _sans(
        size: 11.5,
        weight: 600,
        color: colors.inkFaint,
        letterSpacingEm: 0.1,
        tabularFigures: true,
      ),

      // A saved chit in the thread: its stamp row, then its words.
      chitMeta: _sans(
        size: 11.5,
        weight: 500,
        color: colors.inkFaint,
        letterSpacingEm: 0.02,
        tabularFigures: true,
      ),
      chitText: _serif(size: 16.5, weight: 400, color: colors.ink, height: 1.5),

      // The open chit's field, and the prompt that waits five seconds over it.
      composerBody: _serif(
        size: 19,
        weight: 400,
        color: colors.ink,
        height: 1.6,
      ),
      composerGhost: _serif(
        size: 19,
        weight: 400,
        color: colors.inkFaint,
        height: 1.6,
      ),

      // BEHAVIOUR.md §3.5's line. Set beside the body, never written into it, which
      // is why it is a style of its own rather than [composerGhost].
      failNote: _serif(
        size: 17,
        weight: 400,
        color: colors.inkFaint,
        height: 1.5,
        italic: true,
      ),

      // "earlier ——————— 2 chits". Lowercase serif italic with a hairline
      // running off to the right.
      sectionLabel: _serif(
        size: 16,
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

      // Discard and Save. Colour belongs to the button, not to the label, so
      // this style carries none.
      button: _sans(size: 13, weight: 600, letterSpacingEm: 0.04),

      // The audio pill's duration. Set in inkMuted rather than inkFaint
      // because the pill's 7% seal wash lifts the ground under it enough to
      // drop inkFaint below 4.5:1 — DESIGN-SYSTEM.md §6.4, and the contrast test proves
      // it both ways.
      audioDuration: _sans(
        size: 11.5,
        weight: 600,
        color: colors.inkMuted,
        letterSpacingEm: 0.05,
        tabularFigures: true,
      ),

      tabLabel: _serif(size: 16, weight: 400, color: colors.inkFaint),

      // The recording sheet.
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
      transcript: _serif(
        size: 18,
        weight: 400,
        color: colors.ink,
        height: 1.55,
      ),
      engineNote: _sans(
        size: 13,
        weight: 400,
        color: colors.inkFaint,
        height: 1.45,
        letterSpacingEm: 0.01,
      ),

      // The calendar.
      calendarDay: _serif(size: 16, weight: 400, color: colors.ink, height: 1),
      calendarWeekday: _sans(
        size: 11.5,
        weight: 500,
        color: colors.inkFaint,
        letterSpacingEm: 0.04,
      ),
      legend: _sans(
        size: 11.5,
        weight: 400,
        color: colors.inkFaint,
        letterSpacingEm: 0.02,
      ),
      monthSummary: _serif(
        size: 15,
        weight: 400,
        color: colors.inkMuted,
        italic: true,
      ),
    );
  }

  /// Newsreader — the writing voice. Dates, entry text, section labels, tabs.
  static const String serifFamily = 'Newsreader';

  /// Hanken Grotesk — UI metadata, stamps, buttons.
  static const String sansFamily = 'Hanken Grotesk';

  /// Noto Serif Devanagari — the चित्त mark, and nothing else.
  static const String devanagariFamily = 'Noto Serif Devanagari';

  static const List<String> _serifFallback = <String>[
    'Georgia',
    'Times New Roman',
  ];
  static const List<String> _sansFallback = <String>['Helvetica Neue', 'Arial'];
  static const List<String> _devanagariFallback = <String>[serifFamily];

  /// The `opsz` axis Newsreader carries.
  static const double _minOpticalSize = 6;
  static const double _maxOpticalSize = 72;

  /// Newsreader at [size] logical pixels.
  ///
  /// [letterSpacingEm] is in `em`, as the prototype's CSS writes it, and is
  /// converted here — Flutter's `letterSpacing` is in logical pixels, so the
  /// same `em` value means a different number at every size and converting it
  /// by hand at each call site is how a tracking mistake gets in.
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

  /// Hanken Grotesk at [size] logical pixels. No optical-size axis.
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

  /// Noto Serif Devanagari at [size] logical pixels. The चित्त mark only.
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

  /// The `opsz` value for text drawn at [size] logical pixels.
  ///
  /// The axis is specified in points, and a browser with the default
  /// `font-optical-sizing: auto` — which is how the prototype renders — sets
  /// it to the used font size converted to points. One logical pixel is 0.75
  /// point, so that conversion is applied here and clamped to the axis.
  static double _opticalSizeFor(double size) =>
      (size * 0.75).clamp(_minOpticalSize, _maxOpticalSize);

  /// The nearest [FontWeight] to [weight].
  ///
  /// Carried alongside the variation so that fallback faces, accessibility
  /// tooling and any synthetic styling see the intended weight. The variation
  /// is what actually draws.
  static FontWeight _weightOf(int weight) =>
      FontWeight.values[(weight ~/ 100 - 1).clamp(
        0,
        FontWeight.values.length - 1,
      )];

  /// "chit", in the masthead.
  final TextStyle wordmark;

  /// "चित्त", beside it.
  final TextStyle devanagariMark;

  /// "Sunday".
  final TextStyle weekday;

  /// "13 September".
  final TextStyle date;

  /// "5 am" and "midnight", at the ends of the day arc.
  final TextStyle arcEnd;

  /// "now", capping the ring on the day arc.
  final TextStyle arcNow;

  /// "3:42 PM · RAINING · ⌖" on the open chit.
  final TextStyle ambientStamp;

  /// "11:20 am · overcast · ⌖" on a chit in the thread.
  final TextStyle chitMeta;

  /// What a saved chit says.
  final TextStyle chitText;

  /// The open chit's field.
  final TextStyle composerBody;

  /// The prompt that waits five seconds over the empty field.
  final TextStyle composerGhost;

  /// "Speech wasn't recognised. Your recording is kept."
  final TextStyle failNote;

  /// "earlier", and the other section labels.
  final TextStyle sectionLabel;

  /// "2 chits", beside a section label.
  final TextStyle sectionCount;

  /// Discard, Save chit, Stop & keep. Carries no colour.
  final TextStyle button;

  /// "0:22" on an audio pill.
  final TextStyle audioDuration;

  /// "Today" and "Calendar" in the tab bar.
  final TextStyle tabLabel;

  /// "LISTENING" on the recording sheet.
  final TextStyle sheetState;

  /// The recording clock.
  final TextStyle sheetTime;

  /// The transcript accruing on the recording sheet.
  final TextStyle transcript;

  /// The line under the recording sheet's actions.
  final TextStyle engineNote;

  /// A numeral in the month grid.
  final TextStyle calendarDay;

  /// "M T W T F S S" over the month grid.
  final TextStyle calendarWeekday;

  /// "quiet ▪▪▪▪ full".
  final TextStyle legend;

  /// "22 chits over eleven days".
  final TextStyle monthSummary;

  /// Every style in the scale, so the rules that govern all of them can be
  /// checked rather than trusted.
  ///
  /// ADR-015's failure mode is silent — a style that forgets `fontVariations`
  /// renders at weight 400 and nothing complains — so the invariant is only
  /// enforceable if the styles are enumerable.
  /// `test/core/theme/chit_type_test.dart` is what reads this.
  ///
  /// **A new style must be added here.** One that is not is one nothing checks.
  Iterable<TextStyle> get styles => <TextStyle>[
    wordmark,
    devanagariMark,
    weekday,
    date,
    arcEnd,
    arcNow,
    ambientStamp,
    chitMeta,
    chitText,
    composerBody,
    composerGhost,
    failNote,
    sectionLabel,
    sectionCount,
    button,
    audioDuration,
    tabLabel,
    sheetState,
    sheetTime,
    transcript,
    engineNote,
    calendarDay,
    calendarWeekday,
    legend,
    monthSummary,
  ];

  @override
  ChitType copyWith({
    TextStyle? wordmark,
    TextStyle? devanagariMark,
    TextStyle? weekday,
    TextStyle? date,
    TextStyle? arcEnd,
    TextStyle? arcNow,
    TextStyle? ambientStamp,
    TextStyle? chitMeta,
    TextStyle? chitText,
    TextStyle? composerBody,
    TextStyle? composerGhost,
    TextStyle? failNote,
    TextStyle? sectionLabel,
    TextStyle? sectionCount,
    TextStyle? button,
    TextStyle? audioDuration,
    TextStyle? tabLabel,
    TextStyle? sheetState,
    TextStyle? sheetTime,
    TextStyle? transcript,
    TextStyle? engineNote,
    TextStyle? calendarDay,
    TextStyle? calendarWeekday,
    TextStyle? legend,
    TextStyle? monthSummary,
  }) {
    return ChitType(
      wordmark: wordmark ?? this.wordmark,
      devanagariMark: devanagariMark ?? this.devanagariMark,
      weekday: weekday ?? this.weekday,
      date: date ?? this.date,
      arcEnd: arcEnd ?? this.arcEnd,
      arcNow: arcNow ?? this.arcNow,
      ambientStamp: ambientStamp ?? this.ambientStamp,
      chitMeta: chitMeta ?? this.chitMeta,
      chitText: chitText ?? this.chitText,
      composerBody: composerBody ?? this.composerBody,
      composerGhost: composerGhost ?? this.composerGhost,
      failNote: failNote ?? this.failNote,
      sectionLabel: sectionLabel ?? this.sectionLabel,
      sectionCount: sectionCount ?? this.sectionCount,
      button: button ?? this.button,
      audioDuration: audioDuration ?? this.audioDuration,
      tabLabel: tabLabel ?? this.tabLabel,
      sheetState: sheetState ?? this.sheetState,
      sheetTime: sheetTime ?? this.sheetTime,
      transcript: transcript ?? this.transcript,
      engineNote: engineNote ?? this.engineNote,
      calendarDay: calendarDay ?? this.calendarDay,
      calendarWeekday: calendarWeekday ?? this.calendarWeekday,
      legend: legend ?? this.legend,
      monthSummary: monthSummary ?? this.monthSummary,
    );
  }

  @override
  ChitType lerp(ChitType? other, double t) {
    if (other == null) return this;
    return ChitType(
      wordmark: TextStyle.lerp(wordmark, other.wordmark, t)!,
      devanagariMark: TextStyle.lerp(devanagariMark, other.devanagariMark, t)!,
      weekday: TextStyle.lerp(weekday, other.weekday, t)!,
      date: TextStyle.lerp(date, other.date, t)!,
      arcEnd: TextStyle.lerp(arcEnd, other.arcEnd, t)!,
      arcNow: TextStyle.lerp(arcNow, other.arcNow, t)!,
      ambientStamp: TextStyle.lerp(ambientStamp, other.ambientStamp, t)!,
      chitMeta: TextStyle.lerp(chitMeta, other.chitMeta, t)!,
      chitText: TextStyle.lerp(chitText, other.chitText, t)!,
      composerBody: TextStyle.lerp(composerBody, other.composerBody, t)!,
      composerGhost: TextStyle.lerp(composerGhost, other.composerGhost, t)!,
      failNote: TextStyle.lerp(failNote, other.failNote, t)!,
      sectionLabel: TextStyle.lerp(sectionLabel, other.sectionLabel, t)!,
      sectionCount: TextStyle.lerp(sectionCount, other.sectionCount, t)!,
      button: TextStyle.lerp(button, other.button, t)!,
      audioDuration: TextStyle.lerp(audioDuration, other.audioDuration, t)!,
      tabLabel: TextStyle.lerp(tabLabel, other.tabLabel, t)!,
      sheetState: TextStyle.lerp(sheetState, other.sheetState, t)!,
      sheetTime: TextStyle.lerp(sheetTime, other.sheetTime, t)!,
      transcript: TextStyle.lerp(transcript, other.transcript, t)!,
      engineNote: TextStyle.lerp(engineNote, other.engineNote, t)!,
      calendarDay: TextStyle.lerp(calendarDay, other.calendarDay, t)!,
      calendarWeekday: TextStyle.lerp(
        calendarWeekday,
        other.calendarWeekday,
        t,
      )!,
      legend: TextStyle.lerp(legend, other.legend, t)!,
      monthSummary: TextStyle.lerp(monthSummary, other.monthSummary, t)!,
    );
  }
}
