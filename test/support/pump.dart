import 'package:chit/core/theme/chit_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The content width of a screen at the design size: 390px less the page
/// gutter on both sides. DESIGN-SYSTEM.md §7 — the prototype is mobile at
/// 390×844.
const double pageWidth = 338;

/// Pumps [child] on paper, in the app's own theme.
///
/// A shared widget has to be tested against the real [ChitTheme], not a
/// stand-in: every one of them reads its colours, type and spacing off the
/// four extensions, and a test that supplies its own would be testing the
/// test.
///
/// The child is laid out at the top left with [width] as a *ceiling* rather
/// than as a size, so `tester.getSize` reports what the widget asked for. A
/// slip fills the page because it asks to; a thread node is 15px because that
/// is what it is.
Future<void> pumpOnPaper(
  WidgetTester tester,
  Widget child, {
  double width = pageWidth,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: ChitTheme.theme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width),
            child: child,
          ),
        ),
      ),
    ),
  );
}
