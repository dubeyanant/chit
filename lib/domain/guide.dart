import 'package:flutter/foundation.dart';

@immutable
final class GuideEntry {
  const GuideEntry({required this.title, required this.words});

  final String title;

  final String words;
}

abstract final class Guide {
  static const int longestTitle = 34;

  static const int longestWords = 190;

  static const List<GuideEntry> entries = <GuideEntry>[
    GuideEntry(
      title: 'Hold a chit to open it',
      words:
          'A tap does nothing — the thread is for reading. Holding a chit '
          'opens it, and there you can change its words, swap or drop its '
          'recording and its photo, or delete the chit itself.',
    ),
    GuideEntry(
      title: 'Write @ for a person',
      words:
          'Put @ in front of a name — @anant — and it becomes a way back. '
          'Tap it in any chit to see everything that names them.',
    ),
    GuideEntry(
      title: 'Write # for a topic',
      words:
          'Put # in front of a word — #sleep — and every chit carrying it '
          'gathers under that word in find.',
    ),
  ];
}
