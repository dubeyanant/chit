import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'speech_recognizer.g.dart';

/// What has been recognised so far, split where BEHAVIOUR.md §3.4 draws it.
///
/// The recogniser revises its last word as it hears more of it, so the sheet
/// shows that word in lighter ink until it settles. **The split is a fact
/// about the display, not about the text** — [words] is what goes into the
/// field, and it takes both halves, because Stop & keep can land mid-revision
/// and a word being revised is still a word that was said.
@immutable
final class Transcript {
  /// The [committed] words and the [pending] one still being revised.
  const Transcript({this.committed = '', this.pending = ''});

  /// Nothing heard. The first value of every take and, where recognition
  /// fails, the only one — BEHAVIOUR.md §3.5.
  static const Transcript nothing = Transcript();

  /// The words the recogniser has settled on. The sheet draws these in `--ink`.
  final String committed;

  /// The one word still being revised — §3.4's lighter-ink word. Empty on a
  /// settled result, since then there is nothing left to revise.
  final String pending;

  /// Every word, committed and pending, as it goes into the field.
  String get words {
    if (pending.isEmpty) return committed;
    if (committed.isEmpty) return pending;
    return '$committed $pending';
  }

  /// Nothing was recognised — the §3.5 branch, and not an error.
  bool get isEmpty => words.isEmpty;

  @override
  bool operator ==(Object other) =>
      other is Transcript &&
      other.committed == committed &&
      other.pending == pending;

  @override
  int get hashCode => Object.hash(committed, pending);

  @override
  String toString() => 'Transcript($committed | $pending)';
}

/// Turns speech into words on the device — ADR-005, BEHAVIOUR.md §3.4.
///
/// One take at a time, beside `AudioRecorder` rather than over it: the
/// recogniser takes no file and no stream, so both listen at once and neither
/// knows about the other (TASKS.md D1).
///
/// **It never throws, and it has no error branch.** A recogniser with no
/// on-device model, one that refused to stay on the device, and a take in
/// which nothing was heard all answer the same way — a stream that closes
/// having emitted nothing. §3.5 is one branch because from the user's side
/// those are one event (ADR-005). A fake must fail that way too, or the §3.5
/// tests mean nothing — CLAUDE.md §4.1's Liskov rule.
abstract interface class SpeechRecognizer {
  /// Begins a take, and reports the transcript as it accrues.
  ///
  /// The stream closes when the take ends — on [stop], when the platform gives
  /// up, or at the first thing that goes wrong. **Its last value is the
  /// transcript to keep**, so the sheet holds what it last saw rather than
  /// asking again (TASKS.md D6); a stream that closes without a value is §3.5.
  Stream<Transcript> start();

  /// Ends the take, and completes once the stream has closed.
  ///
  /// It waits a beat for the recogniser's last word rather than cutting it off
  /// (ADR-053) — bounded, so Stop & keep is never held open by a platform that
  /// has stopped answering.
  Future<void> stop();
}

/// The recogniser the app runs on.
///
/// Unimplemented on purpose, for the reason `audioRecorderProvider` is:
/// `domain` cannot import `data` (ARCHITECTURE.md §1), so `main.dart` supplies
/// `OnDeviceSpeechRecognizer` and tests supply a fake.
@Riverpod(keepAlive: true)
SpeechRecognizer speechRecognizer(Ref ref) => throw UnimplementedError(
  'speechRecognizerProvider is overridden at the root — see main.dart',
);
