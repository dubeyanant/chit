import 'package:flutter/material.dart';

import '../../core/extensions.dart';
import 'buttons.dart';
import 'perforated_edge.dart';

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

final class PromptSheet extends StatelessWidget {
  const PromptSheet({
    required this.question,
    required this.keep,
    required this.letGo,
    this.detail,
    super.key,
  });

  final String question;

  final String? detail;

  final String keep;

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
