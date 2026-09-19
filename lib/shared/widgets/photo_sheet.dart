import 'package:flutter/material.dart';

import '../../core/extensions.dart';
import '../../domain/services/photo_source.dart';
import 'buttons.dart';
import 'perforated_edge.dart';

Future<PhotoOrigin?> showPhotoSheet(BuildContext context) =>
    showModalBottomSheet<PhotoOrigin>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: context.colors.scrim,
      useSafeArea: true,
      builder: (BuildContext _) => const PhotoSheet(),
    );

final class PhotoSheet extends StatelessWidget {
  const PhotoSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;

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
                  child: Text(
                    'A photo for this chit',
                    style: context.type.chitText,
                  ),
                ),
                SizedBox(height: space.s5),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: PrimaryButton(
                        label: 'Take one',
                        onPressed: () async =>
                            Navigator.of(context).pop(PhotoOrigin.camera),
                      ),
                    ),
                    SizedBox(width: space.s2),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Choose one',
                        onPressed: () async =>
                            Navigator.of(context).pop(PhotoOrigin.library),
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
