import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/chit_theme.dart';
import 'router.dart';

/// The application root.
///
/// Stateful only so that the router is built once. A `GoRouter` created in
/// `build` would be thrown away and remade on every rebuild, taking each tab's
/// navigation stack with it — which is exactly what ADR-011 exists to prevent.
class ChitApp extends StatefulWidget {
  /// Creates the application root.
  const ChitApp({super.key});

  @override
  State<ChitApp> createState() => _ChitAppState();
}

class _ChitAppState extends State<ChitApp> {
  late final GoRouter _router = buildChitRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'chit',
      debugShowCheckedModeBanner: false,
      theme: ChitTheme.theme,
      routerConfig: _router,
    );
  }
}
