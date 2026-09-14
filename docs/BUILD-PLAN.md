# Build plan

The order the app gets built in, and what "done" means at each step. Each milestone ends with
something runnable; none of them is a refactor of the one before.

The principle behind the ordering: **the data spine before any screen, the field before the
microphone, and real content before polish.** Voice is the most involved feature in the app and
the one most likely to distort everything around it if it arrives first.

Note that the composer is one surface (README §3.2), so M2 builds the whole of it and M5 fills
in the microphone that has been sitting there since M2. The two milestones share a screen, and
M5 should not need to rearrange it.

**Current state is in [PROGRESS.md](PROGRESS.md), not here.** This file says what the order is
and what "done" means; that file says where we actually are. It is the one to read first.

---

## M0 — Foundation

The project stops being a scaffold. Split in two, because the first half is configuration that
can be verified by building and the second half is code that can be verified by looking at it.

### M0a — configuration ✅ done, 14 September 2026

- Delete the counter app. `main.dart` becomes `runApp(ProviderScope(child: ChitApp()))`.
- Every dependency from [PACKAGES.md](PACKAGES.md), resolving; `build_runner` running clean.
- The fonts of README §6.2 downloaded, bundled and declared — as variable fonts (ADR-015).
- Android and iOS only: the desktop scaffolds deleted (ADR-019).
- Platform config in one pass — `minSdk`, permissions, the speech queries intent, the iOS
  usage strings. PACKAGES.md "Platform configuration this implies" is the checklist.
- The real package name, `com.infiniteants.chit`, in place of the scaffold's `com.example.chit`
  — Android namespace and `applicationId`, the Kotlin package and its directory, and the Xcode
  bundle identifiers. It is the app's identity, so it belongs here rather than in a later
  release-prep pass.

**Done when** `flutter pub get`, `flutter analyze`, `dart run build_runner build` and
`flutter build apk --debug` are all clean, and the app launches to a blank screen on a handset.
Blank is correct: `ChitApp` fills the screen with `--paper` and draws nothing else until M0b.

### M0b — the design system in code ✅ done, 14 September 2026

- The folder skeleton of [ARCHITECTURE.md](ARCHITECTURE.md) §2, with the empty files in place
  so nothing lands in the wrong layer by default.
- The four `ThemeExtension`s from README §6 — colours, type, spacing, motion.
- `Clock`, and the lint that nobody calls `DateTime.now()`.
- Analysis options tightened; `riverpod_lint` enabled through `plugins:` (ADR-018).
- The floors that fail silently, as tests: the contrast floor of README §6.4, the
  `fontVariations` rule of ADR-015, and the reduced-motion rule of §6.4.

**Done when** the app launches to an empty screen in `--paper`, with the wordmark set in
Newsreader and the चित्त mark in Noto Serif Devanagari; `flutter analyze` is clean; and the
contrast test of README §6.4 passes over every token pair, composited.

M0b is where the pattern for the accessibility floors was set: **a rule that fails silently
gets a test that checks a property, not an example.** `chit_motion_test.dart` asserting "no
fade is slower than it was" is what found ADR-020 — a rule that was self-consistent and wrong,
and that reading the design would not have caught. M7 has four more floors to enforce and
should be written the same way.

---

## M1 — The data spine

No UI. This is the milestone that is tempting to skip and expensive to retrofit.

- The Drift table, the check constraints, the indexes ([DATA-MODEL.md](DATA-MODEL.md) §1).
- `Chit` with its private constructor and assert; `AmbientStamp`; the two enums.
- `ChitRepository` — interface in `domain`, implementation over the DAO. Both `save()` and
  `updateText()` (ADR-014); the update path exists from the start so nothing later has to grow
  one in a hurry.
- `AudioStore`: temp → permanent, delete, the orphan sweep. No recorder yet; tests write
  dummy files.
- The migration harness and the v1 schema snapshot, before there is anything to migrate.

**Done when** the repository tests pass against an in-memory database: every illegal row shape
is rejected and all four legal ones round-trip, `localDay` is right across a midnight and across
a timezone change, audio moves on save and is deleted on discard, and `updateText` provably
touches nothing but `text`, `textOrigin` and `updatedAt`.

---

## M2 — Today, text only

The first screen a person could use.

- The shell and the two-tab bar; the Calendar tab is a placeholder.
- Header, date, and the day arc from 5am to midnight with a mark per chit and the ring at now.
- The thread: the rail, the chit rows, the ambient stamp row, the `earlier` label and count,
  and the empty state — *"Nothing written yet today."*, no rail, no placeholder row.
- The open chit: the slip, the perforated edge, the pad behind it, the **live field**, and the
  **microphone** in its final position and at its final size — present and inert until M5.
  `design/chit-app-v5.html` is the reference; the composer there is the target.
- The five-second prompt; `canSave`; Discard and Save appearing only once the chit holds
  something.
- The ambient stamp reads a real clock; weather and location are fakes returning fixed values.

**Done when** a chit can be typed, saved, and found in the thread after a restart; the arc
updates the moment it is saved; the empty day looks empty; and an untouched chit shows neither
Discard nor Save.

The microphone is drawn now, not in M5, because README §3.2 makes it an equal and the design
log warns about exactly how it stops being one — by drifting into a row of small grey icons.
Placing it while the field is the only working thing is the honest test of whether it holds its
weight.

The perforated edge is worth getting right here rather than later — the design log notes it is
drawn as holes in the colour of the surface *beneath* the slip, not as a dotted border, and the
metaphor rests on that.

---

## M3 — Ambient capture

The fakes come out.

- `OpenMeteoWeatherService` and the WMO mapping, with the mapping unit-tested against a table
  of codes.
- `GeolocatorLocationService` at high accuracy, accepting the coarse fix when that is all the
  user granted (ADR-016); the permission flow; the pin.
- Parallel capture under a timeout, on chit open. A signal that does not arrive is null and is
  not drawn.
- The platform permission strings themselves landed in M0a. M3 is where the flows that raise
  them do.

**Done when** the composer opens instantly with no network, and a chit saved offline carries a
time, no weather word, and no pin — with nothing in the UI noting the absence.

---

## M4 — Calendar

- The month grid: a date carries a number only when something was written, warmth in four
  steps, the numeral flipping near-white at the top two, today ringed and always numbered.
- Legend and month summary.
- The archive, grouped newest-first, using the same thread treatment as Today.
- Date filtering, and clearing it.
- Month navigation — the prototype's chevrons were disabled because it held one month; the real
  app has no such excuse.

**Done when** saving a chit on Today changes the calendar heat and the month total without a
refresh, because both read the same stream.

Past chits stay non-interactive here. Saved chits **are** editable (ADR-014), the repository
method exists from M1, and README §8.1 is now settled (ADR-017) — but the editor is M6, and
until it exists there is no pointer affordance, no focus stop and no button semantics. The
audio pill is still the only control in a row. The affordance and the editor arrive together.

---

## M5 — Voice

The largest milestone. The microphone has been on screen since M2; this is what happens when it
is pressed.

- `AudioRecorder` over `record`; the microphone permission.
- The recording sheet: the perforated top edge, elapsed time in tabular figures, the live
  waveform, the record dot.
- `OnDeviceSpeechRecognizer` with `onDevice: true` at a single call site (ADR-005), streaming
  partials, with the last word held in lighter ink until it commits.
- **Stop & keep** → the transcript is **appended** to the field and the field stays editable.
  `textOrigin` becomes `transcript`, or `transcriptEdited` if the field already had text.
- The one-way slide from `transcript` to `transcriptEdited` on the first keystroke.
- **The failure path.** No transcript → the audio is kept, the field stays empty *and editable*,
  the note sits beside it. Build this at the same time as the success path, not after it. All
  three routes into it — heard nothing, on-device refused, no model — take the same branch.
- The audio pill and `just_audio` playback; the pill's duration in `--ink-muted`, because its
  7% wash drops `--ink-faint` below the floor.
- The microphone becomes unavailable once a recording is kept, and reads as settled rather than
  broken. One row, one recording.

**Done when** a recording saves with its transcript, replays after a restart, and its text can
be corrected before saving; when a chit that was typed can then be recorded into and keeps both;
and when recognition forced to fail keeps the audio, writes nothing, and still lets the user
type and save.

Test the failure path on a handset with no language model installed, not only with a fake. It is
the case most likely to reach a real user in India first.

---

## M6 — The chit editor

README §8.1, settled by ADR-017. It sits here rather than earlier because the editor has to
handle a chit that already carries an audio pill, and after M5 every chit shape exists.

- The affordance in the thread — on Today and in the archive, both, in this change. Pointer,
  focus stop and button semantics arrive together with the screen they lead to; that is what
  M2 and M4 have been holding back.
- The editor screen: the ambient stamp, the audio pill, the text. Same slip treatment as a
  chit in the thread, because it is the same chit.
- **The audio is not editable and not removable.** No control offers it — not disabled, not
  present. Editing changes what the chit says, never what was said.
- Dirty tracking, and the save prompt on leaving with unsaved changes: keep the edit, or
  discard it.
- Discard, and a hard quit, both cancel the edit and land on Today. Nothing is written.
- `ChitRepository.updateText()` is called at last — it has existed since M1 precisely so this
  milestone does not have to grow one in a hurry. It touches `text`, `textOrigin` and
  `updatedAt`, and nothing else.
- `textOrigin` slides `transcript` → `transcriptEdited` on the first keystroke here too, the
  same one-way move as in the composer.

**Done when** a saved chit can be opened, corrected and saved; when leaving with changes asks
and answering *discard* leaves the row exactly as it was; when editing a chit that has audio
leaves the recording playable and untouched; and when an edit provably moves nothing on the
day arc and relights no calendar tile.

The prompt is the point of this milestone as much as the editor is. Discarding an open chit
needs no confirmation and gets none (README §3.1) — discarding an edit to a record does.

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
  when the field has text in it; `:focus-visible` rings; a semantics audit; goldens for each
  composer configuration and each calendar warmth step.

**Done when** the whole app is walked through once with reduced motion on and once with a
screen reader, and README §6.4 holds as tests rather than as intentions.

---

## After v1

In the order the README's own open questions suggest, not in the order of appetite.

1. ~~**README §8.1 — where a saved chit is edited.**~~ Settled by ADR-017 and pulled forward
   into v1 as **M6**. It used to head this list because it blocked the most.
2. **README §8.2 — re-transcription.** The data model already allows it, and `textOrigin` is
   what keeps an attempt from overwriting the user's own words. Needs a design, and it gets more
   useful the moment a language model can be installed after the fact.
3. **README §8.3 — whether Today carries enough rhythm.** Worth answering with real usage rather
   than more design.
4. Backlog items 1 and 3 (richer ambient capture, resurfacing) make the app stickier; 2 and 5
   (weather as a search axis, the stitch) make it distinctive.
5. Responsive web.

Deliberately not on this list: a cloud speech engine. ADR-005 rules it out until there is an
answer to what happens to the audio, and that is not a scheduling question.

---

## How to use this

One milestone at a time, and each one ends in a state that can be shown to someone. If a
milestone starts needing a piece from a later one, that is worth noticing — it usually means
the ordering was wrong somewhere and it is cheaper to say so than to reach forward.

Every milestone ends by updating [PROGRESS.md](PROGRESS.md), and by correcting whatever else
the work made untrue. That is the standing rule in [CLAUDE.md](../CLAUDE.md) §0, and it is not
optional: this file is only useful to the next session if it is still true.
