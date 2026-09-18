import 'package:flutter/material.dart';

import '../../core/extensions.dart';
import 'buttons.dart';
import 'perforated_edge.dart';

/// Asks one question and returns whether the **letting-go** answer was chosen
/// — **ADR-064**, the app's confirmation idiom.
///
/// The first prompt of any kind in chit, so its shape is what every later one
/// inherits: a slip rising from below, the same paper as the recording sheet
/// (perforated edge, `sheetRadius`, the scrim), a question in the chit's own
/// face, and two answers in the two button weights of DESIGN-SYSTEM.md §6.1.
///
/// **The quiet weight is always the answer that lets something go** — Discard
/// on the edit, Delete on the chit — and the bright one is always the answer
/// that keeps. That is the same ranking the recording sheet and the pill
/// already use, so a thumb that has learned one has learned them all.
///
/// **Every other way out keeps.** The drag, the scrim and the back gesture all
/// answer `false`, for the reason the recording sheet treats them as a cancel:
/// a dismissal nobody chose must land on the outcome that costs nothing.
///
/// **It decides nothing**. Whether to ask is the controller's;
/// this only asks. A modal sheet and not a route, like the recording sheet
/// (ADR-011, ARCHITECTURE.md §3).
Future<bool> showPromptSheet(
  BuildContext context, {
  required String question,
  required String keep,
  required String letGo,
  String? detail,
}) async {
  final bool? letGone = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: context.colors.scrim,
    useSafeArea: true,
    builder: (BuildContext _) => PromptSheet(
      question: question,
      detail: detail,
      keep: keep,
      letGo: letGo,
    ),
  );
  return letGone ?? false;
}

/// The sheet [showPromptSheet] raises. Draws; does not decide.
final class PromptSheet extends StatelessWidget {
  /// A sheet asking [question], answered by [keep] or [letGo].
  const PromptSheet({
    required this.question,
    required this.keep,
    required this.letGo,
    this.detail,
    super.key,
  });

  /// *Keep this edit?* — a short question, the chit's face.
  final String question;

  /// One quieter line under it, when the answer has a consequence worth
  /// naming — *The recording goes with it.* Absent otherwise.
  final String? detail;

  /// The bright answer: what keeps. Pops `false`.
  final String keep;

  /// The quiet answer: what lets go. Pops `true`.
  final String letGo;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final type = context.type;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.slip,
        border: Border(top: BorderSide(color: colors.hair)),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(space.sheetRadius),
        ),
      ),
      child: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: space.s6,
              left: space.gutter,
              right: space.gutter,
              bottom: space.s5,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Semantics(
                  header: true,
                  child: Text(question, style: type.chitText),
                ),
                if (detail != null) ...<Widget>[
                  SizedBox(height: space.s2),
                  Text(detail!, style: type.emptyNote),
                ],
                SizedBox(height: space.s5),
                Row(
                  children: <Widget>[
                    QuietButton(
                      label: letGo,
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                    SizedBox(width: space.s2),
                    Expanded(
                      child: PrimaryButton(
                        label: keep,
                        onPressed: () async => Navigator.of(context).pop(false),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // The same tear edge as a chit and the recording sheet, `s2` in from
          // each end and sitting on the border rather than under it.
          Positioned(
            top: 0,
            left: space.s2,
            right: space.s2,
            child: const PerforatedEdge(),
          ),
        ],
      ),
    );
  }
}
