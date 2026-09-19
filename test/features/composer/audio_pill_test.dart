import 'package:chitt/domain/services/audio_player.dart';
import 'package:chitt/shared/widgets/audio_pill.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_audio_player.dart';

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
      expect(
        AudioPill.barsLitAt(const Duration(seconds: 25), of: take),
        AudioPill.wave.length,
      );
    });

    test('is nothing at all on a take with no length', () {
      expect(
        AudioPill.barsLitAt(const Duration(seconds: 3), of: Duration.zero),
        0,
      );
    });

    test('falls short of the end when the length is overstated', () {
      const Duration sounded = Duration(milliseconds: 3000);
      const Duration claimed = Duration(milliseconds: 3250);

      expect(
        AudioPill.barsLitAt(sounded, of: claimed),
        lessThan(AudioPill.wave.length),
        reason: 'the recorder used to time the encoder opening as audio',
      );
      expect(AudioPill.barsLitAt(sounded, of: sounded), AudioPill.wave.length);
    });

    test('strands more of a short take than a long one', () {
      const Duration overshoot = Duration(milliseconds: 250);
      int darkAfter(Duration sounded) =>
          AudioPill.wave.length -
          AudioPill.barsLitAt(sounded, of: sounded + overshoot);

      expect(
        darkAfter(const Duration(seconds: 3)),
        greaterThan(darkAfter(const Duration(seconds: 30))),
        reason: 'a fixed overshoot is a larger share of a shorter take',
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
      player.missing.add('audio/gone.m4a');

      await player.play(id: 'gone', path: 'audio/gone.m4a');

      expect(player.now, Playback.silent);
    });

    test(
      'a pill built mid-playback is told what is already sounding',
      () async {
        await player.play(id: 'a', path: 'audio/a.m4a');

        final Playback firstSeen = await player.playback.first;

        expect(firstSeen.holds('a'), isTrue);
        expect(firstSeen.playing, isTrue);
      },
    );

    test('stopIf silences the pill it names, and only that one', () async {
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
