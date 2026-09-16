import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions.dart';
import '../../../core/theme/chit_colors.dart';
import '../../../core/theme/chit_motion.dart';
import '../../../domain/models/composer_state.dart';
import '../../../shared/widgets/ambient_stamp_row.dart';
import '../../../shared/widgets/slip.dart';
import '../application/composer_controller.dart';

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
          SizedBox(height: space.s4),
          const _Field(),
          SizedBox(height: space.s4),
          _ActionRow(canSave: state.canSave),
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
/// here, and §3.5's failure note lands in this same overlay in M5 for the same
/// reason — what the machine writes never goes into the field.
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

/// The microphone, then what to do with what has been written.
///
/// BEHAVIOUR.md §4.1: *the row reads left to right — the way in, then what to
/// do with it.* The microphone leads at the full 54px, and **Discard** and
/// **Save chit** arrive to its right as soon as the chit holds anything.
class _ActionRow extends ConsumerWidget {
  const _ActionRow({required this.canSave});

  final bool canSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final motion = context.motion;

    return Row(
      children: <Widget>[
        const _Microphone(),
        SizedBox(width: context.space.s2),
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

/// Drawn in M2, and it does nothing until M5.
///
/// It is here because BEHAVIOUR.md §4.1's layout has to be final — what keeps
/// the microphone an equal is size and placement, and both are decided by
/// where it sits next to the two controls. **It is not marked up as a
/// control**, because it is not one yet: DESIGN-SYSTEM.md §6.4 does not allow
/// a control that does nothing, and the settings gear was deleted under the
/// same rule. M5 gives it an action, a label and a pressed wash together.
class _Microphone extends StatelessWidget {
  const _Microphone();

  /// 54px — one of the four dimensions DESIGN-SYSTEM.md §6.3 allows off the
  /// scale, and **its target does not shrink when text appears** (§6.4).
  static const double size = 54;

  /// The stroke the icon set holds, in the prototype's 20-unit box.
  static const double _strokeInViewBox = 1.22;

  /// The icon's own box, drawn at 20 of the 54.
  static const double _icon = 20;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // No `Semantics` and no `ExcludeSemantics`: a box and a painter carry none
    // of their own, so doing nothing here is what leaves it unmarked. Adding
    // `ExcludeSemantics` would say the same thing louder and imply there was
    // something to suppress.
    return SizedBox.square(
      key: OpenChit.microphone,
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: colors.hair),
          borderRadius: BorderRadius.circular(context.space.radius),
        ),
        child: Center(
          child: CustomPaint(
            size: const Size.square(_icon),
            painter: _MicrophonePainter(
              colour: colors.inkMuted,
              strokeWidth: _strokeInViewBox,
            ),
          ),
        ),
      ),
    );
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
class _CommitControls extends ConsumerWidget {
  const _CommitControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final space = context.space;

    return Row(
      children: <Widget>[
        _Discard(
          onPressed: ref.read(composerControllerProvider.notifier).discard,
        ),
        SizedBox(width: space.s2),
        Expanded(
          child: _Save(
            onPressed: ref.read(composerControllerProvider.notifier).save,
          ),
        ),
      ],
    );
  }
}

/// The quietest of the three. No outline, and no colour of its own.
class _Discard extends StatefulWidget {
  const _Discard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_Discard> createState() => _DiscardState();
}

class _DiscardState extends State<_Discard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;

    return Semantics(
      button: true,
      child: GestureDetector(
        onTapDown: (TapDownDetails _) => setState(() => _pressed = true),
        onTapUp: (TapUpDetails _) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(
            // Decision 4 of TASKS.md group A. v6 pressed this in `--hair-soft`,
            // which measures 1.0145:1 on a chit and is in practice not drawn
            // at all; an ink wash measures 1.17:1. Under reduced motion, where
            // the depress is gone (§6.4), this wash is the *only*
            // acknowledgement the press produces.
            color: _pressed
                ? colors.inkWash(
                    colors.slip,
                    opacity: ChitColors.discardPressedWash,
                  )
                : null,
            borderRadius: BorderRadius.circular(space.radius),
          ),
          child: Padding(
            // 14px by 16px in the prototype; both are `s4`. A padding is a
            // relationship and DESIGN-SYSTEM.md §6.3 keeps those on the scale.
            // At 16px the control measures 49px, clear of §6.4's 44px floor.
            padding: EdgeInsets.all(space.s4),
            child: Text(
              'Discard',
              // The label lifts to `--ink` while it is held. `--ink-faint`
              // clears the floor on a bare chit at 4.56:1 and falls under it
              // on any wash at all — 4.12:1 at even 4%. DESIGN-SYSTEM.md §6.1.
              style: context.type.button.copyWith(
                color: _pressed ? colors.ink : colors.inkFaint,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// **Save chit** — the brightest of the three, and still not a fill.
///
/// The only thing in the app that writes a row (ARCHITECTURE.md §4.1). What it
/// hands the repository is the stamp the chit has held since it opened, never
/// a fresh one — ADR-021 — and pressing it opens a new chit the way Discard
/// does (ADR-026). Both of those live in `ComposerController.save`, because
/// neither is a decision a button should be making.
class _Save extends StatelessWidget {
  const _Save({required this.onPressed});

  /// Writes the chit. Asynchronous, and nothing here waits on it: the state
  /// the button is drawn from changes when the save returns.
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;

    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.inkWash(colors.slip, opacity: ChitColors.saveWash),
            border: Border.all(color: colors.inkMuted),
            borderRadius: BorderRadius.circular(space.radius),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: space.s4),
            child: Text(
              'Save chit',
              textAlign: TextAlign.center,
              style: context.type.button.copyWith(color: colors.ink),
            ),
          ),
        ),
      ),
    );
  }
}
