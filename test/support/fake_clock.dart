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

  @override
  DateTime now() => _now;

  /// Moves the clock to [when].
  void moveTo(DateTime when) => _now = when;

  /// Moves the clock forward by [by].
  void advance(Duration by) => _now = _now.add(by);
}
