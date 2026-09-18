# Architecture

How chit is put together and how it is built. The *why* behind each choice is in
[DECISIONS.md](DECISIONS.md); the behaviour being implemented is in
[BEHAVIOUR.md](BEHAVIOUR.md) and [DESIGN-SYSTEM.md](DESIGN-SYSTEM.md). Where this document
disagrees with either of those or with the [README](../README.md), they win — the three of them
are the design authority.

---

## 1. Shape

Three layers and one rule.

```
domain   ←  data
   ↑
features
```

- **`domain`** — models, and the interfaces the rest of the app talks to. Pure Dart. Imports
  nothing from `data` or `features`, and nothing from Flutter.
- **`data`** — the implementations: Drift, the filesystem, the network, the platform plugins.
- **`features`** — controllers and widgets, one folder per screen.

The rule: **`features` never imports `data`.** A widget watches a controller; the controller
depends on a repository *interface*; Riverpod supplies the implementation at the root — which
is what lets a refused microphone be tested with a recorder that can be told to refuse,
and lets a sync layer appear later (ADR-004) without a screen noticing.

---

## 2. Folders

```
lib/
├── app/            the application root and router — go_router: shell + two tabs
├── core/            the four ThemeExtensions of DESIGN-SYSTEM.md §6, the injected clock (ADR-012),
│                     and the BuildContext sugar that reaches them
├── domain/
│   ├── models/      Chit and its invariant, the stamp, the enums, composer and recording state
│   ├── ambient/     which one fact the stamp draws — the ladder (ADR-038)
│   ├── motion/      speed + accuracy + altitude → one of the four states
│   ├── weather/     WMO code + is_day + wind → one of the five words
│   ├── repositories/   the ChitRepository interface
│   └── services/    interfaces only — audio in and out, weather, location, first-run, ambient capture and signals
├── data/
│   ├── db/          the Drift database, its one table and the DAO
│   ├── audio/       AudioStore — temp → permanent, delete, orphan sweep; the recorder over `record`,
│   │                 the player over `just_audio`
│   ├── dev/         DebugSeeder — DATA-MODEL.md §7
│   ├── weather/     Open-Meteo, mapped via domain/weather
│   ├── location/    the fix, and the one ask
│   ├── preferences/ shared_preferences (ADR-041)
│   └── repositories/   the ChitRepository implementation
├── features/        one folder per screen — shell, today, composer, calendar, editor, onboarding —
│                     each split application/ (controllers) and presentation/ (widgets)
└── shared/
    ├── widgets/     the chit vocabulary used by more than one feature
    └── day_label.dart   *Today* / *Yesterday* / *Friday 11 September* — the archive's headings
                          and the editor's, one function so they cannot disagree
```

`shared/widgets` holds pieces used by more than one feature; a widget used by one screen lives
in that screen's `presentation/widgets/` until a second screen wants it.

**These are the chit vocabulary — no state, no provider, each takes only what it draws.**
`AmbientStampRow` takes an `AmbientStamp`, `Slip` takes a child, which lets a screen compose them
without either knowing about the other. `DayThread` is why BEHAVIOUR.md §4.2's *same thread
treatment as Today* is true by construction — one widget, not two that look alike.

**`AudioPill` is the one that watches a provider**, and it is a control rather than a piece of
vocabulary: which pill is lit is a property of the app's one player, not of the row it sits on,
so threading it down from three screens would be the same fact copied three times.

**`ChitRow` is the one that navigates** (ADR-061). It pushes the editor itself rather than
taking a callback, because both screens that draw it would pass the same one — go_router owns
navigation (CLAUDE.md §4.2) and a destination is not something a row should have to be told.

`Slip` draws its own `PerforatedEdge`, since a slip and its tear are one object. `ThreadRail`
draws only the line; each row places its own `ThreadNode` on it, because where a node falls is
the row's business, not the rail's.

**Every file that belongs under a folder above exists**, even ahead of the milestone that fills
it — which then holds a doc comment naming that milestone, nothing else. An empty named file
says where something belongs; an empty directory does not.

**`Clock` lives in `core/clock.dart`, not `domain`** — `core` is imported by every layer and
depends on none, which is what an injected clock needs. ADR-012's decision is unchanged; only
its stated file path was.

---

## 3. Riverpod conventions

**Everything is generated.** `@riverpod` on a function or a `Notifier` class; `part 'x.g.dart'`;
`dart run build_runner watch -d` while working.

**Five kinds of provider, and the rules differ.**

| Kind | Example | Lifetime |
|---|---|---|
| Infrastructure | `routerProvider`, `appDatabaseProvider`, `chitRepositoryProvider`, the services | `@Riverpod(keepAlive: true)` |
| Stream of truth | `todayChitsProvider`, `timelineChitsProvider`, `monthSummariesProvider`, `archiveChitsProvider` | auto-disposed; Drift re-emits on subscribe |
| The clock, once | `todayProvider`, `todayLocalDayProvider`, `timelineQueryWindowProvider`, `visibleMonthProvider` | auto-disposed; **one read of the clock per screen** — see below |
| Derived | `timelineWindowProvider`, `drawnMonthProvider`, `archiveDaysProvider`, `archiveLimitProvider` | auto-disposed; pure functions of the above — except that `drawnMonthProvider` and `archiveDaysProvider` are notifiers that **hold their last answer while the stream under them is loading** (ADR-049), so each is a function of its inputs and its own last output |
| Screen state | `composerControllerProvider`, `selectedDayProvider`, `archivePagesProvider` | auto-disposed |
| A take | `recordingControllerProvider` | **`keepAlive`** — ADR-057. The one exception, because a take begins before the sheet exists and finishes after it has gone |

**Widgets watch controllers and derived providers. Never a DAO, never the database.** §1's layer
rule, as a lint you should notice yourself breaking.

**A screen reads the clock once, through a provider.** `todayProvider` is `clock.now()` and
nothing else; the date line and the thread both read it rather than the clock directly, so two
reads a millisecond apart can never disagree at midnight (ADR-006, ADR-033).

**Infrastructure providers are declared beside what they build**, except when `features` needs
to watch one that `data` implements — `chitRepositoryProvider` is declared unimplemented beside
its interface in `domain`:

```dart
@Riverpod(keepAlive: true)
ChitRepository chitRepository(Ref ref) => throw UnimplementedError(
  'chitRepositoryProvider is overridden at the root — see main.dart',
);
```

`main.dart` supplies it — the one place the two layers meet. Tests override the same seam on a
bare `ProviderContainer` with real Drift in memory (ADR-031: no widget-pumping tests, so no
second repository implementation to choose between).

**go_router owns navigation entirely** — the shell, both branches (ADR-011), paths, names,
stacks. `ChitRoute` is the one destination list the tab bar is built from. The one hand-written
piece, `BranchFade`, is written *into* go_router's `navigatorContainerBuilder` rather than
around it.

**Riverpod owns everything that outlives a build, the router included** — ADR-001 makes it the
only state mechanism, and a `GoRouter` in a `StatefulWidget` would put the one thing that must
survive a rebuild in the one place that does not. `ChitApp` is a `ConsumerWidget` watching
`routerProvider` and nothing else. The one exception is ADR-011's recording sheet: a modal
sheet, not a route, because dismissing it is not a back navigation.

**Startup is synchronous.** `drift_flutter`'s `driftDatabase(name: 'chit')` resolves its path
lazily, so there is no async bootstrap and no loading state before the home screen — README §1's
*opening the app costs nothing* is a startup requirement, not just a visual one.

**Tests override at the root**, `ProviderContainer(overrides: [...])`, in-memory Drift and
hand-written fakes. No mocking framework.

---

## 4. The data flow, behaviour by behaviour

### 4.1 The open chit is not a row

BEHAVIOUR.md §3.1: opening the app leaves nothing behind. The open chit lives entirely in
`ComposerController`, never in the database — no draft persistence. **Save chit** is the only
insert.

**The controller is synchronous** — `build()` returns a `ComposerState`, never a `Future` of
one. It takes the instant half of the stamp from `AmbientCapture.open()` and hands the slow half
to `settle()`, which lands whenever it lands, or never. A `FutureOr<ComposerState> build()`
would give the open chit a loading state, and *nothing about capture may delay the composer*.

**There is no mode** (§3.2: one surface, a live field with a microphone beside it) —
`ComposerState` is a record of what the chit holds, not which way in the user picked:

```
class ComposerState {
  String        text;          // the field's live content; the user owns it throughout
  String?       audioTempPath; // set once a recording is kept
  Duration?     audioDuration;
  AmbientStamp  stamp;
  bool          isRecording;   // the sheet is up
  bool          microphoneRefused; // drives the line under the action row
  bool          showPrompt;    // the five seconds of §3.3 have run
}

bool get canSave => text.trim().isNotEmpty || audioTempPath != null;
```

`canSave` is §3.1 and §4.1 in full: Save appears when it is true, and only the microphone
otherwise.

**What the transitions must preserve** (§3.4):

- Keeping a recording **leaves the field exactly as it was**. A recording is not words.
- `audioTempPath` is set by recording and cleared only by `removeTake` — **Remove** on the pill
  (ADR-060); editing `text` never touches it, and `removeTake` never touches `text`.
- The microphone is available on an empty or half-written chit, unavailable only while
  `isRecording` or once `audioTempPath` is set — one row holds one recording, so a second take
  would silently destroy the first (DESIGN-SYSTEM.md §6.4).

### 4.1a The timeline is three providers, and only one touches the database

ADR-024, ADR-032, ADR-035. The strip is the one thing on Today whose shape depends on its own
answer, so it is three steps rather than one:

```
todayProvider ──► timelineQueryWindowProvider ──► timelineChitsProvider ──┐
  (the clock,          (three whole local days,       (watchDayRange,     │
   read once)           ADR-006 boundaries)            oldest first)      │
                                │                                         │
                                └──────────► timelineWindowProvider ◄──────┘
                                              (what is drawn: the query
                                               window trimmed to the
                                               oldest chit in it)
```

**The query window and the drawn window cannot be one provider** — what is drawn depends on
what came back, and what came back depends on what was asked for. Splitting them also keeps the
query honest: it stays three days wide however little is drawn, so the strip can grow backwards
the moment there is something to grow into (ADR-035).

**`TimelineWindow` is a plain value, no Flutter, no Riverpod** — `fractionOf`, `dayBoundaries`,
`dayAt`, `trimmedTo` are all answered on it, so a no-widget-test rule (ADR-031) still has
somewhere to check *where* without building anything.

**The widget owns two pieces of state only**: the `ScrollController`, and which day was last
under the middle of the viewport (ADR-034's haptic). Resting at now is computed from scroll
position, not stored.

### 4.2 Ambient capture

`AmbientStamp` is resolved once, when the open chit is created, held in `ComposerState`.
Weather and location run in parallel behind a shared timeout — **12s** (ADR-044, revised from
ADR-007's original 2s once ADR-042 meant nothing waits on a capture) — and the `Clock` is
instant. Whatever has not arrived is `null` and simply is not drawn; nothing here can block,
spin or fail a save (ADR-007).

**Three signals, two calls — ADR-037.** Motion rides on the position fix: `GeoFix` carries
`speed`, `speedAccuracy` and `altitude`, and `AmbientCapture` runs them through
`domain/motion/motion_ladder.dart` for a `MotionState`. Motion costs no extra package or
permission — but a refused location now costs the pin *and* motion together, since they are one
signal.

**Only one of weather and motion is ever drawn**, ranked by `domain/ambient/ambient_fact.dart`
(ADR-038) — presentation logic in `domain` on purpose, since which fact is worth a chit is a
product decision.

**`AmbientCapture` in `domain/services` is M2 group D, and every line in it is a product rule**,
which is why M3 only changed which implementations the two service providers resolve to. Three
things matter:

- **It holds no clock.** `read()` answers the two services and nothing else; a time is read
  where it is used — by the controller for the slip preview, by `save` for the row (ADR-040).
- **Nothing here runs on a path the user waits on.** Launch fires it from a post-frame callback,
  unawaited; save runs it behind a row already written.
- **A throw and a hang both produce `null`.** The one deliberate exception to CLAUDE.md §4.1's
  *fail loudly in development* — to a screen that must not stall, no permission and a fallen-over
  service look the same.

**Captured at launch, and at save only when stale — ADR-042, ADR-045.** `AmbientSignals` owns
*when*, holding the reading for the process's life; `AmbientCapture` owns *what*. No timer, no
refresh on resume. A reading is good for **five minutes** — `AmbientReading.readAt`, stamped by
a clock `AmbientSignals` holds for that purpose — and inside that window a save asks for
nothing.

**The row is written first, patched after only if stale.** A save inserts with whatever is
held; if that reading is older than five minutes, a fresh read starts beside the insert and
corrects the row through `updateAmbient` when it lands — one capture both patches the row and
becomes the next chit's preview. `updateAmbient` is a separate method from `updateText` so one
rule lives in the type: **the patch moves neither `createdAt` nor `updatedAt`** (ADR-014).

**What is held is a preview; what a row carries is the record.** A phone left open all day draws
the launch weather on the open chit, but no chit is ever *recorded* with it.

**Weather takes no position — ADR-025.** `WeatherService.currentCondition()` takes nothing,
because a lookup by coordinates would make weather wait on the (slower, precise) location fix.
M3 uses the device's last known fix — cached, instant — at the cost that the condition can be
for where you were rather than where you are. `wmo_mapping.dart` turns the WMO code + `is_day` +
wind speed into one of §3.6's five words, pure, in `domain`.

**Location is high accuracy, with the coarse fix accepted when that is all the user granted**
(ADR-016) — a neighbourhood-level fix cannot produce OPEN-QUESTIONS.md §9's coarse place
labels. Both outcomes are a successful capture; §3.6 shows a pin, never a name.

### 4.3 The five-second prompt

The timer lives in `ComposerController`, not the widget, so a rebuild does not restart it.
First character cancels it; clearing the field restarts it. The 700ms appearance is
`ChitMotion.fade` (140ms under reduced motion) — the whole event, not something to collapse
further. The five seconds are a product rule, not a pace, and never change.

**A rebuild is exactly what this defends against**, and it fails invisibly: the field relays out
whenever the keyboard arrives or the action row grows, and a widget-held timer would restart to
five seconds each time. `ref.onDispose` cancels it; a **save** arms it again, since it opens a
fresh chit (ADR-040), and so does a **Remove** that leaves the chit holding nothing (ADR-060).

**Drawn over the field, never into it.** `hintText` is the tempting shortcut and wrong twice —
announced as a label, and shown on Material's schedule rather than after five seconds. The
overlay sits over the field's box, sharing its first baseline.

**Nothing else is in that overlay** — an earlier drawn blinking caret came out with ADR-028; the
caret on first tap is the framework's. *ADR-056 put §3.5's failure note in a block above the
field rather than in here, and ADR-058 removed the note altogether.*

**Which words are offered is `Prompts.forStamp`** (ADR-029), pure, over the stamp already held.
`ComposerState.prompt` is a getter, not a stored field, so it cannot drift from the moment it is
about — it changes once if a launch capture lands within the five seconds (ADR-042), and it
reads the stamp on the slip (the preview), never the clock, so the question is about *the moment
you are sitting in* rather than the moment the row will later be stamped with (ADR-040).

### 4.4 Recording

`AudioRecorder` writes to a temp file, and that is the whole of it — **there is no recogniser**
(ADR-058).

`RecordingController` owns the sheet's state: the elapsed figure off the clock and the last
twenty levels the wave draws. **Stop & keep attaches the take and leaves the field alone** — a
recording is not words. It hands the result to `ComposerController` rather than returning it,
since a modal sheet has nothing downstream to return to, and a take that wrote nothing simply
closes the sheet.

It is the one screen controller that is `keepAlive` (ADR-057): a take begins on the microphone's
tap, before the sheet exists, and finishes after it has gone.

**The sheet's Discard, and Remove on the open chit's pill**, both delete the temp file through
`ChitRepository.discardTemp`, the counterpart of `save`'s `audioTempPath`; nothing moves to
permanent storage until Save (ADR-008).

The sheet is raised by `showRecordingSheet`, which is also what ends the take: **every way out
that is not Stop & keep is a cancel** — the drag, the scrim, the back gesture and Discard alike —
so a dismissal the widget never hears about cannot leave a microphone running.

### 4.4.1 Playback

One `AudioPlayer`, `keepAlive`, so two pills can never sound at once; every pill watches the same
`playbackProvider` and asks whether the loaded id is its own. A path is **relative for a saved
chit and absolute for a take not yet kept** (ADR-008), and `JustAudioPlayer` is the one place
that difference is resolved — `features` has no filesystem. A file that has vanished leaves the
player silent and the chit still renders (§6).

**The stream gives every listener the current state before it gives them a change.** A pill is
routinely built long after a recording started sounding — the archive is rebuilt on every tab
change — and a stream carrying only changes left those pills drawn as though nothing were
playing, so the one control that could have stopped the sound was a play button that did
nothing. **`stopIf(id)`** is the other half: Save moves the open chit's take out of the cache and
Remove deletes it, and `ComposerController` stops the player first, because a pill that is about
to stop being drawn cannot stop what it started. The `if` is what keeps a chit playing in the
thread from being silenced by a save.

Recording is available on a chit that already has text (§4.1's append rule), and available
**once** — a row holds one `audioPath`, so the microphone retires once `audioTempPath` is set
rather than silently overwriting it (§3.2).

### 4.5 Save, and why the tabs cannot disagree

`ChitRepository.save()` writes the row and, when there is a recording, moves the audio into
place — one call, ordered so a failed file move never leaves a row pointing at nothing.

`updateText()` is the ADR-014 counterpart: it changes only `text` and `updatedAt`
— `createdAt`, `localDay` and `audioPath` are not parameters, so an edit cannot move a chit in
the thread, relight a calendar tile, or lose a recording.

Everything downstream is a Drift stream — the thread, the timeline, the calendar density and the
month total are four providers over four queries, so one save updates them all by construction.
DESIGN-SYSTEM.md §7 requires the two tabs never disagree; here it is the only thing the
architecture allows.

### 4.6 The calendar is two chains off one reading of the day

M4. Both chains start at `todayProvider` — so the two tabs cannot disagree about *today* — and
neither touches the database more than once:

```
                   writtenMonthsProvider ──► monthNeighboursProvider ──► (the bar's chevrons,
                   (watchWrittenMonths,       (where previous and next     drawn only where
                    yyyymm, ADR-047)           land, or null)              there is somewhere
                                ▲                     ▲                    to go)
todayProvider ──► visibleMonthProvider ──► monthSummariesProvider ──► drawnMonthProvider
  (the clock,        (a notifier: the         (watchDaySummaries          (MonthShape: the
   read once)         month asked for; each    over the month's           rows it draws, the
                      chevron lands on the     own days — one query       density steps and
                      nearest written month)   for grid and summary)      the summary; the last
                                │                                          answer while the next
                                │                                          is in flight, ADR-049)
                                ▼
                        selectedDayProvider ──► archiveChitsProvider ──► archiveDaysProvider
                        (a tile, or null;        (watchDay for a            (grouped by day,
                         resets when the          selection, watchArchive    newest first; held
                         month changes)           paged otherwise)          the same way)
                                                        ▲
                               archivePagesProvider ──► archiveLimitProvider
```

**`MonthShape` is a plain value, no Flutter, no Riverpod** — same reason as `TimelineWindow`:
where the first tile sits, which tile is today, how many are drawn and how dark each is all
have to live somewhere a no-widget-test suite can reach. **The current month draws up to today
and stops** because a future month's `lastDrawnDay` is zero, not because the widget checked.
Count-to-density is a static on it, in the presentation layer, since it is a design scale, not a
data fact. **Which weeks are drawn is its `rows`** (ADR-048) — only the weeks with something in
them.

**The drawn month lags the visible month by one answer, on purpose.** `visibleMonthProvider` is
what the reader asked for; `drawnMonthProvider` is the last thing the database answered for.
Between a chevron tap and the answer they differ, and the bar takes its name from the second so
name and grid change together (ADR-049). `archiveDaysProvider` holds its last answer the same
way, via `Notifier.stateOrNull`.

**`VisibleMonth` computes its own destinations rather than reading `monthNeighboursProvider`
back** — that provider watches the notifier, and a `ref.read` from the notifier's own method
into it is a cycle Riverpod throws on. Both call the same two `YearMonth` functions.

**The selection resets by watching the month, not by being cleared.** `SelectedDay.build` reads
`visibleMonthProvider` and returns null on any change, so nobody has to remember to clear it.

**A filtered archive is `watchDay`** — the same query Today's thread runs. One question,
however it was asked; no second source of data to keep in sync.

---

## 5. Theme and motion

DESIGN-SYSTEM.md §6 becomes four `ThemeExtension`s (ADR-010); two carry rules, not just values.

**`ChitColors`** exposes `seal` and `sealInk` as separate members — marks, fills, borders and
icons take `seal`; anything read as words takes `sealInk`, because `seal` is 4.09:1 on a slip
and text needs 4.5:1.

**`ChitMotion`** exposes two resolvers, not a bag of durations:

```dart
Duration travel(Duration d)      // → Duration.zero when animations are disabled
Duration fade(Duration d)        // → 140ms when animations are disabled
Duration fadeArrival(Duration d) // → 220ms when animations are disabled
```

Reduced motion is a property of *which helper a widget reached for* — a global duration
override would erase that distinction. Fades are re-timed rather than passed through untouched,
so a fade still announces itself without carrying the house pace of motion that is no longer
moving. Ambient loops — the pulse at now, the record dot, the live waveform — take their period
from `ChitMotion.loop`, which returns `Duration.zero` under reduced motion: no ticker, drawn at
rest (ADR-027).

---

## 6. Errors

| What fails | What the user sees |
|---|---|
| Weather or location | that field is absent from the stamp. No message. |
| Microphone permission refused | the sheet does not open; the microphone explains once and stays available |
| Audio file missing at playback | the chit renders; the pill is absent |
| A database write | the only case that gets a visible failure, because the user's words are at stake |

The general shape: **ambient signals fail silently, the user's content never fails silently.**

---

## 7. Testing

**No widget tests** (ADR-031) — `test/docs/no_widget_tests_test.dart` fails if one reappears.
**Anything only visible on a screen is seen on a handset**, and written into PROGRESS.md. This
is a constraint on where behaviour lives, not just on the test folder: a rule unreachable
without a widget belongs in a controller or a pure function instead.

What is tested:

- **Repository and DAO**, against `NativeDatabase.memory()` — the at-least-one invariant, the
  `localDay` across a midnight and a timezone change, audio move-on-save
  and delete-on-discard, `updateText` touching nothing else. *There is no migration test — there
  are no migrations (ADR-059).*
- **Models**, where §5's invariant fails first (a chit that cannot be *built*) and again at the
  table's check constraints, which survive a release build with asserts compiled out.
- **Controllers and services**, on a bare `ProviderContainer` with a fake clock and hand-written
  fakes — the five-second timer, `canSave`, ADR-007's parallel capture and its timeouts, and
  §4.1's rules for what a kept take does and does not touch.
- **Pure functions** — the prompt book, the WMO mapping, the count-to-density scale, the
  timeline position for a time.
- **The accessibility floors of DESIGN-SYSTEM.md §6.4, as arithmetic** — contrast of every text
  token against every surface, including composited translucent ones. The floors that *are*
  spatial — touch targets, semantics, heading order — are a device pass instead.
- **The rules about the rules** — the injected clock of ADR-012, the no-widget-test rule. Not
  README §10's map or the ADR index; CLAUDE.md §4.2 says why there is no test for those.

---

## 8. Working on it

```bash
flutter pub get
dart run build_runner watch -d      # leave running
flutter run
```

Before a commit: `dart format .`, `flutter analyze` (clean — the Riverpod lints run inside it,
because `riverpod_lint` is an analysis-server plugin and there is no separate `custom_lint` step;
[PACKAGES.md](PACKAGES.md) says why), `flutter test`, **and the documents that the change made
untrue** — the two standing rules in [CLAUDE.md](../CLAUDE.md) §0 and §0.1, which include
deleting whatever this change orphaned.

Generated `*.g.dart` and `*.freezed.dart` files are committed, so a fresh clone runs without
codegen first.
