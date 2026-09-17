import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../../core/clock.dart';
import '../../domain/models/chit.dart';
import '../../domain/models/motion_state.dart';
import '../../domain/models/weather_condition.dart';
import '../audio/audio_store.dart';
import '../db/app_database.dart';
import '../db/daos/chit_dao.dart';

/// How many rows and how many recordings a [DebugSeeder] call touched.
typedef SeedOutcome = ({int rows, int recordings});

/// Twenty chits over six weeks, for looking at a calendar that would otherwise
/// be looked at empty — **DATA-MODEL.md §7**.
///
/// **Debug only, and behind a flag.** `main.dart` constructs this when
/// `--dart-define=CHIT_SEED=seed` or `=clear` is passed to a debug build and
/// never otherwise; a release build cannot reach it.
///
/// **Every seeded id starts with [idPrefix]**, and that is the whole of how the
/// rows are told apart from a person's own. Seeding is therefore idempotent —
/// a row whose id already exists is skipped — and [clear] deletes exactly
/// what was seeded and nothing else, with no ledger to keep and no column
/// added to the schema for a tool.
///
/// **Rows are dated relative to the day it runs**, so the busy days are always
/// yesterday and the day before, whichever day that is. That is what puts ten
/// marks on the timeline's strip (open item 15) and two step-four tiles on the
/// calendar without anyone having to write ten chits by hand.
///
/// It writes through the DAO rather than the repository because the repository
/// generates its ids, and a seeded row has to carry the one thing that makes
/// it clearable. The pairing ADR-006 protects still holds: `localDay` comes
/// from [Chit.localDayOf], the same function the repository uses.
///
/// The copy is four mundane words apiece, as DESIGN-LOG.md insists. A literary
/// placeholder makes a screen read as a demonstration, and would mislead here
/// exactly as it did there.
final class DebugSeeder {
  /// A seeder over the DAO, the audio store and the clock.
  ///
  // Assigned rather than initialising formals, for the reason
  // `ChitRepositoryImpl` gives: a named parameter cannot be private.
  // ignore_for_file: prefer_initializing_formals
  const DebugSeeder({
    required ChitDao dao,
    required AudioStore audio,
    required Clock clock,
  }) : _dao = dao,
       _audio = audio,
       _clock = clock;

  /// What every seeded id begins with.
  static const String idPrefix = 'seed-';

  /// The value of `CHIT_SEED` that writes the fixture.
  static const String modeSeed = 'seed';

  /// The value of `CHIT_SEED` that removes it.
  static const String modeClear = 'clear';

  /// How many chits the fixture holds.
  static int get count => _fixture.length;

  final ChitDao _dao;
  final AudioStore _audio;
  final Clock _clock;

  /// Runs [seed] or [clear] for [mode] and says what happened, in one line
  /// for the console.
  ///
  /// Throws [ArgumentError] for any other value, which is a typo on the
  /// command line and should be loud.
  Future<String> apply(String mode) async {
    switch (mode) {
      case modeSeed:
        final SeedOutcome done = await seed();
        return 'chit: seeded ${done.rows} rows and ${done.recordings} '
            'recordings (${count - done.rows} were already there)';
      case modeClear:
        final SeedOutcome done = await clear();
        return 'chit: cleared ${done.rows} seeded rows and '
            '${done.recordings} recordings';
      default:
        throw ArgumentError.value(
          mode,
          'mode',
          'CHIT_SEED takes "$modeSeed" or "$modeClear"',
        );
    }
  }

  /// Writes every fixture row that is not already there.
  Future<SeedOutcome> seed() async {
    final DateTime now = _clock.now();
    int rows = 0;
    int recordings = 0;

    for (final (int index, _Seed seed) in _fixture.indexed) {
      final String id = _idOf(index);
      if (await _dao.byId(id) != null) continue;

      final DateTime at = Chit.startOfLocalDay(
        now,
        offsetDays: -seed.daysAgo,
      ).add(Duration(hours: seed.hour, minutes: seed.minute));

      String? audioPath;
      if (seed.audioSeconds != null) {
        audioPath = await _audio.keep(
          tempPath: await _placeholderRecording(id),
          chitId: id,
        );
        recordings++;
      }

      final bool pinned = seed.pinned;
      await _dao.insertRow(
        ChitsCompanion.insert(
          id: id,
          createdAt: at.millisecondsSinceEpoch,
          localDay: Chit.localDayOf(at),
          // Saved and never edited, so the two are the same moment (ADR-014).
          updatedAt: at.millisecondsSinceEpoch,
          body: Value<String?>(seed.text),
          textOrigin: Value<TextOrigin?>(seed.origin),
          audioPath: Value<String?>(audioPath),
          audioMs: Value<int?>(
            seed.audioSeconds == null ? null : seed.audioSeconds! * 1000,
          ),
          weather: Value<WeatherCondition?>(seed.weather),
          lat: Value<double?>(pinned ? _lat + index * _jitter : null),
          lon: Value<double?>(pinned ? _lon - index * _jitter : null),
          motion: Value<MotionState?>(seed.motion),
        ),
      );
      rows++;
    }

    return (rows: rows, recordings: recordings);
  }

  /// Deletes every seeded row, and the recording each one pointed at.
  ///
  /// Files first, then rows: a row that outlives its file renders as a chit
  /// without a pill (DATA-MODEL.md §5), whereas a file that outlives its row
  /// is an orphan until the next sweep. Neither is harmful, and the order
  /// only decides which one a crash between the two leaves behind.
  Future<SeedOutcome> clear() async {
    int recordings = 0;

    for (final ChitRow row in await _dao.rowsWithIdPrefix(idPrefix)) {
      final String? path = row.audioPath;
      if (path == null) continue;

      final File file = await _audio.resolve(path);
      if (file.existsSync()) {
        await file.delete();
        recordings++;
      }
    }

    final int rows = await _dao.deleteWithIdPrefix(idPrefix);
    return (rows: rows, recordings: recordings);
  }

  static String _idOf(int index) =>
      '$idPrefix${(index + 1).toString().padLeft(2, '0')}';

  /// A few bytes in the system temp directory, for [AudioStore.keep] to move.
  ///
  /// Not audio. It exists so that a seeded recording is a file the row can
  /// point at, which is what a real one is; the pill that will one day play
  /// it is M5's, and these rows are cleared before then.
  static Future<String> _placeholderRecording(String id) async {
    final File file = File(p.join(Directory.systemTemp.path, 'chit-$id.m4a'));
    await file.writeAsString('seeded by DebugSeeder; not a recording');
    return file.path;
  }

  /// Somewhere in Mumbai. Stored and never displayed, like every fix.
  static const double _lat = 19.076;
  static const double _lon = 72.8777;

  /// A few streets per row, so no two seeded fixes are the same point.
  static const double _jitter = 0.0007;

  /// The twenty. Grouped by day, newest day first, and within a day in no
  /// particular order — the DAO sorts.
  ///
  /// Density steps: two days at five (step four), one at three, one at two,
  /// five singles. Shapes: sixteen typed, one transcript, two corrected
  /// transcripts, one recording with nothing recognised (§3.5). Every weather
  /// word appears, one row has no fix, one has no weather, and the three
  /// motion marks appear once or twice each.
  static const List<_Seed> _fixture = <_Seed>[
    // Yesterday — five, one of them recorded, two of them on the move.
    _Seed(
      1,
      21,
      48,
      'Called Ma. Told her about the flat.',
      WeatherCondition.clearNight,
    ),
    _Seed(
      1,
      19,
      5,
      'Market. Forgot the dal again.',
      WeatherCondition.windy,
      origin: TextOrigin.transcript,
      audioSeconds: 14,
      motion: MotionState.walking,
    ),
    _Seed(
      1,
      18,
      52,
      'Bus stuck at the signal.',
      WeatherCondition.windy,
      motion: MotionState.traveling,
    ),
    _Seed(
      1,
      13,
      15,
      'Lunch at the desk. Fourth day.',
      WeatherCondition.overcast,
    ),
    _Seed(1, 7, 40, 'Ran 4k. Knee held up.', WeatherCondition.clear),

    // The day before — five, with §3.5's recording and a six-minute burst.
    _Seed(2, 23, 55, null, WeatherCondition.clearNight, audioSeconds: 47),
    _Seed(
      2,
      18,
      30,
      'Tea with S. Good one.',
      WeatherCondition.overcast,
      origin: TextOrigin.transcriptEdited,
      audioSeconds: 9,
    ),
    _Seed(
      2,
      12,
      10,
      'Reorg meeting pushed again. Third time.',
      WeatherCondition.overcast,
      motion: MotionState.traveling,
    ),
    _Seed(2, 12, 4, 'Left the charger at home.', WeatherCondition.overcast),
    _Seed(2, 9, 10, 'Train 20 late.', WeatherCondition.raining),

    // Singles and pairs back through the month.
    _Seed(4, 22, 2, 'Nothing today.', WeatherCondition.raining, pinned: false),
    _Seed(
      6,
      8,
      5,
      "Didn't sleep. Room too cold, again.",
      WeatherCondition.clear,
      origin: TextOrigin.transcriptEdited,
      audioSeconds: 22,
    ),
    _Seed(6, 20, 30, 'Landlord called. Rent up.', null),
    _Seed(9, 14, 20, 'Dentist. Not as bad.', WeatherCondition.overcast),

    // A three-chit day — density step three, the first one item 12 fails on.
    _Seed(
      12,
      7,
      55,
      'Ran 5k. Slow.',
      WeatherCondition.clear,
      motion: MotionState.walking,
    ),
    _Seed(12, 13, 0, 'Fish for lunch. Regret.', WeatherCondition.clear),
    _Seed(12, 21, 15, 'Read forty pages.', WeatherCondition.clearNight),

    // Three in the previous month, so the chevrons have somewhere to go.
    _Seed(20, 10, 30, 'Long call with the bank.', WeatherCondition.raining),
    _Seed(
      35,
      11,
      20,
      'Window seat. Clouds all the way.',
      null,
      motion: MotionState.flying,
    ),
    _Seed(41, 9, 12, 'New month. Same desk.', WeatherCondition.clear),
  ];
}

/// One fixture row, relative to the day the seeder runs.
final class _Seed {
  const _Seed(
    this.daysAgo,
    this.hour,
    this.minute,
    this.text,
    this.weather, {
    TextOrigin origin = TextOrigin.typed,
    this.audioSeconds,
    this.motion,
    this.pinned = true,
  }) : _originGiven = origin,
       assert(
         text != null || audioSeconds != null,
         'a seeded chit is still a chit — README §5',
       );

  final int daysAgo;
  final int hour;
  final int minute;
  final String? text;
  final WeatherCondition? weather;
  final int? audioSeconds;
  final MotionState? motion;
  final bool pinned;

  /// Ignored when [text] is null, as the invariant requires.
  final TextOrigin _originGiven;

  /// The origin the row carries: null exactly when the text is.
  TextOrigin? get origin => text == null ? null : _originGiven;
}
