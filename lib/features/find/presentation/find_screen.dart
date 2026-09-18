import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/extensions.dart';
import '../../../domain/find/find_axis.dart';
import '../../../domain/quotes.dart';
import '../../today/application/today_controller.dart';
import '../application/find_providers.dart';
import 'widgets/find_list.dart';

/// The find tab's first screen — a line, and the ways down that go anywhere.
class FindScreen extends ConsumerWidget {
  const FindScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int today = ref.watch(todayLocalDayProvider);

    // Watched here and not only on the screen below, for two reasons: an axis
    // with nothing on it is not drawn (§4.6), which needs the answer; and
    // reading it here is what leaves it warm, so tapping a word does not open
    // a screen that has to load (ADR-085).
    final Map<FindAxis, List<FindValue>>? values = ref.watch(axisValuesProvider);

    final List<FindAxis> offered = <FindAxis>[
      for (final FindAxis axis in FindAxis.values)
        if (values?[axis]?.isNotEmpty ?? false) axis,
    ];

    return FindList(
      above: _Quote(line: Quotes.forDay(today)),
      rows: <Widget>[
        if (values != null && offered.isEmpty)
          const _NothingYet()
        else
          for (final FindAxis axis in offered)
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

class _NothingYet extends StatelessWidget {
  const _NothingYet();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: FindWord.rowHeight,
    child: Align(
      alignment: Alignment.centerRight,
      child: Text(
        'Nothing to look through yet.',
        textAlign: TextAlign.right,
        style: context.type.emptyNote,
      ),
    ),
  );
}
