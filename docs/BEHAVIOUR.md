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

Opening the app presents a new chit for today; it becomes a record on **Save chit**. Opening the
app six times leaves nothing behind.

**A chit is stamped when it is saved** (ADR-040) — time, weather, motion and the fix are all
read at the moment Save is pressed, so a chit is always filed on the day it was actually
written.

**The stamp on the open chit is a preview**, not ticking: a chit sat on for twenty minutes lands
in the thread carrying a later time than the slip showed. **Discard** returns the open chit to
empty — which means **new**, not blanked, so the preview is taken again rather than showing a
time that has passed.

**Saving never waits.** The row is written at once with what is in hand. A reading older than
**five minutes** is refreshed behind the save and the chit corrected a moment later; inside five
minutes nothing is asked, since a burst of chits in one sitting is one moment and should cost
one capture (ADR-042, ADR-045).

### 3.2 One surface, two ways in

The open chit is a single writing surface. The field is live the moment the chit opens — typing
costs nothing, not even a tap — and a **microphone** sits beside it as an equal, not a secondary
action in a corner.

The two are not alternatives; there is no mode to choose. A chit may end up as typed text, a
recording with its transcript, a recording whose transcript was corrected by hand, or a
recording with nothing written — all four ordinary.

**Tapping the page gives the field focus; tapping away takes it back.** The keyboard comes up on
first touch (ADR-023 — never on launch) and goes down when a tap lands outside it, since a
keyboard that stays up covers the thread (§4.1). Discard, Save and the microphone are not
*outside* in that sense — they take their tap and the keyboard goes down as they do.

The microphone stays an equal by being reachable and never a step: available on an empty or
half-written chit, its target unchanged by text appearing, and using it never discards what is
already in the field.

**A chit holds one recording.** Once kept, the microphone retires — a second take would destroy
the first. The text stays editable; only the recording is settled. Discarding the chit clears
it.

### 3.3 The prompt waits five seconds

The writing area opens blank. If nothing is written after **5 seconds**, a prompt fades in over
~700ms. Typing a character dismisses it and cancels the timer; clearing the field restarts it.

A prompt shown immediately is an instruction; shown after a pause, it is an offer — people who
know what they want to say never see it.

**Nothing moves before it.** The page opens blank and stays blank; no caret is drawn until the
user taps, and then it is the platform's own (ADR-028).

**Which prompt depends on the moment** — the hour the chit was opened, and the weather if it
arrived (ADR-029). *"Rain. What's it like out?"* at 4pm; *"Still up. What's keeping you?"* at
1am. *"What just happened?"* is the fallback when nothing more specific fits. Every prompt is a
**short question**: no exclamation marks, nothing suggesting a subject worth writing about,
nothing longer than the field's own line.

### 3.4 The recording and its transcript

Tapping the **microphone** raises the recording sheet: elapsed time, a live waveform, and the
transcript accruing word by word, the most recent word in lighter ink until it commits. **Stop &
keep** attaches the recording to the open chit:

- The audio is attached, stays attached, and plays back from the chit's audio pill.
- The transcript is written into the field, and **the field remains the user's** — corrected,
  cut down, or added to. What ends up there is the text of the chit.
- If the field already held text, the transcript is appended after it, never discarding what was
  already written.
- **Save chit** commits it, the same as a typed chit.

The recording and the text are two records of the same moment, not two versions of it — the
audio is what was said, the text is what the chit says, and the audio survives every edit to the
words.

**Speech-to-text runs on the device** — the same recognition a phone keyboard uses for
dictation, nothing sent anywhere, no connection required. Where no on-device model exists,
recognition is simply unavailable — §3.5.

### 3.4.1 Why the transcript is editable

Speech recognition mishears names and place names, and breaks on the English-Hindi
code-switching that is ordinary speech here. A transcript that cannot be fixed is a record that
is quietly wrong. The audio protects the moment regardless — kept whatever happens to the text,
so correcting a word costs nothing that mattered.

### 3.5 When transcription fails, the voice survives alone

If speech is not recognised, or no on-device model is available, **the audio is kept and
nothing is written into the field** — nothing partial, approximate or placeholder is added
automatically.

The field stays empty and the user's: they can type anything, or save with no text at all. The
open chit carries the line *"Speech wasn't recognised. Your recording is kept."*, set beside the
body rather than written into it — an explanation of state, never saved as content.

A garbled transcript is worse than none: unsearchable, a misrepresentation of what was said, and
indistinguishable in the archive from a real record. In the archive, a chit with audio and no
text shows its audio pill and nothing else — still a record the user can play back.

### 3.6 Ambient capture

| Signal | Displayed as |
|---|---|
| Time | `3:42 pm` |
| Weather condition | a word — `raining`, `clear`, `overcast`, `windy`, `clear night` |
| Motion | an icon — a walking figure, a car, a plane. Never a word (ADR-039) |
| Location | a pin symbol on the open chit — the fact of a place, never its name |

The facts sit on one line, lowercase, spaced apart with no separators, in the same words and
case wherever they appear. The open chit's line is `--ink-muted`; a saved chit's is
`--ink-faint` — the chit being written is brighter than the ones already written, the only
difference between them.

Conditions are words because "raining" is a feeling and a temperature reading is not. For
location, knowing *that* a place was recorded is enough context — the pin says so and stops.

**The pin is drawn on the open chit only.** Every chit carries a location, so a pin on all of
them would distinguish nothing; on the open chit it means something present tense — *this is
being noted, now.* Location is still captured and stored for every chit (README §5); only the
thread stopped drawing it as a constant.

**Motion is drawn in the thread as well** — the same argument, reversed (ADR-039). Almost no
chit has a motion, so a mark on two out of twelve carries real information. It is an icon rather
than a word because every English phrase for it — *in transit*, *in vehicle*, *active* — reads
like a fitness tracker.

#### 3.6.1 One ambient fact, ranked

**The row shows the time, one ambient fact and the pin.** Weather and motion share a single
slot and never both appear (ADR-038) — three items at 11.5px is the ceiling the spacing is
built on.

Which one wins, highest first:

| | Fact | Why it sits here |
|---|---|---|
| 1 | `flying` | being in the air says more about a moment than anything else on this list |
| 2 | `traveling` | inside a vehicle, the sky outside is no longer what you are in |
| 3 | `raining` | rain is a feeling, and it outranks a way of moving you are not using |
| 4 | `windy` | the same, one step quieter |
| 5 | `walking` | you feel the weather while walking, so anything louder already won above |
| 6 | `overcast` | the sky is closed, and that is the last thing worth the slot |
| 7 | `clear` / `clearNight` | the default sky |
| — | `stationary` | **never drawn.** Stored, and that is all |

**A chit written at a desk in the rain reads exactly as it did before motion existed** —
`3:42 pm   raining   ⌖`. An icon only *displaces* a word, and only when the phone was actually
moving; `stationary` is what most chits are, and a mark on all of them would distinguish
nothing.

#### 3.6.2 What the motion states mean

Four, and no more (ADR-037), read from the speed on the position fix the pin already needs — so
motion costs no second permission, and a refused location costs the pin and the motion together.

| State | Means | Drawn |
|---|---|---|
| `stationary` | still, or moving too uncertainly to claim otherwise | nothing |
| `walking` | on foot | a walking figure |
| `traveling` | a ground vehicle — car, bus, train, bicycle | a car |
| `flying` | airborne | a plane |

**No `running`, no `cycling`** — speed cannot tell a cyclist at 20 km/h from traffic at the same
speed, and a state the signal cannot defend has no place on a chit.

**A motion that did not arrive is not drawn**, exactly as an absent condition is not drawn
(ADR-007) — indoors, with location refused, or in the first seconds after a cold start there is
usually no usable speed at all.

#### 3.6.3 When capture happens

**At launch, and at a save holding something stale** (ADR-042, amended ADR-045). Once after the
app has drawn, never waited on; again only when a save comes more than five minutes after the
last reading. No polling, no refresh on resume, no capture on a chit merely opened or saved
inside the window.

Five minutes is set by the **place**, not the weather — weather would tolerate an hour, but a
place can move a long way in five minutes. So the open chit's stamp can be hours old on a phone
left open all day, but **no chit is ever recorded with it** — saving re-reads, so the staleness
is on the screen, never in the data.

**Permission is asked once, on first run** (ADR-041, §4.4). A refusal simply means quieter
chits — no pin, no motion, and nothing in the UI mentioning either absence.

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
  │ 3:42 pm   raining   ⌖                   │        ← time, one ambient fact, the pin
  │                                         │        ← the page; prompt after 5s
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

  ▪ 11:20 am   ‹car›                               ← §3.6.1 — the icon displaced the word
  │ Reorg meeting pushed again. Third time.
  ▪ 8:05 am   clear
  │ Didn't sleep. Room too cold, again.
  │ [ ▶ ▁▃▅▂▆▃▁ 0:22 ]

  चित्त                                             ← the closing mark
```

The microphone leads the action row at the foot of the slip, full 54px; **Discard** and **Save
chit** arrive to its right once the chit holds anything typed or recorded. An untouched chit
shows neither. The row reads left to right: the way in, then what to do with it.

The three are ranked by weight, not colour: the microphone and Save share a border, Save carries
the brighter one and a faint ink wash, Discard has no outline at all (DESIGN-SYSTEM.md §6.1,
ADR-022).

Once a recording is kept the microphone **leaves the row** rather than greying out (§3.2) — a
control that retires reads as finished, a disabled one reads as broken, and the audio pill above
is where the recording now lives.

The date sits directly above the timeline, whose own line divides header from content. Weekday
and date share **one line** at 26px, the weekday italic and faint, the date in full ink — a
label, not a masthead (DESIGN-SYSTEM.md §6.2).

**The timeline.** A horizontal line carrying a mark for every chit, each where its time actually
falls — four chits in an hour look like a burst, because they are one. It runs **midnight to
midnight**, covers **today and up to the two days before it**, **scrolls** horizontally, and
rests at now. Saving puts a mark at the current time and scrolls smoothly to it.

**One day is one screen** — scrolling back a screen is scrolling back a day, and now rests in
the middle of the viewport wherever that leaves it (ADR-032).

**Nothing on the strip moves.** No pulse, no blink, no drift; it changes when a chit is saved
and when the day turns, and not otherwise.

**Days with nothing written in them are not drawn at the front** (ADR-035). A strip never opens
on a stretch that was never written in — a first run is today alone, and it grows backwards as
there is something to grow into. A quiet day *between* two written days is still drawn and still
reads as quiet.

Three whole days, not a fixed one-day window, so a chit written at 00:20 still belongs to that
morning and the strip is a rhythm rather than a snapshot (ADR-024).

**A day ends with a tick hanging below the line** — the tick at now's height and weight, in ink
(ADR-050). No label, no date, no weekday: it is there to be *noticed*, not read. Naming each day
would turn a rhythm signal into a second calendar, which §4.2 already is.

**And a day passing can be felt.** Scrolling a boundary past the middle of the screen gives one
small haptic, the way a picker does when a detent goes by (ADR-034) — feedback for a gesture, so
the strip is silent when it scrolls itself after a save.

The timeline's marks are **ink**, not accent; only the marker at `now` is `--seal` (ADR-022), a
**short vertical tick through the line** — the same tick as the day boundary, the same height
and weight, differing only in colour and which side of the line it sits: through it for what is
happening, under it for where a day ended (ADR-036).

**There is no settings control.** A control that does nothing is not marked up as one
(DESIGN-SYSTEM.md §6.4); it arrives when there is something behind it.

The open chit rests on a visible second slip, offset behind it: a pad you tear from.

The चित्त mark closes the day at the foot of the thread — it appears there and beside the
wordmark, nowhere else.

Saving puts the chit's mark on the timeline straight away, so it is a running account of the day
rather than a snapshot of how it started.

Before anything is written, the thread reads *"Nothing written yet today."* and the count beside
**earlier** is omitted — no rail, no placeholder row; an empty day looks empty.

### 4.2 Calendar

Reached from the bottom tab bar.

- **Month grid.** A date carries a number when something was written that day, and the tile's
  density scales with how much — four steps of **ink**, 6% wash at one chit to 30% at four or
  more (all clear of the contrast floor). Today always keeps its number and is ringed in
  `--seal`.

  **The current month is drawn up to today and stops.** A past month draws in full — **but only
  the weeks with something in them** (ADR-048): a week counts when a day of it was written in,
  or is today, and every other week is skipped wherever it falls. Within a drawn week every day
  keeps its cell, numbered or bare, so a tile's column still says its weekday.

  **Today's ring sits on paper, not on the wash** (ADR-046) — a 2px strip of paper between the
  ring and today's density wash, so the ring clears the contrast floor whatever the wash. Today
  with nothing written keeps its number in `--ink-faint`.

  **The chevrons land only on months with something in them** (ADR-047). Previous goes to the
  nearest earlier written month; next to the nearest later one, or back to the current month,
  which counts whatever it holds. **Where there is nowhere to go, no chevron is drawn** — a
  fresh install has neither. Changing the month clears any selected day. **The month on screen
  changes once, when the new one has answered** (ADR-049): the bar, the grid and the summary
  keep drawing the last month until the next is ready, rather than going blank.

- **Month summary** — e.g. *22 chits over eleven days*, the count upright and the rest italic.
  An empty month reads *Nothing written this month*.
- **The archive** — every day grouped newest-first, using the same thread treatment as Today (it
  is the same widget). Each day is headed *Today*, *Yesterday*, or its weekday and date — the
  year only when it is not this one — over a hairline, with its count at the right. Paged as the
  reader nears the end. **An archive with nothing in it draws nothing.**
- Tapping a date filters the archive to that day and frames the tile in ink; tapping again, or
  **Show every day**, clears it — the quiet button, Discard's weight. A filtered day with
  nothing in it reads *"Nothing written that day."*

**There is no legend.** The month summary already says in words what the density says in ink.

**The word is _density_, not _warmth_ or _heat_** — nothing about the grid is warm any more
(CLAUDE.md §4.1's vocabulary rule). ADR-001 and ADR-003 still say "heat"; they are settled
records about aggregate queries, not colour, and are left as written.

### 4.3 Recording sheet

A bottom sheet carrying the same perforated edge as a chit. Covered in §3.4 and §3.5.

### 4.4 First run

The screen a fresh install opens on, **once in the life of an install** (ADR-041).

```
  chit  चित्त

                                                   ← the page rests low; this is
                                                     a page, not a dialog
  ┌ ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ┐        ← the same tear edge as a chit
  │ A chit remembers its moment.            │
  │                                         │
  │ Every chit is stamped with the time,    │
  │ and — if you let it — the weather,      │
  │ whether you were moving, and that a     │
  │ place was recorded.                     │
  │                                         │
  │ A chit shows that a place was noted.    │
  │ It never shows where, and none of it    │
  │ leaves this phone.                      │
  └─────────────────────────────────────────┘

  ┌─────────────────────────────────────────┐
  │                 Allow                   │        ← raises the system dialog
  └─────────────────────────────────────────┘
                  Not now                            ← raises nothing at all
```

**Why it exists at all.** A bare system prompt asks for a permission without saying what it
buys, over a screen the user has not seen yet. This screen makes the case — *so a chit can
remember what the weather was* — before the platform's dialog arrives as a confirmation of
something already agreed to.

**It is built from the vocabulary that already exists** — the wordmark, a slip with its tear
edge, the two button weights of §6.1. Nothing on it is a new kind of object.

| Control | What it does |
|---|---|
| **Allow** | Raises the system location dialog, then opens Today. Whatever the user answers, the app opens — a refusal is not an error state |
| **Not now** | Opens Today. **Raises nothing.** A quiet option that still summoned a system prompt would be a dark pattern wearing a polite label |

**Neither is asked again** — one ask in the life of an install, whichever button ended this
screen (ADR-016). A refusal runs with no pin and no motion, and says nothing about it.

**Only location is asked for here.** The microphone belongs to §3.4, asked for the first time
somebody taps it — asking at launch for a control this build does not yet have would undo the
trust this screen exists to build.
