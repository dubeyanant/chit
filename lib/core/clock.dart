import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock.g.dart';

/// The current time, as something that can be replaced.
///
/// ADR-012. Three behaviours in the specification are functions of the current
/// and none of them is testable otherwise: what counts as today, where a mark
/// falls on the timeline, and the five-second prompt. A fake clock
/// also makes the midnight rollover a thing that gets tested rather than a
/// thing that gets discovered.
///
/// **Nothing else in `lib/` may call `DateTime.now()`.** There is a test that
/// fails if anything does — `test/core/clock_is_the_only_now_test.dart`.
abstract interface class Clock {
  /// The current wall-clock time, in the device's local zone.
  DateTime now();
}

/// [Clock] over the device clock.
///
/// The single legal call to `DateTime.now()` in the whole of `lib/`.
final class SystemClock implements Clock {
  /// The device clock.
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// The clock the app runs on. Overridden in tests.
@Riverpod(keepAlive: true)
Clock clock(Ref ref) => const SystemClock();
