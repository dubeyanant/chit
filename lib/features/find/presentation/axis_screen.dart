import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/extensions.dart';
import '../../../domain/find/find_axis.dart';
import '../application/find_providers.dart';
import 'widgets/find_list.dart';

/// One axis' values — no quote, and ordered as the axis says (§4.6).
class AxisScreen extends ConsumerWidget {
  const AxisScreen({required this.axis, super.key});

  final FindAxis axis;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<FindValue> values =
        ref.watch(axisValuesProvider)[axis] ?? const <FindValue>[];

    if (values.isEmpty) return _Nothing(axis: axis);

    return FindList(
      rows: <Widget>[
        for (final FindValue it in values)
          FindWord(
            key: ValueKey<String>(it.slug),
            word: axis == FindAxis.topics ? '#${it.label}' : it.label,
            onTap: () => context.pushNamed(
              findValueRouteName,
              pathParameters: <String, String>{
                findAxisParameter: axis.slug,
                findValueParameter: it.slug,
              },
            ),
          ),
      ],
    );
  }
}

class _Nothing extends StatelessWidget {
  const _Nothing({required this.axis});

  final FindAxis axis;

  @override
  Widget build(BuildContext context) {
    final space = context.space;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        space.gutter,
        space.s5,
        space.gutter,
        space.s6,
      ),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Text(
          axis.empty,
          textAlign: TextAlign.right,
          style: context.type.emptyNote,
        ),
      ),
    );
  }
}
