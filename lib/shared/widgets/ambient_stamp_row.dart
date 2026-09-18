import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/extensions.dart';
import '../../domain/ambient/ambient_fact.dart';
import '../../domain/models/ambient_stamp.dart';
import '../../domain/models/motion_state.dart';
import '../../domain/models/weather_condition.dart';
import 'motion_icon.dart';

/// Time and one ambient fact, set as a stamp — BEHAVIOUR.md §3.6.
///
/// **No pin** (ADR-066). *It carried one on the open chit until 18 September
/// 2026*; the owner found a mark on every chit jarring, and a mark that is
/// never absent says nothing. Location is still captured and stored exactly
/// as before — README §5 — it is just not drawn.
///
/// One line, lowercase, **spaced apart with no separators**. Three items at
/// 11.5px strung on middle dots is five things to read where there are three.
///
/// **Three items is also the ceiling, which is why weather and motion share a
/// slot** (ADR-038). Motion was a fourth signal and it did not get a fourth
/// place on the row: `AmbientFact.of` ranks the two and one of them is drawn.
/// The ordinary chit is unchanged by that — a chit written at a desk in the
/// rain still reads `raining`, because an icon only ever appears by displacing
/// a word, and only when the phone was moving.
///
/// The same words, the same case and the same size wherever it appears. The
/// open chit differs from a saved one only in being *brighter*
/// (`--ink-muted` against `--ink-faint`) — it does not speak a second dialect. v5 shouted the open chit's stamp in 11.5px
/// uppercase at `.1em` and murmured the same three facts under every chit
/// below it; DESIGN-SYSTEM.md §6.2 has the argument.
///
/// **A signal that did not arrive is not drawn** (ADR-007). Weather, location
/// and motion are best-effort and never block, so a null is simply absent —
/// not a dash, not "unknown", and not a gap where a word would have been.
final class AmbientStampRow extends StatelessWidget {
  /// The stamp on the chit being written. Brighter, and nothing else.
  const AmbientStampRow.open({required this.stamp, super.key})
    : lifted = false,
      _onOpenChit = true;

  /// The stamp under a chit in the thread. Quieter, and it carries motion
  /// (ADR-039).
  ///
  /// **Motion is drawn because it is rare**: almost no chit has one, so the
  /// two you wrote on a train stand out from the ten you wrote at home. The
  /// pin failed the same test the other way — every chit has a location, so a
  /// mark on all of them distinguished nothing — and is gone (ADR-066).
  ///
  /// **[lifted] is the pressed state of the row it sits in** — ADR-061. A
  /// chit row is a button since M6, and its 6% wash drops `--ink-faint` to
  /// 4.42:1, under §6.4's floor. So while the row is held the stamp goes to
  /// `--ink-muted` (5.65:1). It is exactly the rule §6.1 already states for
  /// the quiet button's label, applied to the second place faint ink meets a
  /// wash, and `contrast_test.dart` holds both figures.
  const AmbientStampRow.saved({
    required this.stamp,
    this.lifted = false,
    super.key,
  }) : _onOpenChit = false;

  /// What was captured when the chit was opened.
  final AmbientStamp stamp;

  /// Whether the row this stamp sits in is being held. Always false on the
  /// open chit, which is not a button.
  final bool lifted;

  /// Which of the two the row is. Private, and set by the constructors.
  final bool _onOpenChit;

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    final space = context.space;

    return DefaultTextStyle(
      style: _onOpenChit
          ? type.ambientStamp
          : lifted
          ? type.chitMeta.copyWith(color: context.colors.inkMuted)
          : type.chitMeta,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // The prototype spaces these 11px apart. `s3` is the step, and a gap
          // is a relationship — DESIGN-SYSTEM.md §6.3 keeps every one of those
          // on the scale. Between the facts and nowhere else: a separator is
          // what §3.6 refuses, and so is a space standing in for one.
          for (final (int index, Widget fact) in _facts(
            context,
          ).indexed) ...<Widget>[
            if (index > 0) SizedBox(width: space.s3),
            fact,
          ],
        ],
      ),
    );
  }

  /// The facts this stamp actually has, in order. Never a placeholder.
  List<Widget> _facts(BuildContext context) {
    final AmbientFact? fact = AmbientFact.of(stamp);

    return <Widget>[
      Text(_timeOf(stamp.capturedAt)),
      // **One ambient slot, ranked** — ADR-038. Weather and motion share it,
      // and `AmbientFact.of` decides which. Exhaustive with no `default:`, so
      // a new kind of fact arrives as a compile error rather than as a blank
      // on a chit (CLAUDE.md §4.1).
      if (fact != null)
        switch (fact) {
          WeatherFact(:final WeatherCondition condition) => Text(
            condition.word,
          ),
          // The icon takes the row's own colour: it is standing in for the
          // word it displaced, so it weighs what that weighed.
          MotionFact(:final MotionState state) => MotionIcon(
            state: state,
            colour: _onOpenChit || lifted
                ? context.colors.inkMuted
                : context.colors.inkFaint,
            size: context.space.s3,
          ),
        },
    ];
  }

  /// `3:42 pm` — lowercase, and in the tabular figures the style carries.
  ///
  /// Lowercased rather than formatted lowercase because `intl` has no pattern
  /// for it. §6.2 allows uppercase in exactly one place and this is not it.
  static String _timeOf(DateTime at) =>
      DateFormat('h:mm a').format(at).toLowerCase();
}

/// The word BEHAVIOUR.md §3.6 shows for each condition.
///
/// Presentation, not domain: the enum is the fact and this is how it is said.
/// The switch is exhaustive with no `default:`, so a sixth condition arrives
/// as a compile error rather than as a blank on a chit — CLAUDE.md §4.1.
extension on WeatherCondition {
  String get word => switch (this) {
    WeatherCondition.raining => 'raining',
    WeatherCondition.clear => 'clear',
    WeatherCondition.overcast => 'overcast',
    WeatherCondition.windy => 'windy',
    WeatherCondition.clearNight => 'clear night',
  };
}
