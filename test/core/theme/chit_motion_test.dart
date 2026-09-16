import 'package:chit/core/theme/chit_motion.dart';
import 'package:flutter_test/flutter_test.dart';

/// DESIGN-SYSTEM.md §6.4's reduced-motion rule: **movement collapses and feedback does
/// not.**
///
/// The rule is easy to state and easy to half-implement. Collapsing everything
/// to zero is the tempting shortcut and it is wrong — it deletes the
/// confirmation a user gets that their action landed, which is the one thing
/// reducing motion should never cost them.
void main() {
  const ChitMotion motion = ChitMotion.tokens();
  final ChitMotion reduced = motion.resolve(reduceMotion: true);

  group('the pace table of DESIGN-SYSTEM.md §6.3', () {
    test('is the house pace and the four exceptions to it', () {
      expect(motion.travel(ChitPace.press).inMilliseconds, 90);
      expect(motion.travel(ChitPace.routine).inMilliseconds, 220);
      expect(motion.travel(ChitPace.arrival).inMilliseconds, 400);
      expect(motion.travel(ChitPace.prompt).inMilliseconds, 700);
      expect(motion.travel(ChitPace.exit).inMilliseconds, 140);
    });

    test('exits are quicker than the entrances they undo', () {
      expect(
        motion.travel(ChitPace.exit),
        lessThan(motion.travel(ChitPace.arrival)),
      );
      expect(
        motion.travel(ChitPace.exit),
        lessThan(motion.travel(ChitPace.routine)),
      );
    });

    test('the prompt is the slowest thing in the app, deliberately', () {
      for (final ChitPace pace in ChitPace.values) {
        if (pace == ChitPace.prompt) continue;
        expect(
          motion.travel(pace),
          lessThan(motion.travel(ChitPace.prompt)),
          reason: 'a prompt shown slowly is an offer; $pace should be quicker',
        );
      }
    });
  });

  group('under reduced motion', () {
    test('every kind of movement stops outright', () {
      for (final ChitPace pace in ChitPace.values) {
        expect(
          reduced.travel(pace),
          Duration.zero,
          reason: 'travel, zoom and every ambient loop stop, they do not hurry',
        );
      }
    });

    test('no fade is ever removed', () {
      for (final ChitPace pace in ChitPace.values) {
        expect(
          reduced.fade(pace),
          greaterThan(Duration.zero),
          reason: 'opacity and colour survive — buttons still respond',
        );
      }
    });

    test('an arrival becomes a plain fade going nowhere, at 220ms', () {
      expect(reduced.fade(ChitPace.arrival).inMilliseconds, 220);
      expect(reduced.travel(ChitPace.arrival), Duration.zero);
    });

    test(
      'everything else re-times to 140ms, unless it was already quicker',
      () {
        expect(reduced.fade(ChitPace.routine).inMilliseconds, 140);
        expect(reduced.fade(ChitPace.prompt).inMilliseconds, 140);
        expect(reduced.fade(ChitPace.exit).inMilliseconds, 140);

        // ADR-020. Press feedback is 90ms and stays 90ms: reducing motion must
        // never make the one acknowledgement a finger gets feel slower.
        expect(reduced.fade(ChitPace.press).inMilliseconds, 90);
      },
    );

    test('the five-second prompt still appears, which is the point', () {
      // ARCHITECTURE §4.3: the 700ms appearance is a fade, so it survives.
      // Collapsing it would delete the behaviour rather than calm it.
      expect(reduced.fade(ChitPace.prompt), greaterThan(Duration.zero));
    });

    test('no fade is slower than it was', () {
      for (final ChitPace pace in ChitPace.values) {
        expect(reduced.fade(pace), lessThanOrEqualTo(motion.fade(pace)));
      }
    });
  });

  group('ambient loops', () {
    /// The prototype's pulse at the ring on the timeline — M2 group H, and the
    /// first loop chit will draw now that ADR-028 has taken the caret out.
    const Duration pulseAtNow = Duration(milliseconds: 5200);

    test('run at their own period, which is the component\'s', () {
      expect(motion.loop(pulseAtNow), pulseAtNow);
    });

    test('stop outright under reduced motion, rather than hurrying', () {
      // §6.4 lists them: the pulse at now, the breathing record dot, the live
      // waveform. Zero is the signal to start no ticker at all and draw the
      // thing at rest — *visible*, and still.
      expect(reduced.loop(pulseAtNow), Duration.zero);
    });

    test('are not in the pace table, and could not be', () {
      // A loop has a period; the five paces are how long a transition takes.
      // A 5.2s pulse is longer than the prompt's 700ms and is not a slower
      // piece of motion, which is exactly the comparison the table invites —
      // so it stays out of it. §6.3, ADR-027.
      expect(pulseAtNow, greaterThan(motion.travel(ChitPace.prompt)));
    });
  });

  group('resolve', () {
    test('returns the same instance when the flag already matches', () {
      expect(identical(motion.resolve(reduceMotion: false), motion), isTrue);
      expect(identical(reduced.resolve(reduceMotion: true), reduced), isTrue);
    });

    test('is reversible and carries the curve through', () {
      expect(reduced.resolve(reduceMotion: false).reduceMotion, isFalse);
      expect(reduced.curve, motion.curve);
    });
  });
}
