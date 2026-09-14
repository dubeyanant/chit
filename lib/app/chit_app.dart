import 'package:flutter/material.dart';

/// The application root.
///
/// M0a stands this up as a bare surface in `--paper` so the project builds and
/// launches on a handset. M0b replaces the inline colour and the placeholder
/// text with the theme extensions of README §6 and the real wordmark.
class ChitApp extends StatelessWidget {
  const ChitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'chit',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // --paper. Becomes ChitColors.paper in M0b.
        backgroundColor: Color(0xFF191714),
        body: SizedBox.expand(),
      ),
    );
  }
}
