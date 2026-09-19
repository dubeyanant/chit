# Architecture

How chit is put together. The *why* is in [DECISIONS.md](DECISIONS.md); the behaviour is in
[BEHAVIOUR.md](BEHAVIOUR.md) and [DESIGN-SYSTEM.md](DESIGN-SYSTEM.md), which win where this
document disagrees.

## 1. Shape and folders

Three layers and one rule. **`features` never imports `data`** (ADR-002): a widget watches a
controller, the controller depends on an interface in `domain`, and Riverpod supplies the
implementation at the root — which is what lets a test refuse a microphone and a sync layer arrive
later without a screen noticing. **`domain`** is models and interfaces, pure Dart with no Flutter,
importing neither layer below; **`data`** is the implementations — Drift, the filesystem, the
network, the platform plugins; **`features`** is controllers and widgets, one folder per screen,
split `application/` and `presentation/`.

```
lib/
├── app/       the root and the router — go_router: shell + three tabs
├── core/      the four ThemeExtensions of §6, the injected clock, the BuildContext sugar
├── domain/    models/ (Chit and its invariant, the stamp, the enums, the screen states, the
│              sealed AudioEdit) · ambient/ · motion/ · weather/ · tags/ (the sealed ChitSpan
│              and its grammar) · find/ (the four axes, and where a column sits) ·
│              geo/ (the projection, and how the map frames itself) ·
│              repositories/ · services/
├── data/      db/ · audio/ (store, recorder, player) · dev/ (the seeder, the frame log) ·
│              weather/ · location/ · geo/ (the bundled atlas and its codec) ·
│              preferences/ · repositories/
├── features/  shell, today, composer, calendar, find, editor, onboarding
└── shared/    widgets/ (the chit vocabulary) · day_label.dart · day_group.dart
```

A widget used by one screen stays in that screen's `presentation/widgets/` until a second screen
wants it. `Clock` lives in `core/`, not `domain` — `core` is imported by every layer and depends on
none, which is what an injected clock needs.

**The archive is a lazy sliver, and that is load-bearing** (ADR-077). Every day group is built by
`SliverList.builder`, so what the reader cannot see is not built — and since ADR-079 the list holds
one month, so it is bounded as well as lazy. Anything added to that screen keeps the rule: **a list
whose length is a function of how much somebody has written belongs in a sliver that builds on
demand.**

**The shared widgets are the chit vocabulary — no state, no provider, each takes only what it
draws.** `DayThread` is why the archive's *same treatment as Today* is true by construction: one
widget, not two that look alike. Four earn exceptions — **`AudioPill` watches a provider**, since
which pill is lit is a property of the app's one player rather than of the row — **through a
`select` that answers with its own row's playback**, so one pill's playhead does not rebuild the
forty pills around it (ADR-077); **`ChitRow`
navigates**, pushing the editor itself rather than taking a callback both callers would pass
identically (ADR-061); **`ChitBody` navigates too, and is stateful for it** (ADR-086) — a tag goes
to find on the same argument, and its `TapGestureRecognizer`s have to be owned and disposed, one
built inside `build` leaking one a frame; and **`Microphone` takes a callback**, since the two
screens that draw it send the same take to different owners (ADR-065).

## 2. Riverpod conventions

**Everything is generated** — `@riverpod`, `part 'x.g.dart'`, `build_runner watch -d`.

| Kind | Example | Lifetime |
|---|---|---|
| Infrastructure | the router, database, repository, services | `keepAlive` |
| Stream of truth | `todayChitsProvider`, `timelineChitsProvider`, `monthSummariesProvider`, `archiveChitsProvider` | auto-disposed; Drift re-emits on subscribe |
| The clock, once | `todayProvider`, `timelineQueryWindowProvider`, `visibleMonthProvider` | auto-disposed; one read of the clock per screen |
| Derived | `timelineWindowProvider`, `drawnMonthProvider`, `archiveDaysProvider` | pure functions of the above — except the last two, which **hold their last answer while the stream under them loads** (ADR-049) |
| Screen state | `composerControllerProvider`, `selectedDayProvider`, `editorControllerProvider(id)` | auto-disposed; the editor's is a family keyed by chit id |
| A take | `recordingControllerProvider` | **`keepAlive`** — ADR-057, the one exception |

**Widgets watch controllers and derived providers. Never a DAO, never the database.** **A screen
reads the clock once, through a provider**, so two reads a millisecond apart cannot disagree at
midnight; the one exception is `timelineNowProvider`, which re-reads whenever the rows under the
strip change so the tick keeps up with a save (ADR-066), and can differ by the minute, never the
day. `chitRepositoryProvider` is declared unimplemented beside its interface in `domain` and
overridden in `main.dart` — the one place the two layers meet, and the seam tests override on a bare
`ProviderContainer` with real Drift in memory.

**go_router owns navigation entirely**; `ChitRoute` is the one destination list the tab bar is built
from, and `BranchFade` is written *into* `navigatorContainerBuilder` rather than around it.
**find's two deeper screens are nested routes inside its branch** (ADR-084), so the tab bar stays
and the system back walks up a level — a drill-down held as state, with a `PopScope` to catch back,
is hand-rolling beside the package that already has the seam.
**Riverpod owns everything that outlives a build, the router included** — a `GoRouter` in a
`StatefulWidget` puts the one thing that must survive a rebuild in the one place that does not. The
two exceptions are the recording sheet (ADR-011) and the prompt sheet (ADR-064): modal sheets, not
routes, because dismissing either is not a back navigation. **Startup is synchronous** — Drift
resolves its path lazily, so there is no async bootstrap and no loading state before the home
screen; *opening the app costs nothing* is a startup requirement, not just a visual one.

## 3. The data flow

**The open chit is not a row.** It lives entirely in `ComposerController`, never the database, and
**Save** is the only insert. **The controller is synchronous**, since a `FutureOr` build would give
the open chit a loading state: it takes the instant half of the stamp and hands the slow half to
`settle()`, which lands whenever it lands or never. `ComposerState` records what the chit holds, not
which way in the user picked; keeping a recording **leaves the field exactly as it was**, and
`audioTempPath` is cleared only by `removeTake`, which never touches `text`.

**The timeline is three providers, and only one touches the database.** The query window and the
drawn window cannot be one provider — what is drawn depends on what came back, and what came back
depends on what was asked for — and splitting them keeps the query three days wide however little is
drawn, so the strip grows backwards the moment there is something to grow into (ADR-035).
**`TimelineWindow` is a plain value, no Flutter, no Riverpod**, so a no-widget-test rule still has
somewhere to check *where*. The widget owns two pieces of state: the `ScrollController`, and which
day was last under the middle of the viewport (ADR-034's haptic).

**Ambient capture.** Weather and location run in parallel behind a 12s timeout; whatever has not
arrived is null, and nothing here can block, spin or fail a save. Motion rides on the position fix
(ADR-037), and only one of weather and motion is ever drawn, ranked in `domain` on purpose since
which fact is worth a chit is a product decision. **`AmbientCapture` holds no clock** — a time is
read where it is used. **A throw and a hang both produce `null`**, the one deliberate exception to
*fail loudly in development*. **`AmbientSignals` owns *when*, `AmbientCapture` owns *what***: a
reading is good for one minute, the row is written first and patched only if stale, and
`updateAmbient` is a separate method so one rule lives in the type — **the patch moves neither
`createdAt` nor `updatedAt`**.

**The five-second prompt.** The timer lives in the controller, not the widget: the field relays out
whenever the keyboard arrives or the action row grows, and a widget-held timer would restart each
time — a failure that is invisible. It is drawn *over* the field, never into it; `hintText` is the
tempting shortcut and wrong twice, announced as a label and shown on Material's schedule.
`ComposerState.prompt` is a getter, not a stored field, and reads the stamp on the slip rather than
the clock, so the question is about the moment you are sitting in.

**Recording and playback.** `RecordingController` owns the sheet's state and is the one screen
controller that is `keepAlive` (ADR-057). **Who gets the take is decided at the tap** — `start`
takes a `RecordingSink` and holds it for the take's life, and the sheet knows neither screen. Both
Discard and Remove delete the temp file through `ChitRepository.discardTemp`, and nothing moves to
permanent storage until Save. `showRecordingSheet` is what ends the take, so a dismissal the widget
never hears about cannot leave a microphone running. **One `AudioPlayer`, `keepAlive`**, so two
pills can never sound at once, and `JustAudioPlayer` is the one place a relative saved path and an
absolute temp path are resolved — `features` has no filesystem. **The stream gives every listener
the current state before a change**, a pill being routinely built long after a recording started
sounding; **`stopIf(id)`** is the other half, since a pill about to stop being drawn cannot stop
what it started, and the `if` keeps a chit playing in the thread from being silenced by a save.

**Save, and why the tabs cannot disagree.** `save()` writes the row and moves the audio in one call,
ordered so a failed move never leaves a row pointing at nothing. `update()` takes the words and a
sealed `AudioEdit` in one write (ADR-063); `createdAt`, `localDay` and the ambient fields are not
parameters, so an edit cannot move a chit in the thread or relight a calendar tile. The editor loads
its chit **once** rather than watching it (ADR-062), so it is the one screen that does not re-emit
on a write — the write is its own. Everything downstream is a Drift stream: four providers over four
queries, so one save updates them all by construction. That is the whole mechanism behind *the two
tabs never disagree* — they are not kept in step, they are the same data.

**The calendar is two chains off one reading of the day.** `MonthShape` is a plain value for the
same reason `TimelineWindow` is, and **the current month draws up to today and stops** because a
future month's `lastDrawnDay` is zero, not because the widget checked. **The drawn month lags the
visible month by one answer, on purpose** (ADR-049), the bar taking its name from the drawn one so
name and grid change together. **`VisibleMonth` computes its own destinations** rather than reading
its neighbours provider back, which would be a cycle. **The selection resets by watching the month,
not by being cleared**, and **a filtered archive is `watchDay`** — the same query Today's thread
runs. **The unfiltered archive is the visible month's range** (ADR-079), so the list under the grid
reads the month the bar is naming and cannot drift from it.

## 4. Theme, errors, testing

§6 becomes four `ThemeExtension`s. `ChitColors` exposes `seal` and `sealInk` separately — marks take
`seal`, anything read as words takes `sealInk`. `ChitMotion` exposes resolvers rather than
durations: `travel` goes to zero when animations are disabled, `fade` to 140ms, `fadeArrival` to
220ms, `loop` to zero — no ticker, drawn at rest. **Reduced motion is a property of which helper a
widget reached for**; a global override would erase that distinction, and fades are re-timed rather
than passed through so a fade still announces itself.

**Ambient signals fail silently; the user's content never fails silently.** A failed weather or
location call is simply absent from the stamp; a refused microphone does not open the sheet and
explains once; a missing audio file leaves the chit rendering without its pill. A failed database
write is the only visible failure, the user's words being at stake.

**No widget tests** (ADR-031) — a guard test fails if one reappears, and anything only visible on a
screen is seen on a handset and written into the commit. This constrains where behaviour lives: a
rule unreachable without a widget belongs in a controller or a pure function. Tested instead: the
repository and DAO against `NativeDatabase.memory()`; models, where the invariant fails first and
again at the check constraints, which survive a release build with asserts compiled out; controllers
and services on a bare `ProviderContainer` with a fake clock; pure functions; and §6.4's floors as
arithmetic, composited, the spatial ones being a device pass. **A fake must refuse whatever the real
one refuses** — both times one lied here it cost a handset pass (ADR-057, ADR-067).

Before a commit: `dart format .`, `flutter analyze` clean (the Riverpod lints run inside it —
[PACKAGES.md](PACKAGES.md) says why there is no separate step), `flutter test`, and **the documents
the change made untrue** ([CLAUDE.md](../CLAUDE.md) §0, §0.1). Generated files are committed, so a
fresh clone runs without codegen.
