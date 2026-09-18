import 'package:chit/core/theme/chit_motion.dart';
import 'package:flutter_test/flutter_test.dart';

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

    test('a staggered entrance steps 55ms, inside §6.3\'s 55–60', () {
      expect(motion.stagger().inMilliseconds, inInclusiveRange(55, 60));
      expect(motion.stagger(), ChitMotion.staggerStep);
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

        expect(reduced.fade(ChitPace.press).inMilliseconds, 90);
      },
    );

    test('the five-second prompt still appears, which is the point', () {
      expect(reduced.fade(ChitPace.prompt), greaterThan(Duration.zero));
    });

    test('no fade is slower than it was', () {
      for (final ChitPace pace in ChitPace.values) {
        expect(reduced.fade(pace), lessThanOrEqualTo(motion.fade(pace)));
      }
    });
  });

  group('ambient loops', () {
    const Duration pulseAtNow = Duration(milliseconds: 5200);

    test('run at their own period, which is the component\'s', () {
      expect(motion.loop(pulseAtNow), pulseAtNow);
    });

    test('stop outright under reduced motion, rather than hurrying', () {
      expect(reduced.loop(pulseAtNow), Duration.zero);
    });

    test('are not in the pace table, and could not be', () {
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
