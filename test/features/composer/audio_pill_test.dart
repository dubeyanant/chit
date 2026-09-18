import 'package:chit/domain/services/audio_player.dart';
import 'package:chit/shared/widgets/audio_pill.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_audio_player.dart';

/// **The pill's arithmetic and the one player's state** — ADR-031.
///
/// Nothing here builds a widget. What is tested is what the pill *computes* —
/// the figure, the playhead — and the rule the player exists for: two pills
/// never sound at once. How it looks is a handset job (TASKS.md group G).
void main() {
  group('the figure on a pill', () {
    test('is minutes and padded seconds', () {
      expect(AudioPill.figureFor(const Duration(seconds: 7)), '0:07');
      expect(AudioPill.figureFor(const Duration(seconds: 22)), '0:22');
      expect(
        AudioPill.figureFor(const Duration(minutes: 2, seconds: 4)),
        '2:04',
      );
    });

    test('rounds down, so it never shows a second that has not passed', () {
      expect(AudioPill.figureFor(const Duration(milliseconds: 1900)), '0:01');
      expect(AudioPill.figureFor(Duration.zero), '0:00');
    });
  });

  group('the playhead', () {
    const Duration take = Duration(seconds: 20);

    test('lights nothing at the start and everything at the end', () {
      expect(AudioPill.barsLitAt(Duration.zero, of: take), 0);
      expect(AudioPill.barsLitAt(take, of: take), AudioPill.wave.length);
    });

    test('lights half the bars halfway through', () {
      expect(
        AudioPill.barsLitAt(const Duration(seconds: 10), of: take),
        AudioPill.wave.length ~/ 2,
      );
    });

    test('does not run past the end when the position overshoots', () {
      // just_audio reports a position a shade past the duration at the end of
      // some files, and a bar index past the list is a crash.
      expect(
        AudioPill.barsLitAt(const Duration(seconds: 25), of: take),
        AudioPill.wave.length,
      );
    });

    test('is nothing at all on a take with no length', () {
      // A row that lost its duration is a division by zero, which is a crash
      // in a thread rather than a missing figure.
      expect(
        AudioPill.barsLitAt(const Duration(seconds: 3), of: Duration.zero),
        0,
      );
    });
  });

  group('one player, so two pills never sound at once', () {
    late FakeAudioPlayer player;

    setUp(() => player = FakeAudioPlayer());
    tearDown(() => player.dispose());

    test('a second pill takes the first one off', () async {
      await player.play(id: 'a', path: 'audio/a.m4a');
      player.advanceTo(const Duration(seconds: 5));
      await player.play(id: 'b', path: 'audio/b.m4a');

      expect(player.now.holds('b'), isTrue);
      expect(player.now.holds('a'), isFalse);
      expect(
        player.now.position,
        Duration.zero,
        reason: 'a pill that was not playing has no playhead',
      );
    });

    test('pausing keeps the playhead, and playing again resumes it', () async {
      await player.play(id: 'a', path: 'audio/a.m4a');
      player.advanceTo(const Duration(seconds: 5));
      await player.pause();

      expect(player.now.playing, isFalse);
      expect(player.now.holds('a'), isTrue, reason: 'still the loaded pill');

      await player.play(id: 'a', path: 'audio/a.m4a');
      expect(player.now.position, const Duration(seconds: 5));
      expect(player.now.playing, isTrue);
    });

    test('a file that has vanished leaves the player silent', () async {
      // ARCHITECTURE.md §6: the chit renders, the pill does nothing, and
      // nothing anywhere throws.
      player.missing.add('audio/gone.m4a');

      await player.play(id: 'gone', path: 'audio/gone.m4a');

      expect(player.now, Playback.silent);
    });

    test('a pill built mid-playback is told what is already sounding', () async {
      // **The bug that made a playing pill unstoppable.** The archive is
      // rebuilt on every tab change, so a pill routinely subscribes long after
      // a recording started; a stream carrying only *changes* left it drawn as
      // though nothing were playing, and its one control became a play button
      // that did nothing.
      await player.play(id: 'a', path: 'audio/a.m4a');

      final Playback firstSeen = await player.playback.first;

      expect(firstSeen.holds('a'), isTrue);
      expect(firstSeen.playing, isTrue);
    });

    test('stopIf silences the pill it names, and only that one', () async {
      // Save moves the open chit's take out of the cache and Discard deletes
      // it; either way the pill goes. A player left running would sound a
      // recording with no control anywhere able to stop it.
      await player.play(id: Playback.openChit, path: 'take-1.m4a');

      await player.stopIf('some-other-chit');
      expect(player.now.holds(Playback.openChit), isTrue, reason: 'not it');

      await player.stopIf(Playback.openChit);
      expect(player.now, Playback.silent);
    });

    test('the end is silence rather than a full playhead', () async {
      await player.play(id: 'a', path: 'audio/a.m4a');
      player.finish();

      expect(player.now, Playback.silent);
      expect(
        player.now.holds('a'),
        isFalse,
        reason: 'the label goes back to the take length, not 0:20 forever',
      );
    });
  });
}
