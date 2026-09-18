import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock.g.dart';

abstract interface class Clock {
  DateTime now();
}

final class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

@Riverpod(keepAlive: true)
Clock clock(Ref ref) => const SystemClock();
