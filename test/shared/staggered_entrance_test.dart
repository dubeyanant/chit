import 'package:chit/core/theme/chit_motion.dart';
import 'package:chit/shared/widgets/staggered_entrance.dart';
import 'package:flutter_test/flutter_test.dart';

/// **The arithmetic of the entrance, without building one** — ADR-031.
///
/// What a stagger *looks* like is a handset's to say. What it
/// can be held to here is when each block starts, when the whole thing is
/// over, and that DESIGN-SYSTEM.md §6.4's rule reaches it: under reduced
/// motion the page arrives at once and goes nowhere.
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
      // A day with thirty chits in it is the case this protects: without a
      // cap the last block would arrive a second and a half after the first,
      // which is not an entrance, it is a queue.
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
      // The calendar mounts before its month answers. A run sized off an empty
      // list would shed itself before the content it was meant to carry.
      expect(StaggeredEntrance.totalFor(0, motion: motion), Duration.zero);
    });
  });

  group('under reduced motion', () {
    test('the page arrives all at once', () {
      expect(reduced.stagger(), Duration.zero);
      expect(StaggeredEntrance.delayFor(5, motion: reduced), Duration.zero);
    });

    test('and still arrives — a fade, at the reduced arrival', () {
      // §6.4: movement collapses, feedback does not. A page that skipped its
      // fade under reduced motion would pop rather than arrive.
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
