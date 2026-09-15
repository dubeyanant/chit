import 'package:chit/core/clock.dart';

/// A [Clock] the test moves by hand. ADR-012.
///
/// It is what makes a midnight rollover a thing that gets tested rather than a
/// thing that gets discovered, and it is why nothing in `lib/` is allowed to
/// call `DateTime.now()`.
final class FakeClock implements Clock {
  /// A clock stopped at [_now].
  FakeClock(this._now);

  DateTime _now;
  int _reads = 0;

  /// How many times [now] has been asked since this clock was made.
  ///
  /// ADR-021 turns on *when* the clock is read rather than on what it says: a
  /// chit is stamped when it is opened, so a capture that reads the clock
  /// again after a slow signal comes back would file the chit late. A value
  /// assertion cannot catch that and a count can.
  int get reads => _reads;

  @override
  DateTime now() {
    _reads++;
    return _now;
  }

  /// Moves the clock to [when].
  void moveTo(DateTime when) => _now = when;

  /// Moves the clock forward by [by].
  void advance(Duration by) => _now = _now.add(by);
}
