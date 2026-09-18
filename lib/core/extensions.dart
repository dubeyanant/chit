import 'package:flutter/material.dart';

import 'theme/chit_colors.dart';
import 'theme/chit_motion.dart';
import 'theme/chit_space.dart';
import 'theme/chit_type.dart';

extension ChitThemeContext on BuildContext {
  ChitColors get colors => Theme.of(this).extension<ChitColors>()!;

  ChitType get type => Theme.of(this).extension<ChitType>()!;

  ChitSpace get space => Theme.of(this).extension<ChitSpace>()!;

  ChitMotion get motion =>
      Theme.of(this)
          .extension<ChitMotion>()!
          .resolve(reduceMotion: MediaQuery.disableAnimationsOf(this));
}
