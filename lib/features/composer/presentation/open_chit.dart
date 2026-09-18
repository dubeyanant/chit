import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions.dart';
import '../../../core/theme/chit_colors.dart';
import '../../../core/theme/chit_motion.dart';
import '../../../domain/models/composer_state.dart';
import '../../../domain/services/audio_player.dart';
import '../../../shared/widgets/ambient_stamp_row.dart';
import '../../../shared/widgets/audio_pill.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/slip.dart';
import '../application/composer_controller.dart';
import '../application/recording_controller.dart';
import 'recording_sheet.dart';

/// The slip at the top of Today: the stamp, the field, and the action row.
///
/// BEHAVIOUR.md §4.1 and §3.2. **One surface, no mode** — the field is a real
/// editor and the microphone sits beside it as an equal, not as a secondary
/// action tucked into a corner.
///
/// The slip, its tear edge and the pad behind it come from [Slip]; this widget
/// does not assemble them.
class OpenChit extends ConsumerWidget {
  /// The open chit.
  const OpenChit({super.key});

  /// The microphone.
  ///
  /// Named because it is the one thing on this slip that carries a rule but no
  /// semantics: §6.4 fixes its target at 44px and §3.2 forbids it shrinking
  /// when text appears, and it is deliberately not a control until M5, so
  /// there is no label to find it by. M5 attaches its behaviour here.
  static const Key microphone = Key('open-chit-microphone');

  /// The five-second prompt of BEHAVIOUR.md §3.3.
  ///
  /// Named because its words are not fixed (ADR-029) — they are chosen from
  /// the stamp, so a test that wants the prompt cannot ask for it by the
  /// sentence it expects.
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
          // The pill sits above the page, as v6 places it: the recording
          // arrived first and the words are written under it.
          if (state.hasAudio) ...<Widget>[
            SizedBox(height: space.s4),
            AudioPill(
              id: Playback.openChit,
              path: state.audioTempPath!,
              duration: state.audioDuration ?? Duration.zero,
            ),
          ],
          // **The note sits above the page, never on it** — BEHAVIOUR.md §3.5.
          // v6 pulls the field back up under it with a negative margin, which
          // leaves `s1` between the two: an explanation belongs to the thing
          // it explains, and the page keeps its full height because it is
          // still the user's to type into.
          if (state.sttFailed) ...<Widget>[
            SizedBox(height: space.s4),
            const _FailNote(),
            SizedBox(height: space.s1),
          ] else
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

/// The page. Live from the moment the chit opens, and always the user's.
///
/// **No autofocus — ADR-023.** Taken literally, BEHAVIOUR.md §3.2's *"typing
/// costs nothing, not even a tap"* raises the keyboard on every launch, which
/// covers the thread, the timeline and half the open chit. What §3.2 is
/// actually about is there being no *mode* to choose, and that is intact: this
/// is a real editor, it is the first thing under the stamp, and one tap puts
/// the caret in it. What is gone is one tap, not a decision.
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
    // The controller is the source of truth and this field mirrors it, so that
    // Discard can empty the page and M5's transcript can land in it. Typing
    // does not loop back: by the time this fires the two already agree.
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
          // Two and a half lines. v4 rested at 92px because the bottom of the
          // slip carried two full-width buttons; against a single 54px control
          // that much blank reads as a void with something stranded under it.
          //
          // The constraint is on the field rather than on the stack so that
          // the whole area takes a tap — §3.2's *typing costs nothing* is
          // about the page, not about the one line at the top of it.
          constraints: BoxConstraints(minHeight: context.space.s8),
          child: Semantics(
            label: "Today's chit",
            child: TextField(
              controller: _text,
              onChanged: ref.read(composerControllerProvider.notifier).edit,
              style: context.type.composerBody,
              // The caret is the accent's one job: it marks what is live
              // (ADR-022). Everything else on this slip is ink.
              cursorColor: colors.seal,
              cursorWidth: 1.5,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              // **Tapping away puts the keyboard down.** On mobile Flutter
              // leaves the field focused when the tap lands outside it, which
              // on this screen means the keyboard covers the thread and stays
              // there — the one surface §3.2 says the page is.
              //
              // `onTapOutside` rather than a `GestureDetector` around the
              // screen: a detector would have to be told about every control
              // it must not swallow, and this already knows what *outside*
              // means. Taps on Discard, Save and the microphone still land —
              // the region reports the tap, it does not eat it.
              onTapOutside: (PointerDownEvent _) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              // No border, no fill, no counter. The slip is the surface; a
              // field drawn on top of it would be a second one.
              decoration: const InputDecoration.collapsed(hintText: null),
            ),
          ),
        ),
        // The field's own first line starts at the top of that box, so the
        // ghost laid over the top of it sets on the same baseline.
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

/// The prompt, over an empty page — BEHAVIOUR.md §3.3.
///
/// **Not `hintText`.** A hint is a label on the field: it is announced as one,
/// and it arrives on Material's schedule rather than after five seconds.
/// ARCHITECTURE.md §4.1 warns that placeholder text is the tempting shortcut
/// here, and §3.5's failure note obeys the same rule from its own block above
/// the field — what the machine writes never goes into the field. *This
/// comment used to say the note would land in this overlay; [_FailNote] says
/// why it does not.*
///
/// **There is no drawn caret** — ADR-028. The field's caret is the platform's
/// and appears when the user taps, which is the only caret in the app.
class _Ghost extends ConsumerWidget {
  const _Ghost();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ComposerState state = ref.watch(composerControllerProvider);
    final motion = context.motion;

    // A fade and no rise, the same call group E made for Discard and Save: the
    // prototype lifts this 2px as it arrives, and §6.3's table gives the
    // prompt a pace of its own rather than filing it under authored arrival.
    // **It survives reduced motion at 140ms** — the appearance is the whole
    // event here, so collapsing it would delete the behaviour rather than calm
    // it (ARCHITECTURE.md §4.3).
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

/// **"Speech wasn't recognised. Your recording is kept."** — BEHAVIOUR.md §3.5.
///
/// A property of the state and never a value of `text`: a failure written into
/// the field is a failure the user has to delete before they can write.
///
/// **It is a block above the page, not the prompt's overlay** — v6 draws it
/// that way and it is the only placement that survives the next keystroke. In
/// the overlay it would have to hide the moment anything was typed, and the
/// recording would still be kept and still be unrecognised; the explanation
/// would have gone while the thing it explains had not. What it does take from
/// the prompt is its *turn*: `ComposerController` will not raise one while this
/// is showing, so the two never stack.
class _FailNote extends StatelessWidget {
  const _FailNote();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Text(
        "Speech wasn't recognised. Your recording is kept.",
        style: context.type.failNote,
      ),
    );
  }
}

/// The line beside a refused microphone, said once — TASKS.md D2.
///
/// **Under the action row rather than next to the microphone itself.** Once
/// the chit holds anything the row is microphone, Discard and Save, and there
/// is no width left beside it; a line that had to move when a word was typed
/// would be worse than one that is simply below the row it explains, which is
/// where the thumb already is.
///
/// **It names the OS because there is nowhere else to send anybody** —
/// ADR-041 spends the app's one dialog on location and never asks again, so
/// until there is a settings screen (open item 22) the phone's own is the only
/// way back. Saying so is better than a line that explains the state and
/// leaves the way out to be guessed at.
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

/// The microphone, then what to do with what has been written.
///
/// BEHAVIOUR.md §4.1: *the row reads left to right — the way in, then what to
/// do with it.* The microphone leads at the full 54px, and **Discard** and
/// **Save chit** arrive to its right as soon as the chit holds anything.
class _ActionRow extends ConsumerWidget {
  const _ActionRow({required this.canSave, required this.hasAudio});

  final bool canSave;

  /// Whether a take has been kept. **The microphone retires when it has**
  /// (BEHAVIOUR.md §4.1, §3.2): a chit holds one recording, so a microphone
  /// that stayed would be a control that silently replaced it. A control that
  /// retires reads as finished where a greyed-out one reads as broken, and the
  /// pill above is where the recording now is.
  final bool hasAudio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final motion = context.motion;

    return Row(
      children: <Widget>[
        // It goes as a fade rather than the width collapse v6 animates: the
        // row is a `Row`, and a control shrinking to nothing while its
        // neighbour grows is two authored movements for a routine change
        // (DESIGN-SYSTEM.md §6.3).
        AnimatedSwitcher(
          duration: motion.fade(ChitPace.exit),
          switchInCurve: motion.curve,
          switchOutCurve: motion.curve,
          child: hasAudio ? const SizedBox.shrink() : const _Microphone(),
        ),
        if (!hasAudio) SizedBox(width: context.space.s2),
        Expanded(
          // A fade and no rise. DESIGN-SYSTEM.md §6.3's table puts *"Discard
          // and Save arriving once the chit holds something"* under **routine
          // state change**, not under authored arrival — the prototype reuses
          // its `settle` keyframe here, and an 8px rise makes a routine change
          // look like one of the three moments in the app with any authorship.
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

/// The way in that is not typing — BEHAVIOUR.md §3.2 and §3.4.
///
/// It leads the action row at the full 54px because §4.1 makes it an equal of
/// the field rather than a secondary action, and its target does not shrink
/// when text appears (§6.4).
///
/// *It was drawn in M2 and deliberately not marked up as a control, because
/// §6.4 does not allow one that does nothing.* M5 group D gave it its action,
/// its label and its pressed wash together.
class _Microphone extends ConsumerStatefulWidget {
  const _Microphone();

  /// 54px — one of the four dimensions DESIGN-SYSTEM.md §6.3 allows off the
  /// scale, and **its target does not shrink when text appears** (§6.4).
  static const double size = 54;

  /// The stroke the icon set holds, in the prototype's 20-unit box.
  static const double _strokeInViewBox = 1.22;

  /// The icon's own box, drawn at 20 of the 54.
  static const double _icon = 20;

  @override
  ConsumerState<_Microphone> createState() => _MicrophoneState();
}

class _MicrophoneState extends ConsumerState<_Microphone> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      label: 'Record',
      child: GestureDetector(
        onTapDown: (TapDownDetails _) => setState(() => _pressed = true),
        onTapUp: (TapUpDetails _) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: _record,
        child: SizedBox.square(
          key: OpenChit.microphone,
          dimension: _Microphone.size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _pressed
                  ? colors.inkWash(
                      colors.slip,
                      opacity: ChitColors.micPressedWash,
                    )
                  : null,
              border: Border.all(color: colors.hair),
              borderRadius: BorderRadius.circular(context.space.radius),
            ),
            child: Center(
              child: CustomPaint(
                size: const Size.square(_Microphone._icon),
                painter: _MicrophonePainter(
                  colour: colors.inkMuted,
                  strokeWidth: _Microphone._strokeInViewBox,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Ask, start, then raise the sheet — and on a refusal, none of the three.
  ///
  /// The refusal is already recorded by the time `start` answers `false`
  /// (TASKS.md D2), so there is nothing to decide here: the sheet does not
  /// open and the composer says so on its own.
  Future<void> _record() async {
    // The keyboard would otherwise sit under the sheet for the whole take.
    FocusManager.instance.primaryFocus?.unfocus();

    final bool began = await ref
        .read(recordingControllerProvider.notifier)
        .start();
    if (!began || !mounted) return;

    await showRecordingSheet(context, ref);
  }
}

/// The microphone glyph, in the prototype's own 20-unit box.
class _MicrophonePainter extends CustomPainter {
  const _MicrophonePainter({required this.colour, required this.strokeWidth});

  final Color colour;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = colour
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas
      // <rect x=7.2 y=2.2 width=5.6 height=9.4 rx=2.8/>
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(7.2, 2.2, 5.6, 9.4),
          const Radius.circular(2.8),
        ),
        paint,
      )
      // <path d="M4.4 9.2a5.6 5.6 0 0 0 11.2 0M10 14.8v3"/>
      ..drawPath(
        Path()
          ..moveTo(4.4, 9.2)
          // The cup hangs below the capsule and meets the stem at 14.8, so
          // the semicircle goes left → down → right: counter-clockwise on a
          // screen, which is the SVG's `sweep-flag 0`.
          ..arcToPoint(
            const Offset(15.6, 9.2),
            radius: const Radius.circular(5.6),
            clockwise: false,
          )
          ..moveTo(10, 14.8)
          ..lineTo(10, 17.8),
        paint,
      );
  }

  @override
  bool shouldRepaint(_MicrophonePainter oldDelegate) =>
      oldDelegate.colour != colour || oldDelegate.strokeWidth != strokeWidth;
}

/// **Discard** and **Save chit**, once the chit holds something.
///
/// Three controls, one system, ranked by weight rather than by colour
/// (ADR-022): the microphone and Save share a border, Save carries the
/// brighter one and a faint ink wash, and Discard has no outline at all. *v5
/// made Save a solid `--seal` bar*, which became the loudest thing on the
/// screen the instant a word was typed.
///
/// **Save is the only thing in the app that writes a row** (ARCHITECTURE.md
/// §4.1). It stamps the chit at the moment it is pressed — ADR-040 — and opens
/// a new one after. Both of those live in `ComposerController.save`, because
/// neither is a decision a button should be making.
class _CommitControls extends ConsumerWidget {
  const _CommitControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final space = context.space;

    return Row(
      children: <Widget>[
        QuietButton(
          label: 'Discard',
          onPressed: ref.read(composerControllerProvider.notifier).discard,
        ),
        SizedBox(width: space.s2),
        Expanded(
          child: PrimaryButton(
            label: 'Save chit',
            onPressed: ref.read(composerControllerProvider.notifier).save,
          ),
        ),
      ],
    );
  }
}
