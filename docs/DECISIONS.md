# Architecture decisions

One record per decision that would be expensive to reverse: what was chosen, what it beat, and
why — as a single paragraph, five to ten lines, shorter where possible (CLAUDE.md §0.2). A
change or a supersession edits the record it affects in place, with a clause saying what it used
to say; a wholly new decision gets a new record.

Status of every record below: **accepted**, except ADR-021 which is **superseded** and says so
at its head. Forty-nine records, not fifty-two: **ADR-018, ADR-026 and ADR-030 have been merged
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
| ADR-047 | The calendar draws only where something was written | quiet weeks at either end collapse; the chevrons skip empty months and vanish with nowhere to go. **Rule 1 narrowed by ADR-048** |
| ADR-048 | Every quiet week collapses, wherever it falls | narrows ADR-047 — a bare row across the middle of a month goes too |
| ADR-049 | The calendar holds its last answer while the next is in flight | a slow month over a blank one; the flicker on every change of month |
| ADR-050 | A day boundary is the tick at now, hanging below the line | the same height and weight; `s1` hid behind a mark written near midnight |
| ADR-051 | New ADRs are short | the template shrinks from here — CLAUDE.md §0.2 |
| ADR-052 | The recorder times a take on the clock and reports a level, not decibels | M5 group A — the file is not opened until playback; the waveform draws a number |

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
the speech recognizer must be replaceable by a fake, since BEHAVIOUR.md §3.5 only exists when
recognition produces nothing and there is no other way to reach it in a test. Cost: more files
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

## ADR-005 — Speech-to-text runs on the device

Recognition runs on the handset with nothing leaving the device — `speech_to_text` with
`SpeechListenOptions(onDevice: true)` — over Google Cloud Speech-to-Text, which BEHAVIOUR.md §3.4
originally named. Cloud recognition means every recorded thought leaves the device in an app
whose whole premise is a private journal, and needs a credential ADR-004 already deferred; the
accuracy argument for it has also weakened now that the transcript is editable (ADR-013), since a
worse engine only costs a few seconds of correction rather than a permanent error.
`domain/services/speech_recognizer.dart` keeps the interface — not for an engine swap, but
because a fake is the only way to test §3.5. Cost: on-device models are less accurate, vary by
handset, and may not exist at all for some devices or languages — offline English-Hindi
code-switching in particular should be expected to be poor. No model available is not a distinct
error state; it resolves to the same §3.5 path as a mishearing.

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
on Discard — over storing audio as a BLOB in SQLite. Multi-megabyte blobs bloat the database file
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

`text` and `audioPath` are independently nullable with at least one present; a recording's
transcript lands in an editable field and the audio is kept regardless of what happens to the
words, with a `textOrigin` column recording `typed | transcript | transcriptEdited` — over an
exclusive `source: typed | spoken` with the transcript locked. Speech recognition mishears names
and breaks on code-switching, and a transcript that cannot be corrected is a record that is
quietly wrong; moving the guarantee to the audio — never editable, never removable, always
playable — protects the moment without holding the words hostage. Cost: four legal row shapes
instead of two, an invariant the database can only partly express, and a provenance column
nothing yet reads (kept for OPEN-QUESTIONS.md §8.2's future re-transcription).

---

## ADR-014 — Saved chits are editable; their audio is not

`ChitRepository` gains an update path for `text` (and `textOrigin`, which becomes
`transcriptEdited` on a changed transcript) and no path that changes or removes `audioPath` on an
existing chit. Once the transcript is editable before Save (ADR-013), there is no principled
reason text stops being the user's the moment it is saved — a typo found the next morning is the
same typo. Text is what the chit says and belongs to the user; audio is what was said and belongs
to the moment: a chit can gain text but never lose a recording, and deleting the whole chit is
the only way to remove one. Whether the editor is inline or its own screen was left to
OPEN-QUESTIONS.md §8.1, settled by ADR-017. `updatedAt` stops being written once and forgotten;
the archive's ordering stays on `createdAt`, since editing does not move a chit from the moment
it was written.

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
stores a sharper fact than BEHAVIOUR.md §3.6 displays (a pin, never a name, coordinate or map),
a real tension: the row is precise enough to reconstruct a home address. Accepted because the
database never leaves the device (ADR-004), capture stays best-effort so a refusal costs nothing
(ADR-007), and a user who grants only approximate location gets the old behaviour exactly. Cost:
a precise fix is slower and hungrier, absorbed by ADR-007's timeout; a future sync layer would
need to treat this row as more sensitive.

---

## ADR-017 — The chit editor is a screen, and leaving it asks

OPEN-QUESTIONS.md §8.1 is settled: a saved chit opens in its own screen, not inline in the thread
— over inline editing. Leaving with unsaved changes raises a clear prompt (keep or discard);
quitting outright cancels the edit; the chit's audio stays neither editable nor removable
anywhere (ADR-014). The thread is a reading surface, and a second editable field among its rows
would make it ambiguous which one a tap targets; a screen has room for the stamp, the pill and
the text without the row growing, and somewhere for the save prompt to live. The prompt exists
because discarding an edit throws away a change to something real, unlike discarding a
still-unsaved open chit. This unblocks the thread's tap affordance and becomes M6, after voice
and before polish, so the editor handles a chit that already has an audio pill from day one.

---

## ADR-019 — Android and iOS only; the web folder stays

`windows/`, `linux/` and `macos/` are deleted from the repository; `web/` stays, untouched. The
app is a phone app — a microphone that is an equal to the keyboard, ambient weather and location,
on-device speech are all phone capabilities — and three desktop scaffolds nobody builds only go
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
