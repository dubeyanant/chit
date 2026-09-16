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
  /// Some decisions turn on *when* the clock is read rather than on what it
  /// says, and a value assertion cannot see the difference — two reads a
  /// second apart both look like plausible times. ADR-033's midnight rollover
  /// is the live example: Today must re-read the clock, and counting is the
  /// only way to know that it did.
  int get reads => _reads;

  @override
  DateTime now() {
    _reads++;
    return _now;
  }

  /// Moves the clock to [when].
  void moveTo(DateTime when) => _now = when;
}
