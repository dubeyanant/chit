/// The line find opens with — BEHAVIOUR.md §4.6.
///
/// **Two books in one slot** (ADR-086): mostly house lines, and every fourth
/// day a hint about something the app does not otherwise say out loud. A hint
/// that lived permanently under the thing it described would be chrome on the
/// two sparest screens in the app; one that comes round twice a week is read
/// once and then recognised.
abstract final class FindLine {
  /// The longest a line may be, counted in characters.
  ///
  /// Two lines of the quote face at the gutter, which is what the screen has
  /// room for above a bottom-anchored column. A test counts them.
  static const int longest = 92;

  /// One day in [every] draws a hint instead of a line.
  static const int every = 4;

  /// **House lines, not quotations.** Nothing here is attributed, because a
  /// misattributed quotation is a defect that ships and cannot be checked
  /// from inside the app.
  static const List<String> quotes = <String>[
    'A day you do not write down is a day you take on trust.',
    'You are not keeping a record. You are keeping company.',
    'The weather was doing something while you were busy.',
    'Nothing here is for anybody else to read.',
    'Most of a life is the parts nobody thought to mention.',
    'You remember the loud days. This is for the other ones.',
    'A short note now beats a long one never.',
    'The point was never the writing. It was the noticing.',
    'Half a sentence is still more than nothing.',
    'What you wrote down is the only part that waited.',
    'A week is seven days, and you will remember two.',
    'You can only look back through what you left behind.',
    'The small hours keep better notes than the busy ones.',
    'Every chit is a place you were standing.',
    'Memory edits. Paper does not.',
    'You will want this later, and later is bad at guessing.',
    'The thing you nearly forgot is usually the thing.',
    'Write it before you decide whether it mattered.',
    'A mood passes. A line about it does not.',
    'Nobody is grading the handwriting.',
    'What was the sky doing? You wrote it down, so you know.',
    'The days blur. The notes do not.',
    'Not a diary. Just somewhere to put things.',
    'You were somewhere, and it was some kind of afternoon.',
    'A thought you do not catch goes back to being weather.',
    'The ordinary day is the one worth the ink.',
    'Later, this will read like somebody else wrote it.',
    'You are allowed to write nothing today.',
    'There is no streak here, and nothing is counting.',
    'A note is a favour to whoever you are next year.',
    'The good ones are rarely the ones you laboured over.',
    'Say the small thing. The big one is usually made of it.',
    'It does not have to be true tomorrow.',
    'Two lines on a wet Tuesday outlast a resolution.',
    'You noticed something. That is the whole of it.',
    'The page is not waiting for anything in particular.',
    'Nothing written here is going anywhere.',
    'A record of moods is a map of a year.',
    'You were walking, and then you were not.',
    'Whatever it was, it was worth eleven words.',
    'The past keeps changing. Your notes do not.',
    'What did today feel like? There is still time to say.',
    'Write badly. Nobody is here.',
    'An afternoon you can name is an afternoon you keep.',
    'This is the quiet part of the day, put somewhere.',
  ];

  /// What the app does that nothing on screen says.
  ///
  /// Each earns its place by being **undiscoverable**: a gesture, a rotation,
  /// or a piece of syntax. Nothing here restates what a screen already shows.
  static const List<String> hints = <String>[
    'Write @a_name or #a_topic, and tap it later to find every chit with it.',
    'An underscore in a tag reads as a space: @first_last, #morning_pages.',
    'The question on an empty chit is a different one every time.',
    'Hold a chit anywhere to open it again, or to throw it away.',
    'A chit is stamped when you save it, never when you opened it.',
    'This line changes daily, and every fourth day it explains something.',
    'Tapping a tag from inside another tag takes you straight across.',
  ];

  /// One line, the same all day and different tomorrow.
  ///
  /// **Not random**: a line that changed on every glance would be an ambient
  /// loop (ADR-027), and a book indexed by the day is testable without a
  /// seeded `Random` and without reading a clock in here.
  static String forDay(int localDay) {
    final int i = localDay.abs();

    return i % every == 0
        ? hints[(i ~/ every) % hints.length]
        : quotes[i % quotes.length];
  }

  /// Both books, for the tests that hold every line to the same rules.
  static List<String> get all => <String>[...quotes, ...hints];
}
