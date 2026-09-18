import 'package:chit/data/speech/on_device_speech_recognizer.dart';
import 'package:chit/domain/services/speech_recognizer.dart';
import 'package:flutter_test/flutter_test.dart';

/// The one rule the recogniser holds without a platform — ADR-053.
///
/// The plugin cannot run here, so what is tested is the split BEHAVIOUR.md
/// §3.4 draws and the emptiness §3.5 turns on. Everything else about voice is
/// a handset job; TASKS.md group G says which.
///
/// *There is no error-code table to walk.* Every error ends the take, so the
/// mapping TASKS.md group B expected to find here does not exist — the reason
/// is on `_onError`.
void main() {
  group('the word still being heard', () {
    test('is the last one of a partial result', () {
      final Transcript t = OnDeviceSpeechRecognizer.transcriptOf(
        'the light is going',
        settled: false,
      );

      expect(t.committed, 'the light is');
      expect(t.pending, 'going');
    });

    test('is the whole of a partial with one word in it', () {
      final Transcript t = OnDeviceSpeechRecognizer.transcriptOf(
        'going',
        settled: false,
      );

      expect(t.committed, isEmpty);
      expect(t.pending, 'going');
    });

    test('is nothing once the result settles', () {
      final Transcript t = OnDeviceSpeechRecognizer.transcriptOf(
        'the light is going',
        settled: true,
      );

      expect(t.committed, 'the light is going');
      expect(t.pending, isEmpty);
    });

    test('survives the whitespace a platform pads a result with', () {
      final Transcript t = OnDeviceSpeechRecognizer.transcriptOf(
        '  the light is   going  ',
        settled: false,
      );

      expect(t.committed, 'the light is');
      expect(t.pending, 'going');
    });
  });

  group('a transcript with nothing in it', () {
    test('is what an empty result maps to, settled or not', () {
      expect(
        OnDeviceSpeechRecognizer.transcriptOf('', settled: false),
        Transcript.nothing,
      );
      expect(
        OnDeviceSpeechRecognizer.transcriptOf('   ', settled: true),
        Transcript.nothing,
      );
    });

    test('is empty, which is the §3.5 branch', () {
      expect(Transcript.nothing.isEmpty, isTrue);
      expect(Transcript.nothing.words, isEmpty);
    });
  });

  group('the words that go into the field', () {
    test('are both halves, because Stop & keep can land mid-revision', () {
      const Transcript t = Transcript(
        committed: 'the light is',
        pending: 'going',
      );

      expect(t.words, 'the light is going');
      expect(t.isEmpty, isFalse);
    });

    test('are the committed ones alone once the result settles', () {
      const Transcript t = Transcript(committed: 'the light is going');

      expect(t.words, 'the light is going');
    });

    test('are the pending one alone at the first word', () {
      const Transcript t = Transcript(pending: 'going');

      expect(t.words, 'going');
    });
  });
}
