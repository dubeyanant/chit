import 'package:flutter/material.dart';

import '../../core/extensions.dart';
import '../../domain/guide.dart';
import 'buttons.dart';
import 'perforated_edge.dart';

Future<void> showGuideSheet(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  backgroundColor: Colors.transparent,
  barrierColor: context.colors.scrim,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (BuildContext _) => const GuideSheet(),
);

final class GuideSheet extends StatelessWidget {
  const GuideSheet({super.key});

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
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          Guide.again,
                          style: type.emptyNote.copyWith(
                            color: colors.inkFaint,
                          ),
                        ),

                        for (final GuideEntry entry in Guide.entries) ...[
                          SizedBox(height: space.s5),
                          Semantics(
                            header: true,
                            child: Text(entry.title, style: type.chitText),
                          ),
                          SizedBox(height: space.s2),
                          Text(entry.words, style: type.emptyNote),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(height: space.s5),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: PrimaryButton(
                        label: 'Close',
                        onPressed: () async => Navigator.of(context).pop(),
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
