import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/chit_theme.dart';
import 'router.dart';

class ChitApp extends ConsumerWidget {
  const ChitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Chitt',
      debugShowCheckedModeBanner: false,
      theme: ChitTheme.theme,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
