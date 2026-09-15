# Behaviour

**What chit does, and what it looks like doing it.** §3 is the behaviour specification and §4
is the screens it produces.

This document and [DESIGN-SYSTEM.md](DESIGN-SYSTEM.md) are the design authority alongside the
[README](../README.md), which holds the product model (§1–§2) and the data model (§5). Where
any other document disagrees with these three, the disagreement is a bug in that document,
fixed in the same change that found it — [CLAUDE.md](../CLAUDE.md) §0.

Section numbers are stable across the split: §3.2 is §3.2 wherever it is cited from, and it
lives here. [README §10](../README.md#10-the-map) maps every section to its file.

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
| Location | a pin symbol on the open chit — the fact of a place, never its name |

The three sit on one line, lowercase, spaced apart with no separators between them, and in the
same words and the same case wherever they appear. On the open chit the line is set in
`--ink-muted` and under a saved chit in `--ink-faint`: the chit being written is brighter than
the ones already written, which is the only difference between them.

Conditions are recorded as words because "raining" is a feeling and a temperature reading is
not. The chit carries the feel of the moment.

For location, knowing *that* a place was recorded is enough context for the reader. The pin
says so and stops there.

**The pin is drawn on the open chit only.** *v5 repeated it under every chit in the thread.*
Every chit carries a location, so a pin on all of them distinguishes nothing — it is ten
identical marks down a screen, each carrying no information because none of them could ever be
absent. On the open chit it means something present tense: *this is being noted, now.* The
location is still captured and still stored for every chit (README §5); what changed is that
the thread stopped drawing a constant.

---

## 4. Screens

### 4.1 Today (home)

Shows today.

```
  chit  चित्त
  Sunday 13 September                               ← one line, 26px

  ──●──●─────────────●──●●──◎───────────── ▸
    Fri        Sat          today                   ← the timeline; scrolls, rests at now

  ┌ ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ┐        ← perforated tear edge
  │ 3:42 pm   raining   ⌖                   │
  │ |                                       │        ← live field; prompt after 5s
  │                                         │
  │ ┌────┐                                  │
  │ │ ⏺  │                                  │        ← microphone, 54px, leads the row
  │ └────┘                                  │
  └─────────────────────────────────────────┘

  with something written:

  │ ┌────┐  Discard   ┌──────────────────┐  │
  │ │ ⏺  │            │    Save chit     │  │
  │ └────┘            └──────────────────┘  │

  earlier ─────────────────────────── 2 chits

  ▪ 11:20 am   overcast
  │ Reorg meeting pushed again. Third time.
  ▪ 8:05 am   clear
  │ Didn't sleep. Room too cold, again.
  │ [ ▶ ▁▃▅▂▆▃▁ 0:22 ]

  चित्त                                             ← the closing mark
```

The microphone leads the action row at the foot of the slip, at the full 54px, and **Discard**
and **Save chit** arrive to its right as soon as the chit holds anything — a character typed or
a recording kept. An untouched chit shows neither, because there is nothing to save and nothing
to discard. The row reads left to right: the way in, then what to do with it.

The three are ranked by weight, not by colour: the microphone and Save share a border, Save
carries the brighter one and a faint ink wash, and Discard has no outline at all. *v5 made Save
a solid `--seal` bar*, which became the loudest thing on the screen the instant a word was
typed — and next to it the outlined microphone read as a control from a different app.
DESIGN-SYSTEM.md §6.1 has the washes; ADR-022 has the argument.

Once a recording is kept the microphone **leaves the row** rather than greying out (§3.2). A
control that retires reads as finished; a disabled one reads as broken, and the audio pill
above is where the recording now lives.

The date sits directly above the timeline — the timeline's own line divides the header from the
content, so no separate rule is needed. Weekday and date share **one line** at 26px, the
weekday italic and faint, the date in full ink. *v5 stacked an italic weekday over a 38px
date.* That made what-day-it-is the largest thing on a screen whose subject is the blank slip
underneath, and it pushed the slip down the page. The date is a label here, not a masthead —
DESIGN-SYSTEM.md §6.2.

**The timeline.** A horizontal line carrying a mark for every chit, each one where its time
actually falls — four chits in an hour look like a burst, because they are one. It runs
**midnight to midnight** and covers **today and the two days before it**, it **scrolls**
horizontally, and it rests at now. Saving puts a mark at the current time and the timeline
scrolls smoothly to it.

*It was the **day arc** until 15 September 2026: one day, 5am to midnight, fixed width.* That
window left out the five hours ADR-006 works hardest to protect — a chit written at 00:20
belongs to that morning, and the arc had nowhere to put it but the left edge, on top of 5am.
Three full days also makes it a rhythm rather than a snapshot, which is what README §1 asks the
signal to be. **ADR-024** has the argument, the costs, and the one thing it deliberately leaves
open: how the boundary between one day and the next is drawn.

The timeline's marks are **ink**, not accent; only the ring at `now` is `--seal`. A row of
orange marks made every past moment look as live as the present one (ADR-022).

**There is no settings control.** The prototype draws a gear in the top row and gives it
nothing to do; v1 has no settings screen anywhere in §3 or §4. §6.4 says a control that does
nothing is not marked up as a control, and the design log is blunter — an affordance that leads
nowhere is worse than a missing one. It arrives when there is something behind it.

The open chit rests on a visible second slip, offset behind it: a pad you tear from. The slip
itself is bright enough to read as a surface rather than as a bordered rectangle.

The चित्त mark closes the day at the foot of the thread. It appears there and beside the
wordmark, and nowhere else — *v5 also repeated it at the foot of the calendar*, which made a
closing mark into a page decoration.

Saving puts the chit's mark on the timeline straight away, so it is a running account of
the day rather than a snapshot of how it started. A chit saved at the current time places its
mark inside the now ring — now, with something written in it.

Before anything is written, the thread reads *"Nothing written yet today."* and the count
beside **earlier** is omitted. There is no rail and no placeholder row; an empty day looks
empty.

### 4.2 Calendar

Reached from the bottom tab bar.

- **Month grid.** A date carries a number when something was written that day, and the tile's
  density scales with how much — four steps of **ink**, from a 6% wash at one chit to 30% at
  four or more. The month reads as the shape of what was written rather than as a full grid to
  be scanned. Today always keeps its number so it stays findable, and is ringed in `--seal`.

  *v5 tinted these steps in `--seal`, and flipped the numeral to near-white (`#FFF6EE`) at the
  top two so it would hold contrast against them.* Both are gone. Density is how much ink went
  down on a day, which is what writing actually leaves behind — and in ink the numeral never
  has to change colour to stay legible, so one less colour exists (the four steps run 12.66:1
  down to 5.99:1, all clear of the floor). It also leaves `--seal` meaning exactly one thing on
  this screen: today. ADR-022.

  **The current month is drawn up to today and stops.** A month drawn to its end is a fortnight
  of empty tiles standing for days that have not happened, which reads as a fortnight of days
  with nothing written in them. A past month draws in full.

- **Month summary** — e.g. *22 chits over eleven days*.
- **The archive** — every day grouped newest-first, using the same thread treatment as Today.
- Tapping a date filters the archive to that day; tapping again, or "Show every day", clears it.

**There is no legend.** *v5 carried one — `quiet ▪▪▪▪ full`.* Four swatches in a row explaining
that more ink means more writing is a caption on something nobody misreads, and it competed
with the grid it was explaining. The month summary underneath says the same thing in words a
person would use.

**The word is _density_, not _warmth_ or _heat_.** Those were the right words for a `--seal`
fill and they are the wrong ones for ink — nothing about the grid is warm any more. The
vocabulary rule of CLAUDE.md §4.1 applies to this as much as to `Chit`: the code should read
`density`, not `warmth`. ADR-001 and ADR-003 still say "heat" and "warmth"; they are settled
records written before v6 and their argument is about aggregate queries, not colour, so they
are left as they were written.

### 4.3 Recording sheet

A bottom sheet carrying the same perforated edge as a chit. Covered in §3.4 and §3.5.

