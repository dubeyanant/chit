import 'dart:async';

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

  /// The drawn caret, while it is on.
  ///
  /// Named for the same reason the microphone is: it carries rules and has no
  /// semantics and no words, so there is nothing else to find it by. It is
  /// **absent from the tree on the dark half of a blink**, which is what makes
  /// DESIGN-SYSTEM.md §6.4's *ambient loops stop outright* a thing a test can
  /// see rather than a thing a comment claims.
  static const Key caret = Key('open-chit-caret');

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
  final FocusNode _focus = FocusNode();

  /// Whether to draw the ghost's own caret.
  ///
  /// It says *ready* before the field has been touched, which is the whole
  /// job ADR-023 left it: the app opens with nothing focused, and without it
  /// the page is a blank area with no sign that it is live. Once the field is
  /// focused the framework draws the real one, and two carets is one too many.
  bool _drawCaret = true;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (_focus.hasFocus == !_drawCaret) return;
    setState(() => _drawCaret = !_focus.hasFocus);
  }

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocusChanged)
      ..dispose();
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
              focusNode: _focus,
              onChanged: ref.read(composerControllerProvider.notifier).edit,
              style: context.type.composerBody,
              // The caret is the accent's one job: it marks what is live
              // (ADR-022). Everything else on this slip is ink.
              cursorColor: colors.seal,
              cursorWidth: _Caret.width,
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
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            child: IgnorePointer(child: _Ghost(drawCaret: _drawCaret)),
          ),
      ],
    );
  }
}

/// The caret and the prompt, over an empty page — BEHAVIOUR.md §3.3.
///
/// **Not `hintText`.** A hint is a label on the field: it is announced as one,
/// it arrives on Material's schedule rather than after five seconds, and it
/// has nowhere to put the caret. ARCHITECTURE.md §4.1 warns that placeholder
/// text is the tempting shortcut here, and §3.5's failure note lands in this
/// same overlay in M5 for the same reason — what the machine writes never goes
/// into the field.
class _Ghost extends ConsumerWidget {
  const _Ghost({required this.drawCaret});

  /// The offer itself. A question, because §3.3 is an offer and not an
  /// instruction.
  static const String prompt = 'What just happened?';

  /// Whether the field is still untouched, and so still needs a caret drawn
  /// for it.
  final bool drawCaret;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool showPrompt = ref.watch(
      composerControllerProvider.select((ComposerState s) => s.showPrompt),
    );
    final motion = context.motion;

    return Row(
      // The caret has no baseline of its own, so the flex takes its height as
      // one — which is exactly `vertical-align`'s rule and puts its foot on
      // the line the prompt sits on.
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        _CaretSlot(draw: drawCaret),
        SizedBox(width: context.space.s1),
        // A fade and no rise, the same call group E made for Discard and Save:
        // the prototype lifts this 2px as it arrives, and §6.3's table gives
        // the prompt a pace of its own rather than filing it under authored
        // arrival. **It survives reduced motion at 140ms** — the appearance is
        // the whole event here, so collapsing it would delete the behaviour
        // rather than calm it (ARCHITECTURE.md §4.3).
        AnimatedOpacity(
          opacity: showPrompt ? 1 : 0,
          duration: motion.fade(ChitPace.prompt),
          curve: motion.curve,
          child: Text(prompt, style: context.type.composerGhost),
        ),
      ],
    );
  }
}

/// The caret's place in the ghost line, whether or not one is drawn.
///
/// Kept at a fixed width so that focusing the field does not shift the prompt
/// sideways by the width of a caret.
class _CaretSlot extends StatelessWidget {
  const _CaretSlot({required this.draw});

  /// Whether a caret is drawn in the slot. When it is not, the slot still
  /// holds its width — and the caret's ticker is gone with the widget rather
  /// than left running behind a hidden box.
  final bool draw;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _Caret.width,
      height: _Caret.heightOn(context),
      child: draw ? const _Caret() : null,
    );
  }
}

/// The drawn caret: `--seal`, and blinking unless the user asked it not to.
///
/// DESIGN-SYSTEM.md §6.4 lists the caret blink among the app's ambient loops,
/// so the period is asked of `ChitMotion.loop` rather than run outright. Under
/// reduced motion it comes back as zero, no ticker starts, and the caret is
/// drawn at rest — **visible, and still**. Stopping it by hiding it would take
/// away the one thing telling the user the page is live, and §6.4's rule is
/// that movement collapses while feedback does not.
class _Caret extends StatefulWidget {
  const _Caret();

  /// 1.5px — the field's own caret width as well, so there is one number
  /// behind both and they cannot come to disagree.
  static const double width = 1.5;

  /// One full blink; on for half of it, off for the other half.
  static const Duration blink = Duration(milliseconds: 1150);

  /// `height: 1.05em` and `vertical-align: -.18em`, in the field's own type
  /// size rather than as two more numbers.
  static const double _heightEm = 1.05;
  static const double _dropEm = 0.18;

  /// How tall the caret stands at the field's current type size.
  static double heightOn(BuildContext context) =>
      context.type.composerGhost.fontSize! * _heightEm;

  @override
  State<_Caret> createState() => _CaretState();
}

class _CaretState extends State<_Caret> {
  Timer? _timer;
  Duration? _period;
  bool _on = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final Duration period = context.motion.loop(_Caret.blink);
    if (period == _period) return;
    _period = period;

    _timer?.cancel();
    _timer = null;
    _on = true;
    if (period == Duration.zero) return;

    // A `Timer` rather than an `AnimationController`: the blink is a step and
    // not a curve, and a controller that repeats for ever schedules a frame
    // for ever, which is a `pumpAndSettle` that never settles.
    _timer = Timer.periodic(
      period ~/ 2,
      (Timer _) => setState(() => _on = !_on),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, context.type.composerGhost.fontSize! * _Caret._dropEm),
      child: _on
          ? ColoredBox(key: OpenChit.caret, color: context.colors.seal)
          : null,
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
        // Save is wired to the repository in TASKS.md group G, with the thread
        // that would show the result of pressing it. It is drawn here because
        // §4.1's action row is a layout that has to be settled as one thing.
        const Expanded(child: _Save()),
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
/// Its action arrives with TASKS.md group G, which is where the thread that
/// shows the saved chit is built. Until then this is a drawn control with
/// nothing behind it, which is a state the milestone plans and this comment
/// exists so that nobody has to guess whether it is a bug.
class _Save extends StatelessWidget {
  const _Save();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;

    return DecoratedBox(
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
    );
  }
}
