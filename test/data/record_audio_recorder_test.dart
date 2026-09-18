import 'dart:io';

import 'package:chit/data/audio/record_audio_recorder.dart';
import 'package:chit/domain/services/audio_recorder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('the level the waveform draws', () {
    test('full scale is one and the silence floor is zero', () {
      expect(RecordAudioRecorder.levelOf(0), 1);
      expect(RecordAudioRecorder.levelOf(RecordAudioRecorder.silenceDbfs), 0);
    });

    test('is linear in decibels between the two', () {
      expect(
        RecordAudioRecorder.levelOf(RecordAudioRecorder.silenceDbfs / 2),
        closeTo(0.5, 1e-9),
      );
    });

    test('clamps what the plugin reports past either end', () {
      expect(RecordAudioRecorder.levelOf(-160), 0);
      expect(RecordAudioRecorder.levelOf(12), 1);
    });

    test('reads a non-finite reading as silence', () {
      expect(RecordAudioRecorder.levelOf(double.negativeInfinity), 0);
      expect(RecordAudioRecorder.levelOf(double.nan), 0);
    });
  });

  group('where a take is written', () {
    final Directory temp = Directory(p.join('cache'));
    final DateTime first = DateTime(2026, 9, 17, 9, 30);

    test('is under the temp directory with the extension the store keeps', () {
      final String path = RecordAudioRecorder.tempPathFor(temp, first);

      expect(p.dirname(path), temp.path);
      expect(p.extension(path), '.m4a');
    });

    test('is distinct for two takes a moment apart', () {
      final DateTime second = first.add(const Duration(microseconds: 1));

      expect(
        RecordAudioRecorder.tempPathFor(temp, first),
        isNot(RecordAudioRecorder.tempPathFor(temp, second)),
      );
    });
  });

  group('a recording', () {
    test('cannot have no length', () {
      expect(
        () => Recording(tempPath: 'take.m4a', duration: Duration.zero),
        throwsA(isA<AssertionError>()),
      );
    });

    test('cannot be nowhere', () {
      expect(
        () => Recording(tempPath: '', duration: const Duration(seconds: 3)),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
