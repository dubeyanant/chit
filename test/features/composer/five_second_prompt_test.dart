import 'package:chit/features/composer/application/composer_controller.dart';
import 'package:chit/features/composer/presentation/open_chit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app.dart';

/// The five-second prompt — BEHAVIOUR.md §3.3, ARCHITECTURE.md §4.3.
///
/// *"A prompt shown immediately is an instruction. A prompt shown after a
/// pause is an offer."* Everything here is timing, and every claim in it fails
/// quietly: a prompt that arrives at once is still a prompt, a timer that
/// restarts on every rebuild still fires eventually, and a prompt written into
/// the field still looks right until somebody saves it.
void main() {
  final Finder prompt = find.byKey(OpenChit.prompt);
  const Duration idle = ComposerController.idle;

  /// The prompt's live opacity.
  ///
  /// It is drawn at zero rather than left out of the tree — which is what lets
  /// it fade — so it is **in the tree before it is offered**. Presence is not
  /// the question here; opacity is. It is found by key rather than by its
  /// words, because ADR-029 means the words depend on the stamp.
  double opacity(WidgetTester tester) => tester
      .widget<FadeTransition>(
        find.ancestor(of: prompt, matching: find.byType(FadeTransition)).first,
      )
      .opacity
      .value;

  /// Types a character and takes it away again, which starts the five seconds
  /// over (§3.3). Costs no time at all, so whatever follows measures from
  /// exactly here.
  Future<void> armed(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField), 'x');
    await tester.enterText(find.byType(TextField), '');
    await tester.pump();
  }

  /// The platform asking for less animation, for the length of one test.
  void reduceMotion(WidgetTester tester) {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }

  group('§3.3: it waits', () {
    testWidgets('nothing is offered while the five seconds run', (
      WidgetTester tester,
    ) async {
      await pumpChitApp(tester);
      await armed(tester);

      await tester.pump(idle - const Duration(milliseconds: 1));

      expect(opacity(tester), 0);
    });

    testWidgets('and then it is', (WidgetTester tester) async {
      await pumpChitApp(tester);
      await armed(tester);

      await tester.pump(idle);
      await tester.pumpAndSettle();

      expect(opacity(tester), 1);
    });

    testWidgets('it arrives over 700ms — the slowest thing in the app', (
      WidgetTester tester,
    ) async {
      // §6.3 gives the prompt a pace of its own and the reason is in §3.3: a
      // prompt that snaps in is an instruction however politely it is worded.
      await pumpChitApp(tester);
      await armed(tester);

      await tester.pump(idle);
      await tester.pump(const Duration(milliseconds: 350));

      expect(opacity(tester), greaterThan(0));
      expect(opacity(tester), lessThan(1));

      await tester.pump(const Duration(milliseconds: 350));
      expect(opacity(tester), 1);
    });
  });

  group('§3.3: typing dismisses it, emptying the field starts it again', () {
    testWidgets('the first character takes the whole overlay with it', (
      WidgetTester tester,
    ) async {
      await pumpChitApp(tester);
      await armed(tester);
      await tester.pump(idle);
      await tester.pumpAndSettle();
      expect(opacity(tester), 1);

      await tester.enterText(find.byType(TextField), 'R');
      await tester.pump();

      // Not a fade-out: the prototype hides the ghost outright once the page
      // holds something, because what it was standing in for is now there.
      expect(prompt, findsNothing);
    });

    testWidgets('clearing the field starts the five seconds again', (
      WidgetTester tester,
    ) async {
      await pumpChitApp(tester);
      await tester.enterText(find.byType(TextField), 'Reorg meeting.');
      await tester.pump(idle * 2);

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      expect(opacity(tester), 0, reason: 'it does not come straight back');

      await tester.pump(idle);
      await tester.pumpAndSettle();

      expect(opacity(tester), 1);
    });

    testWidgets('and so does Discard, because that is a new chit', (
      WidgetTester tester,
    ) async {
      // ADR-026: Discard opens a chit rather than blanking one, and a chit
      // that has just opened has been idle for no time at all.
      await pumpChitApp(tester);
      await tester.enterText(find.byType(TextField), 'Nothing worth keeping.');
      await tester.pump(idle * 2);

      await tester.tap(find.text('Discard'));
      await tester.pump();
      expect(opacity(tester), 0);

      await tester.pump(idle);
      await tester.pumpAndSettle();

      expect(opacity(tester), 1);
    });
  });

  group('ARCHITECTURE.md §4.3: the timer belongs to the controller', () {
    testWidgets('a rebuild does not put the five seconds back', (
      WidgetTester tester,
    ) async {
      // Focusing the field rebuilds it — the keyboard arrives and the layout
      // moves. A timer held in the widget would go back to five seconds
      // there, and the difference is invisible: the prompt still arrives,
      // just later, every time the keyboard opens or the action row grows by
      // two controls.
      await pumpChitApp(tester);

      await tester.pump(const Duration(seconds: 4));
      expect(opacity(tester), 0);

      await tester.tap(find.byType(TextField));
      await tester.pump();

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(opacity(tester), 1);
    });
  });

  group('it is an overlay, and never the chit content', () {
    testWidgets('the field is not given a hint', (WidgetTester tester) async {
      // ARCHITECTURE.md §4.1 names placeholder text as the tempting shortcut
      // here, and §3.5's failure note lands in this same overlay in M5 for the
      // same reason: what the machine writes never goes into the field.
      await pumpChitApp(tester);
      final InputDecoration? decoration = tester
          .widget<TextField>(find.byType(TextField))
          .decoration;

      expect(decoration?.hintText, isNull);
      expect(decoration?.hint, isNull);
    });

    testWidgets('and it sets on the line the field would write on', (
      WidgetTester tester,
    ) async {
      // The whole reason an overlay is allowed to stand in for placeholder
      // text is that it is indistinguishable from one — a prompt half a line
      // off is a second column of text, and the first character typed would
      // jump. It is the field's own type at the field's own first line.
      await pumpChitApp(tester);
      await armed(tester);
      await tester.pump(idle);
      await tester.pumpAndSettle();

      expect(
        tester.getTopLeft(prompt).dy,
        tester.getTopLeft(find.byType(EditableText)).dy,
      );
    });

    testWidgets('an offered prompt is still nothing to save', (
      WidgetTester tester,
    ) async {
      await pumpChitApp(tester);
      await armed(tester);
      await tester.pump(idle);
      await tester.pumpAndSettle();

      expect(opacity(tester), 1);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expect(find.text('Save chit'), findsNothing);
    });
  });

  group('ADR-028: the only caret is the platform\'s', () {
    testWidgets('an opened app draws none of its own', (
      WidgetTester tester,
    ) async {
      // The page opens blank and stays blank. Nothing blinks at the user
      // before they have asked for anything, and the framework's caret
      // arrives on the tap that asks — which is the caret every other field
      // on the device has.
      await pumpChitApp(tester);

      expect(find.byType(EditableText), findsOneWidget);
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText))
            .focusNode
            .hasFocus,
        isFalse,
      );
      expect(
        tester.binding.transientCallbackCount,
        0,
        reason: 'nothing is animating on an untouched page',
      );
    });

    testWidgets('and one tap brings it', (WidgetTester tester) async {
      await pumpChitApp(tester);

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      final EditableTextState editable = tester.state<EditableTextState>(
        find.byType(EditableText),
      );
      expect(editable.widget.showCursor, isTrue);
      expect(editable.widget.focusNode.hasFocus, isTrue);
    });
  });

  group('§6.4: the prompt survives reduced motion', () {
    testWidgets('it still arrives, and it arrives at 140ms', (
      WidgetTester tester,
    ) async {
      // The appearance is the whole event here rather than decoration on one,
      // so it is a fade and not travel — collapsing it would delete the
      // behaviour rather than calm it (ARCHITECTURE.md §4.3).
      reduceMotion(tester);
      await pumpChitApp(tester);
      await armed(tester);

      await tester.pump(idle);
      await tester.pump(const Duration(milliseconds: 200));

      expect(opacity(tester), 1);
    });

    testWidgets('and 140ms is the re-timing, not the ordinary pace', (
      WidgetTester tester,
    ) async {
      await pumpChitApp(tester);
      await armed(tester);

      await tester.pump(idle);
      await tester.pump(const Duration(milliseconds: 200));

      expect(
        opacity(tester),
        lessThan(1),
        reason: 'at full motion 200ms is well short of the 700ms it takes',
      );
    });
  });
}
