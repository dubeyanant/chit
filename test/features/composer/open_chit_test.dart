import 'package:chit/core/theme/chit_colors.dart';
import 'package:chit/domain/models/ambient_stamp.dart';
import 'package:chit/domain/models/chit.dart';
import 'package:chit/domain/models/composer_state.dart';
import 'package:chit/domain/models/weather_condition.dart';
import 'package:chit/domain/services/location_service.dart';
import 'package:chit/domain/services/weather_service.dart';
import 'package:chit/features/composer/presentation/open_chit.dart';
import 'package:chit/shared/widgets/ambient_stamp_row.dart';
import 'package:chit/shared/widgets/slip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app.dart';
import '../../support/fake_clock.dart';

/// The open chit — BEHAVIOUR.md §3.1, §3.2 and §4.1.
///
/// Four claims are worth a test here and each of them fails silently:
/// `canSave` decides what the foot of the slip shows; the field does **not**
/// take focus (ADR-023); the stamp is captured **once** (ADR-021); and the
/// microphone is drawn without being marked up as a control, because it is not
/// one until M5 and §6.4 does not allow one that does nothing.
void main() {
  const ChitColors colors = ChitColors.tokens();
  final DateTime openedAt = DateTime(2026, 9, 16, 15, 42);

  /// Today, with the clock stopped at [openedAt].
  Future<FakeClock> pumpToday(
    WidgetTester tester, {
    WeatherService weather = const FakeWeather(WeatherCondition.raining),
    LocationService location = const FakeLocation((lat: 51.4769, lon: -0.0005)),
  }) => pumpChitApp(tester, at: openedAt, weather: weather, location: location);

  Future<void> type(WidgetTester tester, String words) async {
    await tester.enterText(find.byType(TextField), words);
    await tester.pumpAndSettle();
  }

  group('the open chit is on Today, on a slip', () {
    testWidgets('one slip, with the stamp, the field and the row on it', (
      WidgetTester tester,
    ) async {
      await pumpToday(tester);

      expect(find.byType(OpenChit), findsOneWidget);
      expect(
        find.descendant(of: find.byType(OpenChit), matching: find.byType(Slip)),
        findsOneWidget,
      );
      expect(find.byType(AmbientStampRow), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('the stamp is the open chit\'s, so it carries the pin', (
      WidgetTester tester,
    ) async {
      // §3.6: the pin is drawn on the open chit only. This is the first screen
      // that could have got that wrong by reaching for the wrong constructor.
      await pumpToday(tester);

      expect(find.text('3:42 pm'), findsOneWidget);
      expect(find.text('raining'), findsOneWidget);
      expect(find.bySemanticsLabel('Location noted'), findsOneWidget);
    });

    testWidgets('a signal that did not arrive is not drawn', (
      WidgetTester tester,
    ) async {
      // ADR-007 end to end: the services answer nothing, and the row is one
      // fact long rather than carrying a placeholder.
      await pumpToday(
        tester,
        weather: const FakeWeather(null),
        location: const FakeLocation(null),
      );

      expect(find.text('3:42 pm'), findsOneWidget);
      expect(find.bySemanticsLabel('Location noted'), findsNothing);
    });
  });

  group('§3.1: an untouched chit shows neither control', () {
    testWidgets('nothing to save and nothing to discard', (
      WidgetTester tester,
    ) async {
      await pumpToday(tester);

      expect(find.text('Save chit'), findsNothing);
      expect(find.text('Discard'), findsNothing);
    });

    testWidgets('both arrive on the first character', (
      WidgetTester tester,
    ) async {
      await pumpToday(tester);
      await type(tester, 'R');

      expect(find.text('Save chit'), findsOneWidget);
      expect(find.text('Discard'), findsOneWidget);
    });

    testWidgets('whitespace is nothing', (WidgetTester tester) async {
      // A field holding three spaces is an empty field, and README §5's
      // invariant would refuse the row anyway — better to refuse to offer the
      // button than to offer one that throws.
      await pumpToday(tester);
      await type(tester, '   ');

      expect(find.text('Save chit'), findsNothing);
    });

    testWidgets('and they leave again when the field is emptied', (
      WidgetTester tester,
    ) async {
      await pumpToday(tester);
      await type(tester, 'Reorg meeting pushed again.');
      expect(find.text('Save chit'), findsOneWidget);

      await type(tester, '');

      expect(find.text('Save chit'), findsNothing);
      expect(find.text('Discard'), findsNothing);
    });
  });

  group('ADR-023: the field is live, but it does not take focus', () {
    testWidgets('a launched app has no focused editable', (
      WidgetTester tester,
    ) async {
      // Taken literally, §3.2 raises the keyboard on every launch, which
      // covers the thread, the timeline and half the open chit. One line, and
      // a test rather than a comment because autofocus is the obvious thing
      // for the next person to add.
      await pumpToday(tester);

      expect(
        tester.widget<TextField>(find.byType(TextField)).autofocus,
        isFalse,
      );
      expect(
        tester.testTextInput.isVisible,
        isFalse,
        reason: 'no keyboard came up on its own',
      );
    });

    testWidgets('and one tap puts the caret in it', (
      WidgetTester tester,
    ) async {
      // What §3.2 is actually about — no mode to choose — is intact. What is
      // gone is one tap, not a decision.
      await pumpToday(tester);
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(tester.testTextInput.isVisible, isTrue);
    });
  });

  group('ADR-021: the stamp is captured once, when the chit opens', () {
    testWidgets('typing does not re-stamp it', (WidgetTester tester) async {
      // The stamp becomes the chit's createdAt, so re-reading the clock while
      // somebody types would file the chit at the moment they stopped rather
      // than the moment they started. It would still look like a plausible
      // time, which is why this counts reads instead of comparing values.
      final FakeClock clock = await pumpToday(tester);
      final int atOpen = clock.reads;

      await type(tester, 'Didn\'t sleep. Room too cold, again.');

      expect(clock.reads, atOpen);
      expect(find.text('3:42 pm'), findsOneWidget);
    });

    testWidgets('the clock is read once for a chit, not once per signal', (
      WidgetTester tester,
    ) async {
      final FakeClock clock = await pumpToday(tester);

      expect(clock.reads, 1);
    });
  });

  group('§3.1: Discard returns the open chit to its empty state', () {
    testWidgets('the page is empty again and both controls go', (
      WidgetTester tester,
    ) async {
      await pumpToday(tester);
      await type(tester, 'Third time this week.');

      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      expect(find.text('Save chit'), findsNothing);
      expect(find.text('Discard'), findsNothing);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
        reason: 'the field itself was cleared, not just the state behind it',
      );
    });

    testWidgets('ADR-026: what is left is a new chit, stamped now', (
      WidgetTester tester,
    ) async {
      // Discarding at 3:42 and writing at 4:10 must not file the chit at 3:42.
      final FakeClock clock = await pumpToday(tester);
      await type(tester, 'Nothing worth keeping.');

      clock.moveTo(DateTime(2026, 9, 16, 16, 10));
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      expect(find.text('4:10 pm'), findsOneWidget);
      expect(find.text('3:42 pm'), findsNothing);
    });
  });

  group('the action row', () {
    testWidgets('the microphone leads it at 54px, and does not shrink', (
      WidgetTester tester,
    ) async {
      // §6.4: ≥44px with no exceptions. §3.2: what keeps the microphone an
      // equal is that its target does not shrink when text appears — which is
      // exactly the thing a row that has to make space for two new controls
      // would do if nobody stopped it.
      await pumpToday(tester);
      final Finder mic = find.byKey(OpenChit.microphone);

      expect(tester.getSize(mic), const Size(54, 54));
      expect(
        tester.getTopLeft(mic).dx,
        lessThan(tester.getTopLeft(find.byType(Slip)).dx + 54),
        reason: 'it leads the row — §4.1: the way in, then what to do with it',
      );

      await type(tester, 'Something.');

      expect(tester.getSize(mic), const Size(54, 54));
    });

    testWidgets('it is not marked up as a control, because it is not one yet', (
      WidgetTester tester,
    ) async {
      // M5 gives it an action, a label and a pressed wash together. Until
      // then §6.4 applies exactly as it did to the settings gear: a control
      // that does nothing is not marked up as a control.
      await pumpToday(tester);

      expect(find.bySemanticsLabel('Record'), findsNothing);
    });

    testWidgets('Discard washes and lifts its label while it is held', (
      WidgetTester tester,
    ) async {
      // Decision 4 of group A. Under reduced motion, where the depress is
      // gone (§6.4), this wash is the only acknowledgement the press makes —
      // and the label has to lift with it, because --ink-faint falls under
      // the contrast floor on any wash at all.
      await pumpToday(tester);
      await type(tester, 'Held.');

      Color? labelColour() =>
          tester.widget<Text>(find.text('Discard')).style?.color;
      expect(labelColour(), colors.inkFaint);

      final TestGesture press = await tester.startGesture(
        tester.getCenter(find.text('Discard')),
      );
      // The slip is inside a scroll view, so the tap has to win the arena
      // against a vertical drag before `onTapDown` fires. A bare `pump()`
      // lands before that and sees nothing.
      await tester.pump(const Duration(milliseconds: 150));

      expect(labelColour(), colors.ink);

      await press.up();
      await tester.pumpAndSettle();
    });

    testWidgets('every control on the slip clears §6.4\'s 44px', (
      WidgetTester tester,
    ) async {
      await pumpToday(tester);
      await type(tester, 'Measured.');

      for (final String label in <String>['Discard', 'Save chit']) {
        final Size size = tester.getSize(
          find
              .ancestor(of: find.text(label), matching: find.byType(Padding))
              .first,
        );
        expect(
          size.height,
          greaterThanOrEqualTo(44),
          reason: '$label is ${size.height}px tall',
        );
      }
    });
  });

  group('the state behind it', () {
    test('canSave is the whole of §3.1', () {
      final AmbientStamp stamp = AmbientStamp(capturedAt: openedAt);

      expect(ComposerState(stamp: stamp).canSave, isFalse);
      expect(ComposerState(stamp: stamp, text: '  ').canSave, isFalse);
      expect(ComposerState(stamp: stamp, text: 'a').canSave, isTrue);
      expect(
        ComposerState(stamp: stamp, audioTempPath: '/tmp/a.m4a').canSave,
        isTrue,
        reason: 'a recording with nothing written is §3.5, and it is savable',
      );
    });

    test('words get a provenance, and lose it when they go', () {
      // README §5 pairs text with textOrigin: a chit with no words has no
      // provenance for them, and the invariant refuses one without the other.
      final ComposerState empty = ComposerState(
        stamp: AmbientStamp(capturedAt: openedAt),
      );

      expect(empty.textOrigin, isNull);
      expect(
        empty.copyWith(text: 'a', textOrigin: TextOrigin.typed).textOrigin,
        TextOrigin.typed,
      );
    });
  });
}
