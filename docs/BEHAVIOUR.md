# Behaviour

**What chit does** (§3) **and what it looks like doing it** (§4). This file and
[DESIGN-SYSTEM.md](DESIGN-SYSTEM.md) are the design authority alongside the [README](../README.md);
where another document disagrees, that document is wrong.

## 3. Behaviour specification

**3.1 A chit exists once it is saved.** Opening the app presents a new chit for today; it becomes a
record on **Save**, and opening it six times leaves nothing behind. **A chit is stamped when it is
saved** (ADR-040), so it is always filed on the day it was written; the stamp on the open chit is a
**preview**, and it does not tick. **There is no Discard** (ADR-060) — the words are cleared by
selecting them, the recording by **Remove** on the pill. **Saving never waits**: the row is written
at once with what is in hand, and a reading older than **five minutes** is refreshed behind the save
and the chit corrected a moment later; inside five minutes nothing is asked, a burst of chits in one
sitting being one moment (ADR-042, ADR-045).

**3.2 One surface, two ways in.** The field is live the moment the chit opens, with a **microphone**
beside it as an equal; there is no mode, and a chit may end up typed, recorded, or both. **Tapping
the page gives the field focus; tapping away takes it back** — the keyboard comes up on first touch,
never on launch (ADR-023). The microphone stays an equal by being reachable and never a step:
available on an empty or half-written chit, its target unchanged by text appearing, and using it
never discards what is in the field. **A chit holds one recording**, so once kept the microphone
retires and the text stays editable; **a kept take is dropped by Remove**, and the microphone comes
back when it goes, so recording again is the way to a different take. Remove does not touch the
words. **A refused microphone raises nothing and explains once**: the sheet does not open, the
microphone stays tappable, and the line *"The microphone isn't allowed. You can turn it on in your
phone's settings."* appears under the action row — naming the phone's settings because ADR-041
spends the app's one permission dialog on location.

**3.3 The prompt waits five seconds.** If nothing is written after **5 seconds** a prompt fades in
over ~700ms; typing dismisses it and cancels the timer, and clearing the field restarts it. Shown
immediately it is an instruction; after a pause it is an offer. **Nothing moves before it** — no
caret is drawn until the user taps, and then it is the platform's own (ADR-028). **Which prompt
depends on the moment**: the hour the chit was opened, and the weather if it arrived (ADR-029).
Every prompt is a **short question**, nothing suggesting a subject worth writing about and nothing
longer than the field's own line.

**3.4 The recording.** Tapping the microphone raises the sheet: elapsed time, a live waveform, two
controls. **Stop & keep** attaches the recording and **leaves the field exactly as it was** — a
recording is not words. **Save** commits it like any chit, and the order text and audio arrived in
is not recorded. **There is no transcription** (ADR-058): the recording is the record, and anything
a chit says in words was typed by a person.

**3.5 — retired.** *When transcription fails, the voice survives alone.* Gone with transcription
itself (ADR-058). **The number is not reused** — it is cited from other documents and from git.

**3.6 Ambient capture.** The time shows as `3:42 pm`; weather as one of five words — `raining`,
`clear`, `overcast`, `windy`, `clear night`; motion as an icon and never a word (ADR-039); and
**location is not drawn at all** (ADR-066), though it is captured and stored with every chit, never
as a name, a coordinate or a map. The facts sit on one line, lowercase, spaced apart with no
separators, in the same words and case wherever they appear; the open chit's line is `--ink-muted`
and a saved chit's is `--ink-faint`, the chit being written being brighter than the ones already
written and that being the only difference between them. Conditions are words because "raining" is a
feeling and a temperature is not. Location is not drawn because a mark that can never be absent says
nothing; **motion is drawn in the thread as well** — the same argument reversed, almost no chit
having one, so a mark on two out of twelve carries real information.

**3.6.1 One ambient fact, ranked.** Weather and motion share a single slot and never both appear
(ADR-038) — three items at 11.5px is the ceiling the spacing is built on. Highest first: `flying`,
`traveling`, `raining`, `windy`, `walking`, `overcast`, `clear`/`clearNight`. `stationary` is
**never drawn** — stored, and that is all. **A chit written at a desk in the rain reads
`3:42 pm  raining`**: an icon only *displaces* a word, and only when the phone was moving.

**3.6.2 What the motion states mean.** Four, and no more (ADR-037), read from the speed on the
position fix — so motion costs no second permission, and a refused location costs the fix and the
motion together. `stationary` (still, or too uncertain to claim otherwise) draws nothing; `walking`
is a figure, `traveling` a car, `flying` a plane. **No `running`, no `cycling`** — speed cannot tell
a cyclist at 20 km/h from traffic at the same speed. **A motion that did not arrive is not drawn.**

**3.6.3 When capture happens.** At launch, and at a save holding something stale (ADR-042,
ADR-045); no polling, no refresh on resume. Five minutes is set by the **place**, not the weather,
so the preview can be hours old on a phone left open all day — but **no chit is ever recorded with
it**, saving re-reading, so the staleness is on the screen and never in the data. **Permission is
asked once, on first run** (ADR-041); a refusal means quieter chits, and nothing in the UI mentions
it.

## 4. Screens

**4.1 Today (home).** The wordmark and the चित्त mark, then weekday and date on **one line at 26px**
— the weekday italic and faint, the date in full ink. Then the timeline, the open chit on its
visible second slip, the day's thread, and the चित्त mark closing the day.

*The action row.* The microphone leads it at the foot of the slip, full 54px; **Save** arrives to
its right once the chit holds anything, and an untouched chit shows only the microphone. **Remove**
sits at the end of the pill's own row, acting on the recording and not on the chit. The two are
ranked by weight, not colour (§6.1). Once a recording is kept the microphone **leaves the row**
rather than greying out — a control that retires reads as finished, a disabled one reads as broken.

*The timeline.* A horizontal line carrying a mark for every chit, each where its time actually
falls, so four chits in an hour look like the burst they were. **Midnight to midnight**, covering
**today and up to the two days before it**, scrolling, resting at now. Saving puts a mark at the
current time, **moves now to that moment** (ADR-066) and **jumps** to it (ADR-071). **One day is one
screen**, with now in the middle of the viewport (ADR-032), and **nothing on the strip moves** — it
changes when a chit is saved and when the day turns. **Days with nothing written in them are not
drawn at the front** (ADR-035): a first run is today alone, and the strip grows backwards as there
is something to grow into, though a quiet day *between* two written days still draws. **A day ends
with a tick hanging below the line** — now's height and weight, in ink (ADR-050), with no label: it
is there to be *noticed*, not read. **A day passing can be felt** — scrolling a boundary past the
middle gives one small haptic (ADR-034), so the strip is silent when it moves itself. The marks are
**ink**; only now is `--seal`, a tick *through* the line where the boundary hangs *under* it.

**There is no settings control** — a control that does nothing is not marked up as one.

*The thread.* **A chit is opened by holding it**, on Today and in the archive alike (ADR-061), and
**nothing is drawn under the finger** (ADR-071) — what says the hold landed is the phone's own tick.
No chevron: the row *is* the target. A tap does nothing, the thread being a reading surface whose
one tap is the pill's; there is no swipe, deleting living in the editor and not a thumb's width from
a scroll. Before anything is written it reads *"Nothing written yet today."*, with no count, no rail
and no placeholder row.

**4.2 Calendar.** A date carries a number when something was written that day, and the tile's
density scales with how much — four steps of **ink**, 6% at one chit to 30% at four or more. Today
keeps its number and is ringed in `--seal`, with **2px of paper between the ring and the wash** so
it clears the contrast floor whatever the density (ADR-046). **The current month is drawn up to
today and stops**; a past month draws in full, **but only the weeks with something in them**
(ADR-048), wherever a quiet week falls — within a drawn week every day keeps its cell, numbered or
bare, so a tile's column still says its weekday. **The chevrons land only on months with something
in them** (ADR-047), and **where there is nowhere to go, no chevron is drawn**. Changing the month
clears any selected day, and **the month on screen changes once, when the new one has answered**
(ADR-049).

The **month summary** reads *22 chits over eleven days*, the count upright and the rest italic; an
empty month reads *Nothing written this month*. **The archive** groups every day newest-first using
the same thread widget as Today, each headed *Today*, *Yesterday*, or its weekday and date — the
year only when it is not this one — over a hairline with its count at the right, paged as the reader
nears the end; a chit there opens the editor exactly as on Today. Tapping a date filters the archive
and frames the tile in ink; tapping again, or **Show every day**, clears it, and a filtered day with
nothing in it reads *"Nothing written that day."* **There is no legend** — the summary already says
in words what the density says in ink. **The word is _density_, not _warmth_ or _heat_**; ADR-001
and ADR-003 still say "heat" and are settled records about aggregate queries, left as written.

**4.3 Recording sheet.** A bottom sheet with a chit's perforated edge: `● LISTENING` (the one
uppercase in the app), the elapsed figure in tabular figures, twenty waveform strokes, then
**Discard** and **Stop & keep**. **Every other way out is Discard's** — the drag, the scrim and the
back gesture all cancel, so nothing is kept and the take is deleted (ADR-055).

**4.4 First run.** **Once in the life of an install** (ADR-041): the wordmark, then a slip with a
chit's tear edge saying that a chit is stamped with the time and — if you let it — the weather,
whether you were moving, and that a place was recorded; that it never shows where, and that none of
it leaves the phone. Then **Allow**, which raises the system dialog and then opens Today, and **Not
now**, which opens Today and **raises nothing** — a quiet option that still summoned a system prompt
would be a dark pattern wearing a polite label. Whatever the answer the app opens, a refusal is not
an error state, and **neither is asked again** (ADR-016). A bare system prompt cannot say what it
buys; this screen makes the case — *so a chit can remember what the weather was* — before the
platform's dialog arrives as a confirmation of something already agreed to, and **nothing on it is a
new kind of object**. **Only location is asked for here**; the microphone is asked for the first
time somebody taps it.

**4.5 The chit editor.** Reached by holding any chit in the thread, and **it covers the tab bar**
(ADR-062): one task, one way out. The header is a back arrow on the page gutter and the word
*Editing* — not the day, the slip's stamp carrying the time, and not the wordmark, this being
somewhere you came into. **The slip fills the screen** (ADR-066): the saved stamp, the pill with
**Remove** beside it, then the field taking every line left and scrolling inside itself, then
**Cancel** and **Save**, with *Delete this chit* pinned below the slip and always on screen.

**Nothing on this screen can move the stamp** — not the time, the day, the weather, the place or the
motion. An edit changes what the chit says, never when or where it was written, and **a chit whose
row has gone leaves the screen** rather than drawing an empty slip.

**Save appears once something has changed** — *changed* meaning *differs from what was loaded*, so a
character typed and deleted, or a trailing space the save would trim, is not a change; it is
withheld again if what it would write is no longer a chit. Saving writes the words and whatever was
done to the recording in one write (ADR-063), moves `updatedAt`, and returns. **Cancel is always
there, and it leaves at once** (ADR-066) — a press on a button that says Cancel is the decision —
while **the back arrow and the system back gesture ask** when something has changed, a swipe not
being a decision. Either way the row is exactly as it was, an edit living nowhere but this screen
until Save.

**The prompt is a slip-style sheet** (ADR-064), the app's one confirmation idiom: paper rising from
below, a question, two answers in the two button weights — **the quiet one always lets go, the
bright one always keeps**, and dragging, tapping the scrim or pressing back keeps. Three acts, three
words: *Discard* throws away something in flight, *Cancel* abandons an edit, *Delete this chit*
destroys a record.

**Every change to the recording is staged until Save** (ADR-063, ADR-065): Remove stages a removal,
the pill goes and the microphone comes back; a take kept from the sheet is staged as a replacement
and plays from where it sits until Save moves it in. A removal that leaves the chit with nothing
withholds Save, leaving Cancel and *Delete this chit* — the honest pair.

**Delete this chit** is quiet and apart from the action row: the one destructive act is always on
screen, and a step of the scale away from Save rather than an inch from it. It is named in full so
it cannot be read as Discard. It asks, and **there is no undo** (ADR-064) — there is no trash and no
backend, and the prompt is the whole of the protection.
