# Progress

**Where the build is, and what to do next.** This is the handover document: a session that
has read only this file and `CLAUDE.md` should be able to pick up the work.

Updated at the end of every working session, per the standing rule in
[CLAUDE.md](../CLAUDE.md) §0 — including sessions that ended mid-milestone.

**Last updated:** 15 September 2026, after M1 — the data spine — and after the v6 design pass,
which changed documents only.

---

## Status board

| Milestone | State | Notes |
|---|---|---|
| **M0a** — project stops being a scaffold | ✅ done | 14 Sep 2026 |
| **M0b** — the design system in code | ✅ done | 14 Sep 2026 |
| **M1** — the data spine | ✅ done | 15 Sep 2026. ADR-021 |
| M2 — Today, text only | ⬜ next | |
| M3 — ambient capture | ⬜ | |
| M4 — calendar | ⬜ | |
| M5 — voice | ⬜ | |
| M6 — the chit editor | ⬜ | OPEN-QUESTIONS.md §8.1 settled 14 Sep 2026 (ADR-017) |
| M7 — motion and the floors | ⬜ | |

**120 tests, `flutter analyze` clean, debug APK builds.**

The app on a handset is still the masthead on `--paper` and nothing else — M1 added no UI, which
is what it said it would do. That screen was confirmed on a device on 15 September: dark warm
brown, "chit चित्त" in the gutter, which is `--paper` `#191714` behaving exactly as §6.1 sets it.

---

## ⚠ Read this before touching the theme

**The prototype moved to v6 and the code did not.**

`design/chit-app-v6.html` replaced v5 as the visual target on 15 September 2026. Every document
in this repository now describes v6. **`lib/core/theme/` still holds v5's values**, because the
v6 pass was deliberately documentation-only.

So, right now:

| | |
|---|---|
| The documents | describe **v6**. They are the target and they are right |
| `lib/core/theme/`, and `test/core/theme/` | describe **v5**. They are the past and they are wrong |

**Do not "correct" a document to match a constant in the code.** The gap is intentional,
temporary, and listed constant by constant in **open item 11** below. Close it before or with
M2 — M2 is the first milestone that draws anything, and a screen built on v5 tokens is a
correction pass over finished code rather than a value changed once.

Nothing is broken in the meantime: `flutter test` passes, because the tests assert the code's
v5 values and the code still holds them. **That is exactly why this note exists** — the build
will not tell you.

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
  - `ChitColors` — the ten tokens of DESIGN-SYSTEM.md §6.1, plus `sealWash` for flattening the audio
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

---

## Next: M2 — Today, text only

The first screen a person could use. Full statement of done in
[BUILD-PLAN.md](BUILD-PLAN.md) M2; what it looks like is BEHAVIOUR.md §4.1, and
`design/chit-app-v6.html` is the target. The spine it draws from is all in place.

Worth knowing before starting:

- **Do open item 11 first.** M2 is the first milestone that draws anything, and every token it
  reaches for should be the v6 one before a widget uses it.
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

11. ### ⬜ **Re-point `lib/core/theme/` at v6. Scheduled: before or with M2.**

    **This is the open item.** The documents describe v6; the theme extensions were written
    against v5 in M0b and still hold v5's values. Nothing fails today — the tests assert the
    code's own v5 numbers — so nothing will remind you. This list is the reminder.

    **`chit_colors.dart`**
    - `slip` `0xFF211E1A` → **`0xFF24211C`**.
    - Add the ink washes of DESIGN-SYSTEM.md §6.1 as named members, the way `sealWash` already
      exists: the pill at 3.5%, Save at 7% and 13%, the microphone hover at 5%, and the four
      calendar steps at 6 / 12 / 20 / 30%. They are `--ink` at an alpha over a stated ground,
      and §6.4 requires each composite to be checked rather than assumed.
    - `sealWash` was the 7% *accent* wash behind the pill. v6's pill is an ink wash, so that
      member is either renamed or joined by an ink one — do not leave a member called
      `sealWash` describing a surface that has no seal in it.
    - Its doc comment quotes `4.23:1`. The figure is **4.09:1** on the new slip.

    **`chit_type.dart`**
    - `date` 38px → **26px**, and the weekday is no longer a separate stacked style — one line,
      the weekday italic in `--ink-faint` and the date in `--ink`.
    - The composer field 19px → **17.5px**, line-height 1.6 → 1.62.
    - The `--ink-faint` italic failure note 17px → **16.5px**.
    - Every 16px style → **16.5px**: section labels, day headings, tab labels, calendar
      numerals, the wordmark (16 → 16.5).
    - **The ambient stamp is no longer uppercase.** Drop the `.1em` tracking and the
      `TextTransform`; it is 11.5px, weight 500, `.02em`, sentence case — the same style the
      chit meta line uses, differing only in colour.
    - Its doc comment quotes a 2.3× display-to-body ratio. It is **1.6×** now.
    - `legend` is a style for an element v6 deleted. Remove it, and the `copyWith` / `lerp` /
      props entries that go with it.

    **`chit_space.dart`**
    - `sheetRadius` 14px → **8px**; add the calendar tile's **4px** and its 5px grid gap.
    - The four tightened gaps of §6.3 (arc, composer, `earlier` heading, month summary).
    - Its doc comment cites `chit-app-v5.html`. It is v6.

    **`test/core/theme/contrast_test.dart`**
    - Every asserted ratio against `slip` moves: `--ink-muted` 6.02 → **5.82**, `--ink-faint`
      4.72 → **4.56**, `--seal` 4.23 → **4.09**, `--seal-ink` 4.98 → **4.81**. `--ink` on slip
      is 13.03.
    - The pill composite is 3.5% **ink**, not 7% seal: `--ink-faint` **4.17:1** (still fails,
      still the reason the duration is `--ink-muted` at 5.33:1).
    - Add the new washes: Save's label at 10.85:1, and the four calendar numerals at 12.66 /
      10.69 / 8.31 / **5.99**.
    - The comment at the head of the negative cases explains the near-white numeral. That case
      is gone with `#FFF6EE`.

    **`chit_type_test.dart`** asserts that nothing functional is under 11.5px — unchanged — but
    it may also pin sizes that moved. **`chit_app.dart`**'s masthead uses `type.wordmark`, which
    goes 16 → 16.5.

    **When it is done:** `flutter analyze` clean, `flutter test` green with the *new* figures,
    and the masthead checked on a handset against v6 — which also settles open item 1. Then
    delete the ⚠ banner at the head of this file, the note in README §10.4, the one in
    CLAUDE.md §2 and the one at the head of DESIGN-SYSTEM.md, because all four exist only to
    describe this gap.

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
