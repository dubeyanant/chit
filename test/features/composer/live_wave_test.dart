import 'package:chit/features/composer/application/recording_controller.dart';
import 'package:chit/features/composer/presentation/recording_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

/// **The wave is the microphone, not a loop** — ADR-054 as amended.
///
/// The arithmetic is here because it is the one thing about the sheet a test
/// can hold: a bar that does not answer the level is a wave that says *it is
/// hearing you* while hearing nothing. What it looks like moving is a handset
/// job (TASKS.md group G).
void main() {
  const int window = RecordingController.levelWindow;

  group('a bar is its level', () {
    test('silence is the floor and full scale is the whole height', () {
      final List<double> bars = LiveWave.barsFor(<double>[
        0,
        1,
      ], window: window);

      expect(bars[window - 2], LiveWave.floor);
      expect(bars.last, 1);
    });

    test('is linear between the floor and the top', () {
      final List<double> bars = LiveWave.barsFor(<double>[0.5], window: window);

      expect(
        bars.last,
        closeTo(LiveWave.floor + (1 - LiveWave.floor) / 2, 1e-9),
      );
    });

    test(
      'clamps a reading outside 0 to 1 rather than drawing past the box',
      () {
        final List<double> bars = LiveWave.barsFor(<double>[
          -0.2,
          1.4,
        ], window: window);

        expect(bars[window - 2], LiveWave.floor);
        expect(bars.last, 1);
      },
    );
  });

  group('the window', () {
    test('is always full, however few readings have arrived', () {
      // A sheet that has just opened draws a row of ticks, not three bars
      // floating where the wave should be.
      expect(
        LiveWave.barsFor(const <double>[], window: window),
        hasLength(window),
      );
      expect(
        LiveWave.barsFor(<double>[0.4], window: window),
        hasLength(window),
      );
    });

    test('fills from the right, so the newest reading is the last bar', () {
      final List<double> bars = LiveWave.barsFor(<double>[1], window: window);

      expect(bars.last, 1);
      expect(
        bars.take(window - 1),
        everyElement(LiveWave.floor),
        reason: 'nothing was heard before it',
      );
    });

    test('drops the oldest once it is past the window', () {
      final List<double> levels = <double>[
        for (int i = 0; i < window + 5; i++) i / (window + 5),
      ];

      final List<double> bars = LiveWave.barsFor(levels, window: window);

      expect(bars, hasLength(window));
      expect(bars.last, greaterThan(bars.first), reason: 'the tail is newest');
    });

    test('matches the buffer the controller keeps', () {
      // Two windows that disagreed would either starve the wave or make it
      // pad a row it has readings for.
      expect(LiveWave.atRest, hasLength(RecordingController.levelWindow));
    });
  });
}
