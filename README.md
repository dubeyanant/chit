# chit

A private journal for things that hit you during the day.

The name is a wordplay. **चित्त** (*chitta*) is Sanskrit for consciousness, mind, the field
where impressions land. A **chit** is also a small slip of paper you scribble something on
and keep. The app is both: a place where passing impressions get written down on small slips.

> **Status:** in build. M0a is done — the project is no longer a scaffold: dependencies,
> fonts, platform config and the app entry point are in place. M0b, the design system in
> code, is next.
>
> **[`docs/PROGRESS.md`](docs/PROGRESS.md) is where the build actually stands** and is the
> first thing to read. [`CLAUDE.md`](CLAUDE.md) is how to work in this repository.
> The interactive design prototype lives at
> [`design/chit-app-v5.html`](design/chit-app-v5.html) — open it in any browser.
> How the app is put together is in [ARCHITECTURE.md](docs/ARCHITECTURE.md); the order it
> gets built in is [BUILD-PLAN.md](docs/BUILD-PLAN.md).

---

## 1. What chit is

chit assumes **you write when something hits you**: several times a day, in a few words,
and then you get on with your life.

Everything in the product follows from that:

| Assumption | Consequence in the design |
|---|---|
| People write in bursts, not sessions | A chit is short. The composer is always open on the home screen. |
| A day holds many chits | The home screen is a thread of today. |
| Writing happens mid-thought | Opening the app costs nothing — the page is blank and ready. |
| Speaking is often faster than typing | The composer is one surface: a live field, a microphone beside it. |
| Speech gets names, places and code-switching wrong | Whatever the machine hears lands in the field, where it can be fixed. |
| The moment matters as much as the words | Time, weather and location are captured with every chit. |
| The habit survives on rhythm, not scores | Rhythm is shown as shape and colour; the app keeps no score. |

---

## 2. Core concepts

- **chit** — one entry. Text, a recording, or both. Timestamped and stamped with ambient
  context.
- **the open chit** — a blank chit at the top of the home screen: a field ready to type in,
  with a microphone beside it. It becomes a record when the user saves it.
- **the ambient stamp** — time, weather condition and a location marker, captured
  automatically when a chit is opened.
- **the thread** — a day's chits, in order, hanging off a vertical rail. A day reads as one
  continuous thing.
- **the day arc** — a horizontal line from 5am to midnight showing *when* today's chits landed.

---

## 3. Behaviour specification

### 3.1 A chit exists once it is saved

Opening the app presents a new chit for today. It becomes a record when the user presses
**Save chit**. Opening the app six times leaves nothing behind.

**Discard** returns the open chit to its empty state.

### 3.2 One surface, two ways in

The open chit is a single writing surface. The field is live the moment the chit opens — typing
costs nothing, not even a tap — and a **microphone** sits beside it as an equal, not as a
secondary action tucked into a corner.

The two are not alternatives and there is no mode to choose. A chit may end up as typed text,
as a recording with its transcript, as a recording whose transcript was corrected by hand, or
as a recording with nothing written at all. All four are ordinary.

What keeps the microphone an equal is that it is reachable and never a step: it is available on
an empty chit and on one already half-written, its target does not shrink when text appears, and
using it never discards what is already in the field.

**A chit holds one recording.** Once a recording is kept, the microphone retires — it has done
its job, and a second take would have to destroy the first. The text stays editable; only the
recording is settled. Discarding the chit is what clears it.

### 3.3 The prompt waits five seconds

The writing area opens blank. If the user has written nothing after **5 seconds**, a prompt
fades in over ~700ms ("What just happened?"). Typing a character dismisses it and cancels the
timer; clearing the field starts the five seconds again.

A prompt shown immediately is an instruction. A prompt shown after a pause is an offer.
People who know what they want to say never see it.

### 3.4 The recording and its transcript

Tapping the **microphone** raises the recording sheet: elapsed time, a live waveform, and the
transcript accruing word by word, with the most recent word held in lighter ink until it
commits. **Stop & keep** attaches the recording to the open chit.

From that point:

- The audio is attached, and stays attached. It is played back from the chit's audio pill.
- The transcript is written into the field, and **the field remains the user's**. It can be
  corrected, cut down, or added to. What ends up there is the text of the chit.
- If the field already held text, the transcript is appended after it. Recording never
  discards what was already written.
- The user presses **Save chit** to commit it, the same as for a typed chit.

The recording and the text are two records of the same moment, not two versions of it. The
audio is what was said; the text is what the chit says. Neither replaces the other, which is
why the audio survives every edit to the words.

**Speech-to-text runs on the device.** The same on-device recognition a phone keyboard uses for
dictation — nothing is sent anywhere, and it works with no connection at all. Where a handset
or a language has no on-device model, recognition is simply unavailable, and that is §3.5.

### 3.4.1 Why the transcript is editable

An earlier version of this design locked it: what was said was the record, and a hand-corrected
transcript was a third thing that was neither. That was wrong for the people who will use this
app. Speech recognition mishears names, it mishears place names, and it breaks on the
English-Hindi switching that is ordinary speech here. A transcript that cannot be fixed is a
record that is quietly wrong, and the user watching it happen can do nothing about it.

The audio is what protects the moment. It is kept whatever happens to the text, so correcting a
word costs nothing that mattered.

### 3.5 When transcription fails, the voice survives alone

If speech is not recognised — or no on-device model is available — **the audio is kept and
nothing is written into the field.** Nothing partial, approximate, or placeholder is put there
automatically.

The field stays empty and stays the user's: they can type whatever they like, or save the chit
with no text at all. The open chit carries the line *"Speech wasn't recognised. Your recording
is kept."* — set beside the body rather than written into it. It is an explanation of state,
not the chit's content, and it is never saved as one.

The rule is about what the *machine* writes, not about what the user may. A garbled transcript
is worse than none: it is unsearchable, it misrepresents what was said, and it sits in the
archive looking like a record. An empty field the user can fill is not.

In the archive a chit with audio and no text shows its audio pill and nothing else. A recording
the engine could not read is still a record the user can play back.

### 3.6 Ambient capture

| Signal | Displayed as |
|---|---|
| Time | `3:42 pm` |
| Weather condition | a word — `raining`, `clear`, `overcast`, `windy`, `clear night` |
| Location | a pin symbol — the fact of a place, never its name |

Conditions are recorded as words because "raining" is a feeling and a temperature reading is
not. The chit carries the feel of the moment.

For location, knowing *that* a place was recorded is enough context for the reader. The pin
says so and stops there.

---

## 4. Screens

### 4.1 Today (home)

Shows today.

```
  chit  चित्त                                    ⚙
  Sunday
  13 September

  ●────────●───────◎─────────────────────────
  5 am              now                midnight      ← the day arc

  ┌ ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ┐        ← perforated tear edge
  │ 3:42 PM · RAINING · ⌖                   │
  │ |                                       │        ← live field; prompt after 5s
  │                                         │
  │ ┌────┐                                  │
  │ │ ⏺  │                                  │        ← microphone, 54px, leads the row
  │ └────┘                                  │
  └─────────────────────────────────────────┘

  with something written:

  │ ┌────┐ ┌─────────┐ ┌──────────────────┐ │
  │ │ ⏺  │ │ Discard │ │    Save chit     │ │
  │ └────┘ └─────────┘ └──────────────────┘ │

  earlier ─────────────────────────── 2 chits

  ▪ 11:20 am · overcast · ⌖
  │ Reorg meeting pushed again. Third time.
  ▪ 8:05 am · clear · ⌖
  │ Didn't sleep. Room too cold, again.
  │ [ ▶ ▁▃▅▂▆▃▁ 0:22 ]
```

The microphone leads the action row at the foot of the slip, at the full 54px, and **Discard**
and **Save chit** arrive to its right as soon as the chit holds anything — a character typed or
a recording kept. An untouched chit shows neither, because there is nothing to save and nothing
to discard. The row reads left to right: the way in, then what to do with it.

Once a recording is kept the microphone **leaves the row** rather than greying out (§3.2). A
control that retires reads as finished; a disabled one reads as broken, and the audio pill
above is where the recording now lives.

The date sits directly above the day arc — the arc's own line divides the header from the
content, so no separate rule is needed.

The open chit rests on a visible second slip, offset behind it: a pad you tear from.

Saving puts the chit's mark on the day arc straight away, so the arc is a running account of
the day rather than a snapshot of how it started. A chit saved at the current time places its
mark inside the now ring — now, with something written in it.

Before anything is written, the thread reads *"Nothing written yet today."* and the count
beside **earlier** is omitted. There is no rail and no placeholder row; an empty day looks
empty.

### 4.2 Calendar

Reached from the bottom tab bar.

- **Month grid.** A date carries a number when something was written that day, and the tile's
  warmth scales with how much — four steps, from a faint wash at one chit to a strong fill at
  four or more. At the top two levels the numeral flips to near-white to hold contrast. The
  month reads as the shape of what was written rather than as a full grid to be scanned.
  Today always keeps its number so it stays findable, and is ringed.
- **Legend** — `quiet ▪▪▪▪ full`.
- **Month summary** — e.g. *22 chits over eleven days*.
- **The archive** — every day grouped newest-first, using the same thread treatment as Today.
- Tapping a date filters the archive to that day; tapping again, or "Show every day", clears it.

### 4.3 Recording sheet

A bottom sheet carrying the same perforated edge as a chit. Covered in §3.4 and §3.5.

---

## 5. Data model

A chit is text, audio, or both:

| Field | Notes |
|---|---|
| `id` | |
| `createdAt` | drives both the day arc and the day grouping |
| `text` | what the chit says. Typed, transcribed, or transcribed and then corrected. **Null when a recording produced nothing and the user wrote nothing.** |
| `audioPath` | present whenever a recording was kept |
| `textOrigin` | `typed` \| `transcript` \| `transcriptEdited` — where the words came from |
| `weather` | a condition word |
| `location` | stored; surfaced in the UI only as the pin |

`text` and `audioPath` are independently nullable and **at least one of them is always
present** — a chit with neither is not a chit, and is what §3.1 refuses to save.

That leaves four shapes, all ordinary:

| | `text` | `audioPath` |
|---|---|---|
| typed | ● | — |
| recorded and transcribed | ● | ● |
| recorded, transcript corrected | ● | ● |
| recorded, nothing recognised (§3.5) | — | ● |

`textOrigin` is provenance, not behaviour: nothing in the UI reads differently because of it.
It exists so that a future re-transcription (§8.2) can tell whether it would be overwriting the
machine's words or the user's.

---

## 6. Design system

Dark, single palette.

### 6.1 Colour

| Token | Value | Role |
|---|---|---|
| `--paper` | `#191714` | the ground |
| `--slip` | `#211E1A` | a chit's surface |
| `--slip-under` | `#141210` | the pad beneath the open chit |
| `--ink` | `#EDE7DC` | primary text |
| `--ink-muted` | `#A39B8B` | secondary text — 6.4:1 |
| `--ink-faint` | `#8F8879` | metadata — 5.0:1 on ground, 4.7:1 on a chit |
| `--hair` | `#2E2A25` | borders, rules |
| `--hair-soft` | `#252220` | inner dividers |
| `--seal` | `#C4664E` | the one accent — the stamp pressed onto a surface |
| `--seal-ink` | `#D2725A` | the same stamp when it has to be *read* as text |

**One accent, used sparingly.** `--seal` is the red of a stamp pressed onto paper: the caret,
the day-arc marks, the calendar heat field, the active tab dot, audio waveforms, the
microphone, and the Save button.

The accent is one colour in two weights, and which one to use is decided by the job, not by
taste. `--seal` is for marks, fills, borders and icons — anything read as a shape. Wherever
the accent has to carry *words* it lifts to `--seal-ink`, because `--seal` measures 4.24:1 on
a chit surface and text has to clear 4.5:1. That covers the **listening** label on the
recording sheet and the **now** cap on the day arc.

### 6.2 Typography

- **Newsreader** — the writing voice. Dates, entry text, section labels, tab labels.
- **Hanken Grotesk** — UI metadata, stamps, buttons.
- **Noto Serif Devanagari** — the चित्त mark.

Section labels are lowercase serif italic with a hairline running off to the right. Uppercase
appears in one place, the ambient stamp, because a stamp should look stamped.

Anything that counts or keeps time is set in tabular figures — the ambient stamps, chit
times, the recording clock and audio durations. A running timer whose digits change width
reads as unstable, and a column of times that does not align reads as careless.

Display-to-body ratio is roughly 2.3× (38px date over 16.5px entry text).

### 6.3 Spacing, shape, motion

- **Spacing** — 4px base: 4 / 8 / 12 / 16 / 24 / 32 / 48 / 72. Page gutter 26px.
- **Radius** — 2px almost everywhere; paper has cut edges. The recording sheet's top corners
  are the one exception at 14px.
- **Elevation** — hairlines carry the structure. The open chit has one faint shadow so it
  lifts off the pad behind it.
- **Motion** — 220ms `cubic-bezier(.2,0,0,1)` is the house pace. One rule governs the rest:
  **things arrive from where they came from, and settle.**

  A saved chit falls *down* into the thread, because the composer sits above it. A kept
  recording rises *up* into the open chit — the pill first, then the words it produced landing
  in the field — because the recording sheet sits below. Those are the two moments in the app
  with any authorship; everything else is feedback.

  | Kind | Pace |
  |---|---|
  | Press feedback | 90ms; a 0.985 depress, 0.99 on the audio pill. On a phone there is no hover, so this is the only acknowledgement a finger gets |
  | Routine state change | 200–300ms — switching tab, Discard and Save arriving once the chit holds something |
  | Authored arrival | 340–460ms — a chit landing, a recording settling |
  | The idle prompt | 700ms, deliberately slower than everything else (§3.3) |
  | Exits | always quicker than entrances; a slow dismissal reads as lag |

  The staggered arrival (fade plus 6px rise, 55–60ms apart, capped) plays when a screen
  is first built and then sheds itself. Returning to a tab costs a 200ms fade and nothing
  more — Today is opened many times a day, and a re-run entrance would turn that into waiting.
  The stagger does run again when a tapped date actually rebuilds the archive, because there
  it explains why the list changed.

### 6.4 Accessibility floors

Enforced, and verified on every revision:

- **Contrast** — every text colour clears 4.5:1 against the surface it actually sits on,
  *composited*. `--ink-faint` is tuned to pass on both `--paper` and `--slip`. Translucent
  surfaces count as their own surface: the audio pill's 7% `--seal` wash lifts the ground
  under it enough to fail `--ink-faint`, so its duration is set in `--ink-muted`. Any new
  tinted surface needs the same check rather than an inherited assumption.
- **Type** — functional text starts at **11.5px**. Quiet comes from weight and colour.
- **Touch targets** — ≥44px, with no exceptions. The microphone is 54px, and its target is not
  reduced when the field has text in it.
- **Focus** — every interactive element has a visible `:focus-visible` ring in `--seal`.
- **Motion** — under `prefers-reduced-motion`, **movement collapses and feedback does not.**
  Travel, zoom and every ambient loop stop outright: the caret blink, the pulse at now, the
  breathing record dot, the live waveform. What survives is opacity and colour — arrivals
  become a plain fade going nowhere, the scrim still dims, buttons still respond. Reducing
  motion should cost a user animation, not confirmation that their action landed.
- **Semantics** — heading levels never skip, controls that do nothing are not marked up as
  controls, and anything the user typed is escaped before it reaches the DOM.

---

## 7. The prototype

`design/chit-app-v5.html` — one self-contained file, no build step.

`design/chit-app-v4.html` is kept beside it. v4 predates §3.2 and §3.4: it opens the chit with
Write and Speak as two exclusive buttons and locks a spoken chit's transcript. It is history,
not a second option.

Live in it:

- The field is a real editor from the moment the page loads; the 5-second prompt is genuine.
- The microphone opens the recording sheet and accrues a transcript. **Stop & keep** appends it
  to whatever is already in the field and leaves it editable, and the microphone retires.
- Recording into a chit that already has typed text works, and shows the append rule.
- Save adds the chit to today's thread and updates the count, the day arc, the calendar heat
  and the month total together, so the two tabs never disagree.
- Both tabs work; calendar dates filter the archive.
- Audio pills play — simulated, since there is no audio, but the playing state is real: the
  waveform fills to a playhead and the duration counts up.

A **Tweaks** panel (bottom-right, outside the phone frame) reaches the states that are
otherwise hard to get to:

| Switch | What it shows |
|---|---|
| **Transcription: Succeeds / Fails** | flip to Fails and record to see §3.5 — the field stays empty and still takes typing |
| **Text origin** | a readout, not a switch: `typed` / `transcript` / `transcriptEdited`. Provenance is invisible in the app by design, so this is the only way to watch the one-way slide from transcript to edited |
| **Today: Has chits / Empty** | the empty-day state, which a seeded prototype can't reach |
| **Weather word**, **चित्त mark**, **Paper grain** | the three judgement calls still worth looking at both ways |
| **Idle prompt** | suppresses the 5-second prompt of §3.3 |

Deliberately not wired, because they belong to the real app rather than to a design review:

- **Month navigation.** The prototype holds September 2026 only. Both chevrons are shown
  disabled rather than offering a move that goes nowhere.
- **Opening a past chit.** §8.1 has settled that saved chits are editable, but not where that
  editor lives — so the thread still carries no affordance. It arrives with the editor.
- **A second recording on one chit.** One chit holds one recording (§3.2), so the microphone
  retires rather than offering a take that would destroy the first.

Sample content is placeholder and deliberately mundane — real chits are four words long.

---

## 8. The three hard questions

Two are still open. The numbering is stable — §8.1, §8.2 and §8.3 are referred to across the
docs — so a question that gets answered keeps its number.

### 8.1 Where a saved chit is edited — **settled, 14 September 2026**

A saved chit opens in **an editor of its own**, not inline in the thread. The thread is a
reading surface, and Today already carries a live writing surface at the top of it; a second,
differently-behaved editable field in the rows below would make it ambiguous which one a tap
is about to put the cursor in.

**Leaving with unsaved changes asks.** The prompt offers to keep the edit or to discard it.
Quitting outright — answering *discard*, or the app being killed — cancels the edit and
returns to Today, and nothing is written.

The prompt exists because editing a saved chit is not like writing a new one. Discarding an
open chit throws away something that was never a record, and gets no confirmation (§3.1).
Discarding an edit throws away a change to something that is, and gets one.

A chit's **audio is never editable and never removable**, here or anywhere. Editing changes
what the chit says, never what was said.

The affordance in the thread arrives with the editor, in the same change — until then a chit
in the thread is still not tappable, because a pointer that leads nowhere is worse than none.

### 8.2 Re-transcription — open

If a recording produced nothing — no model on the handset, or speech the engine could not
read — should the user be able to ask for another attempt later? The data model allows it,
and `textOrigin` exists so that an attempt can refuse to overwrite words the user typed
themselves.

### 8.3 Does Today carry enough rhythm? — open

The day arc is the only rhythm signal on the home screen. It fills in as chits are saved,
which is the cheapest version of an answer; whether it is enough is still open.

---

## 9. Feature backlog

Ordered by how much each reinforces what chit already is.

| # | Feature | Why it fits |
|---|---|---|
| 1 | Extend ambient capture — coarse place ("home", "office", "in transit"), what was playing | Costs the user nothing; recovers a memory faster than the text does |
| 2 | **Weather as a search axis** — "show me everything I wrote when it was raining" | Possible *because* of the ambient-stamp decision. A genuinely novel way in |
| 3 | Resurfacing — a chit from a year ago on the home screen | Brings people back with their own words |
| 4 | Adapt the prompt to time-to-first-word | Stays out of the way of fluent writers, helps blocked ones |
| 5 | The stitch — one continuous year-long line, one mark per day | Shows a year's rhythm in a single gesture |
| 6 | Voice chits (**in the design**, §3.4) | Matches the "whenever something hits them" trigger. On-device only for now; a cloud engine would be more accurate and is a decision for later |
| 7 | Chit threading — one chit replying to another | Lets a preoccupation reveal itself over weeks |

Suggested order: **1 and 3** make the app stickier; **2 and 5** make it distinctive.
Hold **7** until real usage shows people write in chains.

---

## 10. Project layout

```
chit/
├── CLAUDE.md               how to work in this repository — read it first
├── lib/                    Flutter source
├── assets/fonts/           the three faces of §6.2, as variable fonts, with their licences
├── design/
│   ├── chit-app-v5.html    interactive design prototype — open in a browser
│   └── chit-app-v4.html    superseded; kept for reference
├── docs/
│   ├── PROGRESS.md         where the build stands and what is next — the handover
│   ├── DESIGN-LOG.md       why the design is what it is
│   ├── ARCHITECTURE.md     how the app is put together
│   ├── DECISIONS.md        the architecture decision records
│   ├── DATA-MODEL.md       schema, invariants, queries
│   ├── PACKAGES.md         every dependency and why
│   └── BUILD-PLAN.md       the order it gets built in
├── android/  ios/  web/
└── README.md               this file
```

Android and iOS only. The desktop scaffolds were deleted in M0a — ADR-019. `web/` is kept
because responsive web is planned after v1, and no layout work is being spent on it yet.

This file is the design authority — the product model, the behaviour spec, the design system.
`docs/DESIGN-LOG.md` says why the design is what it is; the rest say how it becomes software.
Where any of them disagrees with this file, this file wins — and the disagreement is a bug in
the other document, fixed in the same change that found it. `CLAUDE.md` §0 is that rule
written down.

### Running the Flutter app

```bash
flutter pub get
dart run build_runner watch      # while working
flutter run                      # an Android device or emulator
```

Targets: Android and iOS. Responsive web comes later — the current design is mobile
at 390×844.
