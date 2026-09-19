import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/services/ambient_signals.dart';

part 'ambient_resume.g.dart';

@Riverpod(keepAlive: true)
AppLifecycleListener ambientResume(Ref ref) {
  final AppLifecycleListener listener = AppLifecycleListener(
    onResume: () => unawaited(
      ref.read(ambientSignalsProvider.notifier).refreshIfShownTooLong(),
    ),
  );

  ref.onDispose(listener.dispose);
  return listener;
}
