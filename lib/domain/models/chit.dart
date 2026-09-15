// Whitespace-only text is the same nothing, and is caught by the check
// constraint on the table and by the repository, which normalises it to
// null before it ever gets here. A const constructor's assert cannot call
// trim(), so this one catches the empty string and leaves the rest to the
// other two places the invariant is held.
@Assert(
  "text == null || text != ''",
  'empty text is no text: an empty field is the chit §3.1 refuses to save',
)
import 'package:freezed_annotation/freezed_annotation.dart';

import 'ambient_stamp.dart';
import 'weather_condition.dart';

part 'chit.freezed.dart';

/// Where a chit's words came from. Provenance, and nothing else.
///
/// Nothing in the UI renders differently because of it (ADR-013). It exists so
/// a future re-transcription (OPEN-QUESTIONS.md §8.2) can tell whether it
/// would be overwriting the machine's words or the user's.
enum TextOrigin {
  /// Typed by hand, start to finish.
  typed,

  /// The recogniser's words, untouched.
  transcript,

  /// The recogniser's words, corrected by the user — or a recording made into
  /// a chit that already held typed text. A one-way move: [transcript] becomes
  /// this on the first keystroke and never goes back.
  transcriptEdited,
}

/// One entry. Text, a recording, or both — never neither.
///
/// The invariant of README §5 is held in three places, because one is not
/// enough (DATA-MODEL.md §2): the asserts below, a table check constraint, and
/// the repository tests. This is the first of the three, and the only one that
/// fails at the moment the wrong object is built.
///
/// There is no `source` field and no union of "typed" against "spoken". A
/// chit is asked [hasText] and [hasAudio], which is what a screen actually
/// wants to know; four shapes that differ only by which fields are populated
/// buy ceremony rather than safety (ADR-013).
@freezed
abstract class Chit with _$Chit {
  /// Lets this class carry getters and statics. Freezed requires it.
  const Chit._();

  /// A saved chit, exactly as its row holds it.
  ///
  /// Building an illegal shape throws in development and is refused by the
  /// database in production.
  @Assert(
    'text != null || audioPath != null',
    'a chit with neither text nor audio is not a chit — README §5',
  )
  @Assert(
    '(text == null) == (textOrigin == null)',
    'textOrigin is null exactly when text is — DATA-MODEL.md §2',
  )
  // Whitespace-only text is the same nothing, and is caught by the check
  // constraint on the table and by the repository, which turns it into null
  // before it can ever reach here. A const constructor's assert cannot call
  // `trim()`, so this one catches the empty string and leaves the rest to the
  // other two places DATA-MODEL.md §2 holds the invariant.
  @Assert(
    "text == null || text != ''",
    'empty text is no text: an empty field is the chit §3.1 refuses to save',
  )
  @Assert(
    '(lat == null) == (lon == null)',
    'a coordinate is both halves or neither',
  )
  @Assert(
    '(audioPath == null) == (audioDuration == null)',
    'a recording has a length; a length without a recording is nothing',
  )
  const factory Chit({
    /// A UUID, generated on the device (ADR-004).
    required String id,

    /// When the chit was opened. Drives the day arc and the ambient stamp.
    required DateTime createdAt,

    /// `yyyymmdd` in the device's zone at the moment it was written, read
    /// straight from its column and **never recomputed** (ADR-006). A chit
    /// written at 00:20 IST belongs to that morning after the device moves to
    /// another timezone, which is only true because this is stored rather
    /// than derived from [createdAt] on read.
    required int localDay,

    /// When the row was last written: the moment it was saved, and then the
    /// moment of every edit after that (ADR-014).
    required DateTime updatedAt,

    /// What the chit says. `null` only when a recording produced nothing and
    /// the user wrote nothing either — BEHAVIOUR.md §3.5.
    String? text,

    /// Where [text] came from. `null` exactly when [text] is.
    TextOrigin? textOrigin,

    /// The recording, relative to the app documents directory (ADR-008).
    /// Absolute paths die on the next iOS update.
    String? audioPath,

    /// How long the recording runs. The audio pill's duration.
    Duration? audioDuration,

    /// The condition when the chit was opened, if it arrived (ADR-007).
    WeatherCondition? weather,

    /// Latitude, if a fix arrived. Stored, never displayed.
    double? lat,

    /// Longitude, if a fix arrived. Stored, never displayed.
    double? lon,
  }) = _Chit;

  /// The local day a moment belongs to, as `yyyymmdd`.
  ///
  /// The one place that turns a wall clock into a day (ADR-006). Called by the
  /// repository at write time and by nothing at read time — the answer is
  /// stored so that it cannot change when the device does.
  static int localDayOf(DateTime when) =>
      when.year * 10000 + when.month * 100 + when.day;

  /// The three signals of BEHAVIOUR.md §3.6, as the one row they are drawn as.
  AmbientStamp get stamp =>
      AmbientStamp(capturedAt: createdAt, weather: weather, lat: lat, lon: lon);

  /// Whether the chit says anything.
  bool get hasText => text != null;

  /// Whether the chit has a recording. There is no mode to ask instead
  /// (ADR-013) — this is the question, and the audio pill is the answer.
  bool get hasAudio => audioPath != null;
}
