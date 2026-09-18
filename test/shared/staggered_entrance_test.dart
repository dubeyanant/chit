import 'package:chitta/core/theme/chit_motion.dart';
import 'package:chitta/shared/widgets/staggered_entrance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ChitMotion motion = ChitMotion.tokens();
  final ChitMotion reduced = motion.resolve(reduceMotion: true);

  group('when each block starts', () {
    test('the first one starts at once', () {
      expect(StaggeredEntrance.delayFor(0, motion: motion), Duration.zero);
    });

    test('each one after it waits a step longer — §6.3', () {
      expect(
        StaggeredEntrance.delayFor(1, motion: motion),
        ChitMotion.staggerStep,
      );
      expect(
        StaggeredEntrance.delayFor(3, motion: motion),
        ChitMotion.staggerStep * 3,
      );
    });

    test('the wait stops growing at the cap', () {
      final Duration atCap = StaggeredEntrance.delayFor(
        StaggeredEntrance.cap,
        motion: motion,
      );

      expect(atCap, ChitMotion.staggerStep * StaggeredEntrance.cap);
      expect(StaggeredEntrance.delayFor(40, motion: motion), atCap);
    });
  });

  group('how long the whole entrance runs', () {
    test('one block is one arrival and nothing else', () {
      expect(
        StaggeredEntrance.totalFor(1, motion: motion),
        motion.fade(ChitPace.arrival),
      );
    });

    test('it is the last block\'s start plus its own arrival', () {
      expect(
        StaggeredEntrance.totalFor(4, motion: motion),
        ChitMotion.staggerStep * 3 + motion.fade(ChitPace.arrival),
      );
    });

    test('nothing to show takes no time at all', () {
      expect(StaggeredEntrance.totalFor(0, motion: motion), Duration.zero);
    });
  });

  group('under reduced motion', () {
    test('the page arrives all at once', () {
      expect(reduced.stagger(), Duration.zero);
      expect(StaggeredEntrance.delayFor(5, motion: reduced), Duration.zero);
    });

    test('and still arrives — a fade, at the reduced arrival', () {
      expect(
        StaggeredEntrance.totalFor(6, motion: reduced),
        reduced.fade(ChitPace.arrival),
      );
      expect(
        StaggeredEntrance.totalFor(6, motion: reduced).inMilliseconds,
        220,
      );
    });
  });

  test('a block rises 6px, as §6.3 sets it', () {
    expect(StaggeredEntrance.rise, 6);
  });
}
