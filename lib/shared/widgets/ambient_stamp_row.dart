import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/extensions.dart';
import '../../domain/ambient/ambient_fact.dart';
import '../../domain/models/ambient_stamp.dart';
import '../../domain/models/motion_state.dart';
import '../../domain/models/weather_condition.dart';
import 'motion_icon.dart';

/// Time, one ambient fact and the pin, set as a stamp — BEHAVIOUR.md §3.6.
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
/// (`--ink-muted` against `--ink-faint`) and in carrying the pin — it does not
/// speak a second dialect. v5 shouted the open chit's stamp in 11.5px
/// uppercase at `.1em` and murmured the same three facts under every chit
/// below it; DESIGN-SYSTEM.md §6.2 has the argument.
///
/// **A signal that did not arrive is not drawn** (ADR-007). Weather, location
/// and motion are best-effort and never block, so a null is simply absent —
/// not a dash, not "unknown", and not a gap where a word would have been.
final class AmbientStampRow extends StatelessWidget {
  /// The stamp on the chit being written. Brighter, and the one place the pin
  /// is drawn.
  const AmbientStampRow.open({required this.stamp, super.key})
    : _onOpenChit = true;

  /// The stamp under a chit in the thread. Quieter, and never pinned —
  /// though it does carry motion (ADR-039).
  ///
  /// Every chit carries a location, so a pin on all of them distinguishes
  /// nothing — it is ten identical marks down a screen, each carrying no
  /// information because none of them could ever be absent. *v5 drew it under
  /// every chit.* **Motion is the opposite case and so it is drawn here**:
  /// almost no chit has one, so the two you wrote on a train stand out from
  /// the ten you wrote at home. Same argument, opposite outcome.
  const AmbientStampRow.saved({required this.stamp, super.key})
    : _onOpenChit = false;

  /// What was captured when the chit was opened.
  final AmbientStamp stamp;

  /// Which of the two the row is. Private, and set by the constructors, so
  /// there is no way to ask for a pinned row in the thread.
  final bool _onOpenChit;

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    final space = context.space;

    return DefaultTextStyle(
      style: _onOpenChit ? type.ambientStamp : type.chitMeta,
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
          // The icon takes the row's own colour, not the pin's: it is standing
          // in for the word it displaced, so it weighs what that weighed.
          MotionFact(:final MotionState state) => MotionIcon(
            state: state,
            colour: _onOpenChit
                ? context.colors.inkMuted
                : context.colors.inkFaint,
            size: context.space.s3,
          ),
        },
      // §3.6: the pin says a place was recorded and stops there — never a
      // name, never a coordinate, never a map. And only on the open chit,
      // where it means something present tense: *this is being noted, now.*
      if (_onOpenChit && stamp.hasLocation)
        _Pin(colour: context.colors.inkFaint, size: context.space.s3),
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

/// The location marker: a pin, drawn rather than written.
class _Pin extends StatelessWidget {
  const _Pin({required this.colour, required this.size});

  /// The path the prototype's SVG draws, in its own 14-unit box.
  static const double _viewBox = 14;

  /// The stroke the icon set holds, in those same units. At 12px it draws at
  /// about 1.22px, which is what every other icon in the app measures.
  static const double _strokeInViewBox = 1.42;

  final Color colour;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Location noted',
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _PinPainter(
            colour: colour,
            strokeWidth: _strokeInViewBox * size / _viewBox,
          ),
        ),
      ),
    );
  }
}

/// Draws the pin of `_Pin`, scaled from the prototype's 14-unit box.
class _PinPainter extends CustomPainter {
  const _PinPainter({required this.colour, required this.strokeWidth});

  final Color colour;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / _Pin._viewBox;
    final Paint paint = Paint()
      ..color = colour
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth / scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas
      ..save()
      ..scale(scale);

    // M7 12.6 s4.4-4 4.4-7 A4.4 4.4 0 0 0 2.6 5.6 c0 3 4.4 7 4.4 7 Z
    final Path teardrop = Path()
      ..moveTo(7, 12.6)
      ..cubicTo(7, 12.6, 11.4, 8.6, 11.4, 5.6)
      ..arcToPoint(
        const Offset(2.6, 5.6),
        radius: const Radius.circular(4.4),
        clockwise: false,
      )
      ..cubicTo(2.6, 8.6, 7, 12.6, 7, 12.6)
      ..close();

    canvas
      ..drawPath(teardrop, paint)
      ..drawCircle(const Offset(7, 5.5), 1.5, paint)
      ..restore();
  }

  @override
  bool shouldRepaint(_PinPainter oldDelegate) =>
      oldDelegate.colour != colour || oldDelegate.strokeWidth != strokeWidth;
}
