# Build plan

The order the app gets built in, and what "done" means at each step. Each milestone ends with
something runnable; none of them is a refactor of the one before.

The principle behind the ordering: **the data spine before any screen, the field before the
microphone, and real content before polish.** Voice is the most involved feature in the app and
the one most likely to distort everything around it if it arrives first.

Note that the composer is one surface (README §3.2), so M2 builds the whole of it and M5 fills
in the microphone that has been sitting there since M2. The two milestones share a screen, and
M5 should not need to rearrange it.

Nothing below has been started. `lib/` is still the default Flutter scaffold.

---

## M0 — Foundation

The project stops being a scaffold.

- Delete the counter app. `main.dart` becomes `runApp(ProviderScope(child: ChitApp()))`.
- Dependencies from [PACKAGES.md](PACKAGES.md); `build_runner` running clean.
- The folder skeleton of [ARCHITECTURE.md](ARCHITECTURE.md) §2, with the empty files in place
  so nothing lands in the wrong layer by default.
- The four `ThemeExtension`s from README §6 — colours, type, spacing, motion — with the fonts
  bundled and declared.
- `Clock`, and the lint that nobody calls `DateTime.now()`.
- Analysis options tightened; `custom_lint` wired.

**Done when** the app launches to an empty screen in `--paper`, with the wordmark set in
Newsreader and the चित्त mark in Noto Serif Devanagari; `flutter analyze` is clean; and the
contrast test of README §6.4 passes over every token pair, composited.

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
- `GeolocatorLocationService` at low accuracy; the permission flow; the pin.
- Parallel capture under a timeout, on chit open. A signal that does not arrive is null and is
  not drawn.
- Platform permission strings, written in chit's voice.

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

Past chits stay non-interactive here. Saved chits **are** editable (ADR-014) and the repository
method exists from M1, but README §8.1 has not settled where the editor lives — so no pointer
affordance, no focus stop, no button semantics. The audio pill is still the only control in a
row. The affordance arrives with the editor, in the same change.

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

## M6 — Motion and the floors

Polish, done deliberately and once.

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

1. **README §8.1 — where a saved chit is edited.** It blocks the most, and it is now purely a
   design question: the repository method ships in M1 and the behaviour is settled by ADR-014.
   Inline in the thread, or a screen of its own. Nothing in the thread becomes tappable until
   this lands, and when it does, the affordance and the editor arrive together.
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
