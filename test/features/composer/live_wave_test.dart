import 'package:chitt/features/composer/application/recording_controller.dart';
import 'package:chitt/features/composer/presentation/recording_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

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
      expect(LiveWave.atRest, hasLength(RecordingController.levelWindow));
    });
  });
}
