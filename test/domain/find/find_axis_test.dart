import 'package:chitta/domain/ambient/ambient_words.dart';
import 'package:chitta/domain/find/find_axis.dart';
import 'package:chitta/domain/models/motion_state.dart';
import 'package:chitta/domain/models/weather_condition.dart';
import 'package:chitta/domain/tags/chit_tags.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('the four axes', () {
    test('every slug round-trips, which is what a route needs', () {
      for (final FindAxis axis in FindAxis.values) {
        expect(FindAxis.ofSlug(axis.slug), axis);
      }
    });

    test('a slug nobody wrote is null, not a crash', () {
      expect(FindAxis.ofSlug('vibes'), isNull);
      expect(FindAxis.ofSlug(''), isNull);
    });

    test('the ambient two read alphabetically, the tag two by count', () {
      expect(FindAxis.weather.byFrequency, isFalse);
      expect(FindAxis.motion.byFrequency, isFalse);
      expect(FindAxis.people.byFrequency, isTrue);
      expect(FindAxis.topics.byFrequency, isTrue);
    });

    test('each says something when it has nothing to offer', () {
      for (final FindAxis axis in FindAxis.values) {
        expect(axis.empty, isNotEmpty);
        expect(axis.empty.endsWith('.'), isTrue);
      }
    });
  });

  group('a slug is not a word — ADR-088', () {
    test('the ambient axes speak §3.6, not their enum names', () {
      expect(FindAxis.weather.wordOf('clearNight'), 'clear night');
      expect(FindAxis.motion.wordOf('traveling'), 'travelling');
    });

    test('the ones that already agree still come back right', () {
      expect(FindAxis.weather.wordOf('raining'), 'raining');
      expect(FindAxis.motion.wordOf('walking'), 'walking');
    });

    test('a person is its own word; a topic gets its sigil back', () {
      expect(FindAxis.people.wordOf('anant dubey'), 'anant dubey');
      expect(FindAxis.topics.wordOf('morning pages'), '#morning pages');
    });

    test('every value an axis offers draws the word it was offered as', () {
      for (final WeatherCondition it in WeatherCondition.values) {
        expect(FindAxis.weather.wordOf(it.name), it.word);
      }
      for (final MotionState it in MotionState.values) {
        if (it == MotionState.stationary) continue;
        expect(FindAxis.motion.wordOf(it.name), it.word);
      }
    });

    test('a slug nothing knows comes back as itself, not a crash', () {
      expect(FindAxis.weather.wordOf('drizzling'), 'drizzling');
      expect(FindAxis.motion.wordOf('stationary'), 'stationary');
    });
  });

  group('a tag knows which axis it is found on — ADR-086', () {
    test('a person goes to people, a topic to topics', () {
      expect(FindAxis.ofTag(TagKind.person), FindAxis.people);
      expect(FindAxis.ofTag(TagKind.topic), FindAxis.topics);
    });

    test('the slug is what the value route is keyed on', () {
      const TagSpan tag = TagSpan(
        kind: TagKind.person,
        label: 'Anant Dubey',
      );

      expect(tag.slug, 'anant dubey');
      expect(tag.key, 'person:anant dubey');
    });

    test('two spellings reach the same route', () {
      const TagSpan upper = TagSpan(kind: TagKind.person, label: 'Mira');
      const TagSpan lower = TagSpan(kind: TagKind.person, label: 'mira');

      expect(upper.slug, lower.slug);
    });
  });

  group('bottom while it fits, top once it does not — ADR-084', () {
    const double row = 44;

    test('four axes sit at the bottom of any handset', () {
      expect(sitsAtBottom(count: 4, rowHeight: row, height: 600), isTrue);
    });

    test('exactly filling the viewport still sits at the bottom', () {
      expect(sitsAtBottom(count: 10, rowHeight: row, height: 440), isTrue);
    });

    test('one row over and it goes to the top', () {
      expect(sitsAtBottom(count: 11, rowHeight: row, height: 440), isFalse);
    });

    test('a year of tags never sits at the bottom', () {
      expect(sitsAtBottom(count: 200, rowHeight: row, height: 800), isFalse);
    });

    test('nothing at all fits anywhere', () {
      expect(sitsAtBottom(count: 0, rowHeight: row, height: 1), isTrue);
    });

    test('a short handset moves the boundary, which is why it is measured', () {
      expect(sitsAtBottom(count: 12, rowHeight: row, height: 560), isTrue);
      expect(sitsAtBottom(count: 12, rowHeight: row, height: 400), isFalse);
    });
  });
}
