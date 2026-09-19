import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions.dart';
import '../../../core/haptics.dart';
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

class EditorScreen extends ConsumerWidget {
  const EditorScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<EditorState?> editor = ref.watch(
      editorControllerProvider(id),
    );

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

    return PopScope<Object?>(
      canPop: !dirty,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (!didPop) leaveEditor(context, ref, id, ask: true);
      },
      child: Scaffold(
        body: SafeArea(
          child: switch (editor) {
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

  await ref.read(editorControllerProvider(id).notifier).abandon();
  if (context.mounted) context.pop();
}

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
                  AmbientStampRow.saved(
                    stamp: chit.stamp,
                    edited: chit.wasEdited,
                  ),

                  if (state.hasAudio) ...<Widget>[
                    SizedBox(height: space.s4),

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

class _Field extends ConsumerStatefulWidget {
  const _Field({required this.id});

  final String id;

  @override
  ConsumerState<_Field> createState() => _FieldState();
}

class _FieldState extends ConsumerState<_Field> {
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

        cursorColor: colors.seal,
        cursorWidth: 1.5,

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
      roomForLetGo: true,
    );
    if (!delete) return;

    ChitHaptics.destroyed();
    await ref.read(editorControllerProvider(id).notifier).delete();
    if (context.mounted) context.pop();
  }
}

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

                onTap: () => leaveEditor(context, ref, id, ask: true),
                child: Padding(
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
