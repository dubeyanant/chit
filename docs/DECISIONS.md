# Architecture decisions

One record per decision that would be expensive to reverse. Each says what was chosen, what
it was chosen over, and what it costs. Superseding a record means adding a new one, not
editing the old one.

Status of every record below: **accepted**, except ADR-021 which is **superseded** and says so
at its head — ADR-001 to ADR-020 on 14 September 2026, ADR-021 to ADR-024 on 15 September 2026,
ADR-025 to ADR-042 on 16 September 2026 and ADR-043 to ADR-046 on 17 September. Forty-three records, not
forty-four: **ADR-018, ADR-026
and ADR-030 have been merged away**, their numbers retired rather than reused, and the note
below says where each one went.

The records are in the order they were written, not in numerical order — ADR-013 and ADR-014
revise ADR-005 and sit beside it. The index is numerical.

| | | |
|---|---|---|
| ADR-001 | Riverpod, with code generation | the only state mechanism |
| ADR-002 | Three layers, and the dependency rule | `features` never imports `data` |
| ADR-003 | Drift over a document store | nearly every screen is an aggregate query |
| ADR-004 | Local-only for v1, with the seams for sync | no backend, no account, client-generated ids |
| ADR-005 | Speech-to-text runs on the device | nothing leaves the phone; §3.5 is what failure looks like |
| ADR-006 | A denormalised local day on every chit | what "today" means, decided once at write time |
| ADR-007 | Ambient capture is best-effort and never blocks | a signal that does not arrive is null, and is not drawn |
| ADR-008 | Audio on the filesystem, path in the row | relative paths, always |
| ADR-009 | Fonts bundled, not fetched | the app opens instantly and works offline |
| ADR-010 | Design tokens as a `ThemeExtension`, not constants | why §6 is four classes. Refined by ADR-020 |
| ADR-011 | `go_router` with a persistent tab shell | returning to a tab costs a fade, not a rebuild |
| ADR-012 | An injected clock | three behaviours are functions of the current time |
| ADR-013 | A chit is text, audio, or both | the one-of invariant of §5 |
| ADR-014 | Saved chits are editable; their audio is not | editing changes what the chit says, never what was said |
| ADR-015 | Variable fonts, and weight through `fontVariations` | and the silent failure that comes with them |
| ADR-016 | Precise location first, coarse as the fallback | and the privacy tension it creates, stated plainly |
| ADR-017 | The chit editor is a screen, and leaving it asks | settles §8.1 |
| ADR-019 | Android and iOS only; the web folder stays | |
| ADR-020 | Reducing motion never makes a fade slower | refines ADR-010 |
| ADR-021 | A chit is stamped when it is opened, not when it is saved | **superseded by ADR-040** — it is stamped when it is saved |
| ADR-022 | The seal means now; a record is ink | refines ADR-010. v6 |
| ADR-023 | The field is live, but it does not take focus | what opening the app costs |
| ADR-024 | The day arc becomes the timeline | three days, full days, scrollable, proportional |
| ADR-025 | The weather service takes no position | clarifies ADR-007 against ADR-016 — how the two signals stay parallel |
| ADR-027 | An ambient loop is not a pace | refines ADR-010 and ADR-020 — where a looping period lives |
| ADR-028 | The caret is the platform's, and chit draws none | reverses group F's drawn caret; corrects ADR-027 |
| ADR-029 | The prompt reads the stamp | extends §3.3 — which words, and what they may not do |
| ADR-031 | No widget tests | the suite came out; a device and a guard test replace it. Absorbs ADR-030 |
| ADR-032 | One day is one screen, and now rests in the middle of it | settles what ADR-024 left to the screen |
| ADR-033 | Today re-reads the clock at midnight | one invalidation rolls the date, the thread and the strip together |
| ADR-034 | A day passing is a haptic | the boundaries are unlabelled by design; this is how they are noticed |
| ADR-035 | Days with nothing in them are not drawn | narrows ADR-024 — the query stays three days, the strip may be one |
| ADR-036 | Now is a tick, not a dot | reverses v6's outline, and the disc that replaced it. No pulse |
| ADR-037 | Motion is read off the position fix, not off a motion sensor | an accelerometer cannot measure speed; a fix already carries it |
| ADR-038 | The stamp carries one ambient fact, ranked | weather and motion share one slot; stationary is never drawn |
| ADR-039 | Motion is an icon where weather is a word | and it is drawn in the thread, where the pin is not |
| ADR-040 | A chit is stamped when it is saved | reverses ADR-021; absorbs ADR-026, whose number is retired |
| ADR-041 | Permission is asked once, on first run, behind a screen of our own | not a bare dialog over a blank page |
| ADR-042 | Ambience is captured at launch and at save, and never in between | no poll, no TTL; the row is written first and patched after. **Amended by ADR-045** |
| ADR-043 | The weather mapping: a wind threshold, a trusted flag, and one word missing | windy at 25 km/h; m/s throughout; `is_day` trusted; snow has no word |
| ADR-044 | The capture budget is twelve seconds, and a stale place beats no place | revises ADR-007 — nothing waits on a capture since ADR-042, and the pin was the cost |
| ADR-045 | A reading stays good for five minutes | amends ADR-042 — a burst of chits costs one capture, not one each |
| ADR-046 | Today's ring sits on paper, not on the tile | closes item 12 — a shape answer, not a token nudge |

`test/docs/readme_maps_everything_test.dart` fails if a record exists without a row above, or a
row without a record.

### The numbers that are not in the table

**Three records have been merged away, and the numbering was left alone.** A citation is only
worth having if it resolves, and roughly two hundred of them point into this file — so ADR-018,
ADR-026 and ADR-030 are not reused, and this is where each one went:

- **ADR-018** — *`riverpod_lint` through `plugins:`, and no `custom_lint`* → **PACKAGES.md**,
  under *Considered and not taken*. It was a fact about how two packages resolve, not a decision
  about how the app is built, and it had a stale line deferring the `DateTime.now()` question to
  M0b — which M0b answered. All of it is in PACKAGES.md now, answer included.
- **ADR-026** — *Discard opens a new chit, and that means a new stamp* → **ADR-040**, on
  16 September 2026. Its entire argument was that a held stamp goes stale and files a chit on
  the wrong day; ADR-040 stamps at save, so there is no interval for a stamp to go stale in and
  the failure it guarded against cannot occur. Discard still opens a new chit — that behaviour
  is stated in ADR-040 and in BEHAVIOUR.md §3.1 — but it is now honesty about a preview rather
  than a correctness fix, and a record whose whole argument has been absorbed has stopped
  earning its place (CLAUDE.md §0.1).
- **ADR-030** — *A screen test gets a hand-written repository* → **ADR-031**, which superseded it
  a few hours after it was accepted. There are no screen tests any more, so the question it
  answered cannot arise; the finding underneath it — real I/O never completes inside a
  `testWidgets` body — is stated inside ADR-031, because it is a property of `flutter_test` that
  will catch somebody again.

**One record is superseded but still here.** ADR-021 — *a chit is stamped when it is opened* —
was reversed by ADR-040 rather than absorbed by it. It was a real decision that was really
tried, and a reversal is only legible beside the thing it reversed, so it keeps its number, its
place and a header saying what happened to it.
---

## ADR-001 — Riverpod, with code generation

**Decision.** Riverpod is the only state mechanism in the app. Every provider is declared with
the `@riverpod` annotation and generated by `riverpod_generator`; `riverpod_lint` and
`custom_lint` run in analysis.

**Over.** Manual `NotifierProvider` declarations; Bloc; `ChangeNotifier` + `provider`.

**Why.** chit's screens are almost entirely derived state — the thread, the day arc, the
calendar heat and the month total are four readings of one table, and DESIGN-SYSTEM.md §7 requires
that they never disagree. Riverpod's dependency graph gives that for free: they all watch the
same database stream and recompute together. Codegen removes the class of bug where a provider
is declared with the wrong type or the wrong family key, which is the main cost of manual
Riverpod.

**Costs.** A `dart run build_runner watch` in the loop, and generated `*.g.dart` files in the
tree. Both are accepted.

**Consequences.** Widgets never read a DAO or a repository directly — see ADR-002 for the
layer rule. State that outlives a screen (database, repositories, services) is `keepAlive`;
screen state is not.

---

## ADR-002 — Three layers, and the dependency rule

**Decision.** `domain` (models, repository interfaces, service interfaces) ← `data`
(Drift, files, network) and `features` (controllers, widgets). `domain` imports nothing from
the other two. Nothing in `features` imports from `data`.

**Over.** A flat `lib/models` + `lib/screens`, which is the usual shape for an app this size.

**Why.** Two things in the plan need a seam. The app is local-only now but will not stay that
way (ADR-004), and the speech recognizer has to be replaceable by a fake — BEHAVIOUR.md §3.5 is a
behaviour that only exists when recognition produces nothing, and there is no other way to
reach it in a test. Both live behind an interface in `domain`, and neither touches a widget.
That is worth one extra folder.

**Costs.** More files per feature than a flat layout. Some interfaces will have exactly one
implementation for a long time.

---

## ADR-003 — Drift, i.e. relational storage, over a document store

**Decision.** Drift (`drift` + `drift_flutter`) as the local database. Chits live in one
table; audio lives on the filesystem with only its path in the row (ADR-008).

**Over.** Isar or Hive; raw `sqflite` over the same SQLite; files-on-disk with a JSON index.
Drift is a typed layer over SQLite, so the choice is SQLite either way — what is being decided
is relational-with-codegen against a document store, and against hand-written SQL.

**Why.** Nearly every screen in BEHAVIOUR.md §4 is an aggregate query. The calendar tile's warmth is
a count per day (§4.2); the month summary is a count plus a distinct-day count; the archive is
a grouped, ordered scan; and backlog item 2 — *"show me everything I wrote when it was
raining"* — is a `WHERE weather = ?`. SQL does all of that in the database rather than by
pulling every chit into Dart. Drift adds type-safe queries, reactive streams that make ADR-001
work, and a real migration story for a schema that will change.

**Costs.** Codegen (already accepted), and a slightly heavier setup than a key-value store.

---

## ADR-004 — Local-only for v1, with the seams for sync

**Decision.** No backend, no account, no network dependency for anything on the critical path.
Weather is the only outbound call and it is optional (ADR-007). Repositories return domain
models and hide their source, so a sync layer can be added behind them.

**Over.** Firebase or Supabase from the start.

**Why.** A private journal is fully useful with no server, and the app should open and accept
writing on a train with no signal. Auth, hosting and a privacy posture are real work that buys
nothing for the behaviour described in BEHAVIOUR.md.

**Costs.** No multi-device, no backup beyond the OS's own. Both are acknowledged and deferred.

**What this obliges us to keep true.** Every row carries a client-generated UUID rather than an
autoincrement integer, and `createdAt` / `updatedAt` are set explicitly. Retrofitting stable
ids onto a synced table is the expensive version of this decision.

---

## ADR-005 — Speech-to-text runs on the device

*Revised 14 September 2026. The first version of this record shipped on-device as a stepping
stone to Google Cloud. On-device is now the decision, not the interim.*

**Decision.** Recognition runs on the handset, with nothing leaving the device — the same
on-device dictation a phone keyboard uses. The `speech_to_text` package with
`SpeechListenOptions(onDevice: true)`, which maps to Android's on-device `SpeechRecognizer` and
iOS's `SFSpeechRecognizer` with `requiresOnDeviceRecognition`. If the platform cannot honour
that, the listen attempt fails rather than silently going to a server, which is the behaviour
we want.

`domain/services/speech_recognizer.dart` still defines the contract and `data/speech/` still
holds the implementation — not because an engine swap is planned, but because a fake recognizer
is the only way to test §3.5, and because the platform's own availability rules are ugly enough
to be worth confining to one file.

**Over.** Google Cloud Speech-to-Text, which BEHAVIOUR.md §3.4 originally named.

**Why.** Cloud recognition means every recorded thought leaves the device, in an app whose
entire premise is a private journal. It also means a credential in the binary or a server to
hold it, which ADR-004 just deferred. And the accuracy argument that justified it has weakened:
now that the transcript is editable (ADR-013), a worse engine costs a few seconds of correction
rather than a permanent error in the record.

**Costs, stated plainly.** On-device models are less accurate, they vary by handset, and for
some devices or languages there will be no model at all. Offline recognition of English-Hindi
code-switching in particular should be expected to be poor.

**Consequences.** No model available is **not** a distinct error state. The recognizer reports
its availability, and unavailable resolves to the §3.5 path — the audio is kept, the field is
empty and editable, the note explains. One code path, whether the engine was missing, refused,
or simply heard nothing.

Reopening this is a privacy decision, not a technical one: it needs an answer to what happens
to the audio, not a benchmark.

---

## ADR-013 — A chit is text, audio, or both

*Supersedes the exclusive model in the first version of ADR-003's schema notes.*

**Decision.** `text` and `audioPath` are independently nullable with **at least one** present.
A recording's transcript lands in an editable field; the audio is kept regardless of what
happens to the words. A `textOrigin` column records `typed | transcript | transcriptEdited`.

**Over.** `source: typed | spoken` with the two mutually exclusive, and the transcript locked.

**Why.** The design log has the full argument. In short: the lock protected the record from the
user, and the user was not the threat — the engine was. Speech recognition mishears names and
comes apart on code-switching, and a transcript that cannot be corrected is a record that is
quietly wrong. Moving the guarantee to the *audio* — never editable, never removable, always
playable — protects the moment without holding the words hostage.

**Costs.** Four legal row shapes instead of two, an invariant the database can only partly
express, and a provenance column nothing currently reads.

**Consequences.**
- `source` is gone. Whether a chit has audio is `audioPath != null`; nothing infers behaviour
  from a mode.
- The §3.5 rule narrows to what it always should have been: it governs what the *machine*
  writes, not what the user may. Nothing partial is auto-filled; the field is still theirs.
- `textOrigin` is provenance only. Nothing in the UI renders differently because of it. It
  exists so a future re-transcription (OPEN-QUESTIONS.md §8.2) can refuse to overwrite the user's words.

---

## ADR-014 — Saved chits are editable; their audio is not

**Decision.** `ChitRepository` gains an update path for `text` (and `textOrigin`, which becomes
`transcriptEdited` when a transcript is changed). It gains no path that changes or removes
`audioPath` on an existing chit.

**Over.** Leaving OPEN-QUESTIONS.md §8.1 open, which is what the first version of these docs assumed.

**Why.** Once the transcript is editable before Save (ADR-013), there is no principled reason
the text stops being the user's the moment it is saved. A typo found the next morning is the
same typo.

The asymmetry is the point. Text is what the chit *says* and belongs to the user; audio is what
*was said* and belongs to the moment. A chit that is only a recording can gain text; a chit
with a recording cannot lose it. Deleting the whole chit remains the way to remove a recording.

**Still open** (OPEN-QUESTIONS.md §8.1): whether the editor is inline in the thread or a screen of its own.
Until that is designed, nothing in the thread carries an affordance — an affordance that leads
nowhere is worse than a missing one, and the design log is emphatic about it. The repository
method can exist ahead of the UI; a dead tap target cannot.

**Consequences.** `updatedAt` stops being a column written once and forgotten. The repository
tests must cover an edited chit — *this line said "goldens and tests for the thread" until
ADR-031, which leaves no way to test a thread at all; what an edit does to the rendered row is
a device check now* — and the archive's ordering stays on `createdAt`, because editing a chit
does not move it: it belongs to the moment it was written.

---

## ADR-006 — A denormalised local day on every chit

**Decision.** Each row stores `createdAt` as UTC milliseconds *and* `localDay` as an integer
`yyyymmdd` computed in the device's timezone at write time. Grouping and calendar queries use
`localDay`. Nothing groups by deriving a date from `createdAt` at read time.

**Over.** Grouping on `date(createdAt, 'localtime')` in SQL, or in Dart after the read.

**Why.** "Today" and "a day in the archive" are local-calendar facts, and a chit written at
00:20 IST belongs to that morning forever. Deriving the day at read time means the answer
changes when the device moves timezone, and it means no index can be used for the grouped
queries the calendar runs on every open.

**Costs.** One redundant column, and the pair must be written together in one place — the
repository, never a DAO caller.

---

## ADR-007 — Ambient capture is best-effort and never blocks

**Decision.** Time, weather and location are gathered when the open chit is created, in
parallel, each under a short timeout. Any signal that does not arrive is null, and a null
signal is simply not drawn. Nothing about capture can delay the composer, show a spinner, or
fail a save.

**Weather source:** Open-Meteo — no API key, no account, current-conditions endpoint. Its WMO
code plus the `is_day` flag and wind speed map to BEHAVIOUR.md §3.6's vocabulary (`raining`, `clear`,
`overcast`, `windy`, `clear night`) through one pure function that is unit-tested. Wind is a
threshold on speed, not a code, so the mapping is ours and belongs in the domain layer.

**Location:** `geolocator` at low accuracy. BEHAVIOUR.md §4.1 shows a pin and never a place name, so
coarse is not a compromise — it is all the precision the product can display.

**Why.** README §1: *opening the app costs nothing — the page is blank and ready.* A composer
that waits on a network call has broken that, and a journal must work offline.

**Costs.** Some chits will carry no weather. That is correct behaviour, not a gap to fill with
a placeholder.

---

## ADR-008 — Audio on the filesystem, path in the row

**Decision.** Recordings are written to `<app documents>/audio/<chit-id>.m4a`. The database
stores the relative path only. Recording writes to a temporary file; the file is moved into
place on **Save chit** and deleted on **Discard**.

**Over.** Storing audio as a BLOB in SQLite.

**Why.** Multi-megabyte blobs bloat the database file, slow every backup and every migration,
and buy nothing — the row never needs the bytes, only `just_audio` does. Storing a *relative*
path matters on iOS, where the app container path changes between installs and an absolute
path saved today is dead after the next update.

**Consequences.** Deleting a chit deletes its file, and a startup sweep reconciles orphans in
both directions: files with no row, and rows whose file has vanished. A row whose audio is
missing still renders — it is a chit, not an error.

---

## ADR-009 — Fonts bundled, not fetched

**Decision.** Newsreader, Hanken Grotesk and Noto Serif Devanagari ship as asset files declared
in `pubspec.yaml`, in the weights actually used and no others.

**Over.** The `google_fonts` package, which downloads at first run and caches.

**Why.** ADR-004 makes offline a requirement, and the first paint of a journal should not
depend on a network round trip or fall back to a system serif. The design log treats
typography as load-bearing; a fallback face is a visibly different app.

**Costs.** A few hundred kilobytes in the bundle, and subsetting is on us.

---

## ADR-010 — Design tokens as a ThemeExtension, not constants

**Decision.** DESIGN-SYSTEM.md §6 becomes typed `ThemeExtension`s — `ChitColors`, `ChitType`,
`ChitSpace`, `ChitMotion` — read through `Theme.of(context)`. Raw hex values and raw
`Duration`s do not appear in widget code.

**Over.** A `lib/constants.dart` of top-level `const` values.

**Why.** The accent has two weights with a rule about which to use (`--seal` for marks,
`--seal-ink` for text), motion has a reduced-motion behaviour that differs per *kind* of
animation, and both rules are enforceable only if there is one place that knows them.
`ChitMotion` exposes `travel(...)` and `fade(...)` (refined by ADR-020, which stops the
re-timing from ever making a fade slower than it was): under `MediaQuery.disableAnimations`,
travel collapses to zero and fade re-times to the design log's 140ms on transitions and 220ms
on arrivals. That is exactly the rule the log argues for, and not the one a global
duration-to-zero would give.

**Costs.** More ceremony than a constants file for the first few widgets.

---

## ADR-011 — go_router with a persistent tab shell

**Decision.** `go_router` with a `StatefulShellRoute` holding the two tabs, so each tab keeps
its own navigation stack and scroll position.

**Over.** A plain `IndexedStack` with a `Navigator` per tab; Navigator 1.0.

**Why.** DESIGN-SYSTEM.md §6.3 is explicit that returning to a tab must cost a 200ms fade and nothing
more — *Today is opened many times a day, and a re-run entrance would turn that into waiting.*
A shell route with kept state gives that; rebuilding the tab on switch does not. The recording
sheet stays a modal sheet rather than a route, because it belongs to the composer's state
machine and dismissing it is not a back navigation.

**Costs.** Overkill for two tabs today. It stops being overkill at the first detail screen,
which §8.1 will probably add.

---

## ADR-012 — An injected clock

**Decision.** Nothing calls `DateTime.now()`. A `Clock` from `domain` is provided by Riverpod
and overridden in tests.

**Why.** Three behaviours in the specification are functions of the current time and all of them are
untestable otherwise: what counts as today (§4.1), where a mark falls on the 5am-to-midnight
arc (§4.1), and the five-second prompt (§3.3). A fake clock also makes the midnight rollover a
thing we can test rather than a thing we discover.

**Costs.** One indirection, everywhere.

---

## ADR-015 — Variable fonts, and weight through `fontVariations`

**Decision.** The three faces of DESIGN-SYSTEM.md §6.2 ship as **variable** fonts — one file per family
(two for Newsreader, which has a separate italic) — and every `TextStyle` in `chit_type.dart`
sets `fontVariations` alongside `fontWeight`.

**Over.** Static instances at the handful of weights PACKAGES.md originally listed
("regular, italic, medium" for Newsreader; "regular, medium" for Hanken Grotesk).

**Why.** That list was wrong, and reading the prototype is what showed it. `chit-app-v5.html`
loads `Newsreader:ital,opsz,wght@0,6..72,300..600;1,6..72,300..500` and
`Hanken Grotesk:wght@400;500;600`. The 38px date is weight **300**; buttons, the ambient stamp
and the `now` cap are **600**. Neither weight was in the list, so static cuts would have
silently rendered the design at the wrong weights.

There is a second reason, and it is the better one. Browsers apply optical sizing by default,
so every glyph in the prototype is drawn at the optical size it is set at — which is precisely
what a 2.3× display-to-body ratio (DESIGN-SYSTEM.md §6.2) needs to look right. Newsreader carries an
`opsz` axis from 6 to 72. Shipping the variable font is the only way the app matches the
prototype rather than approximating it.

Google's canonical `google/fonts` repository ships these families **only** as variable fonts,
so this is also the path with one authoritative source rather than three upstream repositories
of differing freshness.

**The cost, and it is a real one.** A variable font declared once in `pubspec.yaml` renders at
weight 400 no matter what `fontWeight` a `TextStyle` asks for — `fontWeight` alone is silently
ignored. Every style must therefore carry
`fontVariations: [FontVariation('wght', ...), FontVariation('opsz', ...)]`, and a style that
forgets is not an error. It is a wrong-looking screen that analysis will not catch.

This is survivable only because ADR-010 already forbids bare `TextStyle`s in widget code: there
is exactly one file where the mistake can be made. It is written down in CLAUDE.md §4 as a
house rule for that reason.

**Also costs.** ~1.8 MB of fonts, of which Noto Serif Devanagari is 758 KB to draw one word.
Subsetting is noted as an open item rather than done now, because the mark may still change.

*Note, 15 September 2026 — the decision is unchanged, two figures in the evidence are not.* The
prototype this record reads is now `chit-app-v6.html`, and the date it cites as the 300-weight
example is 26px there rather than 38px, so the display-to-body ratio the `opsz` argument rests
on is 1.58× rather than 2.30× (DESIGN-SYSTEM.md §6.2). The weights loaded are the same, a
narrower optical range still spans two thirds of an octave, and `fontVariations` is still the
only way to get any of it. Left in place rather than rewritten: the record says what was known
when the choice was made.

---

## ADR-016 — Precise location first, coarse as the fallback

**Decision.** Location is requested at high accuracy. If the user grants only approximate
location — Android 12+ and iOS 14+ both let them — the coarse fix is accepted and used. The
manifest declares `ACCESS_FINE_LOCATION` and `ACCESS_COARSE_LOCATION`; either outcome is a
successful capture.

**Over.** Coarse-only at low accuracy, which is what ARCHITECTURE.md and PACKAGES.md specified
until this ADR. Both have been corrected.

**Why.** The owner's call, and the reason is the backlog rather than the present screen:
OPEN-QUESTIONS.md §9 item 1 wants coarse place labels — "home", "office", "in transit" — inferred from
the fix. A neighbourhood-level coarse fix cannot separate home from office. Asking for
precision later, after a year of coarse rows, means a year of chits that can never carry the
label.

**The tension, stated plainly.** BEHAVIOUR.md §3.6 shows location as a pin and nothing else — *"the
fact of a place, never its name"* — and this decision stores a far sharper fact than that
display implies. The display promise is unchanged and binding: the UI never surfaces a name, a
coordinate, or a map. But the row is now precise enough to reconstruct a home address, and that
is a real difference in what a leaked or backed-up database would give up.

Three things make it acceptable. The database never leaves the device (ADR-004). ADR-007 keeps
capture best-effort, so a refused permission costs the user nothing. And a user who grants only
approximate location gets exactly the old behaviour, with no degradation and no nagging.

**Costs.** A precise fix is slower and hungrier than a coarse one — ADR-007's timeout is what
keeps that off the composer's critical path. And should a sync layer ever arrive (ADR-004),
this row is more sensitive than it was, which is a constraint on that design rather than a
reason to refuse this one.

---

## ADR-017 — The chit editor is a screen, and leaving it asks

**Decision.** OPEN-QUESTIONS.md §8.1 is settled. A saved chit opens in **its own screen**, not inline in
the thread.

- Leaving the editor with unsaved changes raises a **clear prompt**: keep the edit, or discard
  it.
- Quitting outright — the app is killed, or the prompt is answered *discard* — **cancels the
  edit** and returns to Today. Nothing is written.
- The chit's audio is neither editable nor removable, in the editor or anywhere else. Editing
  changes what the chit says, never what was said (ADR-014).

**Over.** Inline editing in the thread, which was the other candidate in OPEN-QUESTIONS.md §8.1.

**Why.** The thread is a reading surface. Today's screen already carries a live writing surface
at the top of it — the open chit — and a second, differently-behaved editable field in the rows
below would make it ambiguous which one a tap is about to put the cursor in. A screen has room
for the ambient stamp, the audio pill and the text without the row having to grow, and it gives
the save prompt somewhere to belong.

The prompt exists because editing a saved chit is not like writing a new one. Discarding an open
chit throws away something that was never a record; discarding an edit throws away a change to
something that is. The first needs no confirmation and gets none (BEHAVIOUR.md §3.1). The second gets
one.

**Consequences for the build.** This unblocks the thread affordance, which BUILD-PLAN has been
holding back since M2 — *"a chit in the thread carries no affordance, because one that leads
nowhere is worse than none."* It becomes **M6**, after voice and before polish, so the editor
handles a chit that already has an audio pill from its first day rather than growing that case
later. Motion and the accessibility floors move to M7 and stay last. The affordance and the
editor still arrive in the same change.

**Costs.** A screen is more work than an inline field, and it is one more place the ambient
stamp and the audio pill have to be drawn correctly.

---

## ADR-019 — Android and iOS only; the web folder stays

**Decision.** `windows/`, `linux/` and `macos/` are deleted from the repository and `.metadata`
is trimmed to root, android, ios and web. `web/` is left in place, untouched.

**Why.** The app is a phone app. README §10 targets Android and iOS first at 390×844, and every
feature that defines it — a microphone that is an equal to the keyboard, ambient weather and
location, on-device speech — is a phone capability. Three desktop scaffolds that nobody builds
are three scaffolds that go stale, break `flutter analyze` after an SDK bump, and invite a
plugin to be chosen for its desktop support.

`web/` survives because it is the one non-mobile target README §10 actually plans for —
*"Responsive web comes later"* — and deleting it now would only mean regenerating it later.
No layout work is being spent on it before the phone app is real.

**Costs.** Restoring a desktop target means `flutter create --platforms=...` and re-applying any
platform config. That is cheap, and it will not happen.

---

## ADR-020 — Reducing motion never makes a fade slower

**Decision.** Under reduced motion, a fade re-times to ADR-010's targets — 220ms for an
arrival, 140ms for everything else — **unless it was already quicker than that**, in which case
it keeps its own pace. In practice this affects exactly one pace: press feedback stays at 90ms
instead of being stretched to 140ms.

**Over.** ADR-010 as originally written, which set every non-arrival fade to 140ms flat.

**Why.** ADR-010 did not consider press. Its rule was written about *transitions* — a tab
changing, a control arriving — where 140ms is a calm replacement for movement. Press feedback
is not a transition. It is the acknowledgement a finger gets, and DESIGN-SYSTEM.md §6.3 is explicit that
on a phone it is the *only* one. Stretching it from 90ms to 140ms makes a button feel slower to
the one group of users who asked for less animation, not less responsiveness.

DESIGN-SYSTEM.md §6.4 states the principle this follows from: *"Reducing motion should cost a user
animation, not confirmation that their action landed."* A slower acknowledgement is a worse
acknowledgement. So the re-timing is a ceiling rather than an assignment.

**How this was found, which is the part worth keeping.** It was not noticed by reading the
design. `chit_motion_test.dart` asserts "no fade is slower than it was" — a property, not an
example — and that assertion failed on the first run. The rule as written was self-consistent
and wrong, and only a test that checked the *shape* of the answer rather than its values caught
it. Worth remembering when writing the other floors of DESIGN-SYSTEM.md §6.4.

**Costs.** One more clause in a rule that was pleasingly simple. The clause is a `min`, and the
test states it in one line, so the cost is a sentence rather than a branch anyone has to
remember.

---

## ADR-021 — A chit is stamped when it is opened, not when it is saved

> **Superseded by ADR-040 on 16 September 2026**, which reverses it: a chit is now stamped when
> it is **saved**. The record stays because a reversal is only legible beside the thing it
> reversed — and because the failure it created is the reason ADR-026 existed at all. What
> follows is what was decided, not what the app does.


**Decision.** `createdAt` is the moment the open chit was created — the same instant the ambient
stamp was captured. `ChitRepository.save()` takes an `AmbientStamp` and stores its `capturedAt`;
`localDay` is computed from that. The clock is read at save time for one thing only, `updatedAt`.

**Over.** Timestamping the row when **Save chit** is pressed, and treating the stamp's time as a
separate display value.

**Why.** There is one time column, and README §2 has already said what it holds: *"the ambient
stamp — time, weather condition and a location marker, captured automatically when a chit is
opened."* The weather and the place are from the moment the chit was opened, so a time from a
different moment would make the stamp row three facts about two instants — and BEHAVIOUR.md §3.6
draws them as one row because they *are* one observation.

It also follows from what a chit is (README §1): *you write when something hits you.* The moment
worth recording is the one that hit, not the one where the user finished typing it. A chit
opened at 11:58pm and saved at 12:03am belongs to the day it was opened, and that is the answer
most people would expect if asked.

**Costs.** A chit written over a long pause carries a time slightly before the words existed,
and there is no record at all of when Save was pressed — except `updatedAt`, which is the row's
write time and is not displayed. If a future feature needs "when did you finish", it is a new
column, not a reinterpretation of this one.

**Consequences.**

- The repository never reads the clock to decide a chit's day, so the midnight rollover and the
  timezone case are testable with a value rather than a stopped clock (ADR-012 is about the
  other three behaviours, not this one).
- `updatedAt` is the one column set from the clock at save. It is therefore the row's write
  time at insert and the edit time afterwards, which is what the name says.
- M2 must hold the stamp in `ComposerState` from the moment the chit opens and pass that same
  object to `save()`. Re-capturing it on save would quietly undo this decision.

---

## ADR-022 — The seal means now; a record is ink

*Refines ADR-010. Adopted with `design/chit-app-v6.html`, 15 September 2026.*

**Decision.** `--seal` marks what is **live**, and nothing else: the ring at `now` on the day
arc, the caret in the field, the record dot on the recording sheet, the ring around today on
the calendar, and the audio pill *while it is playing*. Everything that is a record rather than
a happening is ink — the arc's marks, the calendar's density steps, the active tab pip, the
audio pill at rest, the microphone, and Save. Surfaces that need to sit above their ground are
tinted with `--ink` at a stated alpha (DESIGN-SYSTEM.md §6.1).

**Over.** v5's rule, which gave the accent to *"the caret, the day-arc marks, the calendar heat
field, the active tab dot, audio waveforms, the microphone, and the Save button"* — roughly,
anything that mattered.

**Why.** An accent used for everything that matters marks nothing, because on a working screen
everything matters. Three concrete failures, all visible in v5 rather than argued from
principle:

- A thread with three recordings in it ran orange down its whole left side. The pill is a
  record like any other until it is the one making a sound.
- A calendar of a busy month was a field of orange, and today's ring — the one thing on that
  screen a person is actually looking for — was more orange inside it.
- Save became the loudest thing on the screen the instant a word was typed, and next to a solid
  accent bar the outlined microphone read as a control borrowed from another app, even though
  BEHAVIOUR.md §3.2 makes the two equals.

Reserving the colour for *now* gives it one meaning that holds on every screen, and it makes
the day arc say something it could not say before: the marks are what happened, the ring is
where you are.

There is a second gain, and it is the one that removes a token rather than adding one. The
calendar's density in ink means a numeral never has to flip to near-white to stay legible over
a strong fill — the four steps run 12.66:1 down to 5.99:1 against `--ink`. `#FFF6EE` was a
colour that existed only to survive the accent, and it is gone with it. So is `#1A1310`, the
dark label that only a solid `--seal` button needed.

**Costs.** Ink washes carry less force than a saturated fill, so density on the calendar is a
quieter signal than heat was — a busy month and a very busy month look more alike. That is
accepted: the month summary states the number in words underneath, and BEHAVIOUR.md §4.2 has
always said the grid is a shape rather than a readout.

The app is also, plainly, less colourful. The register of the design log — *a ground, ink,
hairlines, and one accent* — is unchanged; v5 simply was not keeping to it.

**Consequences.**

- `ChitColors.seal` and `sealInk` keep their split and their meaning; only the surfaces they
  land on changed, so `--seal` measures 4.09:1 on the new `--slip` rather than 4.23:1 and
  `--seal-ink` stays the token for anything read as words.
- **A new floor failure came with it, and is open**: today's `--seal` ring against a dense day
  tile measures 2.61:1 at three chits and 1.88:1 at four or more, under the 3:1 a non-text UI
  component needs. It wants a design answer — PROGRESS.md open item 12.
- DESIGN-SYSTEM.md §6.1 now carries a table of every tinted surface and what it measures,
  because "reach for ink" only stays safe if each wash is checked rather than assumed.

---

## ADR-023 — The field is live, but it does not take focus

*Settles a question M2 could not have built around. 15 September 2026.*

**Decision.** Today opens with the field ready and **unfocused**. The keyboard does not appear
until the user taps. The caret, the five-second prompt and everything else about §3.2's "one
surface" are unchanged.

**Over.** `autofocus: true`, which is the literal reading of BEHAVIOUR.md §3.2 — *"the field is
live the moment the chit opens — typing costs nothing, not even a tap."*

**Why.** Taken literally, that sentence costs the user the screen. A keyboard raised on every
launch covers the thread, the timeline and roughly half the open chit, so the app that opens to
"a blank page, ready" would in fact open to a blank page and a keyboard, with the day it is
supposed to show hidden behind it. README §1 asks for two things at once here — *opening the app
costs nothing* and *a day holds many chits* — and only one of them survives an unprompted
keyboard.

It is also the wrong default for what people actually do with a journal. Opening it to read
back what you wrote this morning is at least as common as opening it to write, and the reading
case pays the whole cost of the writing case's saved tap.

**What §3.2 still gets.** The sentence is about there being no *mode* to choose — no Write
button, no step between opening the app and writing in it. That is intact: the field is a real
editor, it is the first thing under the stamp, and one tap puts the caret in it. What is gone
is one tap, not a decision.

**Costs.** Writing a chit costs a tap it did not have to. That is the whole cost and it is
accepted.

**Consequences.**

- §3.3's five-second prompt starts when the chit opens, not when the field is focused —
  otherwise an unfocused chit would never prompt, and the prompt is an offer to someone looking
  at the screen rather than to someone already typing.
- M2's composer sets no `autofocus`. *This had a widget test until ADR-031 removed the suite;
  it is now a device check, and `docs/PROGRESS.md` carries it — open the app and confirm the
  keyboard does not come up on its own.*
- If this turns out to be wrong it is one line, which is the other reason to decide it now
  rather than to design around it.

---

## ADR-024 — The day arc becomes the timeline: three days, full days, scrollable

*Supersedes the day arc as README §2 and BEHAVIOUR.md §4.1 described it. 15 September 2026.*

**Decision.** The horizontal strip under the date is **the timeline**. It runs midnight to
midnight rather than 5am to midnight, it spans **today and the two days before it**, it scrolls
horizontally and rests at now, and a chit's mark sits where its time actually falls rather than
in a row of evenly spaced dots. Saving places a mark at the current time and the timeline
**scrolls smoothly to it**.

**Over.** The v5/v6 arc: one day, 5am to midnight, fixed width, no scroll.

**Why.**

*The old window dropped chits on the floor.* 5am to midnight is nineteen of twenty-four hours,
and the five it leaves out are exactly the ones ADR-006 goes out of its way to protect — a chit
written at 00:20 belongs to that morning, permanently. The prototype clamps such a chit to
position 0, so a 00:20 chit and a 5:00 chit land on the same pixel. That is not a design
simplification, it is a chit the arc lies about, and it took until M2 to notice because nothing
was drawing it. A full day cannot have that bug.

*One day is a snapshot, not a rhythm.* README §1 says the habit survives on rhythm, and a strip
that resets every midnight can only ever say "today, so far". Three days is the smallest window
in which yesterday-versus-today means anything, and it is small enough to stay a glance rather
than becoming a second calendar — which is what §4.2 is already for.

*Proportional spacing is what makes the shape mean something.* This part is not new — the
prototype already maps minutes to a percentage — and it is stated here because it is now
load-bearing across a wider window. Four chits in an hour should look like a burst; evenly
spaced dots would turn the one thing the timeline knows into decoration.

**Costs, and they are real.**

- **The home screen stops being purely about today.** The design log's argument for the arc was
  that *"the home screen is about today, so its rhythm signal is about today"*. That reasoning
  is now partly overturned and the log says so rather than being quietly edited around it.
- **The thread and the timeline no longer read the same query**, which was a small, pleasing
  property. The thread is one day; the timeline is three. DATA-MODEL.md §4 gains a range query
  and the repository gains `watchDayRange`.
- **A horizontal scroller inside a vertically scrolling page** is a gesture conflict that has to
  be got right rather than assumed.
- **Crowding.** Several chits a day across three days is fifteen to twenty marks in one strip.
  If that reads as a smear it is a finding to record, not to tune away.
- **The prototype no longer shows the target here.** v6 draws the old arc, and for the first
  time the specification leads the prototype rather than following it. DESIGN-SYSTEM.md §7 says
  so explicitly, because "when in doubt about a pixel, open v6" is otherwise a trap.

**Consequences.**

- **The name changes, everywhere.** "The day arc" describes a thing that no longer exists, and
  CLAUDE.md §4.1 is explicit that a synonym is a bug in the making — a name that is simply
  wrong is worse. It is **the timeline** in README §2, in BEHAVIOUR.md, in the design system, and
  in the code: `ChitType.arcEnd` and `arcNow` become `timelineLabel` and `timelineNow`, and
  `features/today/application/day_arc_provider.dart` becomes `timeline_provider.dart`.
- The window is a function of the clock, so it slides when the local day does. A chit already
  saved never moves (ADR-006); the window moves under it.
- The scroll-to-now on save is a third **authored arrival** alongside the two in
  DESIGN-SYSTEM.md §6.3, and like them it is travel: under reduced motion it becomes a jump
  rather than a slower slide (§6.4).
- **How days are delineated is not decided here.** A three-day proportional strip needs
  something saying where one day ends, and the old `5 am` / `midnight` end labels do not do that
  job. It wants a sketch against a real screen rather than a paragraph written in advance —
  TASKS.md group H carries it, and the answer goes into BEHAVIOUR.md §4.1 when it exists.

---

## ADR-025 — The weather service takes no position

*16 September 2026. Clarifies ADR-007's "in parallel" against ADR-016's precise fix.*

**Decision.** `WeatherService.currentCondition()` takes **no arguments**. Where an
implementation gets a position is its own business, on the far side of the `domain` boundary.
M3's `OpenMeteoService` will use the device's **last known** fix — which is cached and
instant — and answer `null` when there is not one.

**Over.** `conditionAt({required double lat, required double lon})`, which is the obvious shape
and the one a reader expects the moment they know Open-Meteo is a lookup by coordinates.

**Why.**

*The obvious shape makes the two signals sequential, and ADR-007 says they are parallel.* If
weather needs the fix, weather cannot start until the fix arrives. ADR-016 then makes that
worse rather than better: it asks for the **precise** location, which is the slow one, so the
faster signal would end up gated on the slower. The composer would wait on the sum of the two
where ADR-007 promised the maximum.

*It would also couple the two failures.* A user who refuses location would silently lose the
weather word as well — two blanks from one refusal, and no way for the row to show the one fact
it could still have had. Keeping weather independent means a refused permission costs exactly
the pin.

*And `domain` should not know that weather is looked up by place.* The interface says what the
product wants — *one condition word, now* — and the fact that one HTTP API happens to need
coordinates is a detail of the implementation that ADR-004's local-first design might replace
anyway.

**Costs.**

- **The condition can be for where you were, not where you are.** A last known fix may be
  hours old. At the resolution of five words across a city this is almost always the same
  answer, and ADR-007 has already decided that an ambient signal is worth less than a composer
  that opens instantly — but it is a real inaccuracy and it is written down here rather than
  discovered in M3.
- **On a device with no fix ever taken, weather is `null`** where the sequential version might
  eventually have produced a word. That is the ordinary ADR-007 outcome and the row simply has
  one fact fewer.
- **The seam is inside `data`.** `OpenMeteoService` will depend on `LocationService`, so the
  wiring in `main.dart` gains an order that a reader has to notice. That is a smaller cost than
  the one it avoids.

**Consequences.** `AmbientCapture` fires both calls at once and neither knows about the other.
ARCHITECTURE.md §4.2 is corrected: it used to say weather and location *run in parallel*
without saying how that was possible given the API, which is the gap this record fills.

---

## ADR-027 — An ambient loop is not a pace

*16 September 2026. Refines ADR-010 and ADR-020. Settles where a looping animation's period
lives, with three more loops still to build.*

**Decision.** `ChitMotion` gets `loop(Duration period)` beside `travel(ChitPace)` and
`fade(ChitPace)`. The **period belongs to the component that loops** — the caret's 1.15s is a
constant on the caret, the way its 1.5px width is — and `ChitMotion`'s job is only to apply
DESIGN-SYSTEM.md §6.4 to it: `Duration.zero` under reduced motion, which is the signal to start
no ticker and draw the thing at rest.

**Over.** Adding `ChitPace.blink` at 1150ms to the pace table, which is the obvious move and
the one the existing `travel` doc invites — it already names the caret blink as something
`travel` serves.

**Why.** A loop has a **period**; the five paces are how long a **transition** takes. They are
not the same quantity and they do not compare, but a single table invites the comparison — and
the app already makes it. DESIGN-SYSTEM.md §6.3 says the idle prompt is *"700ms, deliberately
slower than everything else"*, and `chit_motion_test.dart` holds that claim by walking
`ChitPace.values`. A blink pace at 1.15s would have broken that test while saying nothing true:
the caret is not a slower piece of motion than the prompt, it is a different kind of thing.

The alternative to a token is a bare `Duration` in a widget, which CLAUDE.md §4.2 forbids —
except that §6.3 already carries the pattern for exactly this. A **dimension** may sit off the
scale when it belongs to one component and is named there: the page gutter, the touch target,
the microphone's 54px, the 7px marks. A loop period is the same shape of thing, and this record
extends that rule from space to motion rather than inventing one.

What does not move is the decision itself. §6.4's *movement collapses and feedback does not*
stays inside `ChitMotion`, so a looping widget has no `reduceMotion` branch of its own — which
is the whole reason `context.motion` resolves the flag rather than exposing it.

**Costs.**

- **Two shapes on one class.** `travel` and `fade` take a `ChitPace`; `loop` takes a
  `Duration`. A reader has to notice why, and the answer is this record.
- **Nothing enumerates the loops.** The pace table is a list you can read; the four loops of
  §6.4 are named in prose and in four separate widgets. If M7's floors pass wants to check them
  together it will have to collect them, and the honest answer may be a list at that point.

**Consequences.** M5's record dot and live waveform and M7's pulse at now each name their own
period and ask `loop` for it; none of them adds a pace. The caret is the first, at
`1150ms` in `open_chit.dart`, and `five_second_prompt_test.dart` holds both halves — that it
blinks, and that under reduced motion it stops **drawn** rather than stopping hidden.

---

## ADR-028 — The caret is the platform's, and chit draws none

*16 September 2026. Reverses the drawn caret M2 group F built one commit earlier, and corrects
ADR-027's consequences.*

**Decision.** The open chit draws **no caret of its own**. The page opens blank and nothing on
it moves. Tapping the field focuses it and the framework's caret appears — `--seal`, 1.5px, and
blinking the way every text field on the device blinks.

**Over.** The prototype's drawn caret, which v6 puts in the ghost line and hides on focus, and
which group F ported faithfully: a `--seal` bar blinking at 1.15s on an untouched field.

**Why.** Two reasons, and the first is the one that decides it.

**An app that is animating when you open it is asking for something.** BEHAVIOUR.md §3.1 is that
opening the app six times leaves nothing behind, and README §1 is that opening it costs nothing
— *the page is blank and ready*. A blinking bar on a page nobody has touched is not a statement
that the page is ready; it is a small repeated motion in the corner of the eye of somebody who
opened the app to write four words. The prototype gets away with it because a prototype is
looked at rather than lived with.

**And the page is not actually short of signals.** ADR-023's worry — that a field with no focus
and no caret reads as inert — is answered five seconds later by the prompt, which is what §3.3
is for, and immediately by the slip itself: a page with a tear edge, an ambient stamp and a
microphone under it is legible as something to write on. Group F reasoned that the drawn caret
*was* the affordance ADR-023 traded the keyboard for. On the device it reads as a cursor in an
app that has not been started yet.

**Costs.**

- **There is nothing at all for the first five seconds.** That is the design's own premise
  taken literally, and if it turns out to read as broken the answer is the prompt's timing,
  not a blinking bar — §3.3's five seconds are the dial.
- **§6.4's caret-blink rule now has nothing in this app it can reach.** The only caret is the
  framework's, and Flutter offers no way to steady it that does not also hide it. That was open
  item 14 as a partial gap; it is now the whole of it.

**Consequences.** `_Caret`, `_CaretSlot` and `OpenChit.caret` are gone, and the overlay is the
prompt alone. `ChitMotion.loop` **stays** — ADR-027's decision is about where a loop's period
lives and is unaffected by which loop is built first. Its consequences paragraph named the
caret as that first caller; that is no longer true, and the first is now M5's record dot. The
design system carrying a rule ahead of its first use is the same pattern as `ChitType` holding
twenty-five styles for the eight that are drawn so far.

---

## ADR-029 — The prompt reads the stamp

*16 September 2026. Extends BEHAVIOUR.md §3.3, which named one line.*

**Decision.** The five-second prompt's words are chosen from the ambient stamp the chit already
holds — the hour it was opened, and the weather if it arrived. `domain/prompts.dart` is a book
of twenty-eight short questions and one pure function over it: the **most specific** entry that
fits wins (weather and hour, then weather, then hour), and where several fit equally one is
picked from the stamp's own clock fields.

**Over.** The single fixed line §3.3 names — *"What just happened?"* — which is still in the
book and is still what a chit gets when nothing else fits.

**Why.** The stamp is already captured, already on the screen, and already the thing the product
says the moment is made of (README §1: *the moment matters as much as the words*). A prompt that
ignores it is asking a generic question in front of a line that just said `3:42 pm  raining`.
Asking *"Rain. What's it like out?"* costs nothing that was not already paid for, and it is the
difference between a placeholder and something that noticed.

It also spreads the prompt out. One line seen twice is a label; seen for the fiftieth time it is
furniture. A set of twenty-eight is not variety for its own sake — it is what stops the one
feature in the app that speaks first from becoming something the eye skips.

**What the copy may not do**, because this is the decision that would rot:

- **Every prompt is a question, and none of them is excited.** No exclamation marks, no
  *"Let's…"*, no suggestion of a subject worth writing about. The design log's objection to a
  streak counter is the same objection: chit has no opinion about how much you write.
- **Nothing is longer than the field's own line.** A prompt that wraps is a paragraph where a
  nudge was meant.
- **`test/domain/prompts_test.dart` holds all of that**, because copy fails quietly — the
  wrong tone reads fine to whoever wrote it and is a different app by the tenth one.

**Costs.**

- **The prompt can be wrong about the weather.** ADR-025 has the condition coming from a last
  known fix, so it can be for where you were. *"Rain. What's it like out?"* indoors, on a
  stale fix, is a small oddity — the same one §3.6 already accepts for the stamp itself, and
  the prompt is a question rather than an assertion, which absorbs it better than the stamp
  does.
- **It is more copy to keep in one voice.** Twenty-eight lines is twenty-eight chances to write
  one that sounds like a different product. The tests are the floor and not the ceiling.
- **Until M3 group J you would only ever see the rain prompts**, because the fake weather service always said
  `raining`. That is the fake doing its job, and M3 is where it stops.

**Consequences.** `ComposerState.prompt` is a getter over `Prompts.forStamp(stamp)` rather than
a stored field, so there is one answer and it cannot drift from the moment it is about. It
changes once, if the weather settles (ADR-007) before the five seconds are up. `OpenChit.prompt`
is a key, because a test can no longer ask for the prompt by the sentence it expects.

---

## ADR-031 — No widget tests

*16 September 2026. Replaces the testing half of CLAUDE.md §4.2, and absorbs ADR-030 — which
had decided, a few hours earlier, which fake a screen test should get. There are no screen
tests now, so that question does not arise; the finding underneath it is kept below, because it
is a real property of `flutter_test` and it will catch somebody again.*

**Decision.** chit has **no widget tests**. Nothing under `test/` calls `testWidgets`,
`pumpWidget` or `WidgetTester`, and no test builds a widget in order to look at it. The eight
suites that did — the four in `test/shared/widgets/` and the four in `test/features/` — were
deleted, along with `test/support/app.dart`, `test/support/pump.dart` and
`test/support/fake_repository.dart`, which existed only to serve them.

A claim that can only be checked by pumping a screen is **checked on a device**: build it, look
at it, and write what you saw into `docs/PROGRESS.md`, which already carries an *On a handset*
paragraph for exactly this.

`test/docs/no_widget_tests_test.dart` fails if any of the three APIs reappears. A rule that
lives only in prose lasts until somebody is in a hurry, and the suite this record removes was
not written in one sitting either — it grew one reasonable-looking `testWidgets` at a time.

**Over.** Keeping them, which is the Flutter default — and which the record this one absorbs
had just spent a day trying to make survivable.

**Why.**

- **The second implementation.** This is the one that decided it, and it follows from a
  property of the framework rather than from taste. `flutter_test` runs a `testWidgets` body
  inside a fake-async zone, and **real I/O never completes in it** — not a Drift query, and not
  `Directory.systemTemp.createTemp()` either, which is the probe that makes it obvious. There
  is no error and no timeout: the test simply never finishes, and the runner sits there.
  `tester.runAsync` is the escape hatch and it is the wrong one — it gets the I/O done by
  putting the screen's rebuilds back on the real event loop, and deterministic rebuilds are the
  entire reason `pump` exists. So every screen test needed `FakeChitRepository` beside
  `ChitRepositoryImpl` — **two implementations of one interface**, held together by nothing but
  the Liskov rule and whoever remembers it. A fake that drifts from the real one is a green test
  for a screen that cannot work, which is worse than no test at all: it is a test that reports
  on the fake. That cost was the first one its own record listed, and it is why that record did
  not survive the day.
- **They fail for the wrong reasons.** In one milestone the suite was broken twice by the widget
  tree rather than by the app being wrong. `find.bySemanticsLabel` returns nothing inside a
  `SliverList`, so wrapping Today in a sliver took every semantics finder in the suite to zero
  and read as *the labels are gone*. `RenderRepaintBoundary.toImage()` hangs outright. Neither
  was a defect; both cost a session.
- **They assert the structure, not the thing.** "The microphone is drawn at 54px and is not
  marked up as a control" is a fact about a widget tree. Whether the microphone reads as an
  equal to the field — the actual claim, the one `docs/DESIGN-LOG.md` warns about at length —
  is not visible to a test that never rasterises, and the goldens that would rasterise it are a
  screenshot-diff habit of their own.
- **The device was doing the work anyway.** Every milestone so far ended with a build on a
  handset, and every real visual defect was found there. The widget tests were a second, weaker
  pass over surfaces that a person had already looked at.

**What is tested instead**, and this is the half that matters — the rule is a constraint on
where behaviour lives, not just on what `test/` contains:

| | |
|---|---|
| Models and invariants | `chit_test.dart`, `chits_table_test.dart` — §5's one-of rule where it fails first and where it survives a release build |
| The repository and the DAO | `chit_repository_test.dart`, `audio_store_test.dart`, `migration_test.dart`, against `NativeDatabase.memory()` and a real filesystem |
| Pure functions | `prompts_test.dart`, the WMO mapping, the count-to-density scale, the timeline position for a time |
| Services and controllers | `ambient_capture_test.dart` — through a bare `ProviderContainer` and a fake clock, no widget in sight |
| The design-system floors | `contrast_test.dart`, `chit_type_test.dart`, `chit_motion_test.dart` — arithmetic on tokens, which needs no tree |
| The rules about the rules | `readme_maps_everything_test.dart`, `clock_is_the_only_now_test.dart`, `no_widget_tests_test.dart` |

**Pull the logic out of the widget until it can be tested that way.** A controller that can only
be exercised through a screen is a controller with too much in it — `ComposerController` and
`todayProvider` are both already driveable from a `ProviderContainer`, and the widget tests were
mostly re-asserting through pixels what could be asserted through them directly.

**Costs, stated plainly.**

- **251 tests became 164, then 171.** Real coverage was lost, not just ceremony, and pretending
  otherwise would make this record useless. What could not be saved: the tear edge being holes
  rather than a dotted border (a claim `docs/DESIGN-LOG.md` calls load-bearing and two
  characters of paint code from being wrong), the field not taking focus at launch (ADR-023),
  the stamp being captured once (ADR-021, which was checked by *counting clock reads* — an
  assertion no other kind of test can make), a tab return costing a fade rather than a rebuild
  (ADR-011), and type → save → it is in the thread end to end.
- **Some of it was never a widget test to begin with**, and finding that out is the first move
  whenever this rule looks like it is costing something. Seven assertions came straight back as
  `test/core/theme/widget_constants_test.dart` — the perforation's strip and the thread node's
  halo still equalling `s1`, v6's 1.55px-on-8px figures, the rail's centre still *derived* from
  the mark rather than set beside it — because `ChitSpace.tokens` is a const constructor and
  those are const fields, so every one of them is arithmetic. They had been written as widget
  tests only because they lived near widgets.
- **ADR-021 and ADR-023 have no automated guard at all now.** Both fail silently and both are
  invisible on a device unless you know to look. They are named in `docs/PROGRESS.md`'s device
  checklist for that reason, and that list is the mitigation — it is a weaker one than a test
  and should be read as such.
- **Regressions will be found later and by a person.** That is the trade: the suite's cost was
  continuous and its catches were occasional, but the catches were real.

**Consequences.** ARCHITECTURE.md §7 no longer lists widgets or goldens among what is tested.
README §10.3 lost eight suite rows and three support rows. M2 group I's accessibility sweep and
M7's floors pass are both **device passes** now rather than test-writing, and BUILD-PLAN.md says
so. If this decision is ever reversed, reverse it as a new record and start by reading the
costs above — they are the reason, and they did not stop being true.

---

## ADR-032 — One day is one screen, and now rests in the middle of it

*16 September 2026. Settles the two things ADR-024 left to the screen: how wide three days
are, and what "rests at now" means in pixels.*

**Decision.** The timeline's content is **three viewport widths**, so one day occupies exactly
the width the reader is looking at and scrolling back one screen is scrolling back one day.
The strip's resting offset puts **now in the middle of the viewport and then clamps** it to the
strip's own ends.

**Over.** Two alternatives, and the second is the one that was nearly taken.

- *A fixed number of pixels per hour.* Then the window is as wide as the handset makes it, a
  small phone shows a day and a half and a large one shows two and a half, and "three days" is
  a fact about the query rather than about anything the reader can see.
- *Resting at `maxScrollExtent`*, which is simpler: the viewport is today, always. It is also
  what the clamp gives for most of the day, so the two agree nearly all the time.

**Why.**

*One day per screen makes the window legible without a label.* §4.1 draws the day boundaries as
small unlabelled marks — *there to be noticed, not read* — and that only works if the rhythm is
already obvious. When a day is a screen, the boundary mark arrives at the edge of the viewport
as you scroll, which is where a reader expects a day to end. At a fixed pixel rate the marks
fall anywhere, and the strip needs the labels §4.1 refuses to give it.

*It also makes the resting position computable rather than chosen.* Because the day is the
viewport, "show today" and "scroll to the end" are the same instruction, and the clamp does it
without the widget knowing which day it is on.

*Centring is what makes the small hours work.* This is where it beats resting at the end. At
15:42 the clamp wins and the viewport is today, with now 65% across it — the simpler rule and
this one agree. At **00:20 they do not**: resting at the end would show a nearly empty strip
with now pinned against the left edge and everything written yesterday just off-screen.
Centring pulls back to show yesterday evening beside this morning, which is one continuous
stretch of somebody's night. Those five hours are exactly what ADR-006 works hardest to protect
and what the day arc could not draw at all, and it would be a poor result to place them
honestly and then park the viewport where they cannot be seen.

**Costs.**

- **A day is not a fixed size**, so the same three chits are further apart on a tablet than on
  a phone. Accepted: the strip is a rhythm signal rather than a chart, and nothing is read off
  it by measuring.
- **The rest of the day is drawn even though it has not happened.** At 09:00 two thirds of the
  viewport is empty. That is honest — the day has not happened — but it does mean the strip
  looks emptiest in the morning, when the app is most likely to be opened for the first time.
- **Two rules where one would do.** Most of the day the clamp makes the centring invisible, so
  a reader of the code sees a calculation that appears to do nothing. It is written down here
  because the case it exists for is the one nobody tests by hand.
- **Crowding is untouched by any of this.** ADR-024 left it open and it stays open: fifteen to
  twenty marks across three screens is the thing to look at on a device, not to tune in advance.

**Consequences.** `Timeline` is three `constraints.maxWidth` wide and its resting offset is
`fraction × content − viewport / 2`, clamped. Saving scrolls to that same offset — an authored
arrival, so `ChitMotion.travel` collapses it to a jump under reduced motion (§6.4). The scroll
extents come out right for free: the strip cannot be pushed past today, and it stops two days
back because there is no more content, so *scrollable back two days and no further* needed no
code of its own.

---

## ADR-033 — Today re-reads the clock at midnight

*16 September 2026. What `todayProvider` does when the day it was built for ends.*

**Decision.** `todayProvider` schedules a timer for the next local midnight and invalidates
itself when it fires. Everything on Today is derived from it — the date line, the thread's
`localDay`, the timeline's three-day window — so one invalidation rolls the whole screen over
together.

**Over.** Leaving it, which is what M2 did up to group G and what nothing had yet noticed.

**Why.** A journal is an app that gets left open. A phone put down at 23:50 and picked up at
00:05 showed yesterday's date over yesterday's thread, and would go on showing it until
something else happened to rebuild the screen. That was survivable while the screen was a date
and a thread. It stops being survivable with the timeline: the window is three days ending at
the day it was built for, so **the first chit of the new day would be saved outside the window
it is drawn on** and would have no mark at all — `fractionOf` would answer null and ADR-024's
*a mark that cannot be placed honestly is not drawn* would do exactly what it says.

It belongs in `todayProvider` rather than in the timeline because the failure is not the
timeline's. The date, the thread and the strip must agree about which day it is (that is why
they read one provider and not three clocks), so they have to stop agreeing about *yesterday*
at the same instant too.

**Costs.**

- **A timer per build of `todayProvider`.** It is cancelled in `onDispose`, and the provider is
  built once per screen, so this is one pending timer while Today is alive.
- **It is the one thing on this screen a test cannot drive.** A wall-clock wait is a wall-clock
  wait; `FakeClock` cannot make it fire. What a test *can* do is the arithmetic and the effect,
  and both are covered: `Chit.startOfLocalDay` says when the day ends, and
  `timeline_providers_test.dart` invalidates the provider by hand and checks that the window
  slid and the oldest day fell off. What is untested is that the timer is scheduled for the
  right moment, which is why the boundary is computed by a named function rather than inline.
- **It fires on the wall clock, not on the injected one.** A test that moved `FakeClock` across
  midnight would not see a rollover, which is a place the fake and the real thing differ —
  narrowly, and it is stated here rather than discovered.
- **Nothing else ticks.** The ring at now does not creep along the strip minute by minute; it
  is drawn where now was when the screen was built. A ring that moved would be a second ambient
  loop nobody asked for, and the prototype's does not move either. It follows a save, because a
  save rebuilds the strip anyway.

**Consequences.** `today_controller.dart` imports `dart:async` and `Chit`. `Chit.startOfLocalDay`
is new and sits beside `Chit.localDayOf` — ADR-006 owns where a day starts, and now owns both
ends of it. A device left open across midnight is worth one line on PROGRESS.md's device
checklist, because this is the class of thing that is only ever found by leaving a phone on a
table.

---

## ADR-034 — A day passing is a haptic

*16 September 2026. What the strip does when a boundary goes by under the reader's thumb.*

**Decision.** Scrolling the timeline past a day boundary fires one
`HapticFeedback.selectionClick()`. It is keyed to the **middle of the viewport** — the day the
reader is looking at — and only for a scroll the reader is doing.

**Over.** Nothing, which is what the strip had; and a haptic per *mark*, which is the other
obvious place to put one.

**Why.** The day boundaries are deliberately hard to read. §4.1 draws them as a small
unlabelled mark and says so in as many words: *it is there to be noticed, not read.* That is
the right call visually, and it leaves the strip with no way to tell you that you have just
scrolled out of today and into yesterday — the marks look the same, the line looks the same,
and the one thing that changed is the one thing the design refuses to spell out.

A haptic says it in the channel that is free. It costs no ink, no label and no space, it cannot
be mistaken for a control, and it is the same feedback a picker gives when a detent goes past —
which is what a day boundary is.

*Not per mark*, because a mark is a chit and a day with a dozen of them would turn a scroll
into a rattle. The thing worth feeling is the unit the strip is made of.

**Costs.**

- **It is a sensory channel nothing else in the app uses.** The first haptic in chit arrives
  here, so this record is also the decision that chit has haptics at all. A second one should be
  argued for the same way rather than added because the first exists.
- **It fires on a gesture, so it cannot help a reader who does not scroll.** Someone who never
  touches the strip never learns the boundaries are there. Accepted: the strip is a glance
  first and a thing to explore second.
- **Nothing about the haptic itself is testable here.** A platform channel call has no
  observable effect a `ProviderContainer` can see. What *is* tested is the thing it is keyed to
  — `TimelineWindow.dayAt` — including that the answer changes exactly at a boundary, because a
  boundary that answered the same on both sides would be a day passing in silence.
- **Silence during a programmatic scroll is a rule that has to be remembered.** The scroll-to-now
  after a save can cross a boundary, and buzzing then would be the app reporting its own
  movement. `_settling` is the flag; it is a small piece of state and it exists for one reason.

**Consequences.** `Timeline` listens to its own `ScrollController` and holds the last day under
the centre. `TimelineWindow.dayAt(fraction)` is new and pure. BEHAVIOUR.md §4.1 says a day
passing can be felt; DESIGN-SYSTEM.md §6.3 records the haptic beside the motion it is not.

---

## ADR-035 — Days with nothing in them are not drawn

*16 September 2026. Narrows what ADR-024 draws, without narrowing what it asks for.*

**Decision.** The timeline's **query** is always three days. What it **draws** begins at the day
the oldest chit in that window falls on: leading days with nothing written in them are not drawn
at all. With nothing in the window the strip is today alone, and does not scroll.

Only the **leading** days go. A quiet day between two days that have something is still drawn,
and still takes its full share of the strip.

**Over.** Always drawing three days, which is what ADR-024 said and what shipped an hour
earlier.

**Why.** It was wrong on a handset, and the way it was wrong is worth keeping. Scrolled to the
back-stop on a two-day-old install, the strip is a **bare line**: no marks, no boundary in view,
and — by §4.1's own decision — no label saying which day it is. There is nothing on the screen at
all. A signal that is blank is worse than one that is absent, because the reader has to work out
whether it is empty or broken.

It reads badly at the other end too. A first run drew three days of nothing and let the reader
scroll through two of them, which is the app offering to show its own emptiness.

**And the half of ADR-024's argument that mattered survives.** That record wanted three days so
that *yesterday was quiet and today is not* is visible at a glance. Trimming only the leading
days keeps exactly that: the moment there is anything older than yesterday, yesterday is drawn
in full and its quietness is the thing you can see. What goes is the case where there is no older
context for the quiet to be quiet *against* — and there, "yesterday was empty" is not a rhythm,
it is an install date.

**Costs.**

- **The strip changes width as the app is used.** One screen on the first day, two on the
  second, three from the third on. A reader who learns the gesture on day three would have found
  nothing to scroll on day one. Accepted: there was nothing to scroll *to*.
- **It contradicts ADR-024 as written**, which says the window spans today and the two days
  before it, full stop. That record is not edited; this one narrows it, and BEHAVIOUR.md §4.1
  now carries the qualification.
- **A gap at the front cannot be seen.** If the oldest chit in the window is yesterday's, the day
  before is simply not there, and there is no way to tell that apart from *the app did not exist
  yet*. Both are true and neither is worth a label.
- **The query is still three days wide, which looks wasteful.** It is not: narrowing the query
  would mean a strip that can never grow backwards, because it would have stopped asking whether
  there is anything back there.

**Consequences.** `timelineQueryWindowProvider` is the three-day window the DAO is asked for;
`timelineWindowProvider` is what is drawn, and it is `trimmedTo` the oldest chit. The two cannot
be one provider — the drawn window depends on the answer to the query, and a provider that
depended on its own result would not build. `TimelineWindow.days` became `maxDays`, and
`dayCount` is what a strip is actually made of.

---

## ADR-036 — Now is a tick, not a dot

*16 September 2026. Reverses the ring the prototype draws, after two builds on a handset.*

**Decision.** Now is a **short vertical tick through the line** — 1.5px wide, 12px tall,
`--seal`, straddling the line where a day boundary hangs below it. The word *now* stays above
it. There is no ring, no disc, and **no pulse**.

**Over.** v6's outline ring, and a filled disc. Both were built and looked at on a device; this
record is what that cost.

**Why.**

*The outline failed first, and it failed on arithmetic.* §4.1 had a chit saved at the current
time placing its mark **inside** the ring — *now, with something written in it*. At 11px across
with a 7px square inside it, that is not one marker with something in it. It is two shapes
drawn on top of each other at a size where neither can resolve, and it reads as an accident.

*Filling the disc fixed that and cost more than it fixed.* A solid 11px circle in the one
saturated colour in the app, sitting on a strip whose every other element is a hairline or a
7px mark, is the loudest thing on the screen. The owner's words: *"the filled circle is taking
too much attention."* It is also the screen README §1 describes as *blank and ready*.

*A tick is the right shape for what it is.* Everything else on the strip is a position — a mark
is where a chit was written, a boundary mark is where a day ended. Now is a position too, and a
dot of any kind is an object. Drawing it as a tick puts it in the same family as the boundary
below it and leaves the colour to carry the difference in meaning, which is ADR-022's whole
argument: `--seal` marks what is live, and it does not need size as well.

**What went with it.**

- **The pulse.** It was a ring breathing off a ring, and there is nothing here to breathe any
  more. Nothing on the strip animates now. `ChitMotion.loop` therefore has **no caller again** —
  it had none between ADR-028 and this group — which does not touch ADR-027: that record is
  about where a loop's period lives, not about how many loops exist. M5's record dot is its
  first caller.
- **§4.1's *now, with something written in it*.** A mark saved at this instant sits behind a
  1.5px tick rather than under an 11px disc, so almost all of it is visible — more of it than
  the filled disc allowed, less than the outline promised. The sentence is corrected in §4.1
  rather than left standing.

**Costs.**

- **Three attempts for one 12px object**, and two of them reached a device. That is the cost of
  ADR-031 arriving in the same milestone: there is no widget test that would have caught any of
  this, and there is no widget test that could have. All three failures were failures of
  *reading*, which is what the device checklist exists for.
- **It is a departure from v6**, and the prototype is still the visual target. DESIGN-SYSTEM.md
  §7 carries the list; this is on it.
- **The accent is now carried by 18 square pixels.** If it turns out to be too quiet at arm's
  length the answer is height or weight, not a return to a dot — that is the thing that was
  tried twice.

**Consequences.** `Timeline.ringSize`, `ringStroke`, `pulseScale` and `pulsePeriod` are gone;
`nowStroke` and `nowHeight` replace them. `_NowRing` is `_NowMarker` and holds no state, no
ticker and no `AnimationController`. DESIGN-SYSTEM.md §6.3's list of dimensions off the scale
**returns to four** — the 11px ring was briefly the fifth and is not there any more — and §6.4's
list of ambient loops loses the pulse at now.

---

## ADR-037 — Motion is read off the position fix, not off a motion sensor

*16 September 2026. Adds a third ambient signal without adding a third call.*

**Decision.** `MotionState` — `stationary`, `walking`, `traveling`, `flying` — is derived from
the **speed already on the position fix** that BEHAVIOUR.md §3.6's pin needs. `GeoFix` carries
`speed`, `speedAccuracy` and `altitude` beside its coordinate; `domain/motion/motion_ladder.dart`
turns them into a state; `AmbientCapture` writes it onto the stamp. **No new package, no new
permission, no new dialog, and no third signal.**

**Over.** Reading the accelerometer or the gyroscope, and the platform activity-recognition APIs
(`flutter_activity_recognition`, wrapping Android's `ActivityRecognitionClient` and iOS's
`CMMotionActivity`).

**Why.**

*Neither an accelerometer nor a gyroscope can measure speed.* An accelerometer measures
acceleration; recovering speed from it needs a double integration whose error compounds so fast
that the result is useless within seconds. A gyroscope measures angular rate and says nothing
about travel at all. What an accelerometer is genuinely good for is the periodicity of walking
— and that still cannot separate a car from a train from a plane, because **that distinction
is speed**. Speed comes from GPS Doppler, and it arrives on a fix we are already taking.

*The activity-recognition APIs would cost a permission the app has no way to justify.* They want
`ACTIVITY_RECOGNITION` on Android and Motion & Fitness on iOS — a second system dialog, against
README §1's *opening the app costs nothing*. They also pull in Google Play Services, and the
Flutter wrapper is stream-only with no one-shot query, which fights a model that captures once
when a chit opens. They have no flying class regardless, so the speed ladder would have been
needed anyway.

*And it keeps ADR-007's shape exactly.* Two calls go out in parallel; one of them now yields two
facts. Nothing waits longer, nothing new can fail, and a refused permission costs the pin and
the motion together because they are one signal — which is the same coupling ADR-025 was careful
to avoid between location and *weather*, and is correct here for the opposite reason.

**The ladder.** 0.7 m/s and 3.0 m/s divide stationary from walking from travelling; 55 m/s with
an altitude above 2000 m is flying, and 55 m/s without that altitude is a high-speed train and
stays travelling. **An uncertain reading degrades to `stationary`**: claiming anything above it
requires `speedAccuracy` no larger than `speed` itself — the error smaller than the thing
measured — and `0.0` is read as *unknown* rather than as *perfect*, because some platforms
report it for an accuracy they do not have. Noise can slow a chit down; it can never put a plane
on one.

**Costs.**

- **No fix, no motion.** Indoors, with location refused, and in the first seconds after a cold
  start there is no usable speed. That is an ordinary ADR-007 `null` and it is not drawn — so
  most chits written at a desk carry no motion at all, which is the intended outcome and not a
  degraded one.
- **A stopped car reads `stationary`.** Correct rather than wrong, and not what a user sitting
  in traffic might expect.
- **`flying` will rarely fire.** Most devices disable GPS in airplane mode, and without a fix
  there is no speed. The state is right when it fires and it will not fire often. Written here
  rather than discovered in a bug report.
- **No `running` and no `cycling`.** Speed cannot tell a cyclist at 20 km/h from a car in
  traffic at 20 km/h, and a state the signal cannot defend is the mistake `WeatherCondition`
  already refuses.
- **The thresholds are untuned.** They are defensible arithmetic, not measurements. PROGRESS.md
  carries the device checks.

**Consequences.** `GeoFix` stops being a record and becomes a class — five fields want defaults
and a record cannot give them. `chits.motion` arrives as schema v2, nullable, with **nothing
backfilled**: there is no way to know what a phone was doing last Tuesday, and a guess written
into a row is indistinguishable from a fact a month later. The column takes no index, because
nothing queries it, and no `CHECK (motion IS NULL OR lat IS NOT NULL)` — that would be true
today only because motion happens to be read off the fix, which is a fact about this
implementation rather than about what a chit is.

---

## ADR-038 — The stamp carries one ambient fact, ranked

*16 September 2026. What motion does to a row that was already full.*

**Decision.** The ambient stamp shows the time, **one** ambient fact and the pin. Weather and
motion **share** one slot, and `domain/ambient/ambient_fact.dart` ranks them: flying,
travelling, raining, windy, walking, overcast, clear, clear night. `stationary` is stored and
never drawn.

**Over.** Giving motion its own slot beside the weather word, so a row could read
`8:46 pm  raining  ✈  ⌖`.

**Why.**

*§3.6's spacing argument is a ceiling, not a preference.* The facts sit apart with no separators
because *three items at 11.5px strung on middle dots is five things to read where there are
three*. A fourth item does not survive that sentence — it is the same row, the same size, and
one more thing on it.

*The two are usually alternatives anyway.* Inside a vehicle the sky outside is no longer what
you are in, and being in the air says more about a moment than the weather over the airport
does. Where the weather is the better fact the ladder says so: rain outranks a walk, because
you feel the weather while walking.

*And the ordinary chit is unchanged, which is what makes it safe.* A chit written at a desk in
the rain still reads `8:46 pm  raining  ⌖`, exactly as M2 signed it off. An icon appears only
by **displacing** a word, and only when the phone was moving.

**Costs.**

- **Something true is not shown.** A chit written in a car in the rain records both and draws
  one. Both are in the row, and the ladder decides — which is a real loss of information on
  screen and an accepted one.
- **The ranking is a judgement.** Whether rain should outrank a walk is arguable, and it is
  arguable the other way for someone who walks in the rain often. It is one list in one file,
  and it is tested as a cross product rather than as examples.

**Consequences.** `AmbientFact` is a sealed type rather than a nullable pair, so the widget's
switch is exhaustive with no `default:` and a sixth condition arrives as a compile error. The
prompt book of ADR-029 takes the same ordering — motion outranks weather outranks the hour —
because a chit opened on a train is somewhere, and asking it about the evening wastes the one
thing that was unusual about the moment.

---

## ADR-039 — Motion is an icon where weather is a word, and it is drawn in the thread

*16 September 2026. How the fourth signal is said, and where.*

**Decision.** A motion state is drawn as an **icon**; a condition stays a **word**. The icon is
drawn **under saved chits in the thread as well as on the open chit** — unlike the pin.

**Over.** Giving motion words of its own (`in transit`, `on foot`), and keeping it to the open
chit as §3.6 keeps the pin.

**Why.**

*A condition is recorded as a word because "raining" is a feeling; a motion state is a fact
about the phone.* Every English word for it — *in transit*, *in vehicle*, *active* — reads like
a fitness tracker, and §6.2 is not a voice that says `active`. Drawing it keeps the row to one
word at most, which is also what ADR-038 needs.

*The pin's argument reverses for motion.* §3.6 keeps the pin off the thread because **every**
chit carries a location, so ten identical marks distinguish nothing. Motion is the opposite:
almost no chit has one, so the two you wrote on a train stand out from the ten you wrote at
home. Same argument, opposite outcome — and `stationary` drawing nothing is the same argument a
third time, since it is what most chits are.

*The icon takes the row's colour, not the pin's.* The pin is hard-wired `--ink-faint` because it
is an adornment beside the words; a motion icon is standing in for the word it displaced, so it
weighs what that word weighed — `--ink-muted` on the open chit, `--ink-faint` in the thread.

**Costs.**

- **An icon is guessed at, where a word is read.** There is no legend anywhere in the app. A
  plane and a car are close to universal and a walking figure is the weakest of the three.
- **They are drawn as strokes, not as silhouettes.** At the 12px this actually renders at, an
  outlined plane's wings and a figure's limbs close into a blob under a 1.22px stroke. Three
  lines that suggest a plane survive the size; a traced one does not — so these are sparser
  marks than the pin is.
- **The thread gains density** for the first time since M2 signed it off.

**Consequences.** `lib/shared/widgets/motion_icon.dart` holds the three marks in the pin's own
14-unit box at its own 1.42 stroke, so the row has one drawing weight rather than two. Each
carries a `Semantics` label, which §6.4 requires of a mark that is the whole of a fact with no
text beside it. The paths were designed in `design/chit-app-v6.html` first, which is where the
pin's came from.

---

## ADR-040 — A chit is stamped when it is saved

*16 September 2026. **Reverses ADR-021**, and absorbs ADR-026.*

**Decision.** The clock is read when **Save** is pressed, and that reading becomes the chit's
`createdAt` and its `localDay`. The stamp drawn on the open chit is a **preview** of what will
be recorded, not the value that gets written.

**Over.** ADR-021, which stamped a chit at the moment it was *opened* and passed that held stamp
to the repository untouched.

**Why.**

*A chit is filed on the day it was actually saved, and the wrong-day case becomes impossible.*
ADR-021 created a failure that ADR-026 then had to work around: a chit opened at 23:58 and
written at 00:05 was filed on the previous day, which is the exact thing ADR-006 exists to
prevent. ADR-026 patched it by re-opening the chit on **Discard** so the stamp could not go
stale — a fix for one path out of two, since nothing re-opened a chit that was merely sat on.
Stamping at save removes the whole class: there is no interval between the reading and the write
for anything to go stale in.

*The ambient signals want re-reading anyway.* ADR-042 has a save re-ask both services so a chit
written at six in the evening does not carry the weather fetched at nine in the morning. Once
the row is being built from fresh signals, building it from a stale *time* is the odd one out.

*And what ADR-021 was protecting turns out to be smaller than it looked.* Its argument was that
a chit belongs to the moment you started writing it. That is true of a chit written in ten
seconds, which is nearly all of them — and in that case the two readings are the same to the
minute the stamp displays. Where they differ, the chit was sat on, and *the moment you finished*
is at least as defensible as *the moment you began*.

**Costs.**

- **The stamp on the slip is a preview, and can disagree with the record.** Sit on a chit for
  twenty minutes and the thread shows a later time than the slip did. This is the real cost and
  it is the one thing ADR-021 got right.
- **The preview does not tick**, so it drifts further from the truth the longer a chit is open.
  A self-updating clock would be an ambient loop, and ADR-027 and §6.4 have ruled on those; a
  time that redrew itself on every rebuild would be worse, because it would be unpredictable
  rather than merely stale.
- **It cannot be seen to be wrong.** A stamp taken at the wrong moment is still a perfectly
  plausible time. Only a test that moves a clock across the save can tell, which is why
  `composer_controller_test.dart` does exactly that — the same argument ADR-021's test made,
  pointing the other way.

**Consequences.** `AmbientCapture` no longer holds a `Clock`; the clock is read where a time is
used. `ComposerController.save` builds the stamp itself. **ADR-026 is merged into this record
and its number retired** — *Discard opens a new chit* is still what happens, but it is now
honesty about a preview rather than the load-bearing correctness fix it was, and a record whose
entire argument has been absorbed is a record that has stopped earning its place (CLAUDE.md
§0.1). ADR-021 is **superseded** rather than retired: it was a real decision that was really
reversed, and the reversal is only legible beside it.

---

## ADR-041 — Permission is asked once, on first run, behind a screen of our own

*16 September 2026. Settles the first of M3's four open decisions.*

**Decision.** A fresh install opens on a **first-run screen** — chit's own, full-screen, shown
once in the life of an install — which explains what is captured and why. **Allow** raises the
system location dialog; **Not now** raises nothing. Either way the screen is never shown again
and the app never asks a second time.

Only **location** is requested. The microphone waits for M5 and is asked for when the microphone
is first tapped.

**Over.** Raising the system dialog on first chit open, on first save, or never proactively —
the three candidates TASKS.md listed. And over asking for every permission the app will ever
want, microphone included, in one pass at launch.

**Why.**

*A bare system prompt asks for a permission without saying what it buys.* The honest answer —
*so that a chit can remember what the weather was* — is not something Android or iOS will say on
our behalf, and the dialog appears over a blank page on a screen the user has not seen yet. A
screen of ours can make the case, and the platform's dialog then arrives as a confirmation of
something already agreed to.

*Asking in context sounds better than it is, here.* The in-context moment would be the first
chit open — which is also the moment README §1 promises costs nothing, and §3.1 promises that
six opens leave nothing behind. A system dialog over the open chit is a cost on exactly the path
that is supposed to be free.

*The microphone is not ambience.* Asking for it at launch means asking for a control this build
does not yet have. That is the kind of request that erodes the trust the screen exists to build,
and it draws store scrutiny for a feature the user cannot reach.

**Costs.**

- **README §1's *opening the app costs nothing* gains an exception**, and the README says so
  rather than quietly meaning something narrower. It is one screen, once.
- **`shared_preferences` becomes a dependency**, and `main()` gains the one `await` before
  `runApp`. It is a local read of two booleans; the database and both services stay lazy behind
  it. Without it the router opens on Today and jumps a frame later.
- **A refusal is a dead end.** There is no settings screen to re-enable from, so the only way
  back is the OS. That is the price of ADR-016's no-nagging rule, and a settings path is owed.
- **The screen is shown before the app is.** A first impression that is not Today.

**Consequences.** `LocationService` gains `requestPermission()` and a
`LocationPermissionOutcome`, so `features` can put a dialog on screen without importing
geolocator. The first-run screen is a **top-level route, not a `ChitRoute`** — that enum is the
list the tab bar is built from, and a third constant in it would be a third tab. The launch
capture of ADR-042 is skipped on a fresh install and primed by **Allow** instead, because
capturing before the screen has explained itself is how a system dialog appears over a blank
page.

---

## ADR-042 — Ambience is captured at launch and at save, and never in between

*16 September 2026. Settles the second of M3's four open decisions — the cache.*

**Decision.** The three best-effort signals are read **twice**: once at launch, fired after the
first frame and never awaited, and again when a chit is **saved**. There is no timer, no
time-to-live, and **no refresh when the app returns to the foreground**.

A save **writes the row immediately** with whatever is held, starts the fresh read beside it,
and **patches the row** when it lands.

**Over.** Capturing on every chit open, which is what M2 did; and a time-to-live or a
resume-triggered refresh, which is what a cache normally means.

**Why.**

*Capturing per chit open was the thing ADR-026 warned about.* Four taps of **Discard** made four
network calls and four location fixes. ADR-026 asked for an implementation "as unbothered by
that as the fakes are" without saying how; this is how. Nothing is asked unless a chit is
actually written.

*The two moments that matter are the two that are kept.* Launch is when the open chit needs
something to draw. Save is when a value is committed to a row that will outlive the session.
Every other moment is a poll, and a poll spends battery and data on a word that nobody has asked
to see.

*Writing first and patching after is the only way to have both.* A fresh read costs up to
ADR-007's two seconds, and ADR-007 forbids putting that in front of the user. Waiting would put
it behind the Save button. Not re-reading would leave a chit written at six in the evening
carrying the weather from nine in the morning. So the row goes out at once and is corrected a
moment later — and because §3.6 draws nothing for a `null`, the correction is usually invisible.

**Costs.**

- **The preview goes stale, without bound.** A phone open all day draws the launch weather on
  the open chit. No chit is ever *recorded* with it, because save re-reads — the staleness is
  confined to the screen, which is the right place for it, but it is real and a user could
  notice a word that is hours out of date.
- **A chit can change in the thread a beat after it appears.** At worst one word arrives or
  swaps. Most chits carry no motion and many carry no weather, so most of the time nothing moves.
- **A second write per save.** One extra `UPDATE` against a local SQLite file, off the path the
  user is on.
- **`updatedAt` does not move when the patch lands**, which is a rule somebody will later
  mistake for a bug. ADR-014 makes `updatedAt` the moment the *text* last changed, and a signal
  arriving two seconds after the insert is not an edit anybody made — OPEN-QUESTIONS.md §8.2's
  re-transcription is the thing that would be misled if it did.

**Consequences.** `AmbientSignals` in `domain/services` holds the reading for the life of the
process and owns the *when*; `AmbientCapture` keeps the *what* and loses its clock and its
`open()`/`settle()` pair. `ChitRepository.updateAmbient` is a separate method from `updateText`
precisely so that the `updatedAt` rule above is expressed in the type rather than remembered. It
**does not throw on an unknown id**: nobody is waiting on it and no screen could report it, so a
row deleted between the write and the patch is an ordinary race.

---

## ADR-043 — The weather mapping: a wind threshold, a trusted flag, and one word missing

*17 September 2026. Settles the last two of M3's four open decisions.*

**Decision.** Four things, which belong together because they are all answers to *what does the
app say when Open-Meteo says X*.

1. **`windy` at 7.0 m/s — 25 km/h.** Beaufort 4: raises dust and loose paper, moves small
   branches.
2. **`domain` speaks metres per second throughout**, and the request pins `wind_speed_unit=ms`
   at the boundary.
3. **Open-Meteo's `is_day` flag is trusted** for the `clear` / `clearNight` boundary, and when
   it is absent a clear sky says **nothing at all**.
4. **Snow maps to `overcast`**, because §3.6 has no word for it.

**Over.** A lower wind threshold; converting km/h somewhere downstream; computing sunrise and
sunset from the coordinate; and mapping snow to `raining`.

**Why.**

*A word that is true every day carries nothing.* A coastal city sits at 15–20 km/h most
afternoons. At a 15 km/h threshold every chit written in Mumbai between March and September
would say `windy`, which is the same failure that keeps `MotionState.stationary` off the screen
— and the ambient stamp only has one slot to spend (ADR-038). 25 km/h is where wind stops being
weather you are in and becomes weather you would mention.

*Two units across two domain files is a conversion somebody eventually forgets.* `MotionLadder`
holds thresholds in m/s and `WmoMapping` now holds one too. Open-Meteo answers in km/h by
default, so the unit is pinned in the query string — at the boundary, once — rather than
converted at a call site that a later milestone might duplicate. 8 km/h is a still day and
8 m/s is a windy one, which is how wrong this goes when it goes wrong, and it is why the test
asserts the query parameter rather than trusting the comment.

*Computing sunrise is a lot of code for one word boundary.* `is_day` arrives in the same
response at no extra cost. A solar-position algorithm would need the coordinate, the date and
correct timezone handling to answer the same question slightly better — and ADR-025 means the
coordinate may be an hour old anyway.

*And when the flag is missing, there is no honest answer.* `clear` and `clearNight` are the same
sky and differ only by that flag. Guessing `clear` at two in the morning is exactly the
confident wrongness ADR-007 prefers to leave blank, so a clear sky with no flag produces no
word. Nothing else needs it: rain is rain at midnight.

*Snow is a real gap and `overcast` is the least wrong of five bad options.* `WeatherCondition`'s
own doc says `raining` is "anything falling", which would include snow — but the word drawn on
the chit would say **raining** while it snowed, and putting a wrong noun in somebody's own
journal is a worse failure than under-describing the sky. `overcast` is at least true: the sky
*is* closed.

**Costs.**

- **The threshold is untuned.** Nobody has watched it fire against a real forecast. It is one
  constant in `domain` with its reasoning beside it, which is the cheapest thing in this
  milestone to change.
- **Snow is under-described**, and for an app whose first users are in India that is cheap —
  until it is not. A sixth word is the real answer and PROGRESS.md carries it.
- **`windy` outranks `overcast`**, which §3.6 did not license: it said only that windy *"wins
  over `clear` and never over `raining`"*. A grey sky is a sky's default state and a windy one
  is not, so the wind is the fact worth the slot — but this is an extension of §3.6 rather than
  a reading of it, and it is recorded here so it is not mistaken for one.
- **On a brand-new install the first capture has no weather**, because ADR-025 reads the *last
  known* fix and there is not one yet. It heals in one capture: the location leg of that same
  capture is what fills the platform's cache, so by the first **save** — the capture that
  actually writes a row (ADR-042) — there is a fix. Accepting a one-capture warm-up is cheaper
  than making weather wait on a fresh precise fix, which is the coupling ADR-025 exists to
  prevent.

**Consequences.** `WmoMapping.from` takes a code, the flag and a wind speed, and every code in
the published table resolves — an unrecognised one is a *stated* `null` rather than a gap. Wind
is read even when the code is not, because it is a measured number rather than a category.
`OpenMeteoService` does transport and parsing and no interpretation.

---

## ADR-044 — The capture budget is twelve seconds, and a stale place beats no place

*17 September 2026. Revises ADR-007's two seconds in the light of ADR-042. Found on a handset:
the weather word appeared and **the pin never did**.*

**Decision.** Two changes, one cause.

1. **`AmbientCapture`'s ceiling goes from 2 seconds to 12**, and the fix inside it from 1.5
   seconds to 10.
2. **`currentFix()` falls back to the last known fix** when a fresh one does not arrive — and
   **drops its kinematics** when it does.

**Over.** Keeping the short budget and accepting that the pin is drawn only outdoors with a warm
GPS; and falling back to the cached fix *with* its speed, which would have been simpler.

**Why.**

*Two seconds was right when something was waiting, and nothing is any more.* ADR-007 sized that
figure when the composer itself drove the capture on every chit open — the number existed to
stop a screen stalling. ADR-042 moved capture to launch and save: at launch it runs from a
post-frame callback and is never awaited, and at save it runs behind a row that has already been
written and is already in the thread. **The ceiling was protecting a wait that no longer
exists**, and the only thing it was still doing was cutting off the fix.

*A high-accuracy fix is a GPS fix, and a GPS fix is not a two-second operation.* Cold, indoors,
or under cloud it takes tens of seconds and sometimes never arrives. The handset that found this
was indoors at half past midnight: the weather word appeared — because ADR-025 reads the
*cached* fix, which is instant — and the pin did not, because the fresh one was still coming
when the timeout fired. Every piece was working; the budget was wrong.

*And a pin that needs a satellite is a pin nobody ever sees.* §3.6 draws the pin to say *a place
was recorded* and nothing else — never a name, never a coordinate, never a map. At that
resolution a fix from a few minutes ago is the same answer, so falling back to it costs nothing
the pin was claiming.

*The kinematics are a different matter, and that asymmetry is the whole of the second decision.*
A stale coordinate is still true. A stale **speed** is not: it would say `traveling` about a
phone sitting on a desk, which is exactly the confident wrongness ADR-037's accuracy gate exists
to prevent. So the fallback recovers the pin and never the motion.

**Costs.**

- **A capture can now run for twelve seconds.** Nothing waits on it, but it is twelve seconds of
  GPS per launch and per save. For a journal whose premise is several chits a day that is a real
  battery cost, accepted because recording *where* is the feature.
- **Motion is still rare indoors**, and now visibly rarer than the pin beside it: a chit can
  carry a pin from the cache with no motion at all. That is honest and it will look like a bug
  to somebody who does not know this record exists.
- **The pin can be minutes stale**, and nothing on screen says so. §3.6 already promised the pin
  says nothing more than *somewhere*, so this narrows what was already narrow — but a chit
  written after a short walk may pin where the walk started.
- **The figures are still untuned.** Ten seconds is a guess informed by how GPS behaves, not a
  measurement, and the first device pass that watches the pin arrive is what should correct it.

**Consequences.** `ARCHITECTURE.md` §4.2's *"2s is the working figure"* is corrected.
`OpenMeteoService.timeout` goes to 5 seconds — a mobile-data figure rather than a wifi one —
and stays well inside the ceiling so a slow network cannot spend the time the location call is
also drawing on. The two legs of a capture still run in parallel and still fail independently
(ADR-025).

---

## ADR-045 — A reading stays good for five minutes

*17 September 2026. Amends ADR-042 after M3's device pass.*

**Decision.** A save re-reads the two services **only when what it is holding is more than five
minutes old**. Inside that window it writes the row from the held reading and asks for nothing
at all — no GPS fix, no network call, and no patch to the row afterwards.

`AmbientReading` grows a `readAt`, and `AmbientSignals` holds a clock for the sole purpose of
stamping it.

**Over.** ADR-042's *captured at launch and at save*, which asked on **every** save. And over a
half-measure that skipped only the row patch while still refreshing for the preview — which
would have saved one local database write and none of the cost that matters.

**Why.**

*A sitting is one moment, and it was being charged for as several.* The premise of the app is
several chits a day, often in a burst. Under ADR-042 five chits written over ten minutes bought
five GPS fixes and five API calls, and produced five readings that were the same reading. The
window is what makes a burst cost one capture.

*Five minutes is set by the place, not by the weather.* Weather barely moves in five minutes and
would tolerate an hour. A *place* can move a long way in five, and the pin is the signal with
the shortest honest shelf life — so it sets the ceiling. Below that it is long enough that a
sitting is one capture; above it a chit written after a short walk would pin where the walk
began.

*And the half-measure would have been the worst of both.* Refreshing anyway, for the preview,
spends exactly what this decision exists to stop spending — the row patch is a local write and
costs nothing. Skipping the capture entirely is the only version that does anything.

**Costs.**

- **A chit can be written from a reading up to five minutes old.** That is the trade, stated
  plainly: the row says where you were when the app last looked, not where you were when you
  pressed Save. At the resolution §3.6 draws a pin, and for five words of weather, they are
  almost always the same answer — but *almost* is doing work in that sentence.
- **Motion is the field this fits worst.** A speed five minutes old is exactly the kind of claim
  ADR-037's accuracy gate was built to refuse, and here it can reach a row. A chit written on a
  train five minutes after the launch capture says `stationary`, because that is what the phone
  was doing on the platform. Untested against a real journey.
- **`AmbientSignals` now holds a clock**, which its own doc used to say it deliberately did not.
  The reason it gave still holds for what it was about — no chit takes its time from here — but
  the sentence was broader than the rule, and a reading has to be able to say how old it is.
- **The window is untuned**, like every other figure in this milestone.

**Consequences.** `AmbientCapture.read()` returns `readAt: null`; stamping is `AmbientSignals`'
job, because it is the thing that knows a reading has been *kept*. The composer's
`_refreshAmbience` runs only on the stale path, and then does two jobs with one capture: it
patches the row and becomes what the next chit previews. The freshness rule itself is an
extension on the record, so it is pure and testable without a container.

---

## ADR-046 — Today's ring sits on paper, not on the tile

*17 September 2026. M4 group D. Closes PROGRESS.md open item 12.*

**Decision.** On the calendar, today's `--seal` ring is drawn **at the tile's edge with a 2px
strip of paper inside it**, and the density wash sits inside that strip. Both edges of the ring
meet `--paper`, whatever density today carries, so the pair that is measured is `--seal` on
`--paper` — 4.56:1 — every day of the month.

**Over.** The ring on the wash, as v6 draws it, which measures 2.61:1 against three chits and
1.88:1 against four or more, under §6.4's 3:1 floor for a non-text component. And over two
token answers: lightening the ring, which the design log's *one accent* rule refuses, and
lightening the top two washes, which would collapse the four steps into three.

**Why.**

*Item 12 said in as many words that it wanted a shape, not a token.* Three chits is an ordinary
day in an app whose premise is several a day, so a ring that fails from three onwards fails on
most days that matter. The ring and the fill are the same lightness family on purpose
(ADR-022); moving either one to rescue the pair breaks a decision that is right.

*§6.4 already asks for this.* **Colour is never the only difference** — `--seal` is *less*
contrasty on paper than `--ink-faint` is, so the accent has never carried hierarchy on contrast
and has always needed a shape beside it. A ring around a wash and a ring around a strip of paper
around a wash are two shapes, and the second is the one that also passes.

*And it reads as a stamp.* A frame with a margin inside it is how a date is marked on paper —
the thing chit is named after. The alternative, an offset ring floating outside the tile, spends
three of the four pixels between tiles on a busy grid and reads as a focus ring.

**Costs.**

- **Today's wash is smaller than every other day's** by six pixels on each axis. On a 44px tile
  that is a visible step down, and a reader could take it for a fainter day. The device pass
  is where that gets judged, and TASKS.md group F asks exactly that question.
- **Two pixels is a figure with no test behind it but arithmetic.** Wide enough to be paper at
  arm's length on the reasoning that the perforation's 1.55px holes were not; whether it reads
  is a handset question.
- **`contrast_test.dart` no longer asserts a failure.** The test that carried item 12 for two
  milestones is rewritten to assert the pair that now matters, and keeps the old numbers as
  the record of why the ring moved.

**Consequences.** `DayTile.todayRingGap` and `DayTile.ringWidth` in
`features/calendar/presentation/widgets/month_grid.dart`, asserted in
`widget_constants_test.dart`. §6.4's paragraph on the ring records the fix. The gap is a
*dimension* in §6.3's sense — a property of one component, off the scale by design — and does
not join the list of four, because it is named where it lives and nothing else reads it.
