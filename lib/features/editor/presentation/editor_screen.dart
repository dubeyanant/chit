import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions.dart';
import '../../../core/theme/chit_motion.dart';
import '../../../domain/models/chit.dart';
import '../../../domain/models/editor_state.dart';
import '../../../shared/day_label.dart';
import '../../../shared/widgets/ambient_stamp_row.dart';
import '../../../shared/widgets/audio_pill.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/slip.dart';
import '../../today/application/today_controller.dart';
import '../application/editor_controller.dart';

/// A saved chit, opened from the thread — **ADR-017, ADR-062**, BEHAVIOUR.md
/// §4.5.
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
/// **Every decision is the controller's** (D11): whether Save shows, whether
/// leaving asks. This screen reads getters and draws.
class EditorScreen extends ConsumerWidget {
  /// The editor for the chit with this [id].
  const EditorScreen({required this.id, super.key});

  /// Which chit. Comes off the route's path parameter.
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<EditorState?> editor = ref.watch(
      editorControllerProvider(id),
    );

    // **A chit that is not there sends you back** rather than drawing an empty
    // screen with a back arrow on it. An id outlives its row across a delete,
    // and a dead end explains nothing.
    ref.listen(editorControllerProvider(id), (
      AsyncValue<EditorState?>? _,
      AsyncValue<EditorState?> next,
    ) {
      if (next is AsyncData<EditorState?> &&
          next.value == null &&
          context.mounted) {
        context.pop();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: switch (editor) {
          // Nothing is drawn while the row is in flight. A slip with no stamp
          // and no words on it is a wrong answer rather than a slow one —
          // ADR-007's rule about undrawn signals, applied to a query.
          AsyncData<EditorState?>(value: final EditorState state) => _Editor(
            id: id,
            state: state,
          ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

/// The header, and the chit on its slip.
class _Editor extends ConsumerWidget {
  const _Editor({required this.id, required this.state});

  final String id;
  final EditorState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final space = context.space;
    final Chit chit = state.chit;

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
                SizedBox(height: space.s4),
                _Field(id: id),
                if (state.hasAudio && chit.hasAudio) ...<Widget>[
                  SizedBox(height: space.s4),
                  AudioPill(
                    id: chit.id,
                    path: chit.audioPath!,
                    duration: chit.audioDuration ?? Duration.zero,
                  ),
                ],
                SizedBox(height: space.s4),
                _ActionRow(id: id, canSave: state.canSave),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The chit's words, editable. The same field as the open chit's, less the
/// prompt — a record has nothing to be prompted about.
class _Field extends ConsumerStatefulWidget {
  const _Field({required this.id});

  final String id;

  @override
  ConsumerState<_Field> createState() => _FieldState();
}

class _FieldState extends ConsumerState<_Field> {
  // Seeded once from the loaded chit. Nothing writes the field from outside
  // it afterwards — an edit is the user's, and Cancel leaves the screen
  // rather than rewinding it — so there is no mirror back the way the open
  // chit needs one.
  late final TextEditingController _text = TextEditingController(
    text: ref.read(editorControllerProvider(widget.id)).value?.text ?? '',
  );

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      label: 'The chit',
      child: TextField(
        controller: _text,
        onChanged: ref.read(editorControllerProvider(widget.id).notifier).edit,
        style: context.type.composerBody,
        // The caret is the accent's one job: it marks what is live (ADR-022).
        cursorColor: colors.seal,
        cursorWidth: 1.5,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        onTapOutside: (PointerDownEvent _) =>
            FocusManager.instance.primaryFocus?.unfocus(),
        decoration: const InputDecoration.collapsed(hintText: null),
      ),
    );
  }
}

/// **Save chit**, once something has changed — TASKS.md D7.
///
/// The same rule as Today's row, on Today's terms: a control arrives when
/// there is something for it to do, and a retired one leaves rather than
/// greys out. It is also withheld when a removal has left the chit holding
/// nothing, which is `canSave`'s other half.
class _ActionRow extends ConsumerWidget {
  const _ActionRow({required this.id, required this.canSave});

  final String id;
  final bool canSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final motion = context.motion;

    return AnimatedSwitcher(
      duration: motion.fade(ChitPace.routine),
      reverseDuration: motion.fade(ChitPace.exit),
      switchInCurve: motion.curve,
      switchOutCurve: motion.curve,
      child: canSave
          ? Row(
              children: <Widget>[
                Expanded(
                  child: PrimaryButton(
                    label: 'Save chit',
                    onPressed: () async {
                      await ref
                          .read(editorControllerProvider(id).notifier)
                          .save();
                      if (context.mounted) context.pop();
                    },
                  ),
                ),
              ],
            )
          : const SizedBox.shrink(),
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
              // The 20px glyph alone is under §6.4's 44px floor; `s3` on every
              // side and the row's own 26px line bring the target up to it.
              padding: EdgeInsets.all(space.s3),
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
