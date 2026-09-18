# Build plan

The order the app gets built in, and what "done" means at each step. Each milestone ends with
something runnable; none of them is a refactor of the one before.

The principle behind the ordering: **the data spine before any screen, the field before the
microphone, and real content before polish.** Voice is the most involved feature in the app and
the one most likely to distort everything around it if it arrives first.

Note that the composer is one surface (BEHAVIOUR.md §3.2), so M2 builds the whole of it and M5 fills
in the microphone that has been sitting there since M2. The two milestones share a screen, and
M5 should not need to rearrange it.

**Current state is in [PROGRESS.md](PROGRESS.md), not here.** This file says what the order is
and what "done" means; that file says where we actually are. It is the one to read first.

---

## M0 and M1 — done

**M0a** (configuration) and **M0b** (the design system in code) landed 14 September 2026;
**M1** (the data spine) landed 15 September 2026. What each one contained is in git and in
ARCHITECTURE.md §2; what they *settled* is in the ADRs. Two patterns they set are worth carrying
into every milestone after them, and are why this section is still here at all:

- **A rule that fails silently gets a test that checks a property, not an example.** M0b's
  `chit_motion_test.dart` asserts "no fade is slower than it was" rather than a table of
  durations, and that is what found ADR-020 — a rule that was self-consistent and wrong, and
  that reading the design would not have caught. M7 has four more floors to write.
- **An invariant worth having is worth holding in more than one place, and each place is tested
  where it lives.** README §5's one-of rule is an assert, a check constraint *and* a repository
  refusal, because an assert is compiled out of a release build, a constraint cannot say *why*,
  and a repository is one caller among however many a later milestone adds.

M1 settled where a chit gets its time, and M3 reversed it. **ADR-040 stamps a chit when it is
saved**, so `ComposerController.save` reads the clock at that moment and the `AmbientStamp` in
`ComposerState` is a preview of what will be written rather than the value itself. *ADR-021 held
the opposite and M2 was built to it; the reversal is why `createdAt` and `updatedAt` are now the
same instant at insert.*

---

## M2 — Today, text only ✅ done, 16 September 2026

The first screen a person could use, and the first one that is.

**[TASKS.md](TASKS.md) is M2 cut into buildable groups**, with the five decisions it turns on
already settled — the field does not autofocus (ADR-023), there is no settings control, and the
day arc has become the timeline (ADR-024). This section says what done means; that file says in
what order, and it is the one to work from.

- The shell and the two-tab bar; the Calendar tab is a placeholder.
- Header, date on **one 26px line**, and the **timeline**: midnight to midnight across today
  and the two days before it, a mark per chit where its time actually falls, scrolling and
  resting at now, and scrolling smoothly to a chit as it is saved. Marks in ink, the ring at now
  in `--seal` (ADR-022, ADR-024). It reads three days, so it needs the range query the
  repository does not have yet.
- The thread: the rail, the chit rows, the ambient stamp row, the `earlier` label and count,
  and the empty state — *"Nothing written yet today."*, no rail, no placeholder row.
- The open chit: the slip, the perforated edge, the pad behind it, the **live field**, and the
  **microphone** in its final position and at its final size — present and inert until M5.
  `design/chit-app-v6.html` is the reference; the composer there is the target.
- The five-second prompt; `canSave`; Discard and Save appearing only once the chit holds
  something. *Discard left this row in M6 group A — ADR-060.*
- The ambient stamp reads a real clock; weather and location are fakes returning fixed values.

**Done when** a chit can be typed, saved, and found in the thread after a restart; the timeline
updates the moment it is saved; the empty day looks empty; and an untouched chit shows neither
Discard nor Save — *only the microphone, since ADR-060*.

**All four hold.** *What the milestone taught, which is the part worth keeping:*

- **The prototype is a browser at a desk; the app is 11px at arm's length.** Three of M2's
  records are reversals of something ported faithfully from v6 and then looked at: the drawn
  caret (ADR-028), and the marker at now twice over (ADR-036). None would have been caught by
  reading, and after ADR-031 none could be caught by a test. Budget a build and a look for
  anything small and load-bearing.
- **The specification led the prototype for the first time, and it worked.** ADR-024 replaced
  the day arc in words with nothing drawn, and §4.1 turned out to be enough to build from.
  What it could not settle was how wide a day should be and where the strip should rest —
  those needed the screen in front of you, and became ADR-032.
- **A screen that reads the clock twice is a screen that can show two days.** One
  `todayProvider`, and at midnight it re-reads itself so everything derived from it turns over
  together (ADR-033).

The microphone is drawn now, not in M5, because BEHAVIOUR.md §3.2 makes it an equal and the design
log warns about exactly how it stops being one — by drifting into a row of small grey icons.
Placing it while the field is the only working thing is the honest test of whether it holds its
weight.

The perforated edge is worth getting right here rather than later — the design log notes it is
drawn as holes in the colour of the surface *beneath* the slip, not as a dotted border, and the
metaphor rests on that. v6 sizes them at 1.55px on an 8px pitch; at v5's 1.2px they were
invisible at arm's length, which is the same as not drawing them.

---

## M3 — Ambient capture ✅ done, 17 September 2026

The fakes come out.

- `OpenMeteoService` and the WMO mapping, with the mapping unit-tested against a table of codes.
- `GeolocatorLocationService` at high accuracy, accepting the coarse fix when that is all the
  user granted (ADR-016); the permission flow; the pin.
- Parallel capture under a timeout. A signal that does not arrive is null and is not drawn.
- The platform permission strings themselves landed in M0a. M3 is where the flows that raise
  them do — behind a **first-run screen of our own** (ADR-041), shown once, asking for location
  and leaving the microphone to M5.
- **Motion** — `stationary`, `walking`, `traveling`, `flying`, read off the speed of the same
  fix the pin needs (ADR-037), so it adds no package, no permission and no third call. The stamp
  draws **one** ambient fact rather than two, ranked (ADR-038), and motion is an icon where
  weather is a word (ADR-039). *This was not in the milestone when it was planned.*
- **Captured at launch and at a stale save** (ADR-042, ADR-045), and a chit is **stamped when it
  is saved** (ADR-040). The row is written at once and patched after only if it needed it.

**All of it holds**, checked in release on a handset on 17 September.

*What the milestone taught, which is the part worth keeping:*

- **A milestone can double in scope and still be one milestone.** M3 was planned as six groups
  that drew nothing; it shipped as twelve, with a screen, a schema migration and a reversed ADR.
  What kept it coherent was that every addition answered the same question — *what does a chit
  know about the moment it was written* — and TASKS.md was re-cut twice rather than appended to.
- **A timeout sized for one architecture is wrong in the next, and silently.** ADR-007's two
  seconds existed to stop the composer stalling. ADR-042 moved capture off that path and nobody
  revisited the number, so the budget went on cutting off a GPS fix that nothing was waiting
  for — and the symptom was a missing pin, three milestones away from the cause. **When a
  constraint's reason is removed, the constraint is now a guess.**
- **The device found four things the suite could not, and none of them was a test failure.** A
  release build that drew nothing, a dialog that never appeared, a pin that never appeared, and
  a keyboard that never went down. Three were in code that 300 green tests ran over daily.
  PROGRESS.md's standing list is the only thing that catches this class, and it only works if
  somebody actually holds a phone.
- **Two of the four were caused by a fake being honest.** `FixedLocationService` granted
  permission without asking and answered a fix without a satellite, which is exactly what a fake
  should do — and it meant the first real test of both was the day they came out. A fake that
  cannot fail hides the failure path until the swap.

---

## M4 — Calendar ✅ done, 17 September 2026

- The month grid: a date carries a number only when something was written, density in four
  steps of ink, today ringed and always numbered, and the current month drawn up to today and
  no further. *This used to read "warmth in four steps, the numeral flipping near-white at the
  top two" — v6 tints in ink instead of seal, so the numeral never flips (ADR-022).*
- The month summary. **No legend** — v6 removed it (BEHAVIOUR.md §4.2).
- The archive, grouped newest-first, using the same thread treatment as Today.
- Date filtering, and clearing it.
- Month navigation — the prototype's chevrons were disabled because it held one month; the real
  app has no such excuse.

**Done when** saving a chit on Today changes the calendar density and the month total without a
refresh, because both read the same stream — **and** the seeded rows that the screen was built
against have come off the handset again.

*Two things were added to the milestone when it was cut, on 17 September 2026.* DATA-MODEL.md
§7's debug seeder comes **first**, because nothing about a calendar can be looked at empty and
ADR-035 means an empty yesterday is not even drawn on Today; its rows are cleared as the last
group. And PROGRESS.md item 12 — today's ring failing its contrast floor on a busy tile — is
taken on here rather than deferred a third time, as ADR-046.

Past chits stay non-interactive here. Saved chits **are** editable (ADR-014), the repository
method exists from M1, and OPEN-QUESTIONS.md §8.1 is now settled (ADR-017) — but the editor is M6, and
until it exists there is no pointer affordance, no focus stop and no button semantics. The
audio pill is still the only control in a row. The affordance and the editor arrive together.

**Signed off on a handset on 17 September 2026**, on the fourth look, after three earlier ones
had each sent something back to the desk. What it taught, beside M3's lesson that the standing
device list is the only net for this class:

- **Two of the four looks reversed a documented decision within a day of its being made.**
  ADR-047 kept a quiet week between two written ones on purpose and ADR-048 removed it the same
  afternoon; §4.2's paragraph on empty rows moved twice in two commits. A rule about what an
  empty stretch means cannot be settled at a desk, because at a desk there is no empty stretch.
- **A flicker is a wrong answer.** The grid went to null while the database answered, which
  every doc had defended as *nothing drawn until the query answers* — and on a handset that
  read as breakage, intermittently, because Drift's stream cache sometimes made the answer
  instant (ADR-049). "Null until answered" is right once; after that the last answer is truer
  than a blank.
- **The fixture is part of the interface.** A seeded chit reading *"Nothing today."* was taken
  for the app writing on an empty day. Sample copy that can be read as behaviour will be.
- **Nothing a test could hold was wrong.** Four hundred green tests and six findings, every one
  of them visual or temporal.

---

## M5 — Voice ✅ done, 18 September 2026

The largest milestone. The microphone has been on screen since M2; this is what happens when it
is pressed.

*It was larger still when it was written. Transcription was half of it, and **ADR-058 removed
that half** after it recognised nothing on the first handset it ran on — the bullets about a
recogniser, an appended transcript, `textOrigin` and a failure path are gone with it, along with
the "no language model installed" device test that used to close this milestone.*

- `AudioRecorder` over `record`; the microphone permission, asked at the first tap.
- The recording sheet: the perforated top edge, elapsed time in tabular figures, the live
  waveform drawn from real levels, the record dot, and Discard beside **Stop & keep**.
- **Stop & keep** → the recording is attached and **the field is left alone**. A chit holds
  words, a recording, or both.
- The audio pill and `just_audio` playback; the pill's duration in `--ink-muted`, because its
  3.5% ink wash drops `--ink-faint` to 4.17:1, below the floor. The pill is ink at rest and
  takes the seal only while it is playing (ADR-022). One player, so two pills never sound at
  once.
- The microphone becomes unavailable once a recording is kept, and reads as settled rather than
  broken. One row, one recording.
- A refused microphone opens nothing and says so once.

**Done when** a recording saves, replays after a restart, and a chit that was typed can then be
recorded into and keeps both; when a recording plays from the thread and the calendar; and when
a refused microphone leaves the composer usable and explains itself.

**Signed off on a handset on 18 September 2026**, on the third look. What it taught, beside the
standing lesson that a device is the only net for this class of failure:

- **A feature can be built correctly and still be the wrong feature.** Transcription passed
  every test it had, on a fake that behaved exactly as specified, and recognised nothing the
  first time a real microphone was pointed at it. ADR-005 had written that outcome down as a
  cost two milestones earlier. **A stated cost is a prediction, and it is worth re-reading before
  the code that pays it is written**, not after.
- **A fake that behaves better than the real thing turns a test into a claim about nothing.**
  This cost two handset passes in one day. `FakeSpeechRecognizer` was honest and the tests that
  used it still proved nothing, because the *harness around it* was not: a listener added to a
  provider "for symmetry" gave the controller a lifetime the app does not have (ADR-057), and a
  fake player that carried only changes hid a pill nobody could pause. CLAUDE.md §4.1's Liskov
  rule now names both, because the rule as written covered the fake and not its scaffolding.
- **Removing a feature removed four open risks.** Items 32, 33, 35 and 36 were all about a
  recogniser — two plugins sharing a microphone, a session ending mid-take, a beat spent waiting
  for a last word, a second permission dialog. None survived ADR-058. *The cheapest way to
  answer a hard question is sometimes to stop asking it.*
- **A seeded fixture has to be as real as what it stands in for.** `DebugSeeder` wrote
  thirty-eight bytes of ASCII where a recording should be, which was fine for four milestones
  and became a pill that did nothing the moment one existed — indistinguishable, from the
  outside, from playback being broken.

---

## M6 — The chit editor

OPEN-QUESTIONS.md §8.1, settled by ADR-017. It sits here rather than earlier because the editor has to
handle a chit that already carries an audio pill, and after M5 every chit shape exists.

- The affordance in the thread — on Today and in the archive, both, in this change. Pointer,
  focus stop and button semantics arrive together with the screen they lead to; that is what
  M2 and M4 have been holding back.
- The editor screen, above the tab shell (ADR-062): the ambient stamp, the audio pill, the
  text. Same slip treatment as a chit in the thread, because it is the same chit.
- **The recording is removable and replaceable, like the words** (ADR-063). *This section
  said the opposite until 18 September 2026 — no control, not disabled, not present — and the
  owner reversed it when the milestone was cut.* Removal is staged until Save, since a chit
  with neither words nor a take is a row the database refuses.
- Dirty tracking — *differs from what was loaded* — and the prompt on leaving with unsaved
  changes: keep the edit, or discard it. Cancel, the back arrow and the system back gesture all
  raise it; with nothing changed all three just leave.
- **A chit can be deleted**, from the editor, behind a confirmation and with no undo (open
  item 9). *Delete this chit*, named in full.
- `ChitRepository.updateText()` becomes `update()`, one write taking the text and a sealed
  `AudioEdit`; it touches `text`, the recording and `updatedAt`, and never the stamp or the day.
- **Today's Discard goes** (ADR-060), replaced by **Remove** on the pill — the one voice
  control on both screens.

**Done when** a saved chit can be opened, corrected and saved; when leaving with changes asks
and answering *discard* leaves the row exactly as it was; when a recording can be removed,
replaced, and left alone, and a removal that would empty the chit withholds Save; when a chit
can be deleted and its recording goes with it; and when an edit provably moves nothing on the
timeline and relights no calendar tile.

The prompt is the point of this milestone as much as the editor is. Abandoning an open chit
needs no confirmation and gets none (BEHAVIOUR.md §3.1) — discarding an edit to a record does.
`docs/TASKS.md` carries the cut and the twelve decisions it turns on.

---

## M7 — Motion and the floors

Polish, done deliberately and once. Last, so that every surface it touches already exists.

- The staggered entrance: fade plus a 6px rise, 55–60ms apart, capped, playing on first build
  and then shedding itself. A tab regaining visibility costs a 200ms fade and nothing more.
- The two authored arrivals: a saved chit falls *down* into the thread; a kept recording rises
  *up* into the open chit — the pill first, then its words landing in the field.
- Press feedback everywhere — 90ms, 0.985 depress, 0.99 on the pill. On a phone it is the only
  acknowledgement a finger gets.
- The reduced-motion pass: travel and ambient loops stop, fades and colour survive.
- Touch targets ≥44px with no exceptions — including the microphone's, which does not shrink
  when the field has text in it; focus rings; a semantics audit.

**Done when** the whole app is walked through once with reduced motion on and once with a
screen reader, and DESIGN-SYSTEM.md §6.4 holds as far as it can be held.

**This milestone is mostly a device pass, and ADR-031 is why.** The floors split in two. The
ones that are arithmetic over tokens — contrast, type, the reduced-motion re-timing — are tests,
and always were. The ones that are spatial or perceptual — targets, semantics, whether the
stagger reads as one movement — are a person with a handset, because there are no widget tests
to cover them and goldens are not coming back. Write what you saw into PROGRESS.md as you go: a
floors pass nobody recorded is a floors pass nobody can trust the next time round.

---

## After v1

In the order OPEN-QUESTIONS.md's own §8 suggests, not in the order of appetite.

1. ~~**OPEN-QUESTIONS.md §8.1 — where a saved chit is edited.**~~ Settled by ADR-017 and pulled forward
   into v1 as **M6**. It used to head this list because it blocked the most.
3. **OPEN-QUESTIONS.md §8.3 — whether Today carries enough rhythm.** Worth answering with real usage rather
   than more design.
4. Backlog items 1 and 3 (richer ambient capture, resurfacing) make the app stickier; 2 and 5
   (weather as a search axis, the stitch) make it distinctive.
5. **An export / backup format.** Wanted eventually and not on the v1 path — ADR-004 accepted
   "no backup beyond the OS's own" as a cost of being local-only, and this is the thing that
   would pay it back. *Carried here on 16 September 2026 from DECISIONS.md's "Deliberately not
   decided yet" list, which was removed for duplicating this one.*
6. Responsive web.

Deliberately not on this list: **any speech engine, cloud or on-device.** ADR-058 removed
transcription after it recognised nothing on a handset, and ADR-005 rules a cloud one out until
there is an answer to what happens to the audio. Bringing either back is a product decision, not
a scheduling question.

---

## How to use this

One milestone at a time, and each one ends in a state that can be shown to someone. If a
milestone starts needing a piece from a later one, that is worth noticing — it usually means
the ordering was wrong somewhere and it is cheaper to say so than to reach forward.

Every milestone ends by updating [PROGRESS.md](PROGRESS.md), and by correcting whatever else
the work made untrue. That is the standing rule in [CLAUDE.md](../CLAUDE.md) §0, and it is not
optional: this file is only useful to the next session if it is still true.
