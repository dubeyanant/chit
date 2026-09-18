# Architecture decisions

One record per decision that would be expensive to reverse: what was chosen, what it beat, and
why — as a single paragraph, five to ten lines, shorter where possible (CLAUDE.md §0.2). A
change or a supersession edits the record it affects in place, with a clause saying what it used
to say; a wholly new decision gets a new record.

Status of every record below: **accepted**, except ADR-021 which is **superseded** and says so
at its head. Sixty-seven records, not seventy: **ADR-018, ADR-026 and ADR-030 have been merged
away**, their numbers retired rather than reused, and the note below says where each one went.

ADR-001 through ADR-050 were rewritten to this paragraph form on 17 September 2026, in the same
change that shortened the template (ADR-051) — a one-time retroactive pass, the sole exception
to CLAUDE.md §0.3's usual going-forward-only rule, made because the old five-section essay had
become the single largest cost to a working session's context. Nothing any record *decided*
changed; what was cut was the argument's texture — the alternatives weighed, the historical
asides, the multi-paragraph why. Git holds the fuller version, at the commit before this one.

The records are in the order they were written, not in numerical order — ADR-013 and ADR-014
revise ADR-005 and sit beside it. The index is numerical.

| | | |
|---|---|---|
| ADR-001 | Riverpod, with code generation | the only state mechanism |
| ADR-002 | Three layers, and the dependency rule | `features` never imports `data` |
| ADR-003 | Drift over a document store | nearly every screen is an aggregate query |
| ADR-004 | Local-only for v1, with the seams for sync | no backend, no account, client-generated ids |
| ADR-005 | ~~Speech-to-text runs on the device~~ | **removed by ADR-058** — it recognised nothing on a handset, and the feature went with it |
| ADR-006 | A denormalised local day on every chit | what "today" means, decided once at write time |
| ADR-007 | Ambient capture is best-effort and never blocks | a signal that does not arrive is null, and is not drawn |
| ADR-008 | Audio on the filesystem, path in the row | relative paths, always |
| ADR-009 | Fonts bundled, not fetched | the app opens instantly and works offline |
| ADR-010 | Design tokens as a `ThemeExtension`, not constants | why §6 is four classes. Refined by ADR-020 |
| ADR-011 | `go_router` with a persistent tab shell | returning to a tab costs a fade, not a rebuild |
| ADR-012 | An injected clock | three behaviours are functions of the current time |
| ADR-013 | A chit is text, audio, or both | the one-of invariant of §5 |
| ADR-014 | Saved chits are editable, and an edit never moves the moment | **its audio half reversed by ADR-063** — the stamp and the day are what an edit cannot touch |
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
| ADR-047 | The calendar draws only where something was written | quiet weeks at either end collapse; the chevrons skip empty months and vanish with nowhere to go. **Rule 1 narrowed by ADR-048** |
| ADR-048 | Every quiet week collapses, wherever it falls | narrows ADR-047 — a bare row across the middle of a month goes too |
| ADR-049 | The calendar holds its last answer while the next is in flight | a slow month over a blank one; the flicker on every change of month |
| ADR-050 | A day boundary is the tick at now, hanging below the line | the same height and weight; `s1` hid behind a mark written near midnight |
| ADR-051 | New ADRs are short | the template shrinks from here — CLAUDE.md §0.2 |
| ADR-052 | The recorder times a take on the clock and reports a level, not decibels | M5 group A — the file is not opened until playback; the waveform draws a number |
| ADR-053 | ~~The recogniser streams a split transcript~~ | **removed by ADR-058** with the recogniser it describes |
| ADR-054 | A take goes through the repository, and the wave is a window of levels | M5 group C — one door owns the temp file; the wave is twenty levels, **amended in group D from the single level it first held** |
| ADR-055 | The sheet keeps both of v6's controls, and every other way out is a cancel | M5 group D — Discard beside Stop & keep; one path ends the take; a scrim token that is meant to fail |
| ADR-056 | A refusal names the OS | M5 group F — the phone's settings are the only way back. *Its §3.5 half went with ADR-058* |
| ADR-057 | The recording controller is the one screen controller that is kept alive | a take outlives the sheet; auto-disposed it was collected mid-`start` and no sheet ever opened |
| ADR-058 | Transcription is removed, and a chit's words are always typed | the whole feature, not a flag; `textOrigin` goes with it |
| ADR-059 | There are no migrations while there is nothing to migrate | `schemaVersion` pinned at 1; an old install is reinstalled. **Reverses the moment chit holds data somebody would miss** |
| ADR-060 | The open chit's Discard goes; a recording is dropped from its pill | M6 group A — Discard's last unique job was the take, and the take is on the pill. The sheet's Discard stays |
| ADR-061 | A chit in the thread is opened by holding it, and its stamp lifts under a finger | M6 group B — one widget, so Today and the archive gain it together. A tap until the third look, a hold since (ADR-067). No swipe |
| ADR-062 | The editor is a route above the tab shell | M6 group B — one task, one way out; a one-shot read, not a stream; a missing row pops the screen |
| ADR-063 | An edit is one write, a recording can be removed or replaced, and a chit can be deleted | M6 group C — reverses ADR-014's audio half; the invariant is checked before any file moves |
| ADR-064 | The prompt is a slip-style sheet; three acts, three words; delete confirms and has no undo | M6 group D — the first confirmation in the app, and the idiom every later one inherits. The quiet weight always lets go |
| ADR-065 | A take has one owner, chosen at the tap | M6 group E — `RecordingSink`; the composer and the editor both implement it; the microphone moves to `shared/` |
| ADR-066 | No pin, now keeps up with a save, Cancel leaves at once, the editor fills the screen | the owner's first look at M6 — six calls, one record. Narrows ADR-016; reverses group D's Cancel |
| ADR-067 | The recording sits above the words in the editor, a chit is held to open, and a pill that played without lighting | the owner's third look at M6 — two calls and one finding. Changes ADR-061 in place |
| ADR-068 | The caret blinks under reduced motion, and that is a stated limit | closes open item 14 without a fix; §6.4 names the exception |
| ADR-069 | Press feedback is one widget, and the depress is a token | M7 group A — `Pressable`; the tab bar's ripple goes. **Reversed by ADR-070**, which deletes the widget and the tokens |
| ADR-070 | No press feedback; a row's box is always there; the strip arrives by scrolling | the owner's second look at M7 — three calls, and the middle one is why a recording in the thread would not play |

Kept in step by hand, not by a test — CLAUDE.md §4.2: every record above has a row here, and
every row above a record.

### The numbers that are not in the table

**Three records were merged away**, numbers retired rather than reused since roughly two hundred
citations point into this file. **ADR-018** (*`riverpod_lint` through `plugins:`, no
`custom_lint`*) moved to PACKAGES.md's *Considered and not taken*, since it was a fact about how
two packages resolve rather than a decision about how the app is built. **ADR-026** (*Discard
opens a new chit, so it gets a new stamp*) was absorbed into **ADR-040**: ADR-040 stamps at
save, so there is no interval left for a stamp to go stale in, and ADR-026's whole argument no
longer applies. **ADR-030** (*a screen test gets a hand-written repository*) was superseded by
**ADR-031** hours after being accepted, once screen tests themselves came out; the property it
found — real I/O never completes inside a `testWidgets` body — is stated inside ADR-031 instead.

**ADR-021 is superseded rather than merged away.** It was reversed by ADR-040 but kept in place
with a header saying so, since a reversal is only legible beside the thing it reversed. It
predates the edit-in-place rule of CLAUDE.md §0.2, which is why a later reversal edits the
record directly instead of standing beside it.

---

## ADR-001 — Riverpod, with code generation

Riverpod is the only state mechanism in the app, declared with `@riverpod` and generated by
`riverpod_generator`, over hand-written `NotifierProvider`, Bloc, or `ChangeNotifier` +
`provider`. chit's screens are almost entirely derived state — the thread, the timeline, the
calendar density and the month total are four readings of one table that DESIGN-SYSTEM.md §7
requires never disagree — and Riverpod's dependency graph gives that for free: they watch the
same database stream and recompute together. Codegen removes the class of bug where a provider
is declared with the wrong type or family key. Cost: `dart run build_runner watch` in the loop
and generated `*.g.dart` files in the tree, both accepted. Widgets never read a DAO or a
repository directly — ADR-002 is the layer rule that follows from this.

---

## ADR-002 — Three layers, and the dependency rule

`domain` (models, repository and service interfaces) sits under `data` (Drift, files, network)
and `features` (controllers, widgets); `domain` imports from neither, and `features` never
imports `data` — over a flat `lib/models` + `lib/screens`, the usual shape for an app this size.
Two things need the seam: the app is local-only now but will not stay that way (ADR-004), and
the platform services must be replaceable by fakes, since a microphone a test can refuse is the
only way to reach the composer's refusal path at all. *The example this record was written from
was the speech recogniser, which ADR-058 removed.* Cost: more files
per feature, and some interfaces with exactly one implementation for a long time.

---

## ADR-003 — Drift, i.e. relational storage, over a document store

Drift (`drift` + `drift_flutter`) is the local database — one table for chits, audio on the
filesystem with only its path in the row (ADR-008) — over Isar, Hive, raw `sqflite`, or
files-on-disk with a JSON index; the real choice is relational-with-codegen against a document
store, since Drift is a typed layer over SQLite either way. Nearly every screen in BEHAVIOUR.md
§4 is an aggregate query — the calendar tile's density is a count per day, the month summary a
count plus a distinct-day count, the archive a grouped ordered scan — and SQL does that in the
database rather than by pulling every chit into Dart. Drift adds type-safe queries, reactive
streams that make ADR-001 work, and a real migration story. Cost: codegen (already accepted) and
a slightly heavier setup than a key-value store.

---

## ADR-004 — Local-only for v1, with the seams for sync

No backend, no account, no network dependency on the critical path — weather is the only
outbound call and it is optional (ADR-007) — over Firebase or Supabase from the start. A private
journal is fully useful with no server and should accept writing on a train with no signal; auth,
hosting and a privacy posture are real work that buys nothing for BEHAVIOUR.md. Cost: no
multi-device, no backup beyond the OS's own, both accepted and deferred. This obliges every row
to carry a client-generated UUID rather than an autoincrement integer, with `createdAt` /
`updatedAt` set explicitly — retrofitting stable ids onto a synced table later would be the
expensive version of this decision.

---

## ADR-005 — Speech-to-text runs on the device — REMOVED

**Removed by ADR-058.** Recognition ran on the handset with nothing leaving the device —
`speech_to_text` with `SpeechListenOptions(onDevice: true)` — over Google Cloud Speech-to-Text,
because cloud recognition means every recorded thought leaves the device in an app whose whole
premise is a private journal, and needs a credential ADR-004 had already deferred. **The cost
this record stated is what ended it:** on-device models are less accurate, vary by handset and
may not exist at all for some devices or languages, with offline English-Hindi code-switching
expected to be poor. On the first handset it ran on it recognised nothing. The record stays
rather than going, because ADR-013 and ADR-014 cite it and a dangling citation is worse than a
struck-through one.

---

## ADR-006 — A denormalised local day on every chit

Each row stores `createdAt` as UTC milliseconds and `localDay` as a `yyyymmdd` integer computed
in the device's timezone at write time; grouping and calendar queries use `localDay` rather than
deriving a date from `createdAt` at read time. "Today" and "a day in the archive" are
local-calendar facts, and a chit written at 00:20 belongs to that morning forever — deriving the
day at read time would change the answer when the device moves timezone, and no index could
serve the grouped queries the calendar runs on every open. Cost: one redundant column that must
always be written together, in the repository, never a DAO caller.

---

## ADR-007 — Ambient capture is best-effort and never blocks

Time, weather and location are gathered when the open chit is created, in parallel, each under a
short timeout; any signal that does not arrive is null and simply is not drawn, and nothing about
capture can delay the composer, show a spinner, or fail a save. Weather comes from Open-Meteo (no
key, no account) via one pure mapping function from its WMO code, `is_day` and wind speed to
BEHAVIOUR.md §3.6's five words; location comes from `geolocator`, shown only as a pin and never a
name. Why: README §1 promises opening the app costs nothing, and a composer that waits on a
network call breaks that in an app that must work offline. Cost: some chits will carry no
weather, which is correct behaviour, not a gap to fill with a placeholder.

---

## ADR-008 — Audio on the filesystem, path in the row

Recordings are written to `<app documents>/audio/<chit-id>.m4a`, with only the relative path
stored in the database; a recording writes to a temp file, moved into place on Save and deleted
when the take is dropped — over storing audio as a BLOB in SQLite. Multi-megabyte blobs bloat the database file
and slow every backup and migration for no benefit, since only `just_audio` ever needs the bytes;
a relative path matters because iOS's app container path changes between installs, and an
absolute path saved today is dead after the next update. Deleting a chit deletes its file, and a
startup sweep reconciles orphans both ways; a row whose audio has vanished still renders as a
chit, not an error.

---

## ADR-009 — Fonts bundled, not fetched

Newsreader, Hanken Grotesk and Noto Serif Devanagari ship as bundled asset files in the weights
actually used, over the `google_fonts` package's download-and-cache-at-first-run. ADR-004 makes
offline a requirement, and the first paint of a journal should not depend on a network round trip
or fall back to a system serif — the design log treats typography as load-bearing, and a fallback
face is a visibly different app. Cost: a few hundred kilobytes in the bundle, with subsetting
left as our own responsibility.

---

## ADR-010 — Design tokens as a `ThemeExtension`, not constants

DESIGN-SYSTEM.md §6 becomes typed `ThemeExtension`s — `ChitColors`, `ChitType`, `ChitSpace`,
`ChitMotion` — read through `Theme.of(context)`, over a `lib/constants.dart` of top-level `const`
values. The accent has two weights with a rule about which to use (`--seal` for marks,
`--seal-ink` for text), and motion has a reduced-motion behaviour that differs per kind of
animation; both rules are enforceable only if one place knows them. `ChitMotion.travel()` /
`fade()` (refined by ADR-020) collapse to zero or re-time to 140/220ms under
`MediaQuery.disableAnimations`, which is the design log's actual rule and not what a global
duration-to-zero would give. Cost: more ceremony than a constants file for the first few widgets.

---

## ADR-011 — `go_router` with a persistent tab shell

`go_router` with a `StatefulShellRoute` holds the two tabs, so each keeps its own navigation
stack and scroll position — over a plain `IndexedStack` with a `Navigator` per tab, or Navigator
1.0. DESIGN-SYSTEM.md §6.3 requires that returning to a tab cost a 200ms fade and nothing more,
since Today is opened many times a day and a re-run entrance would turn that into waiting; a
shell route with kept state gives that, rebuilding on switch does not. The recording sheet stays
a modal sheet rather than a route, since it belongs to the composer's state machine and
dismissing it is not a back navigation. Cost: overkill for two tabs today, until the first detail
screen (§8.1) arrives.

---

## ADR-012 — An injected clock

Nothing calls `DateTime.now()`; a `Clock` from `domain` is provided by Riverpod and overridden in
tests. Three specified behaviours are functions of the current time and untestable otherwise —
what counts as today (§4.1), where a mark falls on the timeline, and the five-second prompt
(§3.3) — and a fake clock turns the midnight rollover into something tested rather than
discovered. Cost: one indirection, everywhere.

---

## ADR-013 — A chit is text, audio, or both

`text` and `audioPath` are independently nullable with at least one present — over an exclusive
`source: typed | spoken`, because the guarantee belongs to the audio (never editable, never
removable, always playable) rather than to the words, which stay the user's. **The provenance
half of this record is gone** (ADR-058): it also carried a `textOrigin` column recording
`typed | transcript | transcriptEdited`, whose whole purpose was to say whether words came from
the recogniser, and there is no recogniser. What survives is the shape: three legal rows rather
than four, and an invariant the database can only partly express.

---

## ADR-014 — Saved chits are editable, and an edit never moves the moment

`ChitRepository` gains an update path for `text` — *and for `textOrigin` until ADR-058 removed
it*. There is no principled reason text stops being the user's the moment it is saved: a typo
found the next morning is the same typo. **The second half of this record is reversed by
ADR-063.** *It said the audio was neither editable nor removable — text is what the chit says
and belongs to the user, audio is what was said and belongs to the moment, so a chit could gain
text but never lose a recording and deleting the whole chit was the only way to remove one.*
The owner asked for the recording to be as editable as the words, and it is; what survives of
the argument is the half about the moment: `createdAt`, `localDay` and the ambient fields are
not parameters of any edit. Whether the editor is inline or its own screen was left to
OPEN-QUESTIONS.md §8.1, settled by ADR-017. `updatedAt` stops being written once and forgotten
and moves on any edit; the archive's ordering stays on `createdAt`, since editing does not move
a chit from the moment it was written.

---

## ADR-015 — Variable fonts, and weight through `fontVariations`

The three faces of DESIGN-SYSTEM.md §6.2 ship as variable fonts, one file per family, with every
`TextStyle` in `chit_type.dart` setting `fontVariations` alongside `fontWeight` — over static
instances at a handful of weights. The prototype uses weights (300, 600) a short static list
would have missed silently, and relies on optical sizing across a wide display-to-body ratio,
which only a variable font's `opsz` axis reproduces; Google's canonical font repository also
ships these families only as variable fonts. The real cost: a variable font declared once renders
at weight 400 regardless of `fontWeight` alone — it is silently ignored — so every style must set
both, and a style that forgets is a wrong-looking screen analysis will not catch. Survivable only
because ADR-010 already confines all `TextStyle`s to one file. Also costs ~1.8MB of fonts (758KB
for Noto Serif Devanagari alone); subsetting is deferred.

---

## ADR-016 — Precise location first, coarse as the fallback

Location is requested at high accuracy, with a coarse fix accepted when that is all the user
grants (Android 12+ / iOS 14+); either outcome is a successful capture — over coarse-only at low
accuracy, which earlier docs specified. OPEN-QUESTIONS.md §9 wants coarse place labels ("home",
"office") inferred from the fix, and a neighbourhood-level coarse fix cannot separate them —
asking for precision only later would mean a year of chits that can never carry the label. This
stores a sharper fact than BEHAVIOUR.md §3.6 displays (nothing at all since ADR-066; a pin, never a name, until then),
a real tension: the row is precise enough to reconstruct a home address. Accepted because the
database never leaves the device (ADR-004), capture stays best-effort so a refusal costs nothing
(ADR-007), and a user who grants only approximate location gets the old behaviour exactly. Cost:
a precise fix is slower and hungrier, absorbed by ADR-007's timeout; a future sync layer would
need to treat this row as more sensitive.

---

## ADR-017 — The chit editor is a screen, and leaving it asks

OPEN-QUESTIONS.md §8.1 is settled: a saved chit opens in its own screen, not inline in the thread
— over inline editing. Leaving with unsaved changes raises a clear prompt (keep or discard);
quitting outright cancels the edit. *It also said the chit's audio stayed neither editable nor
removable anywhere; ADR-063 reversed that with ADR-014.* The thread is a reading surface, and a
second editable field among its rows
would make it ambiguous which one a tap targets; a screen has room for the stamp, the pill and
the text without the row growing, and somewhere for the save prompt to live. The prompt exists
because discarding an edit throws away a change to something real, unlike discarding a
still-unsaved open chit. This unblocks the thread's tap affordance and becomes M6, after voice
and before polish, so the editor handles a chit that already has an audio pill from day one.

---

## ADR-019 — Android and iOS only; the web folder stays

`windows/`, `linux/` and `macos/` are deleted from the repository; `web/` stays, untouched. The
app is a phone app — a microphone that is an equal to the keyboard, ambient weather and location,
and a recording kept on the device are all phone capabilities — and three desktop scaffolds nobody builds only go
stale and invite a plugin to be chosen for desktop support it doesn't need. `web/` survives
because README §10 actually plans responsive web later, and deleting it now would only mean
regenerating it. Cost: restoring a desktop target later means `flutter create --platforms=...`
and reapplying config — cheap, and unlikely to happen.

---

## ADR-020 — Reducing motion never makes a fade slower

Under reduced motion a fade re-times to ADR-010's targets (220ms arrival, 140ms otherwise) unless
it was already quicker, in which case it keeps its own pace — in practice this only affects 90ms
press feedback, which stays at 90ms rather than stretching to 140ms — over ADR-010 as first
written, which set every non-arrival fade to 140ms flat. Press is not a transition; it is the
only acknowledgement a phone gives a finger (DESIGN-SYSTEM.md §6.4), and stretching it makes a
button feel slower to the people who asked for less animation, not less responsiveness — reducing
motion should cost animation, not confirmation that the action landed. Found by
`chit_motion_test.dart` asserting the property "no fade is slower than it was," which failed on
first run: the original rule was self-consistent and wrong. Cost: one more clause — a `min` — in
an otherwise simple rule.

---

## ADR-021 — A chit is stamped when it is opened, not when it is saved

> **Superseded by ADR-040 on 16 September 2026**, which reverses it: a chit is now stamped when
> it is **saved**. Kept because a reversal is only legible beside the thing it reversed, and this
> record predates the edit-in-place ADR rule (CLAUDE.md §0.2), which is why a later reversal would
> edit the record directly instead of standing beside it.

`createdAt` was the moment the open chit was created — the same instant the ambient stamp was
captured — with `ChitRepository.save()` taking that stamp's `capturedAt`, over timestamping at
Save with the stamp treated as a separate display value. The reasoning was that README §2's
stamp is one observation of one moment, and a chit belongs to the moment that hit you, not the
moment you finished typing it. Cost: a chit written over a long pause carried a time slightly
before the words existed, with no record of when Save was pressed — the gap ADR-026 then had to
patch around, and which ADR-040 ultimately closed by stamping at save instead.

---

## ADR-022 — The seal means now; a record is ink

`--seal` marks what is live and nothing else — the ring at now, the caret, the record dot,
today's calendar ring, the audio pill while playing; everything else that is a record rather than
a happening is ink — over v5's rule, which gave the accent to anything that mattered, which on a
working screen is everything. Three concrete failures drove it: a thread with recordings ran
orange down its side, a busy calendar month was a field of orange swallowing today's ring, and
Save became the loudest thing on screen the instant a word was typed, reading as unequal to the
microphone (BEHAVIOUR.md §3.2 makes them equals). Reserving the colour for *now* gives it one
meaning everywhere, and lets calendar density live entirely in ink, removing the near-white
numeral colour that only existed to survive the old fill. Cost: ink washes carry less force than
a saturated fill, so calendar density reads quieter — accepted, since the month summary states
the number in words. A new floor failure came with it, today's ring against a dense tile, later
fixed by ADR-046.

---

## ADR-023 — The field is live, but it does not take focus

Today opens with the field ready but unfocused; the keyboard appears only on tap — over
`autofocus: true`, the literal reading of BEHAVIOUR.md §3.2. Taken literally, that sentence costs
the whole screen: a keyboard raised on every launch covers the thread and timeline, and reading
back this morning's chits is at least as common a reason to open a journal as writing a new one.
What §3.2 actually protects — there is no mode, no Write button, no step before writing — stays
intact; one tap replaces zero. The five-second prompt (§3.3) still starts when the chit opens,
not when the field is focused, since it is an offer to someone looking at the screen. Cost:
writing a chit costs one tap it didn't strictly have to, accepted, and reversible in one line if
wrong.

---

## ADR-024 — The day arc becomes the timeline: three days, full days, scrollable

The horizontal strip under the date becomes the timeline: midnight to midnight rather than
5am–midnight, spanning today and the two days before it, scrolling and resting at now, with each
chit's mark at its actual time rather than in evenly spaced dots — over the v5/v6 day arc (one
day, 5am–midnight, fixed width, no scroll). The old window dropped real chits: a chit at 00:20
belongs to that morning (ADR-006) but the arc clamped it to the same pixel as one at 5:00, which
is a chit the arc lied about, not a simplification. One day is also a snapshot, not the rhythm
README §1 wants; three days is the smallest window where yesterday-versus-today means anything
without becoming a second calendar (§4.2 already is one). Costs: the home screen is no longer
purely about today, the thread and timeline no longer share one query, a horizontal scroller sits
inside a vertical page, and the prototype no longer shows the built target. How days are
delineated was left open — later answered by ADR-050.

---

## ADR-025 — The weather service takes no position

`WeatherService.currentCondition()` takes no arguments; where an implementation sources a
position is its own business past the `domain` boundary — M3's implementation uses the device's
last known (cached, instant) fix — over the obvious `conditionAt(lat, lon)`. That shape would
make weather wait on the (slow, precise, ADR-016) fix, defeating ADR-007's parallel capture, and
would couple the two failures — a refused location would silently cost weather too, rather than
only the pin. `domain` also shouldn't know weather happens to be looked up by coordinates, a
detail ADR-004's local-first design might later replace. Costs: the condition can be for where
you were rather than where you are, and weather is null on a device that has never taken a fix —
both ordinary ADR-007 outcomes.

---

## ADR-027 — An ambient loop is not a pace

`ChitMotion` gets `loop(Duration period)` beside `travel()` / `fade()`; the period belongs to the
looping component itself (the caret's 1.15s, like its 1.5px width), and `ChitMotion`'s only job
is applying §6.4's reduced-motion rule to it — `Duration.zero`, no ticker at all — over adding a
`ChitPace.blink` to the existing pace table. A loop's period and a transition's pace are
different quantities that a single table would invite comparing, and the app already had: §6.3
calls the idle prompt "700ms, deliberately slower than everything else," which a table containing
a 1.15s blink would falsify. This extends §6.3's existing allowance for a dimension to sit off
the scale when it's named on the one component it belongs to. Cost: two shapes on one class
(`travel`/`fade` take a `ChitPace`, `loop` takes a raw `Duration`), and nothing yet enumerates the
loops together.

---

## ADR-028 — The caret is the platform's, and chit draws none

The open chit draws no caret of its own; the page opens blank and still, and tapping the field
surfaces the framework's own blinking caret — over the prototype's drawn `--seal` caret, which M2
group F ported faithfully. An app that is animating when you open it is asking for something, and
BEHAVIOUR.md §3.1 / README §1 promise a page that costs nothing and leaves nothing behind — a
blinking bar on an untouched page contradicts that, even though a prototype can get away with it.
The page isn't actually short of signals either: the five-second prompt (§3.3) and the slip's own
tear edge and stamp already read as something to write on. Cost: nothing at all animates for the
first five seconds, which is the design's own premise taken literally; §6.4's caret-blink rule
now has nothing in this app it can reach, since Flutter offers no way to steady the framework's
own caret.

---

## ADR-029 — The prompt reads the stamp

The five-second prompt's words are chosen from the ambient stamp the chit already holds — the
hour it opened, and the weather if it arrived — via `domain/prompts.dart`, a book of twenty-eight
short questions where the most specific match wins, over the single fixed line §3.3 first named
(still the fallback). The stamp is already captured and on screen, and README §1 says the moment
matters as much as the words — a prompt that ignores it asks something generic in front of a line
that just said `3:42 pm raining`. Twenty-eight lines also keeps the app's one line that speaks
first from becoming furniture by the fiftieth chit. Every prompt must stay a question, never
excited, never longer than the field's own line — tested in `prompts_test.dart` since copy fails
quietly. Cost: the prompt can be wrong about weather on a stale fix (ADR-025), and it is more
copy to keep in one voice.

---

## ADR-031 — No widget tests

chit has no widget tests: nothing under `test/` calls `testWidgets`, `pumpWidget` or
`WidgetTester`, enforced by `test/docs/no_widget_tests_test.dart` — the eight suites and three
support files that did were deleted, absorbing ADR-030's finding that real I/O never completes
inside a `testWidgets` body (Drift, even `Directory.systemTemp.createTemp()`), which forced a
second, drift-prone fake implementation behind every screen test. They also failed for framework
reasons unrelated to the app, and asserted tree structure rather than the actual visual claim
goldens would need to check — while every real visual defect so far was found on a device anyway.
What is tested instead: repository/DAO against `NativeDatabase.memory()`, models at the
invariant, pure functions, controllers through a bare `ProviderContainer`, and the design-system
floors as arithmetic — a constraint on where behaviour lives, not just on the test folder. Cost,
stated plainly: 251 tests became 164 then 171, and real coverage was lost — the field-focus rule
(ADR-023) and the opened-vs-saved stamp timing (ADR-021) now have no automated guard, only
PROGRESS.md's device checklist.

---

## ADR-032 — One day is one screen, and now rests in the middle of it

The timeline's content is three viewport widths, so one day occupies exactly one screen and
scrolling back a screen scrolls back a day; the resting offset centres now in the viewport, then
clamps to the strip's ends — over a fixed pixels-per-hour window, or simply resting at
`maxScrollExtent`. One day per screen makes the unlabelled day-boundary marks (§4.1) legible
without a label, arriving at the viewport edge exactly where a reader expects a day to end, and
makes the resting position computable rather than chosen. Centring beats resting-at-the-end in
the small hours specifically: at 00:20, resting at the end would pin now against the left edge
with yesterday's chits just off-screen, while centring shows yesterday evening beside this
morning — exactly the five hours ADR-006 protects. Cost: a day isn't a fixed size, and the
still-unwritten rest of today draws as empty space, both accepted as the price of a rhythm signal
rather than a chart.

---

## ADR-033 — Today re-reads the clock at midnight

`todayProvider` schedules a timer for the next local midnight and invalidates itself when it
fires, rolling the date line, the thread's `localDay` grouping and the timeline's window over
together — over leaving it, which is what M2 shipped. A journal is an app left open, and a phone
picked up at 00:05 after being left at 23:50 would otherwise keep showing yesterday's date over
yesterday's thread; worse, with the timeline's three-day window ending at the day it was built
for, the first chit of the new day would save outside its own drawn window and get no mark at
all. It belongs in `todayProvider` rather than the timeline because the date, thread and strip
all read one provider precisely so they agree — including about when to stop agreeing it's
yesterday. Cost: one pending timer per build of the provider, cancelled on dispose; it fires on
the wall clock rather than the injected one, so a device left open across midnight is a manual
check, not an automated one.

---

## ADR-034 — A day passing is a haptic

Scrolling the timeline past a day boundary under the reader's thumb fires one
`HapticFeedback.selectionClick()`, keyed to the day at the middle of the viewport — over no
feedback at all, or a haptic per chit mark. The boundaries are deliberately hard to read (§4.1:
"there to be noticed, not read"), which leaves no other way to tell a reader they've scrolled
from today into yesterday; a haptic says it in a channel that costs no ink, label or space, the
same way a picker buzzes at a detent. Keyed to the boundary rather than every mark, since a day
with a dozen chits would turn scrolling into a rattle. Costs: haptics are a sensory channel new to
the app, it only reaches a reader who scrolls, and a programmatic scroll-to-now after a save must
stay silent — `_settling` is the flag that keeps the app from buzzing about its own movement.

---

## ADR-035 — Days with nothing in them are not drawn

The timeline's query is always three days, but leading days with nothing written in them are not
drawn — the strip begins at the oldest chit's day and, with nothing in the window, shows today
alone and does not scroll; a quiet day *between* two written days is still drawn in full — over
always drawing three days, which is what ADR-024 said and what shipped an hour earlier. A
two-day-old install scrolled to the back-stop showed a bare, unlabelled line — worse than absent,
since a reader can't tell empty from broken — and a fresh install offered two days of nothing to
scroll through. Trimming only the leading days keeps ADR-024's actual point (yesterday's quiet
next to today's activity is visible at a glance) while dropping the case where there's no older
context for the quiet to read against. Cost: the strip's width now grows as the app is used
rather than being fixed, and BEHAVIOUR.md §4.1 now carries this as a narrowing of ADR-024.

---

## ADR-036 — Now is a tick, not a dot

Now is a short vertical `--seal` tick straddling the line (1.5×12px) — no ring, no disc, no pulse
— over two built-and-viewed alternatives: v6's outline ring, then a filled disc. The outline
failed on arithmetic — a chit saved at the current time was meant to sit *inside* an 11px ring,
which at that size reads as two accidental overlapping shapes rather than one marker. The filled
disc fixed that and became the loudest thing on the screen, "taking too much attention" on the
owner's own words, in an app whose open screen is supposed to read as blank and ready. A tick
puts now in the same visual family as the day-boundary mark below it (ADR-050), letting colour
alone carry the difference in meaning — exactly ADR-022's argument that `--seal` marks what's
live without needing size too. Cost: three built attempts for one 12px object, and
`ChitMotion.loop` again has no caller (until M5's record dot) since the pulse is gone.

---

## ADR-037 — Motion is read off the position fix, not off a motion sensor

`MotionState` (`stationary`/`walking`/`traveling`/`flying`) is derived from the speed already on
the position fix BEHAVIOUR.md §3.6's pin needs — `GeoFix` gains `speed`, `speedAccuracy` and
`altitude`, run through `domain/motion/motion_ladder.dart` — adding a third ambient signal with
no new package, permission or dialog, over reading the accelerometer/gyroscope directly, or
platform activity-recognition APIs. Neither an accelerometer nor gyroscope can measure speed
(only GPS Doppler can, and a fix is already being taken); the activity-recognition APIs would
need a second permission dialog against README §1's promise, pull in Google Play Services, and
still have no flying class. The ladder: 0.7 and 3.0 m/s divide the first three states, 55 m/s
with altitude above 2000m is flying; an uncertain reading degrades to `stationary`, so noise can
slow a chit down but never put a plane on one. Costs: no fix means no motion at all, a stopped
car reads `stationary` correctly but counterintuitively, `flying` will rarely fire since GPS is
usually off in airplane mode, and there is deliberately no `running` or `cycling` — speed alone
can't tell a cyclist from traffic at the same speed.

---

## ADR-038 — The stamp carries one ambient fact, ranked

The ambient stamp shows the time, one ambient fact and the pin — weather and motion share a
single slot, ranked by `domain/ambient/ambient_fact.dart`: flying, travelling, raining, windy,
walking, overcast, clear, clear night, with `stationary` stored and never drawn — over giving
motion its own slot beside the weather word. §3.6's spacing argument (three items at 11.5px is
already five things to read) is a ceiling, not a preference, and a fourth item breaks it; the two
facts are usually alternatives anyway — inside a vehicle the sky outside isn't what you're in. A
chit written at a desk in the rain is unchanged by this, exactly as M2 shipped it, since an icon
only ever displaces a word when the phone was actually moving. Cost: something true goes unshown,
and the ranking itself is a judgement call, tested as a full cross product rather than as
examples.

---

## ADR-039 — Motion is an icon where weather is a word, and it is drawn in the thread

A motion state draws as an icon, a condition stays a word, and — unlike the pin — the icon is
drawn under saved chits in the thread too, over giving motion its own words (`in transit`) and
keeping it, like the pin, to the open chit only. Every English phrase for motion reads like a
fitness tracker, where a condition is genuinely a feeling; and the pin's own reasoning about the
thread reverses for motion — every chit has a location so a pin on all of them says nothing, but
almost no chit has a motion, so the rare mark on a train ride stands out. The icon takes the
row's own ink weight (muted on the open chit, faint in the thread) since it's standing in for the
word it displaced, not adorning the row like the pin. Cost: an icon is guessed at where a word is
read, with no legend anywhere in the app, and the thread gains visual density for the first time
since M2.

---

## ADR-040 — A chit is stamped when it is saved

The clock is read when Save is pressed, and that reading becomes `createdAt` and `localDay`; the
stamp on the open chit is only a preview of what will be recorded — reverses ADR-021 (stamped at
open) and absorbs ADR-026, whose number is retired. ADR-021 created a real failure — a chit
opened at 23:58 and saved at 00:05 filed on the wrong day — that ADR-026 could only patch around
for one of its two paths; stamping at save removes the whole class, since there's no interval left
for the stamp to go stale in. It also matches ADR-042, which re-reads weather and location at
save anyway — building the row from a stale time would be the odd one out. Cost: the slip's
preview time can now visibly disagree with the record if a chit is sat on for a while, and it
doesn't tick, so it drifts further the longer it's open — invisible to anything but a test that
moves a clock across the save, which `composer_controller_test.dart` now does.

---

## ADR-041 — Permission is asked once, on first run, behind a screen of our own

A fresh install opens on chit's own full-screen explanation, shown once ever, before asking for
location — Allow raises the system dialog, Not now raises nothing, and the screen never reappears
— over raising the system dialog at first chit open or first save, or asking for every permission
at once. A bare system prompt can't say what it buys; this screen makes the honest case ("so a
chit can remember what the weather was") before the platform dialog arrives as confirmation of
something already agreed to. Asking in-context at the first chit open would put a system dialog
on exactly the path README §1 and §3.1 promise costs nothing; asking for the microphone here
would be asking for a control M3's build doesn't yet have. Costs: README §1's "costs nothing"
gains its one stated exception, `shared_preferences` becomes a dependency, and a refusal is a
dead end with no settings screen to reconsider from.

---

## ADR-042 — Ambience is captured at launch and at save, and never in between

The three best-effort signals are read twice only — once at launch (fired after the first frame,
never awaited) and again at save — with no timer, no time-to-live and no refresh on foreground
return; a save writes the row immediately with whatever is held, then patches it when a fresh
read lands, over capturing on every chit open (M2's behaviour, which made four taps of Discard
cost four network calls and four fixes). Launch is when the open chit needs something to draw,
and save is when a value gets committed to a row that outlives the session — every other moment
is a poll that spends battery for a word nobody asked to see. Writing first and patching after is
the only way to have both an instant save and a fresh signal, since ADR-007 forbids putting the
read's latency in front of the user. Costs: the open-chit preview can go stale without bound, a
chit can visibly change a beat after it's saved, and there's a second local write per save —
`updatedAt` deliberately does not move when the patch lands, since ADR-014 reserves it for edits
to the text.

---

## ADR-043 — The weather mapping: a wind threshold, a trusted flag, and one word missing

Four related answers to "what does the app say when Open-Meteo says X": `windy` triggers at
7.0 m/s / 25 km/h (Beaufort 4 — wind you'd mention, not just wind you're in); `domain` speaks m/s
throughout, with `wind_speed_unit=ms` pinned in the request rather than converted downstream;
Open-Meteo's `is_day` flag is trusted for `clear`/`clearNight`, and a clear sky with no flag says
nothing rather than guessing; snow maps to `overcast`, since §3.6 has no word for it and
`raining` would be a wrong noun in somebody's own journal. 25 km/h was chosen because a lower
threshold would make `windy` fire on most Mumbai afternoons, the same always-true failure the app
already refuses for `stationary`; the unit is pinned at the API boundary because 8 km/h and 8 m/s
are opposite verdicts. Costs: the threshold and snow's under-description are both
untuned/incomplete, `windy` now outranks `overcast` in an extension beyond what §3.6 literally
licensed, and a brand-new install's first capture has no weather until the first save warms the
location cache (ADR-025).

---

## ADR-044 — The capture budget is twelve seconds, and a stale place beats no place

`AmbientCapture`'s ceiling rises from 2 seconds to 12 (the fix inside from 1.5 to 10), and
`currentFix()` falls back to the last known fix — dropping its kinematics — when a fresh one
doesn't arrive in time, revising ADR-007's original 2s budget. That figure was sized when the
composer itself waited on capture; ADR-042 moved capture to launch (unawaited) and save (behind
an already-written row), so the ceiling was only cutting off the fix rather than protecting a
wait — found on a handset where the weather word appeared (from a cached fix, ADR-025) but the
pin never did, because ten seconds wasn't enough for GPS indoors near midnight. A pin at
chit-stamp resolution tolerates a fix minutes old, so falling back to the cache costs nothing —
but a stale speed would falsely claim `traveling` about a desk, so the fallback recovers the pin
and never the motion. Cost: up to twelve seconds of GPS per launch and save, a real battery cost
accepted because location is the feature; the figures remain untuned guesses.

---

## ADR-045 — A reading stays good for five minutes

A save re-reads the two services only when the held reading is more than five minutes old; inside
that window it writes from what's held and asks for nothing at all — amends ADR-042's every-save
re-read. The app's premise is several chits in a burst, and under the old rule five chits over ten
minutes bought five GPS fixes and five identical readings; five minutes is set by the pin, the
shortest-lived of the three signals, since weather would tolerate an hour but a place can move
meaningfully in five. A half-measure that kept refreshing for the preview while skipping only the
row patch was considered and rejected, since the local database write was never the expensive
part. Costs: a chit can now be written from a reading up to five minutes stale, which fits motion
worst of all — a chit written on a train five minutes after a desk-side launch capture will
honestly say `stationary` — and `AmbientSignals` now holds a clock solely to stamp `readAt`.

---

## ADR-046 — Today's ring sits on paper, not on the tile

Today's `--seal` calendar ring is drawn at the tile's edge with a 2px strip of paper between it
and the density wash, so the measured pair is always `--seal` on `--paper` (4.56:1) rather than
`--seal` on a density fill, which failed §6.4's 3:1 floor from three chits onward — over
lightening the ring (which the design log's one-accent rule refuses) or lightening the top two
density steps (which would collapse the four-step scale to three). §6.4 already requires colour
never be the only difference, and a ring around a strip of paper around a wash is simply the
shape that also passes contrast, while still reading as a stamp — a frame with a margin, the way
a date is marked on paper. Cost: today's wash is visibly smaller than every other day's by six
pixels a side, a tradeoff `contrast_test.dart` now asserts the new pair for.

---

## ADR-047 — The calendar draws only where something was written: quiet weeks at either end collapse, and the chevrons skip empty months

Two rules from one first device pass: a month's grid runs only from its first written week to its
last (a week counts if a day in it was written in, or is today; a quiet week *between* two
written ones still draws), and a chevron only ever lands on a month with something in it, with no
chevron drawn where there's nowhere to go — over drawing the full month from its first week to
today, and one calendar-month-per-chevron with the next one merely disabled. A fresh install
showed two empty rows above the 17th, and the previous chevron landed on an August that was a
bare grid with a dead chevron beside it — the same "days that haven't happened read as days with
nothing written" reasoning the current month already follows, extended to weeks and months in the
past that never will be written in. This mirrors ADR-035's rule for the timeline, and follows
§6.4's refusal of a control with nowhere to go. Costs: the grid's height now changes as the
reader navigates, and a month's shape is no longer comparable across months at a glance. Rule 1
was narrowed further by ADR-048.

---

## ADR-048 — Every quiet week collapses, wherever it falls

A month's grid now draws only weeks with something in them, full stop — a quiet week collapses
whether it's at either end or between two written weeks — narrowing ADR-047's rule 1, which had
deliberately kept a quiet *middle* week drawn. It was asked for on the next look: a seeded August
with writes on the 7th, 13th and 28th left a bare row across the middle, and the owner's plain
instruction was to collapse it too — the objection ADR-047 raised doesn't survive once the day
numbers are printed on the tiles, since a reader isn't counting rows to know a fortnight passed.
The timeline keeps its own different exception (ADR-035 still draws a quiet day between two
written ones), deliberately, since a day is a proportion of time and a week on the grid is just a
row. Cost: a month is no longer a calendar shape at all — two rows might be a fortnight or four
empty months — accepted as the calendar being the shape of what was written, not a grid to scan.

---

## ADR-049 — The calendar holds its last answer while the next is in flight

The month grid and the archive both draw the last answer their query gave, held via
`Notifier.stateOrNull` until the next one arrives (null only before the very first answer) — over
drawing null while any query is in flight, which read as a flicker on a handset: the bar, grid
and summary vanished for the frames Drift took to answer on every month change or tile tap, then
jumped back. This is ADR-007's rule read to its end: an empty state drawn while the real answer
is in flight is a wrong answer, not a slow one, and September's grid under September's name stays
true while August loads — merely late. The bar takes its name from the drawn shape rather than
the requested month, specifically so the name and grid never disagree. Cost: a stale frame is
possible by design, and the two providers are no longer pure functions of only their inputs —
they're functions of their inputs and their own last output too, which ARCHITECTURE.md §3 now
says.

---

## ADR-050 — A day boundary is the tick at now, hanging below the line

The mark where one day ends and the next begins is now drawn at now's own height and weight —
`s3` tall, 1.5px wide, hanging below the line rather than straddling it, in `--ink-faint` — over
the 4px mark (1px × `s1`) that had hung there since ADR-024. At 4px it hid behind an actual chit
mark: a chit written near midnight (which the seeder places at 23:55 on purpose) covered all but
half a pixel of the boundary, so the signal failed exactly when a day was full. Growing it to
now's own tick shape keeps the vocabulary to one shape in two positions (through the line in
accent for what's happening, under it in ink for where a day ended), with colour and side as the
only difference, per ADR-036. Cost: the strip is six pixels taller to keep the required clearance
under the marks, and §4.1's description of the mark as "small" is no longer accurate and is
corrected.

---

## ADR-051 — New ADRs are short

From this record on, and now retroactively applied to ADR-001 through ADR-050 in the same
change, an ADR is a single paragraph, five to ten lines — the decision, what it beat, the reason
or two that mattered, and a cost if one is load-bearing — not the five-headed essay ADR-001
through ADR-050 first used, and not even the labelled Decision/Over/Why/Costs mini-sections this
record itself first tried. CLAUDE.md §0.2 has the exact rule. Several small, related calls from
one session may still share one ADR. A change or a supersession edits the record it affects in
place, with a clause here saying what it used to say, rather than adding a new record beside an
untouched old one — git is the archive for the rest. Cost: a short paragraph says less about
alternatives considered, and DECISIONS.md is no longer the place to reconstruct *how* a decision
was reached, only what was decided and the load-bearing why — that reconstruction now depends on
git history for anything a paragraph dropped.

---

## ADR-052 — The recorder times a take on the clock and reports a level, not decibels

`AudioRecorder.stop()` returns a `Recording` whose length is the injected clock's difference
between start and stop, over reading the duration back from the file with `just_audio` — a
decoder opened on the save path for one integer, when the file is not otherwise touched until
playback, and a second thing that could fail between Stop & keep and the row. The same object
carries the temp path, so `ComposerState`'s `audioTempPath` and `audioDuration` cannot be set
apart. `levels` is a stream of 0-to-1, linear in decibels from a -60 dBFS floor to full scale,
over passing the plugin's dBFS through — the waveform draws a number, and the scale it came off
is the data layer's business, the way a speed's meaning is the ladder's and not geolocator's
(ADR-037). Like every service in `domain`, it never throws: a refusal, a plugin failure and an
empty take are `false` or `null`, because the sheet has one answer to all three. Cost: a
length measured on the clock can be a few frames longer than the audio; the pill's figure is
in whole seconds and does not show it.

---

## ADR-053 — The recogniser streams a split transcript — REMOVED

**Removed by ADR-058, with the recogniser it describes.** It settled three things about
`SpeechRecognizer`: the stream carried committed words and the one still being revised, so
§3.4's lighter-ink word was a property of the data rather than a guess in the widget; there was
**no error-code table**, because Android marks every error permanent and stops listening as it
reports one, so any error simply closed the stream; and `stop()` waited up to 900 ms for the
last word, the one place in the app that ever waited on a signal. Git holds the code. The record
stays because ADR-054 and ADR-055 cite it.

---

## ADR-054 — A take goes through the repository, and the wave is a window of levels

**The temp file is deleted through `ChitRepository.discardTemp`** — *by Discard when this was
written, and since ADR-060 by the sheet's Discard and by Remove on the open chit's pill* — over
a method on
`AudioRecorder` or a direct call to `AudioStore`: `features` cannot reach `data` at all
(ARCHITECTURE.md §1), and `save` already takes a temp path *in*, so one door owns the file's
whole lifetime instead of two. `RecordingState` holds **the last twenty levels, one per bar of
the live wave** — *this originally kept a single number, on the reading that v6's wave is twenty
fixed bars each bobbing on its own loop; group D drew the bars from the microphone instead, so
the wave is the shape of what was just said rather than one loudness split twenty ways.* At the
recorder's 80 ms sampling that window is the last 1.6 seconds. It is data and not an ambient
loop, so nothing about it takes a period from `ChitMotion.loop`; under reduced motion it draws
v6's fixed heights at rest and ignores the microphone, because a wave that moves with a voice is
still a wave that moves. Cost: the audio pill's wave is **not** this — it is v6's fixed shape on
every pill, because the envelope of a saved recording would mean decoding the file to draw a
control 18px tall, and a chit written before anyone stored levels has no envelope at all. What
the pill's bars carry is the playhead. *A third call — `keepRecording` taking a nullable
`Recording` so a take could be words with no file — went with ADR-058: there is no second plugin
to fail apart from, and a take that wrote nothing is simply nothing kept.*

---

## ADR-055 — The sheet keeps both of v6's controls, and every other way out is a cancel

The recording sheet carries **Discard and Stop & keep**, over TASKS.md group D's single control:
v6 draws both, and a sheet whose only button commits leaves the drag gesture carrying a decision
by itself — a person who opened the microphone by accident should be able to say so rather than
having to guess that swiping down throws the take away. `showRecordingSheet` is what ends the
take rather than either button: it awaits the sheet's result and cancels on anything that is not
an explicit keep, so the drag, the scrim, the back gesture and Discard are one path and a
dismissal nobody wired up cannot leave a microphone running. **Stop & keep holds the sheet open
while it finishes** — ADR-053's 900ms ceiling, usually far less — over closing first and letting
the work run on: `recordingControllerProvider` is auto-disposed, so the words would land on a
`Ref` that has gone. The scrim is a new token rather than `--paper` at an alpha, because a scrim
in the app's own ground reads as another surface where this one reads as the page going away; it
is the one colour in the palette *meant* to fail §6.4, at 2.07:1. Cost: a beat of latency on the
one control that commits, with nothing on screen saying why.

---

## ADR-056 — A refused microphone names the OS

The line sits **under the action row** rather than beside the microphone: once the chit holds
anything the row is microphone and Save, and a line that had to move when a word was
typed is worse than one below the row it explains. It reads *"The microphone isn't allowed. You
can turn it on in your phone's settings."* and **names the OS on purpose** — ADR-041 spends the
app's one dialog on location and never asks again, so until there is a settings screen (open
item 22) the phone's own is the only way back, and a line that stated the state without the way
out would leave it to be guessed at. It is `ChitType.failNote` and does not animate: M5 defers
every authored arrival to M7. *This record also placed §3.5's "Speech wasn't recognised" note as
a block above the field rather than in the prompt's overlay; that note went with ADR-058, and
`_armPrompt` no longer has anything to stand aside for.*

---

## ADR-057 — The recording controller is the one screen controller that is kept alive

`recordingControllerProvider` is `@Riverpod(keepAlive: true)`, against ARCHITECTURE.md §3's rule
that screen state is auto-disposed. **A take is not scoped to a widget**: it begins on the
microphone's tap, and the sheet that watches it is only built once `start` has returned, so for
the whole permission round-trip nothing in the app is listening. Auto-disposed, Riverpod
collected the controller during that first await, `Ref.mounted` went false, and `start` cancelled
the take it had just begun — on a handset the microphone opened, the status-bar indicator lit,
and no sheet ever appeared. The alternatives were worse: holding a manual `listenManual`
subscription from the tap until the sheet pops puts the provider's lifetime in a widget's hands
for the one thing that must outlive it, and making the sheet a route so it could own the
controller reverses ADR-011. Nothing is leaked in exchange — `start` resets the state and both
ways out of a take reset it again. Cost: `ref.onDispose` now only runs when the container does,
so it guards an app torn down mid-take rather than a sheet that vanished. **The test that should
have caught this added a listener for symmetry with the composer**, which is the only reason the
bug reached a device; that listener is gone, and ten tests fail without this line.

---

## ADR-058 — Transcription is removed, and a chit's words are always typed

`speech_to_text`, `SpeechRecognizer`, `OnDeviceSpeechRecognizer`, the sheet's transcript, the
§3.5 failure note and the `chits.text_origin` column are all deleted — the whole feature, not
disabled behind a flag. **It recognised nothing on the first handset it ran on**, which is the
outcome ADR-005 had already named as its cost: on-device models vary by handset, may not exist
for a language at all, and are worst at exactly the English-Hindi code-switching that is ordinary
speech here. A transcript that is usually absent and occasionally wrong is a worse record than an
honest recording, and it was charging a plugin, an iOS permission, a schema column, a failure
path and two open items for the privilege. The recording is the record now; anything a chit says
in words was typed. **`textOrigin` goes with it** in a v2 → v3 migration, because with no
recogniser every chit's words are typed and a column with one value is a column nobody can read
anything from — nothing visible is lost, since it was never drawn. *Kept over disabling it:* a
dormant recogniser is a plugin to keep building, a permission to keep explaining and a branch to
keep testing, for a feature nobody has asked to come back. Cost: git is now the only record of
how any of it worked, **ADR-005 and ADR-013 are edited rather than deleted** because other
records cite them, and §3.5 and OPEN-QUESTIONS §8.2 are retired with their numbers unreused.

---

## ADR-059 — There are no migrations while there is nothing to migrate

`schemaVersion` is pinned at **1** and the only strategy is `onCreate: createAll()`; `onUpgrade`
throws a message telling whoever hit it to reinstall. The snapshots under `drift_schemas/`, the
generated helpers and `migration_test.dart` are deleted with the three versions they described —
v1 from M1, v2's `chits.motion` (ADR-037), v3's dropped `text_origin` (ADR-058). **A migration is
a promise made to rows that exist**, and chit has only ever been installed on the owner's own
phone, where every schema change so far has been answered by a reinstall; the harness was
charging a snapshot, a regenerated helper and a doc section per change to protect data nobody
had. *Kept over a silent no-op upgrade:* a database whose shape the app cannot trust must fail at
`open`, not three screens later as a column that is quietly missing (CLAUDE.md §4.1). Cost: **the
first install that is not a development one cannot receive a schema change without losing
everything**, so this reverses the moment chit holds anything somebody would miss — open item 38
carries the trigger, and DATA-MODEL.md §6 keeps the four rules the harness taught rather than
leaving them in git, because the expensive part was never the code.

---

## ADR-060 — The open chit's Discard goes; a recording is dropped from its pill

**Discard leaves the open chit's action row**, and **Remove** appears beside the audio pill
instead — over keeping a control that cleared the whole page. Discard did two things: it emptied
the field, which selecting the words already does and does more precisely, and it deleted a kept
take, which was the only thing nothing else could do; a control whose one remaining job belongs
somewhere more obvious is better placed there than kept for the shape of the row. Remove acts on
the recording and not on the chit, so it sits at the end of the pill's row and leaves the words
exactly as they are — the converse of Stop & keep leaving the field alone. Three consequences
worth not rediscovering: the microphone comes back when a take is removed, so recording again is
how you get a different take rather than a second control that would silently overwrite the
first; the stamp does **not** move, because this is the same chit one part lighter rather than a
fresh one, which is what Discard used to do and why ADR-021 once cared; and `microphoneRefused`
lost its only clearer, so it now clears on the next take that gets as far as the sheet and on
the save that opens a fresh chit. **The recording sheet's Discard is a different control and
stays** (ADR-055) — the word means *throw away the take in progress*, which still happens. Cost:
emptying a half-written chit is now two gestures rather than one, and nobody has felt that on a
handset; if it reads badly the honest answer is a clear affordance on the field, not Discard
back in the row.

---

## ADR-061 — A chit in the thread is opened by holding it, and its stamp lifts under a finger

**Holding the whole chit row opens the editor**, on Today and in the archive both — over a
chevron or an edit affordance beside the row. `ChitRow` is one widget, so the two screens gain
it in the same change and cannot drift; the row *is* the target, so a marker pointing at
something that large would only repeat what the wash says. *It was a tap from group B until the
owner's third look (ADR-067)*: the thread is a reading surface, and a tap that left the page was
a glancing touch away from firing on every scroll — so a tap now does nothing, the pill inside
keeps its own, and the hold is the framework's half second with the strip's tick (ADR-034) at
the moment it is recognised. There is still **no swipe-to-delete**: delete lives in the editor
(ADR-062), and a flick that destroys a memory has nothing to recover it from. The wash arrives
with the finger and leaves with a scroll — **6% ink** (`rowPressedWash`), which forced a second
call: at 6% `--ink-faint` measures **4.42:1** and fails §6.4's floor, so **the row's stamp lifts
to `--ink-muted` (5.65:1) while it is held**, the rule §6.1 already states for the quiet
button's label; `contrast_test.dart` holds both figures. Cost: `AmbientStampRow.saved` takes a
`lifted` flag, presentation state reaching a piece of vocabulary, and a hold is less
discoverable than a tap — the semantics hint says *Hold to open the chit* and nothing tells a
sighted first-timer.

---

## ADR-062 — The editor is a route above the tab shell

The editor is a **sibling of `StatefulShellRoute`, pushed** — over a route inside the current
tab's branch. It covers the tab bar, so editing is one task with one way out and a tab change
cannot strand a half-typed edit in a branch nobody is looking at; being pushed makes the back
gesture and the back arrow the same exit, which matters because ADR-017's prompt has to fire on
both and one exit is easier to get right than three. It is **not a `ChitRoute`** — that enum is
the list the tab bar is built from, so a constant there would be a third tab, the same reason
`firstRunPath` sits outside it. The chit is named by a path parameter and loaded by a **one-shot
read, not a stream**: the thread and the calendar watch because two tabs must never disagree
(§7), but a row re-emitting under a caret is a screen fighting its own user, and the only thing
that writes this row while the editor is open is the editor. A **null answer pops the screen**
rather than drawing a slip with nothing on it, since an id outlives its row across a delete and
a blank screen with a back arrow explains nothing. The header is a back arrow and the chit's
day — not the wordmark, which would make somewhere you came into read as a second home.

---

## ADR-063 — An edit is one write, a recording can be removed or replaced, and a chit can be deleted

**`ChitRepository.updateText` becomes `update`**, taking the text and a sealed `AudioEdit` —
`keep`, `remove`, `replace(tempPath, duration)` — and writing both in one statement; and
**`delete(id)` arrives**, the row and its recording together (open item 9). This **reverses
ADR-014's second half**: audio was neither editable nor removable anywhere, on the argument that
it belonged to the moment, and the owner asked for a recording to be removable and replaceable
like the words are. Chosen over a `removeAudio`/`replaceAudio` pair beside `updateText` because
a Save that changes the words and drops the take must not be two transactions with a window in
which the row is legal by accident, and because README §5's invariant then has one place to be
asserted — on what the row *will* hold, **before any file moves**, so a refused edit leaves the
disk as it found it. Ordering follows DATA-MODEL.md §5: a replacement moves in first (over the
old file, since `keep` names files by chit id), a removal is written first and its file deleted
after, and a delete drops the row then the file — at no point does a row point at nothing, and a
file nobody points at is only an orphan the sweep collects. `updatedAt` moves on any edit, text
or audio; the stamp and the day are not parameters and cannot. Cost: the guarantee `updateText`
carried — *an edit provably cannot lose a recording* — is gone, and what replaces it is the
weaker, still exhaustive one that an edit cannot move a chit in time or place.

---

## ADR-064 — The prompt is a slip-style sheet; three acts, three words; delete confirms and has no undo

chit's first confirmation of any kind is **`showPromptSheet`** — the recording sheet's paper
rising from below, perforated edge, `sheetRadius`, the scrim, a question in the chit's face and
two answers in §6.1's two button weights — over Material's `AlertDialog`, which is free and
familiar and a centred card with another framework's shape and motion in an app that has spent
five milestones not looking like one. **The quiet weight is always the answer that lets go**
(Discard the edit, Delete the chit) and the bright one always keeps, the ranking the recording
sheet and the pill already use; every other way out — drag, scrim, back — keeps, for the reason
the recording sheet treats them as a cancel. It is a modal sheet and not a route, the second
such alongside ADR-011's. **Three acts get three words**: *Discard* throws away something in
flight (the sheet's take, the prompt's edit), *Cancel* abandons an edit, *Delete this chit* —
named in full, at the foot of the slip and apart from the action row — destroys a record;
CLAUDE.md §4.1's vocabulary rule is the reason Cancel is not a second Discard. Cancel, the back
arrow and the system back gesture (`PopScope`) are one exit and ask one question, and only when
something has changed. **Deleting confirms and there is no undo**: there is no trash and no
backend, so an undo would be a whole feature pretending to be a nicety. *The prompt named the recording until ADR-066; it no longer does.* Cost: saving a removed recording is destructive behind one tap —
reversible until Save, then not — and the prompt budget was spent on Delete instead; if that
reads wrong on a handset the fix is a second question, not a softer Remove.

---

## ADR-065 — A take has one owner, chosen at the tap

`RecordingController.start` takes a **`RecordingSink`** — the four things a sheet can tell the
screen under it: refused, started, keep this, cancelled — and holds it for the take's life, so
Stop & keep and every cancel land on whoever asked. *It called `ComposerController` by name
until M6's editor became the second screen to record*; the alternatives were a second recording
controller for the editor (two copies of ADR-057's keep-alive dance and the level window) or
`stopAndKeep` returning the take for the caller to route (which leaves refused-and-started with
nowhere to go). `ComposerController` and `EditorController` both implement the sink, and the
recording sheet is untouched — it still talks to the one controller. The microphone widget moved
to `shared/widgets/` at the same time, for ARCHITECTURE.md §2's reason: a second screen wanted
it. In the editor a kept take is **staged** as `AudioEdit.replace` (D6) and the pill plays it
from its temp path — absolute, as ADR-008 already allows — until Save moves it in; Cancel
discards the temp file, and a take recorded and removed again on a text-only chit is no change
at all. Cost: the sink is held by a keep-alive controller and the editor's is auto-disposed, so
a take whose owner has gone is dropped on the floor rather than delivered — acceptable because
the sheet is modal over the editor and the owner cannot go while it is up.

---

## ADR-066 — The owner's first look at M6: no pin, now keeps up with a save, Cancel leaves at once, the editor fills the screen

Six calls from the first handset pass of M6 on 18 September 2026, recorded together because a
future citation would want them together. **The pin is gone from the open chit** — location is
captured and stored exactly as before, README §5, but a mark that appears on every chit and can
never be absent says nothing and read as jarring; this narrows ADR-016's display half to
*nothing*, and the argument for drawing motion (rare, therefore informative, ADR-039) is the
argument against drawing the pin. **The tick at now is re-read on every save** through
`timelineNowProvider`, the one exception to ARCHITECTURE.md §3's one-clock-read rule: the strip
is static by design and `todayProvider` re-reads only at midnight (ADR-033), so a chit saved
twenty minutes after launch landed *ahead* of now — a mark in the future. Re-reading when the
rows change is exactly when §4.1 says the strip may change, and it cannot disagree with the
date line about the day, only the minute. **Cancel is always shown and leaves at once**,
reversing group D's *Cancel asks*: a press on a button that says Cancel is the decision, and
asking twice is what people learn to dismiss; the back arrow and the system gesture still ask
when something has changed, because a swipe is not a decision. **The editor's slip fills the
screen**, the field taking every line left, with *Delete this chit* pinned below it and always
visible — a long chit is edited in place, not in a box inside a scroll. The header says
*Editing* rather than the day, since the slip's stamp already carries the time; the back arrow's
glyph sits on the gutter with its target overhanging. And **Save chit is Save**, on Today and in
the editor, and the delete prompt no longer names the recording. Cost: the prompt-on-Cancel
that ADR-017 half-assumed is gone, so a stray tap on Cancel loses an edit — the owner accepted
that in exchange for a way out that is always one tap.

---

## ADR-067 — The owner's third look at M6: the recording sits above the words, a chit is held to open, and a pill that played without lighting

Two calls and one finding from the third handset pass, 18 September 2026. **In the editor the
pill sits between the stamp and the words**, where the open chit already puts it — it is the
same slip drawn twice, so the same order, and a recording is the part of a chit that cannot be
read, so it is met before the field rather than found under it; BEHAVIOUR.md §4.5's sketch
moved. **A chit is opened by holding it, not tapping it** — ADR-061, changed in place. And **a
pill tapped while another sounded was heard but never lit**: `just_audio` carries `playing`
across a source change and its `play()` returns early while it is set, so the second pill was
never reported playing and the tap that should have paused it did nothing. `JustAudioPlayer`
now stops before it loads, and `just_audio_player_test.dart` stands a fake platform under the
real plugin to hold it — M5's lesson about fakes read the other way, since `FakeAudioPlayer`
had been honest and the adapter it stood in for was the one that lied.

---

## ADR-068 — The caret blinks under reduced motion, and that is a stated limit

**Open item 14 closes as a limit written into §6.4, not as a fix.** chit draws no caret of its
own (ADR-028), so the only one in the app is Flutter's, and the framework offers no public way
to steady it that does not also hide it — `TickerMode(enabled: false)` zeroes its opacity and
the deterministic-cursor switch is test-only. A stock Android keyboard blinks its own caret
whatever the setting says, so a fix inside chit would steady one caret beside another that
still blinks. Chosen over a framework issue and over a caret of our own, on the owner's call
of 18 September 2026: neither is worth a day of v1. Cost: §6.4's *every ambient loop stops*
has one exception it names.

---

## ADR-069 — Press feedback is one widget, and the depress is a token

**`Pressable` owns the press** — the tap, the held state and the depress at `ChitPace.press` —
and every control is built on it: both button weights, the microphone, the pill, the calendar's
chevrons, the editor's back arrow and the tab bar. The two scale factors live in `ChitMotion`
(`buttonDepress` 0.985, `pillDepress` 0.99) beside the pace table they belong to, and
`ChitMotion.depress` answers 1 under reduced motion the way `travel` answers zero, so no widget
checks the flag. Chosen over a depress added to each control by hand, which is how six controls
end up with five feedbacks, and over Material's `InkWell`, whose ripple the tab bar had been
carrying — a ripple is a second design language. **Superseded within the day by ADR-070**: the
owner saw the depress and the wash together on a handset, called the colour artificial, and then
asked for the whole effect gone, so `Pressable`, `ChitMotion.buttonDepress` and `pillDepress`
are all deleted and every control is a plain tap. What survives of this record is the tab bar
off `InkWell`, and the argument for one press widget if the app ever wants feedback again.

---

## ADR-070 — No press feedback; a row's box is always there; the strip arrives by scrolling

Three calls from the owner's second look at M7, 18 September 2026, recorded together because
one handset produced all three and two of them are the same mistake. **There is no press
feedback at all** — the depress went with the wash, `Pressable` is deleted and every control is
a plain tap again, because the owner saw the colour and called it artificial, then saw the sink
and asked for it gone; a control's answer is now the thing it does, which on every screen here
is visible. *ADR-069 built the widget and this reverses it; the pace stays in §6.3's table,
drawing nothing, because ADR-020's rule is argued from it.* **A chit row's wash is a colour on a
box that is always in the tree**, where it used to be a `DecoratedBox` added on press: swapping
it in changed the shape of the tree, so Flutter rebuilt the subtree under it and disposed the
audio pill's recogniser on the frame the finger landed — a recording in the thread could not be
played at all. The hold made it certain, since `onLongPressDown` fires on the first pointer
event where a tap's own `onTapDown` waits to see whether it has won. It is the rule the two
arrivals of §6.3 are now written to as well: a wrapper that comes and goes is a rebuild, so
`Arrival` stays and is told whether to play. **The timeline is drawn straight through the page's
entrance** (`Unstaggered`), because it already arrives by scrolling to now (ADR-024) and a widget
cannot fade, rise and scroll at once and still look like one thing; it also spares a moving
viewport an `Opacity` layer per frame. Cost: with motion on, a control that is slow to respond
now looks like nothing happened until it does, and §6.1's four pressed washes are kept as record
and drawn by nothing but the chit row.
