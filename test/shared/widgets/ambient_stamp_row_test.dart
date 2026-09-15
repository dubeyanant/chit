import 'package:chit/core/theme/chit_colors.dart';
import 'package:chit/core/theme/chit_type.dart';
import 'package:chit/domain/models/ambient_stamp.dart';
import 'package:chit/domain/models/weather_condition.dart';
import 'package:chit/shared/widgets/ambient_stamp_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/pump.dart';

/// BEHAVIOUR.md §3.6's line, and the two rules that are easy to lose.
///
/// **A signal that did not arrive is not drawn** (ADR-007) — not a dash, not
/// "unknown", not a gap. And **the pin is drawn on the open chit only**: every
/// chit carries a location, so a pin under all of them is ten identical marks
/// carrying nothing.
void main() {
  const ChitColors colors = ChitColors.tokens();
  final ChitType type = ChitType.tokens(colors);

  final DateTime at = DateTime(2026, 9, 15, 15, 42);

  const String pin = 'Location noted';

  AmbientStamp stamp({WeatherCondition? weather, bool located = false}) =>
      AmbientStamp(
        capturedAt: at,
        weather: weather,
        lat: located ? 19.07 : null,
        lon: located ? 72.87 : null,
      );

  /// The style the row sets for the facts inside it.
  TextStyle styleIn(WidgetTester tester) => tester
      .widget<DefaultTextStyle>(
        find
            .descendant(
              of: find.byType(AmbientStampRow),
              matching: find.byType(DefaultTextStyle),
            )
            .first,
      )
      .style;

  group('the three facts', () {
    testWidgets('the time is lowercase — §6.2 allows uppercase in one place, '
        'and this is not it', (WidgetTester tester) async {
      await pumpOnPaper(tester, AmbientStampRow.open(stamp: stamp()));

      expect(find.text('3:42 pm'), findsOneWidget);
    });

    testWidgets('the condition is a word, and clear night is two', (
      WidgetTester tester,
    ) async {
      for (final (WeatherCondition condition, String word)
          in <(WeatherCondition, String)>[
            (WeatherCondition.raining, 'raining'),
            (WeatherCondition.clear, 'clear'),
            (WeatherCondition.overcast, 'overcast'),
            (WeatherCondition.windy, 'windy'),
            (WeatherCondition.clearNight, 'clear night'),
          ]) {
        await pumpOnPaper(
          tester,
          AmbientStampRow.open(stamp: stamp(weather: condition)),
        );
        expect(find.text(word), findsOneWidget, reason: condition.name);
      }
    });

    testWidgets('they are spaced apart, not strung on separators', (
      WidgetTester tester,
    ) async {
      // §6.2: three items at 11.5px with a separator between each is five
      // things to read where there are three.
      await pumpOnPaper(
        tester,
        AmbientStampRow.open(
          stamp: stamp(weather: WeatherCondition.raining, located: true),
        ),
      );

      for (final String separator in <String>['·', '•', '—', '|', ',']) {
        expect(find.textContaining(separator), findsNothing);
      }
    });
  });

  group('ADR-007: a signal that did not arrive is not drawn', () {
    testWidgets('no weather means no word, and no space held for one', (
      WidgetTester tester,
    ) async {
      await pumpOnPaper(tester, AmbientStampRow.open(stamp: stamp()));

      expect(find.byType(Text), findsOneWidget);
      expect(find.text('3:42 pm'), findsOneWidget);
    });

    testWidgets('no fix means no pin, even on the open chit', (
      WidgetTester tester,
    ) async {
      await pumpOnPaper(
        tester,
        AmbientStampRow.open(stamp: stamp(weather: WeatherCondition.clear)),
      );

      expect(find.bySemanticsLabel(pin), findsNothing);
    });

    testWidgets('a stamp with nothing but its time still draws its time', (
      WidgetTester tester,
    ) async {
      // The time is the one signal that cannot fail: it comes from the clock.
      await pumpOnPaper(tester, AmbientStampRow.saved(stamp: stamp()));

      expect(find.text('3:42 pm'), findsOneWidget);
    });
  });

  group('§3.6: the pin is drawn on the open chit only', () {
    testWidgets('the open chit carries it', (WidgetTester tester) async {
      await pumpOnPaper(
        tester,
        AmbientStampRow.open(stamp: stamp(located: true)),
      );

      expect(find.bySemanticsLabel(pin), findsOneWidget);
    });

    testWidgets('a saved chit never does, however well located', (
      WidgetTester tester,
    ) async {
      // The location is still captured and still stored (README §5). What
      // stopped was the thread drawing a constant.
      await pumpOnPaper(
        tester,
        AmbientStampRow.saved(stamp: stamp(located: true)),
      );

      expect(find.bySemanticsLabel(pin), findsNothing);
    });
  });

  group('one dialect, two weights', () {
    testWidgets('the open chit is brighter and the thread is quieter', (
      WidgetTester tester,
    ) async {
      await pumpOnPaper(tester, AmbientStampRow.open(stamp: stamp()));
      expect(styleIn(tester).color, colors.inkMuted);

      await pumpOnPaper(tester, AmbientStampRow.saved(stamp: stamp()));
      expect(styleIn(tester).color, colors.inkFaint);
    });

    testWidgets('and that is the only difference in how they speak', (
      WidgetTester tester,
    ) async {
      // Same size, same case, same weight, same tracking — DESIGN-SYSTEM.md
      // §6.2. v5 set the open chit's stamp in uppercase at .1em, which gave
      // the screen two dialects for the same three facts.
      await pumpOnPaper(tester, AmbientStampRow.open(stamp: stamp()));
      final TextStyle open = styleIn(tester);

      await pumpOnPaper(tester, AmbientStampRow.saved(stamp: stamp()));
      final TextStyle saved = styleIn(tester);

      expect(open.fontSize, saved.fontSize);
      expect(open.fontWeight, saved.fontWeight);
      expect(open.letterSpacing, saved.letterSpacing);
      expect(open.fontSize, type.ambientStamp.fontSize);
    });
  });
}
