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

  /// The scale of DESIGN-SYSTEM.md §6.2, coloured from [colors].
  ///
  /// Display-to-body runs about 1.6× — [date] at 26px over [chitText] at
  /// 16.5px. Anything that counts or keeps time is set in tabular figures,
  /// because a running timer whose digits change width reads as unstable and a
  /// column of times that does not align reads as careless.
  factory ChitType.tokens(ChitColors colors) {
    return ChitType(
      // The masthead. Serif for the word, Devanagari for the mark beside it.
      wordmark: _serif(
        size: 16.5,
        weight: 400,
        color: colors.inkMuted,
        height: 1,
      ),
      devanagariMark: _deva(size: 11.5, color: colors.inkFaint, height: 1),

      // The same mark again, closing the day at the foot of Today and nowhere
      // else (BEHAVIOUR.md §4.1). Larger than the one beside the wordmark and
      // drawn at half strength: it is a full stop rather than a label, and
      // the prototype marks it `aria-hidden`, so §6.4's 4.5:1 floor for
      // *functional* text does not reach it.
      closingMark: _deva(
        size: 13,
        color: colors.inkFaint.withValues(alpha: closingMarkStrength),
        height: 1,
      ),

      // The date, above the day arc — one line, not a stacked masthead. The
      // weekday is the same size and weight as the date beside it and differs
      // only in being italic and faint, so the two set as one phrase.
      // DESIGN-SYSTEM.md §6.2: the date is a label, not the subject.
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

      // The timeline: its labels, and the cap over the ring at now. The cap
      // carries a word, so it is the accent's text weight rather than its mark
      // weight — DESIGN-SYSTEM.md §6.1.
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

      // The ambient stamp on the open chit. The same words, size and case as
      // [chitMeta] under a saved chit — the open chit is distinguished by
      // being brighter, not by speaking a second dialect (DESIGN-SYSTEM.md
      // §6.2). It was 600-weight uppercase at .1em in v5, which shouted the
      // same three facts the thread below murmured.
      ambientStamp: _sans(
        size: 11.5,
        weight: 500,
        color: colors.inkMuted,
        letterSpacingEm: 0.02,
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
      // 17.5px rather than v5's 19px: a line inside the slip held about 34
      // characters at 19 and lands near 40 here, which is where a serif starts
      // reading as a page instead of a column.
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

      // The line beside a refused microphone. Set beside the body, never
      // written into it, which is why it is a style of its own rather than
      // [composerGhost].
      failNote: _serif(
        size: 16.5,
        weight: 400,
        color: colors.inkFaint,
        height: 1.5,
        italic: true,
      ),

      // "earlier ——————— 2 chits". Lowercase serif italic with a hairline
      // running off to the right.
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

      // "Nothing written yet today." — where the thread would be. Quieter
      // than the section label above it and smaller than the chit text it
      // stands in for, because an empty day should look empty
      // (BEHAVIOUR.md §4.1). 15px is the one size in the scale below 16.5
      // that is not metadata, and it is deliberate: the note is prose, and
      // prose that is not a chit should not be set at a chit's size.
      emptyNote: _serif(
        size: 15,
        weight: 400,
        color: colors.inkFaint,
        italic: true,
      ),

      // Both button weights. Colour belongs to the button, not to the label,
      // so this style carries none.
      button: _sans(size: 13, weight: 600, letterSpacingEm: 0.04),

      // The audio pill's duration. Set in inkMuted rather than inkFaint
      // because even ChitColors.pillWash — 3.5% of ink — lifts the ground
      // under it enough to drop inkFaint to 4.17:1, below the floor.
      // DESIGN-SYSTEM.md §6.4, and the contrast test proves it both ways.
      audioDuration: _sans(
        size: 11.5,
        weight: 600,
        color: colors.inkMuted,
        letterSpacingEm: 0.05,
        tabularFigures: true,
      ),

      tabLabel: _serif(size: 16.5, weight: 400, color: colors.inkFaint),

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

      // The calendar. The numeral is [ink] on every density step and never
      // flips to a lighter colour — ADR-022 is what made that possible.
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
      // "22 chits", the upright half of the summary. It carries a count, so
      // it is set in tabular figures like everything else that counts.
      monthSummaryStrong: _serif(
        size: 15,
        weight: 500,
        color: colors.ink,
        tabularFigures: true,
      ),

      // "Tuesday 15 September" over a day in the archive. The same size as
      // chit text and the section label — one of the 16.5px places §6.2
      // names — set upright in `--ink` because it is a heading and not an
      // aside.
      dayHeading: _serif(size: 16.5, weight: 400, color: colors.ink, height: 1),
    );
  }

  /// How much of `--ink-faint` the closing mark is drawn at.
  ///
  /// Half. It is the only place in the app a token is used at part strength,
  /// and it is here because the mark is punctuation rather than text: a full
  /// stop on the day, drawn at the size of a word. At full strength and 13px
  /// it becomes something to read.
  static const double closingMarkStrength = 0.5;

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

  /// "चित्त", closing the day at the foot of Today.
  final TextStyle closingMark;

  /// "Sunday", the italic half of the one date line. Same size and weight as
  /// [date]; only the slant and the colour differ.
  final TextStyle weekday;

  /// "13 September", the other half. A label, not a masthead — §6.2.
  final TextStyle date;

  /// The timeline's labels — whatever ends up marking where one day stops and
  /// the next begins (ADR-024 leaves that to the screen; TASKS.md group H).
  ///
  /// It carried "5 am" and "midnight" when the timeline was a one-day arc.
  final TextStyle timelineLabel;

  /// "now", capping the ring on the timeline.
  final TextStyle timelineNow;

  /// "3:42 pm   raining   ⌖" on the open chit. Lowercase, spaced apart, no
  /// separators — and the only place the pin is drawn (BEHAVIOUR.md §3.6).
  final TextStyle ambientStamp;

  /// "11:20 am   overcast" under a chit in the thread. The same line as
  /// [ambientStamp] in a quieter ink, and without the pin.
  final TextStyle chitMeta;

  /// What a saved chit says.
  final TextStyle chitText;

  /// The open chit's field.
  final TextStyle composerBody;

  /// The prompt that waits five seconds over the empty field.
  final TextStyle composerGhost;

  /// "The microphone isn't allowed..." beside the action row.
  final TextStyle failNote;

  /// "earlier", and the other section labels.
  final TextStyle sectionLabel;

  /// "2 chits", beside a section label.
  final TextStyle sectionCount;

  /// "Nothing written yet today.", standing where the thread would be.
  ///
  /// The calendar's "Nothing written that day." is the same line in the same
  /// voice, which is why this is a style of its own rather than
  /// [monthSummary] borrowed at a different colour: they are the same
  /// situation and they change together.
  final TextStyle emptyNote;

  /// Save chit, Remove, Discard, Stop & keep. Carries no colour.
  final TextStyle button;

  /// "0:22" on an audio pill.
  final TextStyle audioDuration;

  /// "Today" and "Calendar" in the tab bar.
  final TextStyle tabLabel;

  /// "LISTENING" on the recording sheet.
  final TextStyle sheetState;

  /// The recording clock.
  final TextStyle sheetTime;

  /// A numeral in the month grid.
  final TextStyle calendarDay;

  /// "M T W T F S S" over the month grid.
  final TextStyle calendarWeekday;

  /// "over eleven days" — the italic half of the month summary.
  final TextStyle monthSummary;

  /// "22 chits" — the upright half, and *Nothing written* on an empty month.
  final TextStyle monthSummaryStrong;

  /// "Tuesday 15 September", heading a day in the archive.
  final TextStyle dayHeading;

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
    TextStyle? devanagariMark,
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
      devanagariMark: devanagariMark ?? this.devanagariMark,
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
      devanagariMark: TextStyle.lerp(devanagariMark, other.devanagariMark, t)!,
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
