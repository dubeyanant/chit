# chit

A private journal for things that hit you during the day.

The name is a wordplay. **चित्त** (*chitta*) is Sanskrit for consciousness, mind, the field
where impressions land. A **chit** is also a small slip of paper you scribble something on
and keep. The app is both: a place where passing impressions get written down on small slips.

---

## 0. Start here

**This file is the front door, not the whole house.** It holds what chit is (§1–§2) and what a
chit is (§5), and §10 maps everything else. The behaviour specification, the design system and
the open questions live in their own documents — they are still the design authority, they are
just not all in one 500-line file.

Read these four, in this order. It is about ten minutes and it is the whole context.

| # | Read | For |
|---|---|---|
| 1 | **[`docs/PROGRESS.md`](docs/PROGRESS.md)** | **Where the build stands and what to do next.** The status board, what is on a handset, the device checklist, every open item. It is the present, not a log — git is the history. If you read one thing, read this |
| 2 | **[`CLAUDE.md`](CLAUDE.md)** | How to work here — the two standing rules below, the engineering principles, the commit format |
| 3 | **[`docs/BUILD-PLAN.md`](docs/BUILD-PLAN.md)** | What "done" means for the milestone `PROGRESS.md` just named |
| 4 | **[`docs/TASKS.md`](docs/TASKS.md)** | That milestone cut into buildable groups, with the decisions it turns on already settled |

Then read what that milestone points at, and open
[`design/chit-app-v6.html`](design/chit-app-v6.html) in a browser — it is the visual target.
**[§10](#10-the-map) is the map: every file in the repository and why it exists.**

> **Status:** in build, and **M3 is part way through.** Today is a screen a person can use: a
> chit can be typed, saved and read back after a restart, and the strip above it carries a mark
> for every chit where its time falls. A chit now also records **what the phone was doing**
> (ADR-037), the stamp draws **one ranked ambient fact** rather than two (ADR-038), a fresh
> install asks for location behind a screen of its own (ADR-041), and a chit is stamped when it
> is **saved** rather than when it was opened (ADR-040). Weather and location are still fixed
> fakes — M3's remaining groups are what take them out.
>
> This line is a courtesy and goes stale. `docs/PROGRESS.md` is the one that is kept true.

### Section numbers are stable, and global

§1 to §10 are numbered once, across this file and the three documents that hold the rest of the
specification. **A section keeps its number wherever it lives**, so a citation like §6.1 or
§3.5 resolves the same way from any file, and the two hundred-odd cross-references in the docs
and the source did not have to be rewritten when the specification was split.

That is why the numbering here has gaps. It is not an omission:

| | Section | Lives in |
|---|---|---|
| §0 | Start here | this file |
| §1 | What chit is | this file |
| §2 | Core concepts | this file |
| **§3** | **Behaviour specification** | [`docs/BEHAVIOUR.md`](docs/BEHAVIOUR.md) |
| **§4** | **Screens** | [`docs/BEHAVIOUR.md`](docs/BEHAVIOUR.md) |
| §5 | Data model | this file |
| **§6** | **Design system** | [`docs/DESIGN-SYSTEM.md`](docs/DESIGN-SYSTEM.md) |
| **§7** | **The prototype** | [`docs/DESIGN-SYSTEM.md`](docs/DESIGN-SYSTEM.md) |
| **§8** | **The three hard questions** | [`docs/OPEN-QUESTIONS.md`](docs/OPEN-QUESTIONS.md) |
| **§9** | **Feature backlog** | [`docs/OPEN-QUESTIONS.md`](docs/OPEN-QUESTIONS.md) |
| §10 | The map | this file |

### The standing rules

Every change closes the loop on the docs it makes untrue, and nothing that has stopped earning
its place gets committed. Both rules, in full, live in one place —
[`CLAUDE.md`](CLAUDE.md) §0, §0.1 and §0.2 — and are not repeated here.

If you are Claude Code, that file is already loaded: read `docs/PROGRESS.md` and start.

---

## 1. What chit is

chit assumes **you write when something hits you**: several times a day, in a few words,
and then you get on with your life.

Everything in the product follows from that:

| Assumption | Consequence in the design |
|---|---|
| People write in bursts, not sessions | A chit is short. The composer is always open on the home screen. |
| A day holds many chits | The home screen is a thread of today. |
| Writing happens mid-thought | Opening the app costs nothing — the page is blank and ready. **One exception, once:** a fresh install opens on a screen explaining what is captured, and asks (ADR-041). |
| Speaking is often faster than typing | The composer is one surface: a live field, a microphone beside it. A chit holds words, a recording, or both. |
| The moment matters as much as the words | Time, weather, motion and location are recorded with every chit. |
| The habit survives on rhythm, not scores | Rhythm is shown as shape and colour; the app keeps no score. |

---

## 2. Core concepts

- **chit** — one entry. Text, a recording, or both. Timestamped and stamped with ambient
  context.
- **the open chit** — a blank chit at the top of the home screen: a field ready to type in,
  with a microphone beside it. It becomes a record when the user saves it.
- **the ambient stamp** — the time, one ambient fact and a location marker, carried by every
  chit. The time is read when the chit is **saved** (ADR-040); the weather, the motion and the
  fix are read once at launch and again at each save, never in between (ADR-042). The stamp on
  the open chit is a preview of what will be recorded.
- **the thread** — a day's chits, in order, hanging off a vertical rail. A day reads as one
  continuous thing.
- **the timeline** — a horizontal line under the date showing *when* chits landed, each mark
  where its time actually falls. It covers today and the two days before it, midnight to
  midnight, and scrolls; it rests at now (ADR-024).


---

## 5. Data model

A chit is text, audio, or both:

| Field | Notes |
|---|---|
| `id` | |
| `createdAt` | drives both the timeline and the day grouping |
| `text` | what the chit says, typed. **Null on a chit that is only a recording.** |
| `audioPath` | present whenever a recording was kept |
| `weather` | a condition word |
| `location` | stored; surfaced in the UI only as the pin |
| `motion` | what the phone was doing — `stationary`, `walking`, `traveling`, `flying`. Read off the same fix as `location` (ADR-037). Drawn as an icon, and `stationary` is not drawn at all |

`text` and `audioPath` are independently nullable and **at least one of them is always
present** — a chit with neither is not a chit, and is what §3.1 refuses to save.

That leaves three shapes, all ordinary:

| | `text` | `audioPath` |
|---|---|---|
| words alone | ● | — |
| words and a recording | ● | ● |
| a recording alone | — | ● |

**A chit does not record where its words came from.** It used to — `textOrigin` said whether they
were typed, transcribed, or a transcript the user had corrected — and it went with transcription
in M5 (ADR-058). Every chit's words are typed, so there was nothing left to distinguish.


---

## 10. The map

Everything in the repository and why it exists. Nothing here should be reachable only by `ls`:
if a file matters, it has a line in this section — kept true by discipline, not by a test
(CLAUDE.md §4.2: no test cases for documents).

```
chit/
├── README.md               this file — §0 says where to start, §10 is this map
├── CLAUDE.md               how to work here: the two standing rules, the principles, the commits
├── docs/                   §10.1 — eleven documents, one question each
├── lib/                    §10.2 — the Flutter source
├── test/                   §10.3 — what is enforced rather than intended
├── design/                 §10.4 — the prototype, and the visual target
├── assets/fonts/           §10.5 — the three faces of §6.2
├── analysis_options.yaml   §10.6 — CLAUDE.md §4.1 in the form the machine can check
├── pubspec.yaml            §10.6 — every dependency, each justified in docs/PACKAGES.md
└── android/  ios/  web/    §10.6 — platform configuration
```

### 10.1 The documents

| File | Answers | Read it |
|---|---|---|
| [`docs/PROGRESS.md`](docs/PROGRESS.md) | **Where the build stands and what is next.** The status board, what the last session did, and every open item | First. Always |
| [`CLAUDE.md`](CLAUDE.md) | How to work here — the two standing rules, the engineering principles, the commit format, the commands | Second, before writing anything |
| [`docs/TASKS.md`](docs/TASKS.md) | **The current milestone, cut into groups that can each be built, tested and committed on their own.** Holds one milestone at a time and is replaced wholesale when the next starts; `PROGRESS.md` keeps the history | Third, when you are about to write code |
| [`docs/BUILD-PLAN.md`](docs/BUILD-PLAN.md) | The order it gets built in, M0 to M7, and what "done" means for each | Starting a milestone |
| [`docs/BEHAVIOUR.md`](docs/BEHAVIOUR.md) | **§3 and §4** — the behaviour specification and the screens. What the app does and what it looks like doing it | Building any screen |
| [`docs/DESIGN-SYSTEM.md`](docs/DESIGN-SYSTEM.md) | **§6 and §7** — the palette, the three faces, the spacing, the motion, the accessibility floors, and the prototype | Drawing anything |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | How it is put together — the three layers, the folder map, the Riverpod conventions, the data flow behaviour by behaviour | Adding a file and unsure where it goes |
| [`docs/DECISIONS.md`](docs/DECISIONS.md) | The ADRs — every choice, what it was chosen over, what it costs. Indexed at its head, with a note saying where each retired number went | Before reversing something that looks arbitrary |
| [`docs/DATA-MODEL.md`](docs/DATA-MODEL.md) | The schema, the invariants, the queries, and why there are no migrations (ADR-059). §5 here is the product-level version of the same thing | M1, and any change to a row |
| [`docs/PACKAGES.md`](docs/PACKAGES.md) | Every dependency, why it is there, what it was chosen over, and the platform configuration each implies | Before adding a package. Nothing enters `pubspec.yaml` without a line there |
| [`docs/DESIGN-LOG.md`](docs/DESIGN-LOG.md) | Why the design is what it is — including the arguments that were made and lost | Before changing something in §4 or §6 that looks arbitrary. Most of it is load-bearing |
| [`docs/OPEN-QUESTIONS.md`](docs/OPEN-QUESTIONS.md) | **§8 and §9** — the questions still open, and the feature backlog | Deciding what comes after the current milestone |

**The design authority is this file, `BEHAVIOUR.md` and `DESIGN-SYSTEM.md`** — §1 to §9 between
them. Where any other document disagrees with those three, the disagreement is a bug in that
document, fixed in the same change that found it.

### 10.2 The source

The three layers and the one rule are [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) §1; the
file-by-file map is its §2. Every file listed there exists — the ones a milestone has not
reached hold a doc comment naming the milestone that fills them.

```
lib/
├── main.dart      runApp(ProviderScope(child: ChitApp()))
├── app/           the application root and the router (ADR-011)
├── core/          the design system, the clock, the BuildContext accessors
├── domain/        models and interfaces. Pure Dart; imports neither of the two below
├── data/          the implementations: Drift, files, network, platform plugins
├── features/      one folder per screen — shell, today, composer, calendar, editor, onboarding
└── shared/        widgets used by more than one feature
```

**`features` never imports `data`.** Widgets watch controllers, controllers depend on
interfaces in `domain`, Riverpod supplies the implementations at the root — ADR-002.

`lib/core/theme/` is §6 turned into four `ThemeExtension`s — `ChitColors`, `ChitType`,
`ChitSpace` and `ChitMotion` — reached through `context.colors`, `.type`, `.space` and
`.motion`, four accessors rather than one so a widget that needs a colour cannot reach motion.

`lib/domain/` and `lib/data/` are the data spine of M1: the `Chit` model and its invariant, the
one table, the DAO, and `ChitRepository` — the interface in `domain`, the implementation in
`data`, and `main.dart` the one place the two are allowed to meet.

`lib/shared/widgets/` is the chit vocabulary: the slip and its tear edge, the ambient stamp
row and the three motion marks it can draw, the rail a day hangs off and the day's thread over
it, the wordmark, and the two button weights of §6.1. They hold no state and read no provider — each takes what it
draws and nothing else, which is what lets a screen compose them freely.

### 10.3 The tests

What is enforced rather than intended. `flutter test`.

**There are no widget tests, and there will not be** — ADR-031. Nothing here builds a widget;
what can only be seen on a screen is seen on a handset, and written up in PROGRESS.md. Eight
suites and three support files were deleted on 16 September 2026 when that was decided, taking
the count from 251 tests to 171 — 164, plus the seven that came back as arithmetic the moment
somebody looked at whether they had ever needed a widget. The ADR lists what was lost, because
some of it was real and could not come back.

| Suite | Guards |
|---|---|
| `test/core/theme/contrast_test.dart` | §6.4's contrast floor: every text token against every surface it sits on, **composited**. Also the negative cases — `--seal` failing as text on a chit is why `--seal-ink` exists, and `--ink-faint` failing on the audio pill's wash is why the pill's duration is set in `--ink-muted`. It locks §6.1's quoted figures to ±0.01 so the prose and the arithmetic cannot drift apart |
| `test/core/theme/chit_type_test.dart` | ADR-015: every style sets `fontVariations`, not `fontWeight` alone. The three faces of §6.2 are the only families used, the चित्त mark is the only thing set in Devanagari, tabular figures are on everything that counts or keeps time, no functional text is under 11.5px |
| `test/core/theme/chit_motion_test.dart` | §6.4's reduced-motion rule: movement collapses, feedback does not. The suite that found ADR-020 |
| `test/core/theme/widget_constants_test.dart` | The dimensions §6.3 lets a widget spell out as a compile-time constant instead of reading from `ChitSpace` — and the rule that keeps them honest: **a constant copied off the scale still equals it**. The perforation's strip and the thread node's halo are both `s1` written by hand, because a painter and a layout caller each need them before there is a `BuildContext`. Also v6's exact figures, 1.55px on an 8px pitch and the 7px mark, and that the rail's centre stays *derived* from the mark rather than set beside it |
| `test/core/clock_is_the_only_now_test.dart` | ADR-012: nothing in `lib/` calls `DateTime.now()` except `SystemClock` |
| `test/domain/chit_test.dart` | The invariant of §5 where it fails first: a chit with neither text nor audio, text without a provenance, half a coordinate and a recording without a length cannot be *built*. Also `localDayOf` across a midnight |
| `test/data/db/chits_table_test.dart` | The same invariant where it survives a release build — the table's check constraints, every one of them exercised by writing the row by hand, around the repository. Also that the primary key survived being declared beside them |
| `test/data/chit_repository_test.dart` | **M1's statement of done.** All three legal shapes round-tripping against a database in memory, every illegal one refused, `localDay` across a midnight and across a timezone change, audio moved on save, `updateText` provably touching nothing but `text` and `updatedAt`, and every query of DATA-MODEL.md §4 as it arrived — the timeline's range, the calendar's day summaries, the archive's paging, and the written months the chevrons step through |
| `test/data/audio_store_test.dart` | ADR-008: a recording is moved rather than copied, its stored path is relative and uses forward slashes, discarding twice is not a failure, and the orphan sweep deletes what no chit claims |
| `test/data/record_audio_recorder_test.dart` | ADR-052, the two rules the recorder holds without a microphone: the waveform's level is 0 at the silence floor and 1 at full scale, linear between and clamped past either end, with a non-finite reading as silence; a take's path is under the cache with the extension the store keeps and distinct for two takes a microsecond apart. Also that a `Recording` cannot have no length or no file |
| `test/data/debug_seeder_test.dart` | DATA-MODEL.md §7's seeder, and the two claims that fail quietly on a handset: **seeding twice writes nothing**, and **clearing removes exactly the seeded rows and recordings** while a chit somebody wrote is left alone. Also that the fixture reaches all three shapes of §5, every weather word and all three motion marks — because a seeder that skips the recording-with-no-words hides the shape most likely to be forgotten |
| `test/data/open_meteo_service_test.dart` | **The one call the app makes to the outside world**, with no network in the suite — every failure is produced on purpose against a fake `http.Client`. A 500, a body that is not JSON, JSON of the wrong shape, a client that throws and one that never comes back all resolve to the same `null` (ADR-007). It also pins two things that would break silently: that the request asks for **`wind_speed_unit=ms`**, since 8 km/h is a still day and 8 m/s is a windy one; and that it reads the **last known** fix and never `currentFix`, which is what keeps ADR-025's two signals parallel |
| `test/domain/services/ambient_capture_test.dart` | ADR-007, clause by clause: the two signals go out **in parallel** rather than one after the other, each under its own timeout, and **a signal that does not arrive is null** — whether it hung, threw, or simply had nothing to say. Since ADR-040 the time is no longer part of it; what is left is the half with the failure modes |
| `test/domain/services/ambient_signals_test.dart` | **ADR-042, by counting.** *Captured twice and never in between* is invisible when it is wrong — an implementation that polled would pass every assertion about values in this repository and show up only as battery on somebody's phone. So this counts how many times the services were asked: reading the held value asks nothing, `prime` asks once, `refresh` asks again and replaces rather than merges |
| `test/features/composer/composer_controller_test.dart` | **ADR-040's reversal**, which fails silently — a stamp taken at the wrong moment is still a plausible time, and only a clock moved across the save can tell. The row carries the save time and not the open time; a chit opened at 23:58 and saved at 00:05 lands on the *new* day; and ADR-042's half: the save returns without waiting on a capture that never comes back, and the patch that follows moves neither `createdAt` nor `updatedAt`. **Since M5 it also carries §3.4**: Discard deleting the temp take, a recording with no words saving and coming back as a chit, and the take stopping when Save moves its file — while a chit playing in the thread is left alone |
| `test/features/composer/audio_pill_test.dart` | ADR-031 again: what the pill *computes*, never how it looks. The figure, and a playhead that lights nothing at the start, half the bars halfway, everything at the end, and does not run off the end of the list when `just_audio` reports a position past the duration or a row has lost its length. Then the rule the one player exists for — a second pill takes the first one off, a pause keeps its playhead, a vanished file leaves the player silent, and the end is silence rather than a full playhead |
| `test/features/composer/live_wave_test.dart` | ADR-054 as amended: **a bar is its level.** The floor at silence, the full height at full scale, linear between, clamped outside; and the window always full so a sheet that has just opened draws a row of ticks rather than three bars floating, filling from the right with the newest reading last |
| `test/features/composer/recording_controller_test.dart` | The sheet's take without a sheet (ADR-031): **the take surviving the permission round-trip with nothing listening** — ADR-057's bug, and the container here deliberately has no listener — either kind of refusal closing the sheet, the elapsed figure read off the clock rather than counted, the wave keeping only its window, Stop & keep leaving the field alone, and a sheet that vanished without cancelling still closing the microphone |
| `test/features/onboarding/first_run_controller_test.dart` | **ADR-041's one promise: the app asks once.** The claim a future change breaks silently, since re-asking every launch is annoying rather than broken. Every refusal settles it and none of them is an error; **Not now** never raises a dialog at all; a grant is what primes the launch capture; and the screen is never owed twice whichever button ended it |
| `test/domain/prompts_test.dart` | The prompt book of ADR-029, and two kinds of claim that fail differently. The **choice** — most specific first, the small hours treated as their own part of the day, stable for one chit and varied across chits, and never dependent on the machine's time zone. And the **copy**, which fails quietly: every prompt is a question, none of them shouts or instructs, nothing is said twice, and none is long enough to wrap the field. Since ADR-037 it also holds the rung above weather: a chit opened on the move is asked about the move, and `stationary` is asked exactly what a chit with no motion at all is asked |
| `test/domain/motion/motion_ladder_test.dart` | **ADR-037's arithmetic**, which is where M3's motion correctness lives. Every band and both sides of every floor; the altitude rule that keeps a 300 km/h train off an aeroplane; and the gate — a speed whose error is larger than itself degrades to `stationary`, so noise can slow a chit down and can never put a plane on one. Also the three ways a platform says *no reading*: null, negative and NaN |
| `test/domain/weather/wmo_mapping_test.dart` | **M3's weather arithmetic.** The published WMO table walked rather than sampled, because an example-per-case test passes happily with half of it unmapped: every code resolves, no code is claimed by two sets, and an unrecognised one is `null` rather than a guess. Also the precedence — rain over wind, wind over a closed sky — and the two honest silences: a clear sky with no `is_day`, and a malformed wind reading |
| `test/domain/ambient/ambient_fact_test.dart` | **ADR-038's ladder**, as the whole cross product rather than as chosen examples — four motion states against five conditions, plus the two null rows, each resolving to the rung the record names. A precedence bug is exactly what an example misses. It also pins the claim that made the change safe to ship: a chit written at a desk in the rain still reads `raining` |
| `test/features/today/timeline_window_test.dart` | **The arithmetic the timeline rests on** (ADR-024): the window is three whole local days ending at the next midnight, an hour is the same width wherever it falls, and a moment outside it is `null` rather than clamped — which is the day arc's bug, where a chit at 00:20 and one at 5:00 landed on the same pixel. Also that the window slides at midnight, and that a chit falls off the far end when it does |
| `test/features/today/timeline_providers_test.dart` | The seam between that arithmetic and the query under it, on a `ProviderContainer`: the strip asks for exactly the three days the window spans, it reads `todayProvider` rather than the clock a second time, and one save reaches both the strip and the thread — two queries over one table, and not two sources of truth |
| `test/features/calendar/month_shape_test.dart` | **The arithmetic the month grid rests on** (BEHAVIOUR.md §4.2), with no widget near it: the grid starts on a Sunday, the current month is drawn up to today and stops while a past month draws in full, **only the weeks with something in them are drawn**, a quiet week between two written ones included in what goes, and the August the second pass looked at loses its bare middle row (ADR-048), the chevrons' destinations are the nearest written month either side or null at the floor and at the current month, a row outside the month is ignored rather than drawn on a wrong tile, density is four steps and four or more is the fourth, and the summary reads *22 chits over eleven days* and is singular twice for one chit on one day. Also the archive's day labels — *Today*, *Yesterday*, then the weekday and date with the year only when it is not this one — grouping by day, and that `Chit.dateOf` inverts `localDayOf` |
| `test/features/calendar/calendar_providers_test.dart` | The calendar's wiring on a `ProviderContainer` over real Drift: the month asks for exactly its own days and re-queries when navigated, **the chevrons skip empty months and have nowhere to go on a fresh install** (ADR-047), next lands on the current month whether or not it was written in, a selected day narrows the archive to one query and the same tile or **Show every day** widens it, changing the month clears the selection, the archive pages, **the drawn month and the archive hold their last answer while the next is in flight** (ADR-049) — and **one save reaches the grid, the summary and the archive** with nothing keeping them in step, which is BUILD-PLAN.md M4's statement of done as far as a test can hold it |
| `test/docs/no_widget_tests_test.dart` | ADR-031, which is otherwise a rule in a file nobody has to read: no `testWidgets`, `pumpWidget` or `WidgetTester` anywhere under `test/`. The suite it replaced grew one reasonable-looking widget test at a time, which is how it would come back |
| `test/support/contrast.dart` | Not a suite — the WCAG arithmetic, in one place so every check uses the same maths |
| `test/support/fake_clock.dart` | Not a suite — the `Clock` of ADR-012 that a test moves by hand. It also counts its reads, which is how ADR-021's *stamped when opened* is checked: when the clock was read is the thing that matters, and no assertion on the value can see it |
| `test/support/fake_audio_recorder.dart` | Not a suite — an `AudioRecorder` that can be told to refuse. It refuses the way the real one refuses, with a `false` or a `null` and never an exception, because a fake that can fail in a way the real one cannot tests a path the app does not have |
| `test/support/fake_audio_player.dart` | Not a suite — an `AudioPlayer` driven by hand, with one loaded pill at a time because that is the whole reason the interface exists. A path in its `missing` set leaves it silent with no error, which is exactly what the real one does with a file that has vanished |

The pattern, set in M0b and worth keeping: **a rule that fails silently gets a test that checks
a property, not an example.** `chit_motion_test.dart` asserting "no fade is slower than it was"
is what caught a motion rule that was self-consistent and wrong.

M1 adds a second pattern: **an invariant worth having is worth holding in more than one place.**
README §5's one-of rule is an assert, a check constraint and a repository refusal, and each of
the three is tested where it lives — because an assert is compiled out of a release build, a
constraint says nothing about *why*, and a repository is one caller among however many a later
milestone adds.

### 10.4 The prototype

| File | |
|---|---|
| [`design/chit-app-v6.html`](design/chit-app-v6.html) | The interactive design prototype and **the visual target**. One self-contained file, no build step — open it in any browser. §7 says what is live in it and what is deliberately not wired |

When in doubt about a pixel, open v6. The type scale, the spacing steps and the motion pace
table were all read from the prototype.

*v5 and v4 sat here until 16 September 2026 and were deleted.* Both were superseded — v5 by
ADR-022's accent rule, v4 before that by §3.2 and §3.4 — and a superseded prototype beside the
live one invites being opened by mistake. `git log --oneline -- design/` finds the commit that
removed them, if the *before* half of ADR-022 is ever wanted as a file rather than as the
argument the ADR already makes in words.

### 10.5 Assets

`assets/fonts/` holds the three faces of §6.2 as **variable** fonts with an `OFL.txt` beside
each: Newsreader (upright and italic), Hanken Grotesk, Noto Serif Devanagari. ADR-015 says why
variable rather than static cuts, and what it costs — weight has to be applied through
`fontVariations`, because `fontWeight` alone is silently ignored.

### 10.6 Configuration

| File | |
|---|---|
| [`analysis_options.yaml`](analysis_options.yaml) | The engineering principles of `CLAUDE.md` §4.1 in the form the machine can check: strict casts, inference and raw types; exhaustive switches and unawaited futures as errors; immutability and documentation rules. `riverpod_lint` runs inside `flutter analyze` through the `plugins:` key — no separate command, and `docs/PACKAGES.md` says why there cannot be one |
| [`pubspec.yaml`](pubspec.yaml) | Dependencies and the font declarations. Every entry is justified in [`docs/PACKAGES.md`](docs/PACKAGES.md) |
| `android/app/src/main/AndroidManifest.xml` | `RECORD_AUDIO`, both location permissions (ADR-016) and `INTERNET`. *It also carried a `<queries>` intent for `android.speech.RecognitionService`, which went with transcription — ADR-058.* |
| `android/app/build.gradle.kts` | `minSdk 24` — `record_android`'s floor, the highest of any plugin — and the `com.infiniteants.chit` application id |
| `android/gradle.properties` | `kotlin.incremental=false`. Without it every plugin's Kotlin compile fails to close its caches on Windows; `docs/PROGRESS.md` has the detail |
| `ios/Runner/Info.plist` | The microphone and location usage strings — the only copy in the app the design never sees, so they are written in chit's voice |

Android and iOS only — ADR-019. The desktop scaffolds went in M0a; `web/` is kept because
responsive web is planned after v1, and no layout work is being spent on it yet.

### 10.7 Running it

```bash
flutter pub get
dart run build_runner watch      # leave running while working
flutter analyze                  # must be clean before a commit
flutter test
flutter run                      # an Android device or emulator
flutter run --dart-define=CHIT_SEED=seed    # the same build with six weeks of chits — DATA-MODEL.md §7
flutter run --dart-define=CHIT_SEED=clear   # and the same build with them taken off again
```

Targets: Android and iOS. Responsive web comes later — the current design is mobile at 390×844.

On Windows, `flutter pub get` warns unless **Developer Mode** is enabled; plugin builds need
symlink support. `start ms-settings:developers`.
