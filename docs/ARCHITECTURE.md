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

The rule: **`features` never imports `data`.** A widget that needs a chit watches a controller;
the controller depends on a repository *interface*; Riverpod supplies the implementation at the
root. It is what lets a sync layer appear later (ADR-004) without a screen noticing, and — more
immediately — it is the only way to test the §3.5 failure path, which needs a recognizer that
can be told to hear nothing.

---

## 2. Folders

```
lib/
├── main.dart                       runApp(ProviderScope(child: ChitApp()))
│
├── app/
│   ├── chit_app.dart               MaterialApp.router, theme wiring
│   └── router.dart                 go_router: shell + two tabs
│
├── core/
│   ├── theme/
│   │   ├── chit_colors.dart        ThemeExtension — DESIGN-SYSTEM.md §6.1 tokens
│   │   ├── chit_type.dart          ThemeExtension — the three faces, the scale
│   │   ├── chit_space.dart         4px scale, radii, the 26px gutter
│   │   ├── chit_motion.dart        durations, curves, travel() vs fade()
│   │   └── chit_theme.dart         assembles ThemeData from the above
│   ├── clock.dart                  injected now (ADR-012), and clockProvider
│   └── extensions.dart             BuildContext sugar for the extensions above
│
├── domain/
│   ├── models/
│   │   ├── chit.dart               freezed; the one-of invariant
│   │   ├── ambient_stamp.dart      time + weather? + location? + motion?
│   │   ├── weather_condition.dart  enum: raining | clear | overcast | windy | clearNight
│   │   ├── motion_state.dart       enum: stationary | walking | traveling | flying (ADR-037)
│   │   ├── day_summary.dart        localDay + count — feeds the calendar
│   │   └── composer_state.dart     the open chit's state machine
│   ├── prompts.dart                the five-second prompt of §3.3, chosen from the stamp
│   ├── ambient/
│   │   └── ambient_fact.dart       which one fact the stamp draws — the ladder (ADR-038)
│   ├── motion/
│   │   └── motion_ladder.dart      speed + accuracy + altitude → one of the four states
│   ├── weather/
│   │   └── wmo_mapping.dart        WMO code + is_day + wind → one of the five words
│   ├── repositories/
│   │   └── chit_repository.dart    interface
│   └── services/
│       ├── speech_recognizer.dart  interface (ADR-005)
│       ├── audio_recorder.dart     interface
│       ├── weather_service.dart    interface — no position argument (ADR-025)
│       ├── location_service.dart   interface, GeoFix, and the permission ask (ADR-041)
│       ├── first_run_store.dart    interface — the two flags an install remembers
│       ├── ambient_capture.dart    the two in parallel under a timeout (ADR-007)
│       └── ambient_signals.dart    holds the reading; launch and save (ADR-042)
│
├── data/
│   ├── db/
│   │   ├── app_database.dart       Drift database + migrations
│   │   ├── tables/chits_table.dart
│   │   └── daos/chit_dao.dart
│   ├── audio/audio_store.dart      temp → permanent, delete, orphan sweep
│   ├── preferences/prefs_first_run_store.dart  shared_preferences (ADR-041)
│   ├── weather/open_meteo_service.dart      calls out; maps via domain/weather
│   ├── weather/fixed_weather_service.dart   M2 only; M3 deletes it
│   ├── location/geolocator_location_service.dart
│   ├── location/fixed_location_service.dart M2 only; M3 deletes it
│   ├── speech/on_device_speech_recognizer.dart
│   └── repositories/chit_repository_impl.dart
│
├── features/
│   ├── shell/                      bottom tab bar, the two tabs
│   ├── today/
│   │   ├── application/            today_controller.dart, timeline_provider.dart
│   │   └── presentation/           today_screen.dart, widgets/{day_thread,timeline}.dart
│   ├── composer/
│   │   ├── application/            composer_controller.dart, recording_controller.dart
│   │   └── presentation/           open_chit.dart, recording_sheet.dart
│   ├── calendar/
│   │   ├── application/            month_provider.dart, archive_provider.dart
│   │   └── presentation/           calendar_screen.dart, widgets/
│   ├── editor/                     M6 — a saved chit, on its own screen (ADR-017)
│   │   ├── application/            editor_controller.dart — dirty tracking, the save prompt
│   │   └── presentation/           editor_screen.dart
│   └── onboarding/                 the first-run screen, shown once (ADR-041)
│       ├── application/            first_run_controller.dart
│       └── presentation/           first_run_screen.dart
│
└── shared/widgets/
    ├── slip.dart                   a chit surface, its tear edge and the pad behind it
    ├── perforated_edge.dart        holes in the surface beneath — see the design log
    ├── thread_rail.dart            the rail (ThreadRail) and the mark on it (ThreadNode)
    ├── ambient_stamp_row.dart      .open and .saved — §3.6's two weights, and the pin
    ├── motion_icon.dart            the three marks of ADR-039; stationary draws nothing
    ├── wordmark.dart               "chit चित्त", baseline-aligned
    ├── buttons.dart                the two weights of §6.1
    └── audio_pill.dart
```

`shared/widgets` holds the pieces used by more than one feature. A widget used by one screen
lives in that screen's `presentation/widgets/`, and moves out only when a second screen wants it.

**These are the chit vocabulary, and they hold no state and read no provider.** They take what
they draw and nothing else — `AmbientStampRow` takes an `AmbientStamp`, `Slip` takes a child —
which is what lets a screen compose them without either of them knowing about the other. M2
group C wrote the first four; `wordmark.dart` and `buttons.dart` arrived with the first-run
screen (ADR-041), each **moved out of the one feature that used to own it** the moment a second
feature wanted it, which is the rule above doing its job rather than an exception to it.

`Slip` draws its own `PerforatedEdge`, because a slip and the tear that made it are one object
rather than two a caller has to remember to assemble. `ThreadRail` is the opposite case and
deliberately so: it draws the line and nothing else, and the thread's rows place their own
`ThreadNode` over it — where a node falls depends on what the row says, which is the screen's
business and not the rail's.

As of M1, every file in `domain/models`, `domain/repositories`, `data/db` and `data/audio` above
holds real code, along with `data/repositories/chit_repository_impl.dart`. `TextOrigin` lives in
`models/chit.dart` rather than in a file of its own: it is half of the `text` / `textOrigin`
pairing the chit's invariant is about, and splitting it from the assert that enforces it would
gain a file and lose the connection.

**Every file above exists**, as of M0b. The ones a milestone has not reached yet hold a doc
comment naming the milestone that fills them and nothing else. An empty named file is a
stronger statement about where something belongs than an empty directory, and the cost of
being wrong about a layer is paid at the moment the first line is written, not later.

**`Clock` lives in `core`, not in `domain`.** ADR-012's prose says "a `Clock` from `domain`";
the tree above has always said `core/clock.dart`, and that is where it is. `core` is imported
by every layer and depends on none of them, which is exactly what an injected clock needs, and
`domain` is for the vocabulary of the product rather than for the machinery under it. The ADR's
decision is unchanged — nothing calls `DateTime.now()` — only its file path was wrong.

---

## 3. Riverpod conventions

**Everything is generated.** `@riverpod` on a function or a `Notifier` class; `part 'x.g.dart'`;
`dart run build_runner watch -d` while working.

**Five kinds of provider, and the rules differ.**

| Kind | Example | Lifetime |
|---|---|---|
| Infrastructure | `routerProvider`, `appDatabaseProvider`, `chitRepositoryProvider`, the services | `@Riverpod(keepAlive: true)` |
| Stream of truth | `todayChitsProvider`, `timelineChitsProvider`, `daySummariesProvider` | auto-disposed; Drift re-emits on subscribe |
| The clock, once | `todayProvider`, `todayLocalDayProvider`, `timelineQueryWindowProvider` | auto-disposed; **one read of the clock per screen** — see below |
| Derived | `timelineWindowProvider`, `monthHeatProvider` | auto-disposed; pure functions of the above |
| Screen state | `composerControllerProvider`, `selectedDateProvider` | auto-disposed |

**Widgets watch controllers and derived providers. Never a DAO, never the database.** That is
the layer rule of §1, expressed as a lint you should notice yourself breaking.

**A screen reads the clock once, through a provider.** `todayProvider` is `clock.now()` and
nothing else, and the date line and the thread both read it rather than each asking the clock.
Two reads a millisecond apart are two different answers at midnight, and a screen showing one
day's date above another day's chits is the failure ADR-006 exists to prevent, arriving by a
different route. It also keeps the read count honest, which is the only thing that can catch a
screen that stopped re-reading the clock at midnight (ADR-033).

**Where an infrastructure provider is declared follows from that rule.** `appDatabaseProvider`
and `audioStoreProvider` are declared beside the things they build, in `data`, because only
`data` and the root ever read them. `chitRepositoryProvider` cannot be: a controller in
`features` has to watch it, and `features` may not import `data`. So it is declared beside its
*interface* in `domain`, unimplemented —

```dart
@Riverpod(keepAlive: true)
ChitRepository chitRepository(Ref ref) => throw UnimplementedError(
  'chitRepositoryProvider is overridden at the root — see main.dart',
);
```

— and supplied in `main.dart`, which is the one place the two layers are allowed to meet. A test
overrides the same seam, on a bare `ProviderContainer` and with real Drift in memory (ADR-031:
there are no tests that pump a screen, so there is no second repository implementation to
choose between). `domain` takes a dependency on `riverpod_annotation` for this; it is pure Dart
and brings nothing from Flutter or `data` with it.

### go_router and Riverpod take every responsibility they can

Neither is here to be a thin wrapper over something hand-rolled beside it. Where one of them
already solves a problem, it solves it.

**go_router owns navigation, entirely.** The shell and both branches (ADR-011), the paths, the
route names, which branch is current, and each branch's stack. `ChitRoute` is the one list of
destinations and the tab bar is built from it, so a destination cannot be added to the router
and quietly miss its tab. Nothing navigates by assembling a path string. The one thing written
by hand is `BranchFade`, and that is written *into* go_router's `navigatorContainerBuilder`
extension point rather than around it — the package has no cross-fading container, and
`StatefulShellRoute.indexedStack` swaps branches with nowhere to put §6.3's 220ms.

**Riverpod owns everything that outlives a build, including the router.** A `GoRouter` is state
— it holds the navigation stack of every branch — so it lives in `routerProvider` and not in a
`StatefulWidget`. ADR-001 says Riverpod is the only state mechanism in the app, and a router
parked in a widget puts the one thing that must survive a rebuild in the one place that does
not. It also keeps the router reachable by anything that later needs to redirect on what a
provider knows. `ChitApp` is a `ConsumerWidget` that watches it and nothing else.

**The one deliberate exception is ADR-011's**, and it stays: the recording sheet is a modal
sheet rather than a route, because it belongs to the composer's state machine and dismissing it
is not a back navigation. That is a decision with a record, not an oversight — reversing it
means a new ADR.

**Startup is synchronous.** `drift_flutter`'s `driftDatabase(name: 'chit')` resolves its own
path lazily, so there is no async bootstrap and no loading state between launch and the home
screen. README §1 — *opening the app costs nothing* — is a startup requirement as much as a
visual one.

**Tests override at the root.** `ProviderContainer(overrides: [...])` with an in-memory Drift
database and fake services. No mocking framework; the interfaces in `domain` are small enough
to implement by hand, and a hand-written fake is readable in six months.

---

## 4. The data flow, behaviour by behaviour

### 4.1 The open chit is not a row

BEHAVIOUR.md §3.1: opening the app six times leaves nothing behind. So the open chit lives entirely
in `ComposerController`, never in the database, and there is no draft persistence. **Save chit**
is the only thing that inserts.

**The controller is synchronous, and that is ADR-007 rather than a shortcut.** `build()` returns
a `ComposerState`, never a `Future` of one: it takes the instant half of the stamp from
`AmbientCapture.open()` and hands the slow half to `settle()`, which lands into the state
whenever it lands, or never. A `FutureOr<ComposerState> build()` would give the open chit a
loading state, and a loading state is a spinner whether or not one is drawn — *nothing about
capture can delay the composer*.

**There is no mode.** BEHAVIOUR.md §3.2 makes the composer one surface — a live field with a
microphone beside it — so `ComposerState` is a record of what the chit currently holds, not a
union of which way in the user picked:

```
class ComposerState {
  String        text;          // the field's live content; the user owns it throughout
  TextOrigin?   textOrigin;    // typed | transcript | transcriptEdited
  String?       audioTempPath; // set once a recording is kept
  Duration?     audioDuration;
  AmbientStamp  stamp;
  bool          isRecording;   // the sheet is up
  bool          sttFailed;     // drives the §3.5 note, and nothing else
  bool          showPrompt;    // the five seconds of §3.3 have run
}

bool get canSave => text.trim().isNotEmpty || audioTempPath != null;
```

`canSave` is the whole of BEHAVIOUR.md §3.1 and §4.1: Discard and Save appear when it is true, and an
untouched chit shows neither. The five-panel state machine the first version of this document
described is gone with the modes.

**What the transitions must preserve**, because each of these is a rule from §3.4 that is easy
to break in a text controller:

- Keeping a recording **appends** its transcript to whatever is in the field; it never replaces
  it. If the field was empty, `textOrigin` becomes `transcript`; if it already had typed text,
  the result is `transcriptEdited`, because the words are now partly the user's.
- Any subsequent keystroke on `transcript` moves it to `transcriptEdited`, once, and never back.
- `audioTempPath` is set by recording and cleared only by Discard. No edit to `text` touches it.
- The microphone is available on an empty chit and on a half-written one, and its target does
  not shrink when text appears (DESIGN-SYSTEM.md §6.4). It is unavailable in exactly two cases: while
  `isRecording`, and once `audioTempPath` is set — one row holds one recording, so a second
  take would have to silently destroy the first. That is a v1 limit, and it should read as a
  settled state rather than a broken button.

`sttFailed` drives the note of §3.5 and nothing else. The note is a property of the state and
never a value of `text` — which now matters more than it did, because `text` is bound to an
editable field: a note written there is a note the user has to delete before they can write.
Placeholder text has the same problem in a milder form and is the tempting shortcut here.

### 4.1a The timeline is three providers, and only one of them touches the database

ADR-024, ADR-032, ADR-035. The strip is the one thing on Today whose shape depends on its own
answer, so it is deliberately three steps rather than one:

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

**The query window and the drawn window cannot be one provider.** What is drawn depends on what
came back, and what came back depends on what was asked for; a single provider would have to
watch its own result. Splitting them also keeps the query honest: it stays three days wide
however little is drawn, so the strip can grow backwards as soon as there is anything back
there to grow into (ADR-035).

**`TimelineWindow` is a plain value with no Flutter and no Riverpod in it**, and every question
about *where* is answered on it — `fractionOf`, `dayBoundaries`, `dayAt`, `trimmedTo`. That is
ADR-031 applied where it bites: under a no-widget-test rule, correctness has to live somewhere
a test can reach without building anything, so the widget is left with layout and gestures and
nothing to be wrong about.

**The widget owns two pieces of state and no more**: the `ScrollController`, and which day was
last under the middle of the viewport (for ADR-034's haptic). Resting at now is computed from
the scroll position rather than stored, so nothing has to be invalidated when the window changes
shape underneath it.

### 4.2 Ambient capture

`AmbientStamp` is resolved once, when the open chit is created, and held in `ComposerState`.
Weather and location run in parallel behind short timeouts (2s is the working figure); the
`Clock` is instant. Whatever has not arrived is `null`, and a null field simply is not drawn.
Nothing here can block, spin, or fail a save (ADR-007).

**There are three signals and still two calls — ADR-037.** Motion rides in on the position fix:
`GeoFix` carries `speed`, `speedAccuracy` and `altitude` beside its coordinate, and
`AmbientCapture` puts them through `domain/motion/motion_ladder.dart`, one pure function, to get
a `MotionState`. So the parallel shape above is untouched, nothing waits longer, and motion
costs no package and no second permission. The corollary is that a refused location costs the
pin **and** the motion together, because they are one signal — the coupling ADR-025 went out of
its way to avoid between location and *weather*, and the right one here.

**Only one of weather and motion is ever drawn**, and `domain/ambient/ambient_fact.dart` ranks
them (ADR-038). That is presentation logic living in `domain` on purpose: which fact is worth a
chit is a product decision, and the widget only switches on the answer.

**`AmbientCapture` in `domain/services` is that paragraph, and it is the whole of it** — M2
group D. Every line is a product rule rather than a network detail, which is why it sits in
`domain` and why M3 changes only which implementations the two service providers resolve to.
Three things about it are load-bearing:

- **The capture holds no clock.** `AmbientCapture.read()` answers the two services and nothing
  else. A time is read where a time is used: by `ComposerController` for the preview on the
  slip, and by its `save` for the value that goes into the row (ADR-040). *This used to be an
  `open()`/`settle()` pair that carried a `capturedAt` through it.*
- **Nothing here ever runs on a path the user is waiting on.** At launch it is fired from a
  post-frame callback and never awaited; at save it runs behind a row that has already been
  written. There is no third caller, and adding one is how the two-second timeout below becomes
  visible to somebody.
- **A signal that throws and a signal that hangs produce the same `null`.** This is the one
  place the *fail loudly in development* rule of CLAUDE.md §4.1 is deliberately not applied:
  to a screen that must not stall there is no useful difference between no network, no
  permission and a service that fell over.

**Captured at launch and at save, and never in between — ADR-042.** `AmbientSignals` owns the
*when* and holds the reading for the life of the process; `AmbientCapture` owns the *what*.
There is no timer, no time-to-live and no refresh on resume. *The composer used to drive a
capture on every chit open,* which meant four taps of **Discard** made four network calls and
four location fixes.

**The row is written first and patched after.** A save inserts with whatever is held, starts a
fresh read beside it, and corrects the row through `ChitRepository.updateAmbient` when it lands.
That method exists separately from `updateText` so that one rule is in the type rather than in
somebody's memory: **the patch moves neither `createdAt` nor `updatedAt`** — moving the first
would move the chit in the thread and, across a midnight, onto another day; moving the second
would claim the user had edited something (ADR-014).

**What is held is a preview; what a row carries is the record.** They differ on purpose, and the
staleness lives on the screen rather than in the data: a phone open all day draws the launch
weather on the open chit, and no chit is ever *recorded* with it.

**Weather takes no position — ADR-025.** This document used to say the two signals run in
parallel without saying how that was possible, given that Open-Meteo is a lookup by
coordinates: the obvious `conditionAt(lat, lon)` would make weather wait on the fix, and
ADR-016 made the fix the slow, precise one. `WeatherService.currentCondition()` therefore takes
nothing, and M3's implementation uses the device's **last known** fix, which is cached and
instant. The cost is that the condition can be for where you were rather than where you are.

Weather comes back from Open-Meteo as a WMO code; `wmo_mapping.dart` turns code + `is_day` +
wind speed into one of the five words BEHAVIOUR.md §3.6 allows. That function is pure and lives in
`domain` — it encodes a product decision, not a network detail.

Location is asked for at **high accuracy, with the coarse fix accepted when that is all the
user granted** (ADR-016). This corrects what this document used to say — *"`geolocator` at low
accuracy"* — and the reason is OPEN-QUESTIONS.md §9's coarse place labels, which a neighbourhood-level fix
cannot produce. Both outcomes are a successful capture and neither changes the UI: §3.6 shows a
pin and never a name. A precise fix is the slower of the two, which is exactly what the timeout
above is for.

### 4.3 The five-second prompt

The timer lives in `ComposerController`, not in the widget, so a rebuild does not restart it.
First character cancels it; clearing the field starts it again. The 700ms appearance is
`ChitMotion.fade` and therefore survives reduced motion, at 140ms — it is the whole event, and
collapsing it would delete the behaviour rather than calm it. The five seconds are a product
rule, not an animation, and never change: `ComposerController.idle`, not a pace.

**A rebuild is the thing this is defending against, and it is invisible when it fails.** The
field is laid out again whenever the keyboard arrives or the action row grows by two controls,
and a timer held in the widget would go back to five seconds each time — the prompt still
appears, just later, and only sometimes. `ref.onDispose` cancels it; **Discard** arms it again,
because **Discard** opens a chit that has just been opened (ADR-040).

**It is drawn over the field, never into it.** `hintText` is the shortcut §4.1 warns about and
it is wrong twice over: a hint is announced as a label on the field, and it arrives on
Material's schedule rather than after five seconds. The overlay sits over the top of the
field's own box, and because the field's first line starts at the top of that box the two set
on one baseline. M5's §3.5 note lands in the same overlay, for the same reason.

**Nothing else is in that overlay.** An earlier version put a drawn blinking caret beside the
prompt, the way the prototype does; ADR-028 took it out. The page opens blank and still, and
the caret that appears on the first tap is the framework's.

**Which words are offered is `Prompts.forStamp` — ADR-029**, a pure function in `domain` over
the stamp the chit already holds. `ComposerState.prompt` is a getter over it rather than a
stored field, so there is one answer and it cannot drift from the moment it is about; it
changes once, if a launch capture lands (ADR-042) inside the five seconds. Nothing in there
reads a clock: the prompt is chosen from the stamp on the slip, which is the preview, so the
question asked is about **the moment you are sitting in** rather than the moment the row will
later be stamped with (ADR-040).

### 4.4 Recording

`AudioRecorder` writes to a temp file. `SpeechRecognizer` — on-device, `onDevice: true`, no
network path at all (ADR-005) — streams partial results into a *pending* transcript held by the
recording sheet, not into `text`. The sheet shows it accruing with the last word in lighter ink.

On **Stop & keep**, the pending transcript is appended to the field under the rules in §4.1.
An empty or absent transcript instead sets `sttFailed`, leaving the field untouched and the
temp audio attached. Both outcomes keep the audio; that is the point of ADR-013.

Three things resolve to `sttFailed`, and the code should have one branch for all of them: the
engine heard nothing usable, the platform refused on-device recognition, or the handset has no
model for the language. From the user's side these are the same event.

**Discard** deletes the temp file. Nothing moves to permanent storage until Save (ADR-008).

Recording is available on a chit that already has text — that is the ordinary case of §4.1's
append rule. It is available **once**: a row holds one `audioPath`, so a second take would have
to destroy the first, and the microphone retires once `audioTempPath` is set rather than
silently overwriting it (BEHAVIOUR.md §3.2).

### 4.5 Save, and why the tabs cannot disagree

`ChitRepository.save()` writes the row and, when there is a recording, moves the audio into
place — one call, ordered so a failed file move does not leave a row pointing at nothing.

`ChitRepository.updateText()` is the ADR-014 counterpart: it changes `text`, `textOrigin` and
`updatedAt`, and it can change nothing else. `createdAt`, `localDay` and `audioPath` are not
parameters, so an edit cannot move a chit in the thread, relight a calendar tile, or lose a
recording.

Everything downstream is a Drift stream. The thread, the timeline, the calendar density and the
month total are four providers reading four queries, so a save updates them together by
construction. *The thread and the timeline read the same query until ADR-024; the timeline
covers three days now and the thread one, so they are `watchDay` and `watchDayRange`.* DESIGN-SYSTEM.md §7 requires that the two tabs never disagree; the prototype held them in
step by hand, and here it is the only thing the architecture allows.

### 4.6 Calendar queries

Two, both grouped on `localDay` (ADR-006):

- `daySummaries(monthStart, monthEnd)` → `(localDay, count)` rows. The count maps to the four
  density steps of BEHAVIOUR.md §4.2; the mapping is in the presentation layer, since it is a design
  scale and not a fact about the data.
- `chitsGroupedByDay(limit, offset)` → the archive, newest day first, paged.

Selecting a date sets `selectedDateProvider`; the archive provider watches it and filters. No
second source of data, no copy to keep in sync.

---

## 5. Theme and motion

DESIGN-SYSTEM.md §6 becomes four `ThemeExtension`s (ADR-010). Two of them carry rules, not just values:

**`ChitColors`** exposes `seal` and `sealInk` as separate members with doc comments stating the
split — marks, fills, borders and icons take `seal`; anything read as words takes `sealInk`.
The design log explains why (`seal` is 4.09:1 on a slip; text needs 4.5:1). *That figure was
4.23:1 until v6 brightened `--slip`; the rule it justifies did not move.*

**`ChitMotion`** exposes two resolvers rather than a bag of durations:

```
Duration travel(Duration d)      // → Duration.zero when animations are disabled
Duration fade(Duration d)        // → 140ms when animations are disabled
Duration fadeArrival(Duration d) // → 220ms when animations are disabled
```

Reduced motion is then a property of *which helper a widget reached for*, which is the
distinction the design log insists on and the one a global duration override would erase. The
fades are not passed through untouched: the design log re-times them to 140ms on transitions
and 220ms on arrivals, so a fade still announces itself without carrying the house pace of an
animation that is no longer moving.
Ambient loops — the pulse at now, the record dot, the live waveform — take their period from
`ChitMotion.loop`, which hands back `Duration.zero` under reduced motion: the signal to start
no ticker at all and draw the thing at rest (ADR-027). *chit draws no caret of its own, so the
caret blink §6.4 also names is the framework's — see PROGRESS.md open item 14.*

---

## 6. Errors

| What fails | What the user sees |
|---|---|
| Weather or location | that field is absent from the stamp. No message. |
| Speech recognition — heard nothing, refused on-device, or no model | `sttFailed` — the audio is kept, the field is empty and theirs to type in, the note explains |
| Microphone permission refused | the sheet does not open; the microphone explains once and stays available |
| Audio file missing at playback | the chit renders; the pill is absent |
| A database write | the only case that gets a visible failure, because the user's words are at stake |

The general shape: **ambient signals fail silently, the user's content never fails silently.**

---

## 7. Testing

**No widget tests** — ADR-031, and `test/docs/no_widget_tests_test.dart` fails if one appears.
Nothing under `test/` builds a widget. **Anything that can only be seen on a screen is seen on a
handset**, and what was seen is written into PROGRESS.md.

That is a constraint on where behaviour lives, not only on the test folder: if a rule cannot be
reached without a widget, the rule is in the wrong place, and the fix is to move it down into a
controller or a pure function rather than to pump a tree to get at it.

What is tested:

- **Repository and DAO** against `NativeDatabase.memory()` — the at-least-one invariant and the
  `textOrigin` pairing, the `localDay` computation across a midnight and a timezone change, the
  audio move-on-save and delete-on-discard, and that `updateText` leaves `createdAt`,
  `localDay` and `audioPath` untouched. Plus the migration, against the snapshots committed in
  `drift_schemas/`.
- **Models**, where the invariant of §5 fails first — a chit that cannot be *built* — and again
  at the table's check constraints, where it survives a release build with the asserts compiled
  out.
- **Controllers and services** on a bare `ProviderContainer`, with a fake clock and hand-written
  fake services. The five-second timer; `canSave`; ADR-007's parallel capture and its timeouts;
  and the transcript rules of §4.1 — append rather than replace, the one-way slide from
  `transcript` to `transcriptEdited`, and all three routes to `sttFailed`.
- **Pure functions** — the prompt book, the WMO mapping, the count-to-density scale, the
  timeline position for a time. Most of what used to be asserted through a screen belongs here,
  and getting it here is the work.
- **The accessibility floors of DESIGN-SYSTEM.md §6.4 as arithmetic, not as intentions.** The
  contrast of every text token against every surface it is used on, including composited
  translucent surfaces — which is where the audio pill's wash caught the design out, 7% seal in
  v5 and 3.5% ink in v6, a failure either way. Contrast is a calculation over tokens and needs
  no widget tree; the floors that *are* spatial — touch targets, semantics, heading order — are
  a device pass instead.
- **The rules about the rules** — README §10's map, the injected clock of ADR-012, and the
  no-widget-test rule itself.

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
