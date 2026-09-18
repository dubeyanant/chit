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
    final type = context.type;

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
              const Align(alignment: Alignment.centerLeft, child: Wordmark()),
              const Spacer(),
              Slip(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('A chit remembers its moment.', style: type.chitText),
                    SizedBox(height: space.s4),
                    Text(
                      'Every chit is stamped with the time, and — if you let '
                      'it — the weather, whether you were moving, and that a '
                      'place was recorded.',
                      style: type.chitText.copyWith(color: colors.inkMuted),
                    ),
                    SizedBox(height: space.s4),
                    Text(
                      'A chit shows that a place was noted. It never shows '
                      'where, and none of it leaves this phone.',
                      style: type.chitText.copyWith(color: colors.inkMuted),
                    ),
                  ],
                ),
              ),
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
