import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/chit_theme.dart';
import 'router.dart';

/// The application root.
///
/// Stateless, because the one thing here that has to outlive a rebuild — the
/// router, and with it every tab's navigation stack — is held by Riverpod
/// rather than by this widget (ADR-001). See `router.dart`.
class ChitApp extends ConsumerWidget {
  /// Creates the application root.
  const ChitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'chit',
      debugShowCheckedModeBanner: false,
      theme: ChitTheme.theme,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
