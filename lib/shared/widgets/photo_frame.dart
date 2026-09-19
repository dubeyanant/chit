import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/extensions.dart';
import '../../domain/photo_file.dart';
import 'buttons.dart';

final class PhotoFrame extends ConsumerWidget {
  const PhotoFrame({required this.path, this.onRemove, super.key});

  static const double height = 168;

  final String path;

  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final space = context.space;

    final Widget frame = ClipRRect(
      borderRadius: BorderRadius.circular(space.radius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: colors.hair),
          borderRadius: BorderRadius.circular(space.radius),
        ),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: ref
              .watch(photoFileProvider(path))
              .maybeWhen(
                data: (String file) => Image.file(
                  File(file),
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext _, Object _, StackTrace? _) =>
                      const SizedBox.shrink(),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
        ),
      ),
    );

    final VoidCallback? remove = onRemove;
    if (remove == null) {
      return Semantics(image: true, label: 'Photo', child: frame);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Semantics(image: true, label: 'Photo', child: frame),
        ),
        SizedBox(width: space.s2),
        QuietButton(label: 'Remove', onPressed: remove),
      ],
    );
  }
}
