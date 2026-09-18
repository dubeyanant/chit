import 'package:flutter/scheduler.dart';

typedef FrameSpan = ({int frames, int janky, int p50, int p90, int worst});

final class FrameLog {
  FrameLog({required this.report, this.every = _every});

  static const Duration budget = Duration(microseconds: 16667);

  static const int _every = 120;

  final void Function(String line) report;

  final int every;

  final List<int> _build = <int>[];
  final List<int> _raster = <int>[];

  void watch() => SchedulerBinding.instance.addTimingsCallback(_record);

  void _record(List<FrameTiming> timings) {
    for (final FrameTiming timing in timings) {
      _build.add(timing.buildDuration.inMicroseconds);
      _raster.add(timing.rasterDuration.inMicroseconds);
    }
    if (_build.length < every) return;

    report(
      'chit frames: build ${line(span(_build))} · '
      'raster ${line(span(_raster))}',
    );
    _build.clear();
    _raster.clear();
  }

  static FrameSpan span(List<int> micros) {
    if (micros.isEmpty) {
      return (frames: 0, janky: 0, p50: 0, p90: 0, worst: 0);
    }

    final List<int> sorted = <int>[...micros]..sort();
    return (
      frames: sorted.length,
      janky: sorted.where((int at) => at > budget.inMicroseconds).length,
      p50: _percentile(sorted, 50),
      p90: _percentile(sorted, 90),
      worst: sorted.last,
    );
  }

  static String line(FrameSpan span) =>
      '${span.frames} frames, ${span.janky} over budget, '
      'p50 ${_ms(span.p50)} p90 ${_ms(span.p90)} worst ${_ms(span.worst)}';

  static int _percentile(List<int> sorted, int at) {
    final int index = ((at / 100) * (sorted.length - 1)).round();
    return sorted[index.clamp(0, sorted.length - 1)];
  }

  static String _ms(int micros) => '${(micros / 1000).toStringAsFixed(1)}ms';
}
