import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/extensions.dart';
import '../../../domain/find/find_axis.dart';
import '../application/find_line_provider.dart';
import '../application/find_providers.dart';
import 'widgets/find_list.dart';
import 'widgets/outline_backdrop.dart';

class FindScreen extends ConsumerWidget {
  const FindScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String line = ref.watch(findLineProvider);

    final Map<FindAxis, List<FindValue>>? values = ref.watch(
      axisValuesProvider,
    );

    final List<FindAxis> offered = <FindAxis>[
      for (final FindAxis axis in FindAxis.values)
        if (values?[axis]?.isNotEmpty ?? false) axis,
    ];

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const OutlineBackdrop(),
        _words(context, line, values, offered),
      ],
    );
  }

  Widget _words(
    BuildContext context,
    String line,
    Map<FindAxis, List<FindValue>>? values,
    List<FindAxis> offered,
  ) {
    return FindList(
      above: _Quote(line: line),
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
  Widget build(BuildContext context) =>
      Text(line, textAlign: TextAlign.right, style: context.type.quote);
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
