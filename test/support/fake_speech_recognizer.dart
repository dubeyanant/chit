import 'dart:async';

import 'package:chit/domain/services/speech_recognizer.dart';

/// A [SpeechRecognizer] that can be told to hear nothing — CLAUDE.md §4.1's
/// Liskov rule.
///
/// **It fails the way the real one fails, which is not at all** (ADR-053).
/// There is no error to inject and no exception to throw, because
/// `OnDeviceSpeechRecognizer` has neither: a phone with no on-device model,
/// one that refused to stay on the device, and a take in which nothing was
/// said all end as a stream that closed with nothing on it. A `canHear` of `false` is
/// every one of those three, which is exactly the claim §3.5 makes.
final class FakeSpeechRecognizer implements SpeechRecognizer {
  /// Whether a take produces any words at all.
  ///
  /// `false` closes the stream at once — the §3.5 branch, whatever caused it.
  bool canHear = true;

  /// How many takes have been stopped.
  int stops = 0;

  StreamController<Transcript>? _session;

  @override
  Stream<Transcript> start() {
    final StreamController<Transcript> session = StreamController<Transcript>();
    _session = session;
    if (!canHear) {
      // Closed before the caller has listened, the way the real one closes an
      // `initialize` that answered `false`. The done event still arrives.
      unawaited(session.close());
      _session = null;
    }
    return session.stream;
  }

  /// Delivers a partial result: [committed] words, with [pending] still being
  /// revised.
  ///
  /// The two halves are given rather than split from one string on purpose.
  /// *Where* the split falls is `OnDeviceSpeechRecognizer`'s rule and it has
  /// its own test; a fake that re-derived it would agree with the real one by
  /// construction and prove nothing about either.
  void hear({required String pending, String committed = ''}) =>
      _session?.add(Transcript(committed: committed, pending: pending));

  /// Delivers a settled result. Nothing is pending after one.
  void heard(String words) => _session?.add(Transcript(committed: words));

  @override
  Future<void> stop() async {
    stops++;
    final StreamController<Transcript>? session = _session;
    _session = null;
    await session?.close();
  }
}
