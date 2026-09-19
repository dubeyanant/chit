import 'dart:async';

import 'package:flutter/services.dart';

abstract final class ChitHaptics {
  static void selected() => unawaited(HapticFeedback.selectionClick());

  static void committed() => unawaited(HapticFeedback.lightImpact());

  static void destroyed() => unawaited(HapticFeedback.mediumImpact());
}
