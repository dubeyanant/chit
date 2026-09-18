import 'package:chitta/data/dev/frame_log.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('what a span of frames says', () {
    test('an empty span claims nothing', () {
      expect(FrameLog.span(<int>[]), (
        frames: 0,
        janky: 0,
        p50: 0,
        p90: 0,
        worst: 0,
      ));
    });

    test('janky counts frames over the 16.7ms budget, and only those', () {
      final int budget = FrameLog.budget.inMicroseconds;

      expect(
        FrameLog.span(<int>[budget - 1, budget, budget + 1]).janky,
        1,
        reason: 'a frame exactly on budget made it',
      );
    });

    test('the percentiles do not depend on the order they arrived in', () {
      final List<int> rising = <int>[for (int i = 1; i <= 100; i++) i * 1000];
      final List<int> shuffled = <int>[...rising.reversed];

      expect(FrameLog.span(shuffled), FrameLog.span(rising));
      expect(
        FrameLog.span(rising).p50,
        51000,
        reason: 'nearest rank, which rounds up on an even count',
      );
      expect(FrameLog.span(rising).p90, 90000);
      expect(FrameLog.span(rising).worst, 100000);
    });

    test('one frame is its own every percentile', () {
      final FrameSpan span = FrameLog.span(<int>[4200]);
      expect(<int>[span.p50, span.p90, span.worst], everyElement(4200));
    });

    test('memory is read in megabytes, to one place', () {
      expect(FrameLog.megabytes(0), '0.0MB');
      expect(FrameLog.megabytes(1024 * 1024), '1.0MB');
      expect(FrameLog.megabytes(157 * 1024 * 1024 + 512 * 1024), '157.5MB');
    });

    test('reading a span never sorts the list it was handed', () {
      final List<int> given = <int>[9, 1, 5];
      FrameLog.span(given);
      expect(given, <int>[9, 1, 5]);
    });
  });
}
