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

