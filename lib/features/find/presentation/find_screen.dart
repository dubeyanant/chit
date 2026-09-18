import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/extensions.dart';
import '../../../domain/find/find_axis.dart';
import '../../../domain/quotes.dart';
import '../../today/application/today_controller.dart';
import 'widgets/find_list.dart';

/// The find tab's first screen — a line, and the four ways down.
class FindScreen extends ConsumerWidget {
  const FindScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int today = ref.watch(todayLocalDayProvider);

    return FindList(
      above: _Quote(line: Quotes.forDay(today)),
      rows: <Widget>[
        for (final FindAxis axis in FindAxis.values)
          FindWord(
            key: ValueKey<String>(axis.slug),
            word: axis.label,
            onTap: () => context.pushNamed(
              findAxisRouteName,
              pathParameters: <String, String>{findAxisParameter: axis.slug},
            ),
          ),
      ],
    );
  }
}

class _Quote extends StatelessWidget {
  const _Quote({required this.line});

  final String line;

  @override
  Widget build(BuildContext context) => Text(
    line,
    textAlign: TextAlign.right,
    style: context.type.quote,
  );
}
