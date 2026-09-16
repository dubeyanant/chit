import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/slip.dart';
import '../../../shared/widgets/wordmark.dart';
import '../application/first_run_controller.dart';

/// The screen a fresh install opens on, once — **ADR-041**.
///
/// **A screen of ours before a dialog of the platform's.** A bare system
/// prompt over a blank page asks for a permission without saying what it buys,
/// and the honest answer — *so a chit can remember what the weather was* — is
/// not something Android or iOS will say on our behalf. So the explanation is
/// here, in chit's own voice, and the system dialog is raised only after
/// somebody has agreed to it.
///
/// **A full screen rather than a sheet.** It is shown once in the life of an
/// install, so it can afford the room; and a scrim over an empty Today is a
/// busier first impression than a page that was composed.
///
/// It is built out of the vocabulary that already exists — the [Wordmark], a
/// [Slip] with its tear edge, and the two weights of [PrimaryButton] and
/// [QuietButton]. Nothing here is a new kind of object, which is the point: the
/// first thing a user sees should be the app, not a preamble to it.
final class FirstRunScreen extends ConsumerWidget {
  /// The screen.
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
                  // Deliberately fire-and-forget: the screen closes on the
                  // state change, and nothing here has an error to report.
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
