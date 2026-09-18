import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions.dart';
import '../../../core/theme/chit_motion.dart';
import '../../../domain/models/audio_edit.dart';
import '../../../domain/models/chit.dart';
import '../../../domain/models/editor_state.dart';
import '../../../shared/widgets/ambient_stamp_row.dart';
import '../../../shared/widgets/arrival.dart';
import '../../../shared/widgets/audio_pill.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/focus_ring.dart';
import '../../../shared/widgets/microphone.dart';
import '../../../shared/widgets/prompt_sheet.dart';
import '../../../shared/widgets/slip.dart';
import '../../composer/application/recording_controller.dart';
import '../../composer/presentation/recording_sheet.dart';
import '../application/editor_controller.dart';

/// A saved chit, opened from the thread — **ADR-017, ADR-062**, BEHAVIOUR.md
/// §4.5.
///
/// It **covers the tab shell** rather than sitting inside a tab: one task with
/// one way out, so a tab change cannot strand a half-typed edit.
///
/// **The slip fills the screen** (ADR-066): the header above it, *Delete this
/// chit* pinned below it, and everything between is the chit — the field
/// grows to whatever height is left, so a long chit is edited in place rather
/// than in a box inside a scroll.
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

    final bool dirty = editor.value?.shouldPromptOnLeave ?? false;

    // **The system back gesture asks when something has changed** (ADR-017,
    // ADR-064) — a stray swipe is not a decision, where a press on Cancel is.
    // With nothing changed the pop goes straight through. A programmatic pop
    // — after Save, after Cancel, when the row has gone — is not a system pop
    // and is never intercepted.
    return PopScope<Object?>(
      canPop: !dirty,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (!didPop) leaveEditor(context, ref, id, ask: true);
      },
      child: Scaffold(
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
      ),
    );
  }
}

/// Leaves the editor.
///
/// **Cancel leaves at once** — a press on a button that says Cancel is the
/// decision, and asking again is asking twice (ADR-066). **The back arrow and
/// the system gesture ask** when something has changed, because a swipe or a
/// glancing tap is not a decision (ADR-017). Either way, whether there *is*
/// a change to lose is `EditorState.shouldPromptOnLeave`'s call, not this
/// function's (TASKS.md D11). Whatever was staged is thrown away.
Future<void> leaveEditor(
  BuildContext context,
  WidgetRef ref,
  String id, {
  required bool ask,
}) async {
  final bool dirty =
      ref.read(editorControllerProvider(id)).value?.shouldPromptOnLeave ??
      false;

  if (ask && dirty) {
    final bool discard = await showPromptSheet(
      context,
      question: 'Keep this edit?',
      keep: 'Keep',
      letGo: 'Discard',
    );
    if (!discard) return;
  }

  // A staged take is a temp file nobody will move now; the row itself was
  // never touched.
  await ref.read(editorControllerProvider(id).notifier).abandon();
  if (context.mounted) context.pop();
}

/// The header, the chit filling the screen, and Delete pinned under it.
class _Editor extends ConsumerWidget {
  const _Editor({required this.id, required this.state});

  final String id;
  final EditorState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final space = context.space;
    final Chit chit = state.chit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(
            space.gutter,
            space.s4,
            space.gutter,
            space.s5,
          ),
          child: _Header(id: id),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: space.gutter),
            child: Slip(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // The **saved** stamp, not the open chit's: this is a record
                  // being read, so it is not brighter for being on a screen of
                  // its own (BEHAVIOUR.md §3.6).
                  AmbientStampRow.saved(stamp: chit.stamp),
                  // The recording sits above the words, where the open chit
                  // puts it (ADR-067) — the same slip, so the same order. It
                  // is the stored recording or a staged replacement, and the
                  // state knows which (ADR-008: relative for the first,
                  // absolute for the second). **Remove** stages; nothing
                  // touches the file until Save (D6).
                  if (state.hasAudio) ...<Widget>[
                    SizedBox(height: space.s4),
                    // **A staged replacement rises, the stored one does not**
                    // (§6.3). Opening a chit that already had a recording is
                    // not an arrival; recording a new one over it is, and the
                    // pill remounts at that moment because a removal took the
                    // old one out of the tree first.
                    Arrival(
                      from: Offset(0, space.s4),
                      play: state.audio is ReplaceAudio,
                      child: AudioPill(
                        id: chit.id,
                        path: state.audioPath!,
                        duration: state.audioDuration ?? Duration.zero,
                        onRemove: ref
                            .read(editorControllerProvider(id).notifier)
                            .removeAudio,
                      ),
                    ),
                  ],
                  SizedBox(height: space.s4),
                  Expanded(child: _Field(id: id)),
                  SizedBox(height: space.s4),
                  _ActionRow(id: id, state: state),
                  if (state.microphoneRefused) ...<Widget>[
                    SizedBox(height: space.s2),
                    const _MicrophoneNote(),
                  ],
                ],
              ),
            ),
          ),
        ),
        // **Pinned below the slip, apart from the action row** (ADR-064,
        // ADR-066): always on screen, and a step of the scale from Save
        // rather than an inch from it. Distance is the first defence and the
        // prompt is the second.
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: space.gutter,
            vertical: space.s4,
          ),
          child: Center(child: _DeleteControl(id: id)),
        ),
      ],
    );
  }
}

/// The chit's words, editable, **filling whatever height the slip has**. The
/// same field as the open chit's, less the prompt — a record has nothing to be
/// prompted about.
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
        // The field is the page: it takes the height it is given and scrolls
        // inside it, so the slip never has to.
        expands: true,
        maxLines: null,
        minLines: null,
        textAlignVertical: TextAlignVertical.top,
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        onTapOutside: (PointerDownEvent _) =>
            FocusManager.instance.primaryFocus?.unfocus(),
        decoration: const InputDecoration.collapsed(hintText: null),
      ),
    );
  }
}

/// The microphone when there is no recording, **Cancel always**, and **Save
/// chit** once there is something to save — TASKS.md D7, ADR-066.
///
/// Cancel is always there because it is the way out, and a way out that
/// appears only sometimes is a way out that has to be looked for. Save
/// arrives with the first real change and leaves again if a removal has left
/// the chit holding nothing, which is `canSave`'s other half.
///
/// *Cancel*, not *Discard*: Discard is the word for throwing away something
/// in flight — the sheet's take, the prompt's edit — and a chit being edited
/// is a record. Three acts, three words (ADR-064).
class _ActionRow extends ConsumerWidget {
  const _ActionRow({required this.id, required this.state});

  final String id;
  final EditorState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final motion = context.motion;
    final space = context.space;

    return Row(
      children: <Widget>[
        // **The microphone comes back whenever the chit holds no recording**
        // — BEHAVIOUR.md §3.2's rule, on this screen: a chit holds one take,
        // so the way to a different one is to remove the first. It fades as
        // Today's does (DESIGN-SYSTEM.md §6.3, routine change).
        AnimatedSwitcher(
          duration: motion.fade(ChitPace.exit),
          switchInCurve: motion.curve,
          switchOutCurve: motion.curve,
          child: state.hasAudio
              ? const SizedBox.shrink()
              : _EditorMicrophone(id: id),
        ),
        if (!state.hasAudio) SizedBox(width: space.s2),
        QuietButton(
          label: 'Cancel',
          onPressed: () => leaveEditor(context, ref, id, ask: false),
        ),
        SizedBox(width: space.s2),
        Expanded(
          child: AnimatedSwitcher(
            duration: motion.fade(ChitPace.routine),
            reverseDuration: motion.fade(ChitPace.exit),
            switchInCurve: motion.curve,
            switchOutCurve: motion.curve,
            // A `Row` with one `Expanded` child, not the button bare — the
            // switcher lays its child out loose, and a bare button loose is
            // the width of its label. Same fix as Today's Save, same day.
            child: state.canSave
                ? Row(
                    children: <Widget>[
                      Expanded(
                        child: PrimaryButton(
                          label: 'Save',
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
          ),
        ),
      ],
    );
  }
}

/// The editor's microphone: the shared [Microphone], with the take staged
/// on this chit rather than attached to the open one (ADR-065).
class _EditorMicrophone extends ConsumerWidget {
  const _EditorMicrophone({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Microphone(onRecord: () => _record(context, ref));

  Future<void> _record(BuildContext context, WidgetRef ref) async {
    FocusManager.instance.primaryFocus?.unfocus();

    final bool began = await ref
        .read(recordingControllerProvider.notifier)
        .start(into: ref.read(editorControllerProvider(id).notifier));
    if (!began || !context.mounted) return;

    await showRecordingSheet(context, ref);
  }
}

/// The line beside a refused microphone — the open chit's, word for word
/// (ADR-056). Under the action row for the reason it is there too.
class _MicrophoneNote extends StatelessWidget {
  const _MicrophoneNote();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Text(
        "The microphone isn't allowed. You can turn it on in your phone's "
        'settings.',
        style: context.type.failNote,
      ),
    );
  }
}

/// **Delete this chit** — named in full, so it cannot be read as Discard
/// (TASKS.md D8), and behind the prompt with no undo (D10). Closes open
/// item 9.
class _DeleteControl extends ConsumerWidget {
  const _DeleteControl({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) => QuietButton(
    label: 'Delete this chit',
    onPressed: () => _delete(context, ref),
  );

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final bool delete = await showPromptSheet(
      context,
      question: 'Delete this chit?',
      keep: 'Keep it',
      letGo: 'Delete',
    );
    if (!delete) return;

    await ref.read(editorControllerProvider(id).notifier).delete();
    if (context.mounted) context.pop();
  }
}

/// A back arrow, and *Editing*.
///
/// The arrow's glyph sits on the page gutter, where the wordmark sits on
/// Today, with its 44px target overhanging into the gutter rather than
/// pushing the glyph in — a target is a relationship with a thumb, not a
/// thing the eye has to see aligned. **Not the day**: the slip's own stamp
/// already carries the time, and what the header has to say is what this
/// screen is for (ADR-066).
class _Header extends ConsumerWidget {
  const _Header({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final space = context.space;
    final colors = context.colors;

    return Row(
      children: <Widget>[
        Transform.translate(
          offset: Offset(-space.s3, 0),
          child: Semantics(
            button: true,
            label: 'Back',
            child: FocusRing(
              onActivate: () => leaveEditor(context, ref, id, ask: true),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                // The same exit as the system gesture: it asks when something
                // has changed. Cancel, in the row below, does not.
                onTap: () => leaveEditor(context, ref, id, ask: true),
                child: Padding(
                  // `s3` on every side takes the 20px glyph to 44px, §6.4's
                  // floor; the translate above puts the glyph itself on the
                  // gutter.
                  padding: EdgeInsets.all(space.s3),
                  child: Icon(
                    Icons.arrow_back,
                    size: 20,
                    color: colors.inkMuted,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Semantics(
            header: true,
            child: Text('Editing', style: context.type.date),
          ),
        ),
      ],
    );
  }
}
