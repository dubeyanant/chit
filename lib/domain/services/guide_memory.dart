import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'guide_memory.g.dart';

abstract interface class GuideMemory {
  Future<bool> hasBeenRead();

  Future<void> remember();
}

@Riverpod(keepAlive: true)
GuideMemory guideMemory(Ref ref) => throw UnimplementedError(
  'guideMemoryProvider is overridden at the root — see main.dart',
);
