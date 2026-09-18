import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions.dart';
import '../../../domain/models/chit.dart';
import '../../../shared/day_label.dart';
import '../../../shared/widgets/ambient_stamp_row.dart';
import '../../../shared/widgets/audio_pill.dart';
import '../../../shared/widgets/slip.dart';
import '../../today/application/today_controller.dart';
import '../application/editor_controller.dart';

/// A saved chit, opened from the thread — **ADR-017, ADR-062**.
///
/// It **covers the tab shell** rather than sitting inside a tab: one task with
/// one way out, so a tab change cannot strand a half-typed edit.
///
/// The chit is drawn on the same [Slip] Today writes on and under the same
/// stamp the thread reads, because it is the same chit. **Nothing here can
/// move the stamp** — `createdAt`, `localDay` and the three ambient fields are
/// not parameters of anything this screen can call, which is the *no metadata*
/// rule made structural rather than remembered (TASKS.md D4).
///
/// Read-only as of M6 group B. The field, the action row and *Delete this
/// chit* arrive in groups C to F.
class EditorScreen extends ConsumerWidget {
  /// The editor for the chit with this [id].
  const EditorScreen({required this.id, super.key});

  /// Which chit. Comes off the route's path parameter.
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Chit?> chit = ref.watch(editorChitProvider(id));

    // **A chit that is not there sends you back** rather than drawing an empty
    // screen with a back arrow on it. An id outlives its row across a delete,
    // and a dead end explains nothing.
    ref.listen(editorChitProvider(id), (
      AsyncValue<Chit?>? _,
      AsyncValue<Chit?> next,
    ) {
      if (next is AsyncData<Chit?> && next.value == null && context.mounted) {
        context.pop();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: switch (chit) {
          // Nothing is drawn while the row is in flight. A slip with no stamp
          // and no words on it is a wrong answer rather than a slow one —
          // ADR-007's rule about undrawn signals, applied to a query.
          AsyncData<Chit?>(value: final Chit chit) => _Editor(chit: chit),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

/// The header, and the chit on its slip.
class _Editor extends ConsumerWidget {
  const _Editor({required this.chit});

  final Chit chit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final space = context.space;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        space.gutter,
        space.s4,
        space.gutter,
        space.s8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _Header(localDay: chit.localDay),
          SizedBox(height: space.s5),
          Slip(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // The **saved** stamp, not the open chit's: this is a record
                // being read, so it carries no pin and it is not brighter for
                // being on a screen of its own (BEHAVIOUR.md §3.6).
                AmbientStampRow.saved(stamp: chit.stamp),
                if (chit.hasText) ...<Widget>[
                  SizedBox(height: space.s4),
                  Text(chit.text!, style: context.type.chitText),
                ],
                if (chit.hasAudio) ...<Widget>[
                  SizedBox(height: space.s4),
                  AudioPill(
                    id: chit.id,
                    path: chit.audioPath!,
                    duration: chit.audioDuration ?? Duration.zero,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A back arrow and the chit's day.
///
/// *Today*, *Yesterday* or *Sunday 13 September*, in the one-line treatment
/// Today's own date uses (DESIGN-SYSTEM.md §6.2 — a label, not a masthead).
/// **Not the wordmark**: this is a place you came into, not a second home.
class _Header extends ConsumerWidget {
  const _Header({required this.localDay});

  final int localDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final space = context.space;
    final colors = context.colors;

    return Row(
      children: <Widget>[
        Semantics(
          button: true,
          label: 'Back',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: context.pop,
            child: Padding(
              // `s3` on every side takes the 18px glyph to 42px — under
              // §6.4's floor on its own, which the row's own height makes up.
              padding: EdgeInsets.only(right: space.s3),
              child: Icon(Icons.arrow_back, size: 20, color: colors.inkMuted),
            ),
          ),
        ),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              dayLabel(
                localDay: localDay,
                today: ref.watch(todayLocalDayProvider),
              ),
              style: context.type.date,
            ),
          ),
        ),
      ],
    );
  }
}
