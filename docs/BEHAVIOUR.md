# Behaviour

**What Chitta does** (§3) **and what it looks like doing it** (§4). This file and
[DESIGN-SYSTEM.md](DESIGN-SYSTEM.md) are the design authority alongside the [README](../README.md);
where another document disagrees, that document is wrong.

## 3. Behaviour specification

**3.1 A chit exists once it is saved.** Opening the app presents a new chit for today; it becomes a
record on **Save**, and opening it six times leaves nothing behind. **A chit is stamped when it is
saved** (ADR-040), so it is always filed on the day it was written; **the open chit shows no time at
all** (ADR-080), a clock drawn before the stamp exists being a preview of a number it cannot
promise. **There is no Discard** (ADR-060) — the words are cleared by
selecting them, the recording by **Remove** on the pill. **Saving never waits**: the row is written
at once with what is in hand, and a reading older than **one minute** is refreshed behind the save
and the chit corrected a moment later; inside the minute nothing is asked, a burst of chits in one
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
longer than the field's own line — **46 characters, and a test counts them**. There are about
seventy, and the book is meant to grow: what keeps it honest is that the most specific entry that
fits wins, so a new pair never has to be slotted above an old one by hand.

**3.4 The recording.** Tapping the microphone raises the sheet: elapsed time, a live waveform, two
controls. **Stop & keep** attaches the recording and **leaves the field exactly as it was** — a
recording is not words. **Save** commits it like any chit, and the order text and audio arrived in
is not recorded. **There is no transcription** (ADR-058): the recording is the record, and anything
a chit says in words was typed by a person.

**3.5 — retired.** *When transcription fails, the voice survives alone.* Gone with transcription
itself (ADR-058). **The number is not reused** — it is cited from other documents and from git.

**3.6 Ambient capture.** The time shows as `3:42 pm` **on a saved chit and nowhere else**
(ADR-080); weather as one of five words — `raining`,
`clear`, `overcast`, `windy`, `clear night`; **motion as one of three, in the same voice** —
`walking`, `travelling`, `flying` (ADR-039, an icon until 078 — the enum stays `traveling`, the
word is British like the rest of the copy); and **location is not drawn at all** (ADR-066), though
it is captured and stored with every chit, never
as a name, a coordinate or a map. The facts sit on one line, lowercase, spaced apart with no
separators, in the same words and case wherever they appear; the open chit's line is `--ink-muted`
and a saved chit's is `--ink-faint`, the chit being written being brighter than the ones already
written and that being the only difference between them. Conditions are words because "raining" is a
feeling and a temperature is not. Location is not drawn because a mark that can never be absent says
nothing; **motion is drawn in the thread as well** — the same argument reversed, almost no chit
having one, so a word on two out of twelve carries real information.

**3.6.1 One ambient fact, ranked.** Weather and motion share a single slot and never both appear
(ADR-038) — three items at 11.5px is the ceiling the spacing is built on. Highest first: `flying`,
`traveling`, `raining`, `windy`, `walking`, `overcast`, `clear`/`clearNight`. `stationary` is
**never drawn** — stored, and that is all. **A chit written at a desk in the rain reads
`3:42 pm  raining`**: a motion only *displaces* the weather, and only when the phone was moving.

**The open chit fills that slot or says `writing`** (ADR-080). It carries no time, so the fact is
the whole line and an empty line would move the field under the thumb the moment weather landed;
`writing` is the present tense of what the slip is doing, in the same lowercase single word the
facts speak in. A phone that refused location never leaves it — honest, that being the whole of what
the chit can say about where it is.

**A chit that has been edited says so, and does not say when.** `edited` follows the fact —
`3:42 pm  raining  edited` — reaching the three-item ceiling and never passing it, because the
question a thread answers is *which of these did I go back to*, not *at what hour*. The time on the
row stays the one the chit was written at: **an edit never moves the stamp** (§4.5). It is drawn
wherever a saved chit is — the thread, the archive and the editor's own slip.

**3.6.2 What the motion states mean.** Four, and no more (ADR-037), read from the speed on the
position fix — so motion costs no second permission, and a refused location costs the fix and the
motion together. `stationary` (still, or a reading noisier than the speed it carries) draws nothing.
**A speed the platform reported without an error beside it is still a speed** (ADR-078): Android
sends 0.0 for an accuracy it does not have, and reading that as noise is what kept a train at
`stationary`. **No `running`, no `cycling`** — speed cannot tell a cyclist at 20 km/h from traffic
at the same speed. **A motion that did not arrive is not drawn.** **`flying` will almost never
fire, and that is not a bug to fix** — most devices disable GPS in airplane mode, so there is no
fix and no speed; a barometer is the honest route if it ever matters.

**3.6.3 When capture happens.** At launch, and at a save holding something stale (ADR-042,
ADR-045); no polling, no refresh on resume. **One minute** is set by the **place**, not the weather,
so the preview can be hours old on a phone left open all day — but **no chit is ever recorded with
it**, saving re-reading, so the staleness is on the screen and never in the data. **Permission is
asked once, on first run** (ADR-041); a refusal means quieter chits, and nothing in the UI mentions
it.

**A reading landing mid-chit changes the facts and nothing else** (ADR-081). The launch capture
finishes seconds after the app opens, which is squarely inside the time somebody spends writing
their first sentence: it moves the word on the stamp, and it leaves the text, the kept take and the
hour the chit was opened exactly where they were.

**3.7 Tags are written into the words** (ADR-082). **`@somebody` is a person and `#something` is a
topic**, marked while typing and drawn on the saved chit: **a person loses its `@` and is set in
italic**, a **topic keeps its `#` and is set in `--ink-faint`**. Italic is difference enough for a
name; a topic's only other difference would be colour, which §6.4 forbids a signal to rest on
alone, so its sigil stays and carries the rest.

**An underscore inside a tag is a space** — `@anant_dubey` is written with the underscore and reads
*anant dubey*, because a tag has to survive being one word while typing and be two when read. A run
of them is still one space. **The whole tag counts as one thing**, matched regardless of case and
of whether it was spelt with underscores or not, which is what a search would count later.

**A tag starts at a word start and ends on a letter, a digit or a mark.** `work@example.com` carries
no tag, `@anant.` tags the name and leaves the full stop, `@anant's` leaves the possessive, and a
trailing underscore falls outside rather than drawing as a space nobody can see. Any script — a
Devanagari matra is a combining mark and belongs to the word it sits on.

**Nothing here is tappable, and the raw text is what is stored.** A tap on the thread still does
nothing and the row is still opened by holding it (§4.1), so this is how a chit *reads* and not yet
a way in — that is backlog item 8, and this is the half of it that is decided. **The editor shows
the words as they were typed**, underscores and sigils and all, because that is what an edit edits.

## 4. Screens

**4.1 Today (home).** The wordmark — चित्त, and nothing beside it — then weekday and date on
**one line at 26px**, the weekday italic and faint, the date in full ink. **That line and the
calendar's month sit at the same height** (§6.3), so switching tab does not move the heading. Then
the timeline, the open chit on its visible second slip, the day's thread, and the चित्त mark closing
the day.

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
empty month reads *Nothing written this month*. **The archive under it is that month and nothing
else** (ADR-079) — change the month and the chits change with it, which is what makes the grid and
the list one screen rather than two. It groups the month's days newest-first using the same thread
widget as Today, each headed *Today*, *Yesterday*, or its weekday and date — the year only when it
is not this one — over a hairline with its count at the right; a chit there opens the editor exactly
as on Today. **There is no endless scroll and no paging**: a month is the page, and the chevrons are
how you turn it. Tapping a date filters the archive
and frames the tile in ink; tapping again, or **Show every day**, clears it, and a filtered day with
nothing in it reads *"Nothing written that day."* **There is no legend** — the summary already says
in words what the density says in ink. **The word is _density_, not _warmth_ or _heat_**; ADR-001
and ADR-003 still say "heat" and are settled records about aggregate queries, left as written.

**4.3 Recording sheet.** A bottom sheet with a chit's perforated edge: `● LISTENING` (the one
uppercase in the app), the elapsed figure in tabular figures, twenty waveform strokes, then
**Discard** and **Stop & keep**. **Every other way out is Discard's** — the drag, the scrim and the
back gesture all cancel, so nothing is kept and the take is deleted (ADR-055).

**4.4 First run.** **Once in the life of an install** (ADR-041): the wordmark, then two slips on a
chit's tear edge and two answers. **The first says what to expect** (ADR-074) — that the page is
always open and a few words then **Save** make a chit; that the microphone speaks one instead and
the take is kept rather than transcribed; and that a chit is opened again by **holding** it, the one
gesture nothing on a screen can advertise. **The second asks**: a chit is stamped with the time and
— if you let it — the weather, whether you were moving, and that a place was recorded; it never
shows where, and none of it leaves the phone. **The wordmark is centred here and nowhere else**, and
**the screen does not scroll** — the copy is cut until it fits, a first screen that slides under the
thumb being a worse welcome than a shorter sentence. Then **Allow**, which raises the system dialog
and then opens Today, and **Not now**, which opens Today and **raises nothing** — a quiet option
that still summoned a system prompt would be a dark pattern wearing a polite label. Whatever the answer the app opens, a refusal is not
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
row has gone leaves the screen** rather than drawing an empty slip. What an edit does add is the
word `edited` (§3.6.1), which appears on the slip the moment Save returns.

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

**4.6 Find.** The third tab, and the way back to a chit you cannot date. **Three screens deep, and
each one is a route** (ADR-084), so the system back walks up a level rather than out of the tab.

*The first screen.* A line at the top — one of about forty-five, **the same all day and different
tomorrow** — and then, at the **bottom right**, four words: `weather`, `motion`, `people`,
`topics`. The words are one touch target apart, with the same space under the last as between any
two, so the column reads as a rhythm rather than a list.

**This is the one surface in the app that is not left-aligned** (ADR-084). Everything else hangs off
the left gutter; find's column is flush *right*, because it is a set of targets rather than a
reading surface, and the right edge is where a right thumb already is. **The lines are house lines,
not quotations** — nothing is attributed, a misattribution being a defect that ships and cannot be
checked from inside the app.

*The second screen.* One axis' values, **no quote**, the same right-flush column. `weather` and
`motion` read **alphabetically**, both being short lists a reader already knows the whole of, where
alphabetical is what lets a word be *found*. `people` and `topics` read **most written first**, both
growing without limit, so the useful ones rise; **a tie breaks alphabetically**, or two tags written
once each would swap places on every save. A topic keeps its `#`, as it does on a chit (§3.7).

**A value is drawn only if something carries it** — a sky nobody wrote under is not offered, and
`stationary` is never offered because it is never drawn (§3.6.1). An axis with nothing on it says so
in one line rather than showing an empty column.

*Where the column sits.* **At the bottom while it fits, and from the top once it does not**
(ADR-084) — measured against the handset, not guessed at a count, because five weathers fit anywhere
and a year of tags fits nowhere. A list that has overflowed must start at the top, or its first
row — the one written most — would open off the top of the screen.

*The third screen.* Every chit carrying that value, headed by the value, grouped by day
newest-first in the same thread Today and the archive use — so a chit is opened by holding it here
too. **One value at a time**: find is a way *to* a chit, not a query builder, and two values at once
is the question nobody asked on the way in.
