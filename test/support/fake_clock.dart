import 'package:chitta/core/clock.dart';

final class FakeClock implements Clock {
  FakeClock(this._now);

  DateTime _now;
  int _reads = 0;

  int get reads => _reads;

  @override
  DateTime now() {
    _reads++;
    return _now;
  }

  void moveTo(DateTime when) => _now = when;
}
