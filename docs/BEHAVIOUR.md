| 3:42 pm   raining   ⌖                   |        ← time, one ambient fact, the pin
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

**A chit is stamped when it is saved** (**ADR-040**). The time, the weather word, the motion and
the fix are all read at the moment **Save chit** is pressed, and a chit is therefore always
filed on the day it was actually written. *This reverses the earlier rule, which stamped a chit
when it was opened and then had to defend against the stamp going stale.*

**The stamp on the open chit is a preview.** It shows the time the chit was opened and does not
tick, so a chit sat on for twenty minutes lands in the thread carrying a later time than the
slip showed. That is the cost of the rule above and it is accepted rather than hidden.

**Discard** returns the open chit to its empty state — and *empty* means **new**, not blanked:
the preview is taken again, so the blank slip does not sit there showing a time that has passed.

**Saving never waits.** The row is written at once with what the app has in hand. If that
reading is more than **five minutes** old a fresh one is taken behind the save and the chit is
corrected a moment later; inside five minutes nothing is asked at all, because a burst of chits
in one sitting is one moment and should cost one capture (**ADR-042**, **ADR-045**). Nothing
about a save is ever behind a network call.

### 3.2 One surface, two ways in

The open chit is a single writing surface. The field is live the moment the chit opens — typing
costs nothing, not even a tap — and a **microphone** sits beside it as an equal, not as a
secondary action tucked into a corner.

The two are not alternatives and there is no mode to choose. A chit may end up as typed text,
as a recording with its transcript, as a recording whose transcript was corrected by hand, or
as a recording with nothing written at all. All four are ordinary.

**Tapping the page gives the field focus; tapping away takes it back.** The keyboard comes up on
the first touch of the page (ADR-023 — never on launch) and goes down again the moment a tap
lands outside it. A keyboard that stays up after you have plainly finished covers the thread,
which is the half of the screen §4.1 is about.

The controls on the slip are not *outside* in that sense: Discard, Save and the microphone still
take their tap, and the keyboard goes down as they do.

What keeps the microphone an equal is that it is reachable and never a step: it is available on
an empty chit and on one already half-written, its target does not shrink when text appears, and
using it never discards what is already in the field.

**A chit holds one recording.** Once a recording is kept, the microphone retires — it has done
its job, and a second take would have to destroy the first. The text stays editable; only the
recording is settled. Discarding the chit is what clears it.

### 3.3 The prompt waits five seconds

The writing area opens blank. If the user has written nothing after **5 seconds**, a prompt
fades in over ~700ms. Typing a character dismisses it and cancels the timer; clearing the field
starts the five seconds again.

A prompt shown immediately is an instruction. A prompt shown after a pause is an offer.
People who know what they want to say never see it.

**Nothing moves before it.** The page opens blank and stays blank — no caret is drawn on an
untouched field, and the one that appears when the user taps is the platform's, the same caret
every other text field on the device has. *An earlier version drew its own, blinking, from the
moment the app opened; an app that is animating when you open it is asking for something.*
**ADR-028**.

**Which prompt depends on the moment** — the hour the chit was opened, and the weather if it
arrived (**ADR-029**). *"Rain. What's it like out?"* at four in the afternoon; *"Still up.
What's keeping you?"* at one in the morning. The ambient stamp is already captured and already
on the screen, so a prompt that ignores it is asking a generic question in front of a line that
just said `3:42 pm  raining`.

*"What just happened?"* is still in the book and is still what a chit gets when nothing more
specific fits. Every prompt is a **short question**: no exclamation marks, nothing that
suggests a subject worth writing about, and nothing longer than the field's own line. chit has
no opinion about how much you write, which is the same reason it keeps no score (§1).

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
| Motion | an icon — a walking figure, a car, a plane. Never a word (ADR-039) |
| Location | a pin symbol on the open chit — the fact of a place, never its name |

The facts sit on one line, lowercase, spaced apart with no separators between them, and in the
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
location is still captured and still stored for every chit (README §5); what changed is what
the thread stopped drawing a constant.

**Motion is drawn in the thread as well** — the same argument, reversed (ADR-039). Almost no
chit has a motion, so a mark that appears on two chits out of twelve carries real information:
the ones you wrote on a train stand out from the ones you wrote at home. It is an icon rather
than a word because every English phrase for it — *in transit*, *in vehicle*, *active* — reads
like a fitness tracker, and §6.2 is not a voice that says `active`.

#### 3.6.1 One ambient fact, ranked

**The row shows the time, one ambient fact and the pin.** Weather and motion share a single
slot and never both appear — ADR-038. Three items at 11.5px is the ceiling the spacing above is
built on, and motion arrived fourth.

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

The consequence worth stating plainly: **a chit written at a desk in the rain reads exactly as
it did before motion existed** — `3:42 pm   raining   ⌖`. An icon appears only by *displacing*
a word, and only when the phone was actually moving. `stationary` is what most chits are, and a
mark on all of them would distinguish nothing.

#### 3.6.2 What the motion states mean

Four, and no more (ADR-037). They are read from the speed on the position fix the pin already
needs — so motion costs no second permission and no second dialog, and a refused location costs
the pin and the motion together.

| State | Means | Drawn |
|---|---|---|
| `stationary` | still, or moving too uncertainly to claim otherwise | nothing |
| `walking` | on foot | a walking figure |
| `traveling` | a ground vehicle — car, bus, train, bicycle | a car |
| `flying` | airborne | a plane |

**There is no `running` and no `cycling`.** Speed cannot tell a cyclist at 20 km/h from a car in
traffic at 20 km/h, and a state the signal cannot defend has no more place on a chit than a
temperature reading does.

**A motion that did not arrive is not drawn**, exactly as a condition that did not arrive is
not drawn (ADR-007). Indoors, with location refused, and in the first seconds after a cold
start there is usually no usable speed at all — so most chits carry no motion, and nothing in
the UI mentions its absence.

#### 3.6.3 When capture happens

**At launch, and at a save holding something stale** — ADR-042 as amended by ADR-045. Once after
the app has drawn, never waited on; and again when a chit is saved more than five minutes after
the last reading came back. There is no polling, no refresh on resume, and no capture at all on
a chit that is merely opened — or on one saved inside the window.

Five minutes is set by the **place** rather than the weather. Weather would tolerate an hour; a
place can move a long way in five minutes, and the pin is the signal with the shortest honest
shelf life.

So the stamp on the open chit draws whatever landed at launch, and on a phone that has been open
all day that can be hours old. **No chit is ever recorded with it**, because saving re-reads —
the staleness is on the screen, not in the data.

**Permission is asked once, on first run** (ADR-041), behind §4.4's screen. An install where it
was refused simply has quieter chits: no pin, no motion, and — since the two are one signal —
nothing in the UI mentioning either absence.

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
**midnight to midnight** and covers **today and up to the two days before it**, it **scrolls**
horizontally, and it rests at now. Saving puts a mark at the current time and the timeline
scrolls smoothly to it.

**One day is one screen**, so scrolling back a screen is scrolling back a day, and now rests in
the middle of the viewport wherever that leaves it — which for most of the day means the screen
is today, and in the small hours means yesterday evening is beside this morning (ADR-032).

**Nothing on the strip moves.** No pulse, no blink, no drift; it changes when a chit is saved
and when the day turns, and not otherwise.

**Days with nothing written in them are not drawn at the front** (ADR-035). A strip never opens
on a stretch that was never written in: on a first run it is today alone and does not scroll,
and it grows backwards as there is something back there to grow into. A quiet day *between* two
days that have something is still drawn, and still reads as quiet.

*It was the **day arc** until 15 September 2026: one day, 5am to midnight, fixed width.* That
window left out the five hours ADR-006 works hardest to protect — a chit written at 00:20
belongs to that morning, and the arc had nowhere to put it but the left edge, on top of 5am.
Three full days also makes it a rhythm rather than a snapshot, which is what README §1 asks the
signal to be. **ADR-024** has the argument and the costs.

**A day ends with a tick hanging below the line** — the tick at now's height and weight, in ink
(ADR-050). No label, no date, no weekday — the mark and nothing else. It is there to be
*noticed*, not read: someone who sees two of them is looking at three days and will know it
without being told, and someone who never looks at them has lost nothing. Naming each day would
turn a rhythm signal into a second calendar, and §4.2 is already that. *It was a small 4px mark
for two milestones*, and the first strip with ten marks on it showed why that could not stay: a
chit written near midnight sat over it and left half a pixel showing.

**And a day passing can be felt.** Scrolling a boundary past the middle of the screen gives one
small haptic, the way a picker does when a detent goes by (ADR-034). It is the same decision as
the mark: the boundary is worth noticing and not worth reading, and a haptic costs no ink, no
label and no space. It is feedback for a gesture, so the strip is silent when it scrolls itself
after a save.

This is the question ADR-024 left open and it is answered here, which is where that record said
the answer would go.

The timeline's marks are **ink**, not accent; only the marker at `now` is `--seal`. A row of
orange marks made every past moment look as live as the present one (ADR-022).

That marker is a **short vertical tick through the line** — thin, and taller than a mark, so it
reads as a position rather than as an object sitting on the strip. It is the same tick as the
day boundary — the same height and weight — and the difference is the colour and which side of
the line it sits: through it for what is happening, under it for where a day ended. *v6 draws a ring
here, and this section used to say a chit saved at the current time places its mark inside it —
"now, with something written in it". At 11px on a handset the two read as separate shapes, and
filling the ring to fix that made it the loudest thing on a quiet screen.* ADR-036 has both
attempts and what each cost.

**There is no settings control.** The prototype draws a gear in the top row and gives it
nothing to do; v1 has no settings screen anywhere in §3 or §4. §6.4 says a control that does
nothing is not marked up as a control, and the design log is blunter — an affordance that leads
nowhere is worse than a missing one. It arrives when there is something behind it.

The open chit rests on a visible second slip, offset behind it: a pad you tear from. The slip
itself is bright enough to read as a surface rather than as a bordered rectangle.

The चित्त mark closes the day at the foot of the thread. It appears there and beside the
wordmark, and nowhere else — *v5 also repeated it at the foot of the calendar*, which made a
closing mark into a page decoration.

Saving puts the chit's mark on the timeline straight away, so it is a running account of the day
rather than a snapshot of how it started. A chit saved at this instant lands behind the tick at
now, which is thin enough to leave most of it showing.

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
  with nothing written in them. A past month draws in full — **but only the weeks with
  something in them** (ADR-048). A week counts when a day of it was written in, or is today;
  every other week is not drawn, wherever it falls in the month. Within a drawn week every day
  keeps its cell, numbered or bare, so a tile's column still says its weekday: today under
  Thursday says *the 17th* before the number is read. *This paragraph has moved twice in two
  commits. It first said a quiet fortnight before the first chit was two rows with no numbers,
  and the first device pass, on a fresh install with two empty rows above the 17th, asked why;
  then it kept a quiet week between two written ones as the timeline keeps a quiet day
  (ADR-047), and the second pass, looking at a bare row across the middle of August, asked for
  that to go as well.* The strip and the grid now read an empty stretch differently, on
  purpose: a day on the strip is a proportion of real time, a week on the grid is a row.

  **Today's ring sits on paper, not on the wash** — ADR-046. The ring is drawn at the tile's
  edge with a 2px strip of paper inside it, and today's density wash sits inside that. *v6 puts
  the ring directly on the wash,* where `--seal` fails §6.4's 3:1 floor from three chits
  onwards; on paper it clears it every day, and today is a different *shape* from every other
  day as well as a different colour, which §6.4 asks for outright. Today with nothing written
  keeps its number in `--ink-faint`.

  **The chevrons land only on months with something in them** (ADR-047). Previous goes to
  the nearest earlier written month, skipping empty ones; next to the nearest later one, or back
  to the current month, which counts whatever it holds because it is where the next chit goes.
  **Where there is nowhere to go, no chevron is drawn** — a fresh install has neither. *v6 draws
  both and disables one, and so did the app for one commit, until the first device pass landed
  on an empty August with a dead chevron beside it.* It is not possible to go back in time and
  write, so a month nobody can act on is never shown. Changing the month clears any selected
  day. **The month on screen changes once, when the new one has answered** (ADR-049): the bar,
  the grid and the summary keep drawing the last month until the next is ready, rather than
  going blank for the frames a query takes — which the handset saw as a flicker.

- **Month summary** — e.g. *22 chits over eleven days*, the count upright and the rest italic.
  An empty month reads *Nothing written this month*.
- **The archive** — every day grouped newest-first, using the same thread treatment as Today:
  it is the same widget. Each day is headed *Today*, *Yesterday*, or its weekday and date —
  *Friday 11 September*, with the year only when it is not this one — over a hairline, with its
  count at the right. It is paged as the reader nears the end. **An archive with nothing in it
  draws nothing**: a fresh install's calendar is the grid, today's ring and the summary line,
  which already says the month is empty (the same reading of §4.1 the thread takes).
- Tapping a date filters the archive to that day and frames the tile in ink; tapping again, or
  **Show every day**, clears it. *Show every day* is the quiet button — Discard's weight — and
  not v6's outlined bar: a fourth control weight for one control on one screen is a weight
  nothing else would use. A filtered day that turns out to hold nothing reads *"Nothing written
  that day."*

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

### 4.4 First run

The screen a fresh install opens on, **once in the life of an install** — ADR-041.

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
buys, over a screen the user has not seen yet. The honest answer — *so a chit can remember what
the weather was* — is not something Android or iOS will say on our behalf. This screen makes the
case; the platform's dialog then arrives as a confirmation of something already agreed to.

**It is built from the vocabulary that already exists** — the wordmark, a slip with its tear
edge, and the two button weights of §6.1. Nothing on it is a new kind of object, because the
first thing a user sees should be the app rather than a preamble to it.

| Control | What it does |
|---|---|
| **Allow** | Raises the system location dialog, then opens Today. Whatever the user answers there, the app opens — a refusal is not an error state and there is no second screen about it |
| **Not now** | Opens Today. **Raises nothing.** A quiet option that still summoned a system prompt would be a dark pattern wearing a polite label |

**Neither is asked again.** The app spends one ask in the life of an install, whichever button
ended this screen (ADR-016). An install that refused runs with no pin and no motion, and says
nothing about it — §3.6's `null` is simply not drawn.

**Only location is asked for here.** The microphone belongs to §3.4 and is asked for the first
time somebody taps the microphone, because asking at launch for a control this build does not
yet have is the thing that would undo the trust this screen exists to build.

