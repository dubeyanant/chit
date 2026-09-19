# Behaviour

**What Chitt does** (§3) **and what it looks like doing it** (§4). This file and
[DESIGN-SYSTEM.md](DESIGN-SYSTEM.md) are the design authority alongside the [README](../README.md);
where another document disagrees, that document is wrong.

## 3. Behaviour specification

**3.1 A chit exists once it is saved.** Opening the app presents a new chit for today; it becomes a
record on **Save**, and opening it six times leaves nothing behind. **A chit is stamped when it is
saved** (ADR-040), so it is always filed on the day it was written; **the open chit shows no time at
all** (ADR-080), a clock drawn before the stamp exists being a preview of a number it cannot
promise. **There is no Discard** (ADR-060) — the words are cleared by selecting them, the recording
by **Remove** on the pill, and the photo by **Remove** beside its frame. **Saving never waits**: the
row is written at once with what is in hand, and a reading older than **one minute** is refreshed
behind the save and the chit corrected a moment later; inside the minute nothing is asked, a burst
of chits in one sitting being one moment (ADR-042, ADR-045).

**3.2 One surface, three ways in.** The field is live the moment the chit opens, with a
**microphone** and a **camera** beside it as equals; there is no mode, and a chit may end up typed,
recorded, photographed, or any of those together (ADR-106). **Tapping the page gives the field
focus; tapping away takes it back** — the keyboard comes up on first touch, never on launch
(ADR-023). The microphone stays an equal by being reachable and never a step: available on an
empty or half-written chit, its target unchanged by text appearing, and using it never discards
what is in the field. **A chit holds one recording**, so once kept the microphone retires and the
text stays editable; **a kept take is dropped by Remove**, and the microphone comes back when it
goes, so recording again is the way to a different take. Remove does not touch the words.
**A chit holds one photo**, and the camera behaves exactly as the microphone does: it retires
once a photo is kept, comes back when **Remove** takes it, and tapping it asks the phone for a new
one — take it now or choose one already there. A photo never touches the words either.

**A refused microphone raises nothing and explains once**: the sheet does not open, the microphone
stays tappable, and the line *"The microphone isn't allowed. You can turn it on in your phone's
settings."* appears under the action row — naming the phone's settings because ADR-094 spends the
app's one permission dialog on location.

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

**A kept recording is played from its pill**, whose bars are the playhead: they fill as it sounds,
**against the length the player decoded rather than the one the row stores** (ADR-103), and a take
that reaches its end rests with every bar lit until it is tapped again, when it starts over.

**3.4.1 The photo.** Tapping the camera raises a sheet with two ways to one photo — **Take one**
opens the phone's camera, **Choose one** its library — and both hand back a single image that is
copied beside the chit and never read again from where it came (ADR-106). It is drawn as a frame
under the stamp: full width, a fixed height, cropped to fill rather than letterboxed. **A refused
camera or library does nothing at all** — no photo is staged and nothing is said, the OS having
already said it.

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

**3.6.3 When capture happens.** At launch, at a save holding something stale (ADR-042, ADR-045),
and **on coming back to the app when what is on screen is half an hour old** (ADR-104); no polling.
**One minute** is set by the **place**, not the weather, and it is the window a *save* uses; the
half hour is the window a *screen* uses, so a glance away costs nothing — but **no chit is ever
recorded with a stale reading**, saving re-reading, so what staleness is left is on the screen and
never in the data. **The place is
asked for at a save** (ADR-094), never at launch and never behind a screen of ours: the OS decides
how many times, a refusal means quieter chits, and nothing in the UI mentions it either way. **The
permission and the phone's location switch are separate asks**, in that order, and the switch is
offered by the OS's own sheet — **once a run**, never again after a no, and not at all until the
permission is held (ADR-102).

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
of them is still one space. **A tag is drawn in lower case however it was typed** (ADR-092):
`@Anant` and `@anant` are one person and read as one word, the fold happening where the tag is read
out of the words so that the chit, the row in find and the route cannot disagree. **The whole tag
counts as one thing**, which is what a search counts later; the stored text keeps what was typed.

**A tag starts at a word start and ends on a letter, a digit or a mark.** `work@example.com` carries
no tag, `@anant.` tags the name and leaves the full stop, `@anant's` leaves the possessive, and a
trailing underscore falls outside rather than drawing as a space nobody can see. Any script — a
Devanagari matra is a combining mark and belongs to the word it sits on.

**A tag is tapped, and the row it sits in is still held** (ADR-086). Tapping `@anant` or `#rent`
anywhere a saved chit is drawn opens find on that tag — **switching tab if it has to**, and
**unwinding to find's root and re-entering** rather than stacking, so back walks *find → that axis
→ that tag* however you arrived and tapping tag after tag never piles a stack up. **It is the one
tap in a thread that does anything**; everything that is not a tag still does nothing, and the row
is still opened by holding it (§4.1). **The editor shows the words as they were typed**, underscores
and sigils and all, because that is what an edit edits — and the raw text is what is stored.

## 4. Screens

**4.0 The shell.** The wordmark above, the tabs below, and whichever tab is up between them.
**The tabs are not drawn until something has been written** (ADR-097): on a fresh install *past* is
an empty grid and *find* has nothing to look through, so tabs that go nowhere are chrome promising
rooms that are not furnished yet. The first save draws them and they stay; deleting the last chit
takes them away again, which is the same screen a fresh install gets and is honest for the same
reason. **They do not fade in** — a bar that travels draws the eye to the movement rather than to
the words, which is ADR-071's finding.

**find is held back further, until it has somewhere to go** (ADR-109): a chit carrying a tag, or a
sky word, or a motion — any axis with a value in it. **`stationary` is not one**, being stored and
never drawn (§3.6.1), so it is no row to arrive at. Until then the bar holds two, evenly divided;
find arrives on the right the moment an axis fills, and goes again if the last value is edited or
deleted away — **and a reader standing in find when that happens is returned to Today**, since the
tab they are in has stopped existing.

**The wordmark opens the guide** (ADR-110). चित्त is on every tab and has never done anything;
tapping it raises a slip of what the app cannot teach in passing — that a chit is **held** to open
it, that `@` names a person and `#` a topic, and that `_` joins words inside a tag and is read as a
space. It is the only place in the app that explains itself. **It shows itself once**, on the first
launch of an install (ADR-111), and **opens with the line that says how to get back to it** — the
first thing read on the one showing nobody asked for is how to ask for it again; after
that it is reached and never shown, and an uninstall is the only thing that resets it.

**4.1 Today (home).** The wordmark — चित्त, and nothing beside it — then weekday and date on
**one line at 26px**, the weekday italic and faint, the date in full ink. **That line and the
past's month sit at the same height** (§6.3), so switching tab does not move the heading. Then
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
**nothing is drawn under the finger** (ADR-071) — what says the hold landed is the phone's own tick,
one of the three the app speaks in (§6, ADR-096).
No chevron: the row *is* the target. A tap does nothing, the thread being a reading surface whose
one tap is the pill's — **a photo in the thread is looked at and not tapped** (ADR-106), the frame
being a mark on the slip and not a control; there is no swipe, deleting living in the editor and not a thumb's width from
a scroll. Before anything is written it reads *"Nothing written yet today."*, with no count, no rail
and no placeholder row.

**4.2 Past.** A date carries a number when something was written that day, and the tile's
density scales with how much — four steps of **ink**, 6% at one chit to 30% at four or more. Today
keeps its number and is ringed in `--seal`, with **2px of paper between the ring and the wash** so
it clears the contrast floor whatever the density (ADR-046). **The current month is drawn up to
today and stops**; a past month draws in full, **but only the weeks with something in them**
(ADR-048), wherever a quiet week falls — within a drawn week every day keeps its cell, numbered or
bare, so a tile's column still says its weekday. **The chevrons land only on months with something
in them** (ADR-047), and **where there is nowhere to go the chevron is dimmed rather than taken
away** (ADR-088) — it is drawn in `--ink-disabled`, does nothing, and tells a screen reader it is
disabled. A control that vanishes moves the one beside it and leaves a reader wondering whether the
app has one. **Their glyphs sit on the gutter**, not the 44px targets around them. Changing the
month
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

**4.4 — retired.** *First run.* The welcome screen is gone and **the app opens on Today** (ADR-094);
the place is asked for at the first save, by the platform's own dialog and with nothing of ours
before or after it. **The number is not reused** — it is cited from other documents and from git.

**4.5 The chit editor.** Reached by holding any chit in the thread, and **it covers the tab bar**
(ADR-062): one task, one way out. The header is a back arrow on the page gutter and the word
*Editing* — not the day, the slip's stamp carrying the time, and not the wordmark, this being
somewhere you came into. **The slip fills the screen** (ADR-066): the saved stamp, the pill and the
photo frame with **Remove** beside each, then the field, then **Cancel** and **Save**, with
*Delete this chit* below the slip. **The slip scrolls its own contents** (ADR-108) — the stamp, the
pill, the frame and the field move together while the action row stays at the foot, so a chit
carrying both a recording and a photo can still be written in with the keyboard up, and the caret is
carried into view as it moves. **The field grows from a floor** rather than taking whatever is left.

**Nothing on this screen can move the stamp** — not the time, the day, the weather, the place or the
motion. An edit changes what the chit says, never when or where it was written, and **a chit whose
row has gone leaves the screen** rather than drawing an empty slip. What an edit does add is the
word `edited` (§3.6.1), which appears on the slip the moment Save returns.

**Save appears once something has changed** — *changed* meaning *differs from what was loaded*, so a
character typed and deleted, or a trailing space the save would trim, is not a change; it is
withheld again if what it would write is no longer a chit. Saving writes the words and whatever was
done to the recording and the photo in one write (ADR-063), moves `updatedAt`, and returns. **Cancel is always
there, and it leaves at once** (ADR-066) — a press on a button that says Cancel is the decision —
while **the back arrow and the system back gesture ask** when something has changed, a swipe not
being a decision. Either way the row is exactly as it was, an edit living nowhere but this screen
until Save.

**The prompt is a slip-style sheet** (ADR-064), the app's one confirmation idiom: paper rising from
below, a question, two answers in the two button weights — **the quiet one always lets go, the
bright one always keeps**, and dragging, tapping the scrim or pressing back keeps. Three acts, three
words: *Discard* throws away something in flight, *Cancel* abandons an edit, *Delete this chit*
destroys a record. **Which answer gets the wide slot is not that rule** (ADR-105): everywhere but
one, the bright *keep* is the wide one; on *Delete this chit* the quiet *Delete* is, with Keep it
small to its left.

**Every change to the recording or the photo is staged until Save** (ADR-063, ADR-065, ADR-106):
Remove stages a removal, the pill or the frame goes and its control comes back; a take kept from the
sheet or a photo taken from the camera is staged as a replacement and is played or drawn from where
it sits until Save moves it in. A removal that leaves the chit with nothing withholds Save, leaving
Cancel and *Delete this chit* — the honest pair.

**Delete this chit** is quiet and apart from the action row, a step of the scale away from Save
rather than an inch from it. It is named in full so it cannot be read as Discard. It asks, and
**there is no undo** (ADR-064) — there is no trash and no backend, and the prompt is the whole of
the protection. **It is not drawn while the keyboard is up** (ADR-108): the step that keeps it
apart from Cancel closes when the slip is squeezed, and two quiet buttons touching read as one
control. It comes back with the keyboard, and a chit is never destroyed from a screen somebody is
writing on.

**4.6 Find.** The third tab, and the way back to a chit you cannot date. **Three screens deep, and
each one is a route** (ADR-084), so the system back walks up a level rather than out of the tab.

*The first screen.* A line at the top, **the same for as long as find is the tab on screen, and a
different one next time it is arrived at** (ADR-093) — walking down to an axis and back is the same
visit, so the line never moves while it is being read. Usually one of
forty-five house lines, and **every fourth one a hint instead** (ADR-086) about something the app
does and does not otherwise say: the tag syntax, that an underscore in a tag reads as a space, that
the question on an empty chit is a different one every time. **A hint lives here rather than under
the thing it describes** — a caption that never goes away is chrome on the sparest screens in the
app, while one that comes round twice a week is read once and then recognised.

Then, at the **bottom right**, four words: `weather`, `motion`, `people`, `topics`. The words are
one touch target apart, with the same space under the last as between any two, so the column reads
as a rhythm rather than a list.

**Only an axis that goes somewhere is drawn** (ADR-085) — a word nobody has written anything under
is not offered, the same argument §4.1 makes against a control that does nothing. A new install
shows one or two words and earns the rest. An app with nothing in it at all says *Nothing to look
through yet.* **While the chits are still arriving, nothing is drawn but the line**: an empty
column is a different answer, and showing it first is a frame of the wrong one.

**This is the one surface in the app that is not left-aligned** (ADR-084). Everything else hangs off
the left gutter; find's column is flush *right*, because it is a set of targets rather than a
reading surface, and the right edge is where a right thumb already is. **The lines are house lines,
not quotations** — nothing is attributed, a misattribution being a defect that ships and cannot be
checked from inside the app.

**Behind the words there is a faint map** (ADR-089) — here and **on the screen one step in**, and
nowhere deeper: the axis screen is still a list of words to choose between, where the screen below
it is the chits themselves and the map behind a body of writing is a texture under text. **It is the
same map, not a second one**: the two screens are the same rectangle of the same branch, so the
framing arithmetic lands on the same answer and nothing has to be kept in step. It shows where the
**newest chit that knew where it was** was
written: the built-up area around that fix drawn **filled**, its neighbouring towns, the coast, the
lakes and the rivers around it left as outlines, and the fix itself the one bright mark, sitting
wherever it actually falls rather than in the middle. The view is **the city and most of the same
again around it** — near enough that a place is recognisable, wide enough that its river or its
coast comes with it — and it opens wider when there is little about, so a town off the edge is
reached rather than lost. **It is a region and never a street**: no roads, no labels, no names.

**Nothing is drawn where there is nothing.** A phone that never got a fix, a first run with no chits
yet, and a fix in open desert with no town, no water and no coast within reach all draw no map at
all — a lone mark on an empty screen reads as a fault rather than as a fact (ADR-007). The map is
**still**: it does not animate, drift or reappear, and it changes only when a newer chit is written
somewhere else, which re-frames it around the new place.

*The second screen.* One axis' values, **no quote**, the same right-flush column. `weather` and
`motion` read **alphabetically**, both being short lists a reader already knows the whole of, where
alphabetical is what lets a word be *found*. `people` and `topics` read **most written first**, both
growing without limit, so the useful ones rise; **a tie breaks alphabetically**, or two tags written
once each would swap places on every save. A topic keeps its `#`, as it does on a chit (§3.7).

**A value is drawn only if something carries it** — a sky nobody wrote under is not offered, and
`stationary` is never offered because it is never drawn (§3.6.1). **An axis with nothing on it is
not reachable from the screen above** (ADR-085), so its one-line note is a backstop for a chit
deleted while the screen is open, not something a reader is meant to arrive at.

*Where the column sits.* **At the bottom while it fits, and from the top once it does not**
(ADR-084) — measured against the handset, not guessed at a count, because five weathers fit anywhere
and a year of tags fits nowhere. A list that has overflowed must start at the top, or its first
row — the one written most — would open off the top of the screen.

*The third screen.* Every chit carrying that value, headed by the value, grouped by day
newest-first in the same thread Today and the archive use — so a chit is opened by holding it here
too. **One value at a time**: find is a way *to* a chit, not a query builder, and two values at once
is the question nobody asked on the way in.
