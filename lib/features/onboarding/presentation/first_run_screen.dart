import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/slip.dart';
import '../../../shared/widgets/wordmark.dart';
import '../application/first_run_controller.dart';

final class FirstRunScreen extends ConsumerWidget {
  const FirstRunScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final space = context.space;

    final FirstRunController controller = ref.read(
      firstRunControllerProvider.notifier,
    );

    return Scaffold(
      backgroundColor: colors.paper,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: space.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: space.s5),
              const Center(child: Wordmark()),
              SizedBox(height: space.s6),
              const Spacer(),
              const _Tips(),
              SizedBox(height: space.s4),
              const _Ask(),
              SizedBox(height: space.s5),
              PrimaryButton(label: 'Allow', onPressed: controller.allow),
              SizedBox(height: space.s2),
              Align(
                child: QuietButton(
                  label: 'Not now',
                  onPressed: () => unawaited(controller.notNow()),
                ),
              ),
              SizedBox(height: space.s5),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tips extends StatelessWidget {
  const _Tips();

  static const List<String> _lines = <String>[
    'The page is always open — write, then Save.',
    'Or tap the microphone and speak; a recording is kept, not transcribed.',
    'Hold a chit to open it again.',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final type = context.type;

    return Slip(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('A few words first.', style: type.chitText),
          for (final String line in _lines) ...<Widget>[
            SizedBox(height: space.s3),
            Text(line, style: type.chitText.copyWith(color: colors.inkMuted)),
          ],
        ],
      ),
    );
  }
}

class _Ask extends StatelessWidget {
  const _Ask();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final type = context.type;

    return Slip(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('A chit remembers its moment.', style: type.chitText),
          SizedBox(height: space.s4),
          Text(
            'The time, and — if you let it — the weather, whether you were '
            'moving, and that a place was noted. It never shows where, and '
            'none of it leaves this phone.',
            style: type.chitText.copyWith(color: colors.inkMuted),
          ),
        ],
      ),
    );
  }
}
