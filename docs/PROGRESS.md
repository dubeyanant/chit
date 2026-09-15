# Progress

**Where the build is, and what to do next.** This is the handover document: a session that
has read only this file and `CLAUDE.md` should be able to pick up the work.

Updated at the end of every working session, per the standing rule in
[CLAUDE.md](../CLAUDE.md) §0 — including sessions that ended mid-milestone.

**Last updated:** 16 September 2026, after M1, after v6 — which moved the documents and then the
code behind them — and after M2 groups A, B, C, D and E.

---

## Status board

| Milestone | State | Notes |
|---|---|---|
| **M0a** — project stops being a scaffold | ✅ done | 14 Sep 2026 |
| **M0b** — the design system in code | ✅ done | 14 Sep 2026 |
| **M1** — the data spine | ✅ done | 15 Sep 2026. ADR-021 |
| **M2** — Today, text only | 🔶 in progress | groups A–E of [TASKS.md](TASKS.md) done; **F and G are next**. ADR-023 to ADR-026 |
| M3 — ambient capture | ⬜ | |
| M4 — calendar | ⬜ | |
| M5 — voice | ⬜ | |
| M6 — the chit editor | ⬜ | OPEN-QUESTIONS.md §8.1 settled 14 Sep 2026 (ADR-017) |
| M7 — motion and the floors | ⬜ | |

**206 tests, `flutter analyze` clean, debug APK builds.**

**On a handset:** the masthead on `--paper`, a two-tab bar, and **the open chit** — a slip with
its tear edge and the pad behind it, its stamp reading `3:42 pm   raining   ⌖` spaced and never
separated, a page to write on, and a microphone leading the action row. Typing brings
**Discard** and **Save chit**; Discard works, and Save is drawn and does nothing until group G.
Tapping *calendar* cross-fades to a placeholder line that M4 deletes. Below the slip there is
nothing yet: the date line and the thread arrive with G, the timeline with H.

*Nobody has looked at any of it on a device. Group E is the first milestone work with real
type on a real surface, which is what open item 1 has been waiting for.*

*The palette was confirmed on a device on 15 September, before the shell existed: dark warm
brown, "chit चित्त" in the gutter — `--paper` `#191714` behaving exactly as §6.1 sets it. Nobody
has looked at the tab bar on a real screen yet.*

---

## What M0a did

- **Dependencies.** `pubspec.yaml` carries every package in [PACKAGES.md](PACKAGES.md), all
  resolving at their pinned versions. `custom_lint` was dropped — ADR-018.
- **The scaffold is gone.** `lib/main.dart` is `runApp(ProviderScope(child: ChitApp()))`.
- **Platforms.** `windows/`, `linux/` and `macos/` deleted; `.metadata` trimmed. `web/` kept
  — ADR-019.
- **Fonts.** The three families of DESIGN-SYSTEM.md §6.2 in `assets/fonts/` as **variable** fonts with
  their OFL licences — ADR-015, which corrected what PACKAGES.md used to say.
- **Android.** `minSdk` 24 (`record_android`'s floor). `RECORD_AUDIO`, `ACCESS_FINE_LOCATION`,
  `ACCESS_COARSE_LOCATION`, `INTERNET`, and the `android.speech.RecognitionService` queries
  intent `speech_to_text` needs from targetSdk 30.
- **iOS.** The three usage strings in `Info.plist`, in chit's voice. Deployment target 15.0,
  already above every plugin's floor.
- **Package name.** `com.infiniteants.chit` in all five places it lives.
- **Gradle.** `kotlin.incremental=false` — every plugin's `compileDebugKotlin` failed with
  *"Could not close incremental caches"* on this Windows setup, reproducibly. Costs rebuild
  time and nothing else.

---

## What M0b did

- **The skeleton.** Every file in [ARCHITECTURE.md](ARCHITECTURE.md) §2 exists. The ones a
  milestone has not reached hold a doc comment naming that milestone and nothing else.
- **The four theme extensions** in `lib/core/theme/`:
  - `ChitColors` — the ten tokens of DESIGN-SYSTEM.md §6.1, plus `sealWash` (replaced by `inkWash` in v6) for flattening the audio
    pill's translucent surface so it can actually be checked.
  - `ChitType` — twenty-five styles, the whole scale. Every one sets `fontVariations`.
  - `ChitSpace` — the 4px scale under the prototype's own `s1`…`s8` names, so porting a rule
    out of the CSS is a rename rather than a translation.
  - `ChitMotion` — the pace table as a `ChitPace` enum with `travel()` and `fade()`.
- **`context.colors` / `.type` / `.space` / `.motion`** in `lib/core/extensions.dart`. Four
  accessors, not one, so a widget that needs a colour cannot reach motion. `.motion` resolves
  the reduced-motion flag from `MediaQuery`, which is what makes DESIGN-SYSTEM.md §6.4 one decision.
- **`Clock`** in `lib/core/clock.dart` with `clockProvider`, and a test that fails if anything
  else in `lib/` calls `DateTime.now()`.
- **`analysis_options.yaml`** tightened: strict casts, inference and raw types; exhaustive
  switches and unawaited futures as errors; immutability and documentation rules;
  `riverpod_lint` through `plugins:`.
- **The masthead.** "chit चित्त" on `--paper`, baseline-aligned, in the page gutter.
- **Three test suites**, 43 tests at the time: the contrast floor of DESIGN-SYSTEM.md §6.4 composited, the
  `fontVariations` rule of ADR-015, and the reduced-motion rule of §6.4.

### Two things M0b changed elsewhere

1. **DESIGN-SYSTEM.md §6.1's contrast figures were slightly wrong** and are now measured. `--ink-muted`
   is 6.49:1 on the ground (was quoted as 6.4), `--ink-faint` 5.08:1 (was 5.0), and `--seal`
   is 4.23:1 on a chit (was 4.24). The test asserts the corrected values to ±0.01, so the
   prose and the arithmetic cannot drift apart again.
2. **ADR-020.** Under reduced motion the old rule stretched press feedback from 90ms to 140ms
   — slower, for the users who asked for less animation. The re-timing is now a ceiling, not
   an assignment. Found by a test asserting a *property* ("no fade is slower than it was")
   rather than a value; worth copying when M7 writes the remaining floors.

**Verified:** `flutter analyze` clean, `flutter test` 43 passing, `dart format` clean,
`dart run build_runner build` clean, `flutter build apk --debug`, and the masthead confirmed
rendering on a handset.

### After M0b: the README became a map

The README was 541 lines and held the whole specification, so "read the README" meant reading
a wall. It is now 271 lines: **§0** is the reading order and the standing rule, **§10** is the
map of every file in the repository, and §1, §2 and §5 are what chit is and what a chit is.
The rest moved out:

| Section | Now in |
|---|---|
| §3 behaviour specification, §4 screens | `docs/BEHAVIOUR.md` |
| §6 design system, §7 the prototype | `docs/DESIGN-SYSTEM.md` |
| §8 the three hard questions, §9 backlog | `docs/OPEN-QUESTIONS.md` |

**Section numbers did not change**, and that was the whole trick. Roughly two hundred citations
in the docs and the source point at §6.1, §3.5, §8.1 and the rest. A section keeps its number
wherever it lives, so only the filename in front of a citation had to be rewritten — never the
number. That is why README §0 has a table of which file owns which number, and why the README's
own numbering has gaps. **Never renumber.**

The design authority is now three files — `README.md`, `BEHAVIOUR.md`, `DESIGN-SYSTEM.md` —
and `CLAUDE.md` §1 and §0's table say so.

`test/docs/readme_maps_everything_test.dart` keeps the map honest: it fails if a document, a
prototype, a test suite or a top-level source directory exists without a line in README §10,
or if an ADR exists without a row in the index now at the head of `DECISIONS.md`. An index
nobody maintains is worse than none, so this one is maintained by the build.

The same pass found three places still quoting `--seal` at **4.24:1** after §6.1 was corrected
to 4.23 — `ARCHITECTURE.md`, `DESIGN-LOG.md` and `chit_colors.dart`'s own doc comment. All
three are fixed. Worth noting how it happened: the figure was corrected where the test pointed
and nowhere else, and a `grep` for the old value would have caught it in seconds. **When a
number changes, grep for the old one before committing** — the standing rule is only as good as
the search that backs it, which is now step 4 of `CLAUDE.md` §0's checklist.

**Not verified:** how the type actually renders on a handset. The masthead is on screen but
nobody has looked at Newsreader and Noto Serif Devanagari at real size on a real display. Do
that before M2 starts drawing with the scale — see open item 1.

---

## What M1 did

Everything BUILD-PLAN.md M1 asked for. No UI, which is the milestone that is tempting to skip
and expensive to retrofit.

- **The models.** `Chit` (freezed, private constructor, five asserts), `AmbientStamp`,
  `DaySummary`, `WeatherCondition`, and `TextOrigin` — the last of these lives inside
  `chit.dart` rather than in a file of its own, because it is half of the `text` / `textOrigin`
  pairing the invariant is about.
- **The table.** One table, three indexes, five check constraints. `Chit.localDayOf` is the one
  place a wall clock becomes a `yyyymmdd`.
- **The database and the DAO.** The three queries of DATA-MODEL.md §4 — `watchDay`,
  `watchDaySummaries`, `watchArchive` — plus `byId`, the insert, the narrow update, and the
  audio paths the sweep needs.
- **The repository.** Interface in `domain`, implementation in `data`, and `main.dart` the one
  place they meet. Both `save()` and `updateText()` (ADR-014): the update path exists from the
  start so M6 does not have to grow one in a hurry.
- **The audio store.** Temp → permanent, discard, the orphan sweep, and `resolve` for playback.
  The sweep is wired at startup in `main.dart` and nothing waits for it.
- **The migration harness**, and `drift_schemas/drift_schema_v1.json` committed before there is
  anything to migrate.
- **Seventy-one tests**, taking the suite from 49 to 120.

### The three things M1 changed elsewhere

1. **ADR-021 — a chit is stamped when it is opened, not when it is saved.** There is one time
   column and README §2 already said what it holds. `save()` takes the `AmbientStamp` and stores
   its `capturedAt` as `createdAt`; the clock is read at save time for `updatedAt` alone.
   **M2 has to honour this**: hold the stamp in `ComposerState` from the moment the chit opens
   and pass that same object to `save()`. Re-capturing it on save undoes the decision silently.

2. **The text column is `body`, and the row class is `ChitRow`.** DATA-MODEL.md §1 used to show
   `TextColumn get text => text().nullable()();`, which does not compile — `text` is the name of
   Drift's own column builder. The rename was forced twice over: the versioned-schema classes
   that `drift_dev schema generate` writes derive their Dart names from the SQL, so a column
   called `text` also breaks the migration harness. Found by building the harness at v1 rather
   than at v2, which is the whole argument for building it early. **The rename stops at the data
   layer** — README §5, the domain model and every screen still say `text`.

3. **Open item 3 is closed.** `sqlite3_flutter_libs 0.6.0+eol` is the latest release and the
   package is now empty: `package:sqlite3` 3.x ships the native library itself and our tree
   already resolves it at 3.5.2. Nothing to do, and it falls away when `drift_flutter` drops it.
   The happy consequence is that `NativeDatabase.memory()` opens in `flutter test` on Windows
   with no setup at all, which is what every repository test runs against.

**The pattern worth copying**, and the M1 counterpart to M0b's *test a property, not an
example*: **an invariant worth having is worth holding in more than one place, and each place is
tested where it lives.** README §5's one-of rule is an assert, a check constraint and a
repository refusal — because an assert is compiled out of a release build, a constraint cannot
say *why*, and a repository is one caller among however many a later milestone adds. The three
suites that hold it are `test/domain/chit_test.dart`, `test/data/db/chits_table_test.dart` and
`test/data/chit_repository_test.dart`.

**Verified:** `flutter analyze` clean, `flutter test` 120 passing, `dart format` clean,
`dart run build_runner build` clean.

---

## What the v6 pass did — documents only, 15 September 2026

`design/chit-app-v6.html` arrived and became the visual target. **No code was changed**, by
instruction: this pass moved the documents so that the target is written down, and left the
work of moving the code as open item 11.

v6 changes nothing about what the app *does*. §3 is untouched. It is a visual revision, and the
through-line is one decision:

**ADR-022 — the seal means now; a record is ink.** The accent had spread to the caret, the
arc's marks, the calendar heat, the tab pip, the audio pill, the microphone and Save — which is
to say, to everything that mattered, which is to say, to nothing. It now marks only what is
live: the ring at now, the caret, the record dot, today's ring, and a pill *while it is
playing*. Everything else is ink.

The rest, and where each is written down:

| Change | Recorded in |
|---|---|
| `--slip` `#211E1A` → `#24211C`, and every ratio measured against a chit moved with it | DESIGN-SYSTEM.md §6.1 |
| The accent rule, and the table of ink washes that replaces it | §6.1, ADR-022 |
| The date: stacked weekday over 38px → one 26px line. The field: 19px → 17.5px | §6.2 |
| No uppercase anywhere; the ambient stamp and the chit meta line are the same words in the same case | §6.2, BEHAVIOUR.md §3.6 |
| The pin is drawn on the open chit only | BEHAVIOUR.md §3.6 |
| The calendar: density in ink, no near-white numeral, no legend, the month drawn up to today | BEHAVIOUR.md §4.2 |
| The चित्त closing mark appears at the foot of Today only | BEHAVIOUR.md §4.1, DESIGN-LOG.md |
| Sheet radius 14px → 8px; calendar tiles 4px at a 5px gap; perforation 1.55px at 8px | §6.3 |
| Grain on by default at 5%; live waveform 32 bars → 20 thin strokes | §6.3, §7 |
| Four vertical gaps tightened so the slip sits higher | §6.3 |

**Two open items closed, one opened.**

- **Open item 2 is closed by v6** and needs no token after all. `#FFF6EE` existed only so a
  numeral could survive a strong `--seal` fill, and `#1A1310` existed only as the label on a
  solid `--seal` button. Both fills are gone, so both colours are gone. Worth noticing: the
  fix for "we have two colours with no token" turned out to be removing the thing that needed
  them, not naming them.
- **Open item 12 is new, and it is a real floor failure**: today's `--seal` ring measures
  1.88:1 against a four-chit tile. It came in with ADR-022 and is written down rather than
  waved through.

**Verified:** every figure quoted in the documents above was recomputed from the v6 CSS rather
than carried over — the same WCAG arithmetic `test/support/contrast.dart` uses, checked against
the one v5 figure the design log already recorded (4.36:1) before any new number was written
down. `flutter test` still passes at 120, unchanged, because no code moved.

### And then the code, the same day

Open item 11 is **done**, so the documents and `lib/core/theme/` describe v6 together again.
What moved:

- **`ChitColors`** — `slip` to `#24211C`; `sealWash` replaced by `inkWash`, since v6 has no
  accent wash left anywhere in the app; the wash alphas named (`pillWash`, `saveWash`,
  `pillPressedWash`, `micPressedWash`, `densitySteps`) so that neither a widget nor a test
  spells a design value twice. No hover alphas — a finger has no hover, and web is after v1.
- **`ChitType`** — the date to 26px on one line with the weekday beside it at the same size and
  weight; the field to 17.5px; every 16px style to 16.5px; the ambient stamp down from
  600-weight `.1em` to 500-weight `.02em` in `--ink-muted`; `legend` deleted.
- **`ChitSpace`** — `sheetRadius` 14 → 8, and `tileRadius` 4 added.
- **The vocabulary** — `heat` and `warmth` are `density` in `lib/` now, per BEHAVIOUR.md §4.2.

**Ten new assertions, 120 → 130**, and the theme tests now pin the v6 figures the same way M0b
pinned v5's. Three of them are new in kind: the weekday and date must set as one phrase, the
open chit and the thread must speak one dialect, and a chit must separate from the ground by
more than v5 managed — properties of the v6 decisions rather than of its numbers.

**Two things this pass found that reading could not.**

1. **The uppercase claim in §6.2 was wrong** and is corrected. It read *"there is no
   uppercase"*; `LISTENING` on the recording sheet still is, and always was — v6 removed the
   uppercase from the ambient stamp, not from the app. Written from the diff without checking
   the sheet.
2. **`--hair-soft` collapsed on a chit.** M0b's hairline test has a "collapse detector" floor of
   1.03:1, and brightening `--slip` pushed the pair from 1.0498:1 to 1.0145:1 — the test failed
   on the first run after the token changed. It is open item 13. The detector was written in
   M0b as a guard against a token being *tuned* until it vanished; what actually happened is
   that a different token moved underneath it, which is the better argument for having it.

**Verified:** `flutter analyze` clean, `flutter test` 130 passing, `dart format` clean,
`flutter build apk --debug`.

---

## M2 group A — the five decisions, settled

[TASKS.md](TASKS.md) is M2 in ten groups; group A was the decisions the rest of it turns on, and
it is done. Three are small and two reach a long way.

1. **Gaps come off the scale, always.** The wordmark's 7px gap is `s2` and no token was added
   for it. The rule is now written down in DESIGN-SYSTEM.md §6.3 and CLAUDE.md §4.2, along with
   the line it draws: a *dimension* may sit off the scale when it belongs to one component and
   is named (the gutter, the touch target, the microphone, the 7px marks); a *gap* may not,
   because a gap is a relationship and the scale exists to keep relationships consistent.
2. **ADR-023 — the field does not take focus at launch.** BEHAVIOUR.md §3.2 says typing costs
   "not even a tap", and taken literally that costs the user the screen instead: a keyboard on
   every launch hides the thread, the timeline and half the open chit. §3.2's point is that
   there is no *mode* to choose, and that survives intact.
3. **No settings control.** The prototype draws a gear with nothing behind it and v1 has no
   settings anywhere in §3 or §4.
4. **Discard gets a pressed ink wash** — closes open item 13, above, and turned up the
   label-contrast problem recorded there.
5. **ADR-024 — the day arc becomes the timeline.** Full days rather than 5am–midnight, three
   days rather than one, scrolling and resting at now, proportional, and scrolling smoothly to
   a chit as it is saved.

**ADR-024 is the one with reach**, and two things about it are worth carrying forward.

It fixed a bug nobody had seen because nothing was drawing it yet: 5am–midnight leaves out the
five hours ADR-006 works hardest to protect, so a chit written at 00:20 — which ADR-006 insists
belongs to that morning — had nowhere to go but the left edge, stacked on top of 5am. **A
specification can hold a contradiction for two milestones if no code has had to honour it.**

And it renamed a thing the whole repository referred to. "The day arc" describes something that
no longer exists, and CLAUDE.md §4.1 is explicit that a synonym is a bug in the making — a name
that is plainly wrong is worse. It is **the timeline** now, in the README, in the specification,
in the design system and in the code: `ChitType.arcEnd` and `arcNow` are `timelineLabel` and
`timelineNow`, and `day_arc_provider.dart` is `timeline_provider.dart`. About forty references.

**It also cost the architecture a property**, which is stated rather than glossed: the thread
and the arc used to read the same query and the two tabs could not disagree by construction.
The timeline covers three days and the thread covers one, so M2 adds
`ChitRepository.watchDayRange` and there are four queries behind six readings rather than three.

**Verified:** `flutter analyze` clean, `flutter test` 132 passing, `dart format` clean,
`flutter build apk --debug`. Group A moved no widgets — the app still opens to the masthead.

The day boundary ADR-024 left open is now answered, in BEHAVIOUR.md §4.1 where that record said
the answer would go: **a small upward mark below the line, unlabelled.** Noticed rather than
read — naming each day would make the timeline a second calendar, and §4.2 is already that.

---

## M2 group B — the shell and the frame

The app routes. Two tabs, a masthead that belongs to neither of them, and a tab bar; Today is an
empty page and the calendar is a placeholder line that M4 deletes.

- `app/router.dart` — `StatefulShellRoute`, two branches, and `ChitRoutes` so nothing navigates
  by a loose string.
- `app/chit_app.dart` is now `MaterialApp.router` and nothing else — a `ConsumerWidget` that
  watches `routerProvider` and holds nothing.
- `features/shell/presentation/shell_screen.dart` — the masthead, the tab bar, and `BranchFade`.
  The wordmark moved here out of `chit_app.dart`, which is where ARCHITECTURE.md §2 puts a
  widget only one screen uses.
- **Ten tests**, 132 → 142.

### The two packages carry as much as they can

Written down as a house rule in CLAUDE.md §4.2 and ARCHITECTURE.md §3, because the first pass
at this group did not follow it: the router was built in a `StatefulWidget`.

That was wrong by a rule already on the books rather than by taste. A `GoRouter` holds the
navigation stack of every branch, which makes it state, and ADR-001 says Riverpod is the only
state mechanism in the app — so a router in a widget puts the one thing that must survive a
rebuild in the one place that does not. It is `routerProvider` now, `keepAlive`, disposed with
the container, and `ChitApp` is a `ConsumerWidget` holding nothing. Every test passed unchanged
across the move, which is the seam being right rather than the change being small.

`ChitRoute` is now the single list of destinations and the tab bar is built from it, so a route
cannot be added without its tab — there is a test for that. Route names come from the enum
constants, so there is nothing to keep in sync.

**One exception stays, and it has a record.** ADR-011 puts the recording sheet in a modal sheet
rather than a route, because it belongs to the composer's state machine and dismissing it is not
a back navigation. Reversing that means a new ADR, not a quiet change in M5.

### Three things this group found

1. **`StatefulShellRoute.indexedStack` cannot do the one thing ADR-011 asked for.** An
   `IndexedStack` swaps branches instantly and there is nowhere in it to put §6.3's 220ms. The
   route is therefore a plain `StatefulShellRoute` with a `navigatorContainerBuilder` that
   stacks the branches and cross-fades them — state preserved, and a fade as well. Worth
   knowing because `.indexedStack` is the form every example uses.
2. **A branch is built lazily.** The calendar is not in the widget tree until the tab is first
   tapped, so "both branches stay alive" is true of *returning* to a tab and not of launching.
   The test says so rather than asserting at launch and quietly passing for the wrong reason.
3. **`find.bySemanticsLabel` does not read the semantics tree.** It matches each widget's own
   configuration, so it still finds text that an ancestor has excluded — the opposite of what a
   test of `ExcludeSemantics` needs. The shell test walks the real tree from its root instead.
   Anything later that checks what a screen reader can reach should do the same.

**Verified:** `flutter analyze` clean, `flutter test` 142 passing, `dart format` clean,
`flutter build apk --debug`.

---

## M2 group C — the chit vocabulary

Four shared widgets and one type style. No data, no provider, nothing on the screen yet: each
of these takes what it draws and nothing else, which is what lets groups E and G compose them
without either knowing about the other.

- `shared/widgets/slip.dart` — the surface, its hairline, the 2px cut edge, §6.3's one faint
  shadow, and the pad behind it. **It draws its own `PerforatedEdge`**, because a slip and the
  tear that made it are one object rather than two a caller has to remember to assemble.
- `shared/widgets/perforated_edge.dart` — a painter. §6.3's 1.55px-at-8px figures are constants
  here, exactly as that section said they would be, and **the 1.55 is a radius** — the CSS
  gradient stop it was read from measures from the centre.
- `shared/widgets/ambient_stamp_row.dart` — `.open` and `.saved`, two named constructors and no
  third. The pin belongs to `.open` and `.saved` cannot ask for one (§3.6). The weather word is
  an exhaustive switch in the presentation layer, so a sixth condition is a compile error
  rather than a blank on a chit.
- `shared/widgets/thread_rail.dart` — `ThreadRail` draws the line and **nothing else**;
  `ThreadNode` is the 7px mark with its halo of paper. Where a node falls depends on what the
  row says, which is group G's business and not the rail's.
- `emptyNote` in `ChitType` — 15px serif italic in `--ink-faint`, joined to `styles`,
  `copyWith` and `lerp`. The scale is back at twenty-five: v6 retired `legend` and this
  replaces the count.
- `test/support/pump.dart` — pumps a widget on paper in the real theme. It gives a **maximum**
  width rather than a size, so `tester.getSize` reports what the widget asked for.
- **Thirty-two tests**, 142 → 174.

### Three prototype numbers went back on the scale, and the list of dimensions did not grow

The stamp's 11px gaps are `s3`, the pad behind the slip is offset by `s1` rather than 5px across
and 6px down, and the perforation's inset from each end is `s2`. §6.3 permits exactly four
off-scale dimensions and every one of these had to fail that test to be allowed through —
none did. Group A's decision 1, applied three more times.

The rail is the interesting one, because it *looks* like a fifth dimension and is not.
`ThreadRail.centre` is `ThreadNode.markSize / 2`, so the rail runs down the middle of a mark
whose left edge is flush with the thread's. *The prototype puts the node 2px to the left of the
rail — a leftover from when it was offset by the page gutter rather than by the thread's own
inset. A node the rail does not come out of the middle of is a mark beside a line.* Derived
rather than declared means the two cannot drift apart; DESIGN-SYSTEM.md §6.3 carries the
departure.

### Two things this group found

1. **`RenderRepaintBoundary.toImage()` hangs in a widget test.** The first version of the
   perforated-edge test rendered the strip and read its pixels, which is the obvious way to
   prove *holes rather than a border* — and the future never completes, because the test
   binding runs no rasterizer. There is no error and no timeout from `flutter test`; the run
   simply never ends, which cost most of an hour to recognise. **Use `flutter_test`'s paint
   matchers instead**: `paints..circle(...)` for what is drawn and
   `paintsExactlyCountTimes(#drawLine, 0)` for what is not. The second half is the half that
   matters — a dotted border would pass every check that only looked for the holes.
2. **A `Container` with a decoration is a `DecoratedBox` in the tree**, so a test looking for
   "the node's decoration" found two and failed on *Bad state: Too many elements*. `ThreadNode`
   is written as an explicit `SizedBox` → `DecoratedBox` → `Center` → `DecoratedBox` now, and
   the test asserts the two layers **in order** — paper, then ink — which says more than either
   layer alone did.

**No ADR.** Nothing here could reasonably have gone another way at the level an ADR records:
the three snapped numbers are group A's decision applied, and the rail's centring is a
prototype leftover corrected. Where the code departs from v6, §6.3 says so.

**Verified:** `flutter analyze` clean, `flutter test` 174 passing, `dart format` clean. No APK —
nothing in this group is on a screen to look at.

---

## M2 group D — the ambient stamp, faked

ADR-007 in code, a milestone before the services behind it are real. The two interfaces, the
assembly, and two fixed-value implementations wired at the root — so M3 is a swap of two lines
in `main.dart` and nothing above them moves.

- `domain/services/weather_service.dart` and `location_service.dart` — the interfaces, each with
  its provider declared beside it and unimplemented, the way `chitRepositoryProvider` is. A
  `GeoFix` is a **record**, so half a fix cannot be built: that is `AmbientStamp`'s assert made
  unreachable rather than merely enforced.
- `domain/services/ambient_capture.dart` — `AmbientCapture.capture()`, which is the whole of
  ADR-007: both signals at once, each under a 2s timeout, whatever is missing left `null`.
- `data/weather/fixed_weather_service.dart` and `data/location/fixed_location_service.dart` —
  **M2 only, and M3 deletes both.** `raining`, and a fix at the Royal Observatory: a landmark
  rather than a plausible address, so nothing in M2's rows ever looks like a place a person was.
- **Eleven tests**, 174 → 185.

### ADR-025 — the weather service takes no position

The one thing here that could reasonably have gone another way, and the obvious shape is the
wrong one. Open-Meteo is a lookup by coordinates, so `conditionAt(lat, lon)` is what a reader
expects — and it would make weather wait on the location fix, which ADR-016 made the *precise*
one and therefore the slow one. ADR-007 promises the maximum of the two signals and that shape
delivers the sum. It would also couple their failures: refusing location would silently cost
the weather word as well.

So `currentCondition()` takes nothing, and M3's implementation uses the device's **last known**
fix — cached, instant. The cost is real and is written down rather than discovered in M3: the
condition can be for where you were rather than where you are. ARCHITECTURE.md §4.2 used to
claim the two ran in parallel without saying how that was possible; that gap is what the record
closes.

### Two things worth knowing

1. **The clock is read before either signal is asked for**, and the test counts the reads rather
   than checking the value. `capturedAt` becomes `createdAt` (ADR-021), so a clock read after a
   slow network came back would file the chit up to a whole timeout after the moment it belongs
   to — and the stamp would still *look* right, because it would hold a perfectly plausible
   time. Only a read count can see that. `FakeClock` gained a `reads` counter for it.
2. **A signal that throws and a signal that hangs are the same event.** This is the one place
   *fail loudly in development* is deliberately not applied, and ADR-007 is the reason: to a
   composer that must not stall there is no useful difference between no network, no permission
   and a service that fell over. Both paths are tested, with fakes that actually hang and
   actually throw rather than returning a quick `null` that pretends to — the Liskov rule of
   CLAUDE.md §4.1 applied to a fake.

**Verified:** `flutter analyze` clean, `flutter test` 185 passing, `dart format` clean,
`dart run build_runner build` clean. No APK — still nothing new on a screen.

---

## M2 group E — the open chit

The first thing in the app a person can touch. `ComposerState` and its `canSave`, the
controller, and the slip itself — stamp row, field, action row — placed on Today.

- `domain/models/composer_state.dart` — ARCHITECTURE.md §4.1's record, freezed. The audio and
  recording fields are here and unset: M5 fills them, and `canSave` is already defined in terms
  of one of them.
- `features/composer/application/composer_controller.dart` — the stamp held from open, text
  edits, `textOrigin: typed` the moment there are words and `null` again when there are not.
- `features/composer/presentation/open_chit.dart` — the slip, the field, the microphone, and
  the two controls.
- **Twenty-one tests**, 185 → 206.

### The controller is synchronous, and that is the whole of ADR-007

`build()` returns a `ComposerState`, never a `Future` of one. A `FutureOr<ComposerState>
build()` is the obvious shape — the stamp comes from two services, so of course it is async —
and it would hand the open chit a loading state, which is a spinner whether or not one is
drawn. ADR-007 does not allow that.

So `AmbientCapture` became **two methods rather than one**: `open()` is synchronous and gives
the chit its time at once, and `settle()` lands the weather and the fix whenever they arrive.
*Group D's `capture()` is gone; it was one commit old and had no other caller.* The clock is
still read exactly once, in `open()`, and `settle()` carries `capturedAt` through untouched.

A settled stamp can also come back to a chit that no longer exists — discarded, or saved — so
the controller checks `capturedAt` before taking it. That is a race the fakes never lose and a
real network will.

### ADR-026 — Discard opens a new chit, so it takes a new stamp

BEHAVIOUR.md §3.1 says Discard *"returns the open chit to its empty state"*, and the cheap
reading is to blank the text and keep the stamp. That files a chit discarded at 3:42 and
written at 4:10 under 3:42 — and at 23:58, under **the wrong day**, which is the exact failure
ADR-006 exists to prevent. `discard()` is `state = _openChit()`: the same path the controller
takes when it is first built, so there is one way for a chit to come into existence.

**Discard moved into this group from G**, because it needs no repository and a pressed wash is
only worth testing on a control that does something. **Save is drawn and does nothing until
G**, which is where the thread that would prove it worked gets built; `open_chit.dart` says so
where somebody would otherwise file a bug.

### Three smaller things

1. **The microphone carries no semantics at all** — not `ExcludeSemantics`, just nothing. A box
   and a painter have none of their own, so doing nothing is what leaves it unmarked, and
   §6.4's rule about controls that do nothing is satisfied the way the settings gear satisfied
   it. It is at `OpenChit.microphone`, which is where M5 attaches its behaviour.
2. **Discard and Save fade in without a rise.** The prototype reuses its `settle` keyframe here
   — opacity plus 8px — but §6.3's own table files *"Discard and Save arriving once the chit
   holds something"* under **routine state change**, not under authored arrival. An 8px rise
   would make a routine change look like one of the three moments in the app with any
   authorship.
3. **A bare `ProviderScope` no longer boots the app.** Today builds the open chit, which needs
   the two services `domain` leaves unimplemented, so the shell test stopped compiling the
   moment E landed — correctly. `test/support/app.dart` is now the one place a test states the
   other half of that seam, and every test that pumps `ChitApp` goes through it.

**One tripwire worth remembering:** a `GestureDetector` inside a scroll view does not call
`onTapDown` until the tap has won the arena against the vertical drag, so a test that presses
and then `pump()`s sees nothing at all. Pressing and pumping ~150ms is what makes Discard's
wash visible to a test.

**Verified:** `flutter analyze` clean, `flutter test` 206 passing, `dart format` clean,
`dart run build_runner build` clean.

---

## Next: M2 groups F and G

**F — the five-second prompt.** All timing, and separable: the timer lives in the controller
rather than the widget (ARCHITECTURE.md §4.3), 700ms, and it **survives reduced motion** at
140ms because it is the whole event rather than decoration. Not `hintText` — an overlay, which
is also where M5's failure note lands. The caret blink stops under reduced motion. The field
and the controller it needs are both in place.

**G — the thread, and Save end to end.** Where M2 becomes an app somebody could use: the date
line, `earlier` and its count, the thread off `watchDay`, the empty state, and Save wired to
`ChitRepository.save()`.

Two things G must get right, and both fail silently:

- **Pass `state.stamp` to `save()`** — the held one, never a fresh capture (ADR-021). Nothing
  in the repository's own tests can catch a re-capture, because a re-captured stamp is a
  perfectly plausible time.
- **Saving opens a new chit**, the way Discard does (ADR-026). The same `_openChit()`.

---

## Earlier: M2 — Today, text only

The first screen a person could use. Full statement of done in
[BUILD-PLAN.md](BUILD-PLAN.md) M2; what it looks like is BEHAVIOUR.md §4.1, and
`design/chit-app-v6.html` is the target. The spine it draws from is all in place.

**[TASKS.md](TASKS.md) is the working list** — M2 in ten groups, A to J, each one buildable and
committable on its own. A to E are done; F and G are next, and the section above says what they are.

Worth knowing for the rest of the milestone:
- **The composer holds the stamp from the moment it opens** (ADR-021). Weather and location are
  fakes returning fixed values until M3, but the *time* is real and comes from `clockProvider`.
- **`ChitRepository` is already what M2 needs**: `watchDay(int localDay)` for the thread and the
  arc — one stream, so they cannot disagree — and `save()` taking the stamp, the text and the
  origin. Today's `localDay` is `Chit.localDayOf(clock.now())`.
- **The microphone is drawn in M2 and inert until M5.** BEHAVIOUR.md §3.2 makes it an equal and
  the design log warns exactly how it stops being one.
- Open item 1 — the type on a handset — is worth settling here, when there is real text to
  compare against the prototype.
- Open item 2 — the two colours with no token — M2 hits the filled Save button's label.

---

## Open items

Things a future session needs to know but that are not yet scheduled work.

1. **Nobody has looked at the type on a handset.** The masthead renders, but the optical-size
   mapping is a judgement call that has never been checked against the prototype side by side:
   `ChitType._opticalSizeFor` converts logical pixels to points at 0.75, which is what the CSS
   spec says a browser does with `font-optical-sizing: auto`. If Newsreader looks heavier or
   lighter than `design/chit-app-v6.html` at the same size, that constant is the first suspect.
   Worth settling in M2, when there is real text to compare — and note that v6 narrowed the
   optical range it has to cover, from 38px/16.5px to 26px/16.5px, so the constant matters a
   little less than it did.
2. ~~**DESIGN-SYSTEM.md §6.1 has no token for two colours the design uses.**~~ **Closed
   15 September 2026 by v6**, which removed both rather than naming either. `#FFF6EE` was a
   numeral lifted to survive a strong `--seal` calendar fill, and `#1A1310` was the label on a
   solid `--seal` Save button. ADR-022 replaced both fills with ink washes that `--ink` reads
   cleanly on (5.99:1 at the densest tile, 10.85:1 on Save), so neither colour exists any more.
3. ~~**`sqlite3_flutter_libs` resolves to `0.6.0+eol`.**~~ **Closed 15 September 2026.** It is
   the latest release and the package is now empty — `package:sqlite3` 3.x ships the native
   library itself and our tree resolves it at 3.5.2. Nothing to do; the shim falls away when
   `drift_flutter` drops it. PACKAGES.md has the detail.
4. **`speech_to_text` applies the Kotlin Gradle Plugin,** and the build warns that future
   Flutter versions will fail on plugins that do. Harmless on 3.47.4. Check before any Flutter
   upgrade, since ADR-005 makes that package hard to swap.
5. **Developer Mode on Windows.** `flutter pub get` warns that plugin builds need symlink
   support. Not currently blocking — the APK builds. If a build fails in a way
   `kotlin.incremental=false` does not explain, check this: `start ms-settings:developers`.
6. **Font bundle is ~1.8 MB,** of which Noto Serif Devanagari is 758 KB to draw one word.
   PACKAGES.md suggests subsetting before shipping; this is the file that makes it worth doing.
7. **`public_member_api_docs` is on.** It is valuable in `domain`, `data` and `core`, and it
   is noise on a zero-argument widget constructor. If M2 finds it a real tax, the answer is a
   nested `analysis_options.yaml` under `lib/features/` rather than turning it off everywhere
   — and either way it is a change that gets recorded.
8. **OPEN-QUESTIONS.md §8.2 (re-transcription) and §8.3 (does Today carry enough rhythm) are still open.**
   Neither blocks anything before M7.
9. **Nothing deletes a chit yet, so the orphan sweep has little to collect.** `ChitRepository`
   has no `delete`, because no screen offers one and BEHAVIOUR.md does not describe one —
   ADR-014 mentions deleting a chit as the way to remove a recording, which is the closest the
   specification comes. The sweep still earns its place: a save that moves the file and then
   fails to write the row leaves exactly the orphan it collects. When a delete arrives it goes
   in the repository, deletes the row and the file together, and gets its own test.
10. **The debug seeder of DATA-MODEL.md §7 does not exist.** It becomes worth writing the moment
    the calendar has something to shade — M4, or M2 if the archive feels empty while building
    it. A seeded day must cover all four shapes of §2, especially the recording with `NULL`
    text.

11. ~~**Re-point `lib/core/theme/` at v6.**~~ **Closed 15 September 2026**, in the session after
    the one that opened it. The four extensions, their tests and `lib/`'s vocabulary all
    describe v6 now, and the four ⚠ banners that pointed here are gone with it. What moved is
    listed under *"And then the code, the same day"* above. Two things the checklist got wrong,
    recorded because the next checklist will make the same kind of mistake: the tightened gaps
    of §6.3 are not tokens at all — they are which step a widget takes, and they land in M2 and
    M4 — and `sealWash` was not renamed but replaced, because v6 leaves no accent wash anywhere
    in the app.

12. ### ⬜ **Today's ring fails its contrast floor on a busy day.** Wants a design answer.

    New with ADR-022. Today is ringed in `--seal` on the calendar; the tile under it is an ink
    wash whose strength depends on how much was written that day. As a non-text UI component
    the ring needs 3:1, and it gets:

    | Tile | Ratio | |
    |---|---|---|
    | empty | 4.56:1 | passes |
    | one chit | 3.97:1 | passes |
    | two | 3.36:1 | passes |
    | three | **2.61:1** | fails |
    | four or more | **1.88:1** | fails |

    A day with three chits is an ordinary day in an app whose premise is several a day, so this
    is not a corner case — on a busy today the one mark a person is looking for is the hardest
    to see. Do not fix it by nudging a token: the ring and the fill are the same lightness
    family by design now. It probably wants a different *shape* for today — a ring drawn
    outside the tile, a gap between ring and fill, or a mark rather than a border. It is M4's
    problem and M4 should not invent the answer under time pressure; DESIGN-SYSTEM.md §6.4
    carries it too.

    The figures above are asserted in `test/core/theme/contrast_test.dart` — including the two
    that fail. **Fixing this breaks that test**, which is deliberate: whoever fixes it is told
    to come back and rewrite the record rather than leaving a stale one behind.

13. ~~**`--hair-soft` has collapsed on a chit.**~~ **Closed 15 September 2026** by M2's decision
    A4. The token was not nudged: `--hair-soft` divides on the ground, where it always did and
    still measures 1.13:1, and the one place that put it on a chit — Discard's pressed
    background — takes `ChitColors.discardPressedWash` (6% ink, 1.17:1) instead.

    It turned up a second thing on the way, which is the part worth keeping. **Discard's label
    is `--ink-faint`, and `--ink-faint` fails on any wash at all** — 4.12:1 at 4%, and the wash
    is 6%. So the label lifts to `--ink` while the control is held. A pressed state is a surface
    that text sits on, and §6.4 makes no exception for surfaces that are brief. The prototype
    already brightens the label on hover for exactly this reason; nobody had noticed that the
    hover rule was solving a contrast problem rather than a decoration one.

    *The original entry, for the record:*

    v6 brightened `--slip` by four points and `--hair-soft` is `#252220`, so the pair now
    measures **1.0145:1** — it measured 1.0498:1 in v5, which was already marginal. On a chit
    surface the token is, in practice, not drawn.

    It is used on a chit in exactly one place: the pressed background of **Discard**. That
    matters more than the count suggests, because press also carries a 0.985 depress — and
    under `prefers-reduced-motion` the depress is gone (DESIGN-SYSTEM.md §6.4), so this invisible
    wash becomes the *only* feedback that pressing Discard produces. A control that
    acknowledges nothing reads as broken.

    Three ways out, none of them chosen: lift `--hair-soft` a few points (it still has to stay
    quiet as a divider on `--paper`, where it measures 1.13:1 and is fine); give Discard a
    pressed state in `ChitColors.inkWash` like the other two controls already have; or accept
    it and make sure §6.4's reduced-motion pass in M7 gives press feedback that does not depend
    on this token. **M2 draws Discard**, so M2 is where it stops being hypothetical.

    Found by the hairline "collapse detector" in `contrast_test.dart` failing the first time the
    token moved — a floor written in M0b against a token being *tuned* into invisibility, which
    instead caught a different token moving underneath it.
