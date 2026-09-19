import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions.dart';
import '../../../core/haptics.dart';
import '../../../core/theme/chit_motion.dart';
import '../../../domain/models/composer_state.dart';
import '../../../domain/services/audio_player.dart';
import '../../../shared/widgets/ambient_stamp_row.dart';
import '../../../shared/widgets/arrival.dart';
import '../../../shared/widgets/audio_pill.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/microphone.dart';
import '../../../shared/widgets/slip.dart';
import '../application/composer_controller.dart';
import '../application/recording_controller.dart';
import 'recording_sheet.dart';

class OpenChit extends ConsumerWidget {
  const OpenChit({super.key});

  static const Key microphone = Key('open-chit-microphone');

  static const Key prompt = Key('open-chit-prompt');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ComposerState state = ref.watch(composerControllerProvider);
    final space = context.space;

    return Slip(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AmbientStampRow.open(stamp: state.stamp),

          if (state.hasAudio) ...<Widget>[
            SizedBox(height: space.s4),

            Arrival(
              from: Offset(0, space.s4),
              child: AudioPill(
                id: Playback.openChit,
                path: state.audioTempPath!,
                duration: state.audioDuration ?? Duration.zero,

                onRemove: ref
                    .read(composerControllerProvider.notifier)
                    .removeTake,
              ),
            ),
          ],
          SizedBox(height: space.s4),
          const _Field(),
          SizedBox(height: space.s4),
          _ActionRow(canSave: state.canSave, hasAudio: state.hasAudio),
          if (state.microphoneRefused) ...<Widget>[
            SizedBox(height: space.s2),
            const _MicrophoneNote(),
          ],
        ],
      ),
    );
  }
}

class _Field extends ConsumerStatefulWidget {
  const _Field();

  @override
  ConsumerState<_Field> createState() => _FieldState();
}

class _FieldState extends ConsumerState<_Field> {
  late final TextEditingController _text = TextEditingController(
    text: ref.read(composerControllerProvider).text,
  );

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(composerControllerProvider.select((ComposerState s) => s.text), (
      String? _,
      String next,
    ) {
      if (next == _text.text) return;
      _text.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    });

    final colors = context.colors;
    final bool blank = ref.watch(
      composerControllerProvider.select(
        (ComposerState s) => s.text.trim().isEmpty,
      ),
    );

    return Stack(
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: context.space.s8),
          child: Semantics(
            label: "Today's chit",
            child: TextField(
              controller: _text,
              onChanged: ref.read(composerControllerProvider.notifier).edit,
              style: context.type.composerBody,

              cursorColor: colors.seal,
              cursorWidth: 1.5,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,

              onTapOutside: (PointerDownEvent _) =>
                  FocusManager.instance.primaryFocus?.unfocus(),

              decoration: const InputDecoration.collapsed(hintText: null),
            ),
          ),
        ),

        if (blank)
          const Positioned(
            left: 0,
            top: 0,
            right: 0,
            child: IgnorePointer(child: _Ghost()),
          ),
      ],
    );
  }
}

class _Ghost extends ConsumerWidget {
  const _Ghost();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ComposerState state = ref.watch(composerControllerProvider);
    final motion = context.motion;

    return AnimatedOpacity(
      opacity: state.showPrompt ? 1 : 0,
      duration: motion.fade(ChitPace.prompt),
      curve: motion.curve,
      child: Text(
        state.prompt,
        key: OpenChit.prompt,
        style: context.type.composerGhost,
      ),
    );
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

class _ActionRow extends ConsumerWidget {
  const _ActionRow({required this.canSave, required this.hasAudio});

  final bool canSave;

  final bool hasAudio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final motion = context.motion;

    return Row(
      children: <Widget>[
        AnimatedSwitcher(
          duration: motion.fade(ChitPace.exit),
          switchInCurve: motion.curve,
          switchOutCurve: motion.curve,
          child: hasAudio
              ? const SizedBox.shrink()
              : const _OpenChitMicrophone(),
        ),
        if (!hasAudio) SizedBox(width: context.space.s2),
        Expanded(
          child: AnimatedSwitcher(
            duration: motion.fade(ChitPace.routine),
            reverseDuration: motion.fade(ChitPace.exit),
            switchInCurve: motion.curve,
            switchOutCurve: motion.curve,
            child: canSave ? const _CommitControls() : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

class _CommitControls extends ConsumerWidget {
  const _CommitControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: <Widget>[
        Expanded(
          child: PrimaryButton(
            label: 'Save',
            onPressed: () async {
              ChitHaptics.committed();
              await ref.read(composerControllerProvider.notifier).save();
            },
          ),
        ),
      ],
    );
  }
}

class _OpenChitMicrophone extends ConsumerWidget {
  const _OpenChitMicrophone();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Microphone(
    key: OpenChit.microphone,
    onRecord: () => _record(context, ref),
  );

  Future<void> _record(BuildContext context, WidgetRef ref) async {
    FocusManager.instance.primaryFocus?.unfocus();

    final bool began = await ref
        .read(recordingControllerProvider.notifier)
        .start(into: ref.read(composerControllerProvider.notifier));
    if (!began) return;
    ChitHaptics.selected();
    if (!context.mounted) return;

    await showRecordingSheet(context, ref);
  }
}
