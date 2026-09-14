# Design log

Why chit is shaped the way it is. Read this before changing something that looks arbitrary —
most of it is load-bearing.

---

## The register

chit is drawn in the register of Kenya Hara and MUJI: a ground, ink, hairlines, and one
accent. Structure is carried by 1px rules and spacing rather than by cards and shadows,
because a journal should feel like paper rather than like software.

It is dark because journalling happens at night more often than not, and because a single
palette keeps a one-feature app honest.

## The name does design work

चित्त / chit is not only brand copy. It set the central metaphor, and the metaphor set the UI:

- A chit is **small** — entries are short, and the composer never pretends to be a page.
- Chits **accumulate** — the day is a stack, and the open chit rests on a visible pad.
- Chits are **torn off** — hence the perforated edge on the composer and the recording sheet.
- चित्त is the **field where impressions land** — hence ambient capture. The moment is part of
  the record, not just the words.

The perforation is drawn as **holes, not as a line**. The dots are the colour of the surface
*beneath* the slip, so the edge reads as punched through paper. Drawn in a hairline tone they
would be lighter than the slip, which is a dotted border — a different object entirely, and
one that says nothing about tearing. It is a two-character difference in the CSS and the
whole metaphor rests on it.

The Devanagari mark appears twice: beside the wordmark, and as a closing mark at the foot of
each scroll. Both are toggleable in the prototype — whether it reads as grounding or as
decoration is a judgement worth revisiting.

## The pieces that carry the most weight

**The day arc.** The home screen is about today, so its rhythm signal is about today: a line
from 5am to midnight with a mark where each chit landed, and a pulsing ring at now. It also
does double duty as the rule under the date, which is why the header carries no separate line.

**The thread.** Chits hang off a vertical rail rather than sitting in a list of cards. A day
reads as one continuous thing, which is what makes several-chits-a-day legible at a glance.

**The pad beneath the composer.** A second slip, offset a few pixels, implying more where
this came from.

**The calendar as a shape.** A date carries a number when something was written that day, and
the tile's warmth scales with how much. What the month shows is the shape of what was
written — a sparse field in a quiet month, a dense one in a full month — rather than a grid
of thirty numbers to be read one at a time.

**The pin without a place name.** Knowing a location was captured is context. Naming it is
noise, and a privacy surface with nothing to show for it.

## Write and Speak as equals — and then as one surface

*Superseded in part. The reasoning stands; the shape it produced does not.*

The original composer offered Write and Speak as two buttons identical in size, weight, border
and type. The symmetry was the decision: the moment one gets a fill colour or more height, the
app has quietly declared that typing is the real way and speaking is the fallback — or the
reverse.

That symmetry existed to keep a **choice** fair. Once a chit could hold both text and audio
(see below), there was no longer a choice to keep fair, and the fork became a tap charged for
nothing. The composer is now one surface: a live field with a microphone beside it.

The concern survives the change and gets harder, not easier. A field is large and a microphone
is small, so equality can no longer come from matching dimensions — it has to come from the
microphone being **always reachable and never a step**. It is there on an empty chit and on a
half-written one, it never clears what is in the field, and its target does not shrink when
text appears. The failure mode to watch for is the microphone drifting into a toolbar of small
grey icons, at which point speaking has quietly become a feature and typing has become the app.

Symmetry has to hold **optically**, not just in the stylesheet. The two icons are drawn in
different viewBoxes, so identical `stroke-width` values do not produce identical strokes on
screen — at one point Write rendered a 1.28px stroke against Speak's 1.15px, and the pair
stopped looking equal for reasons no one could name by reading the code. Effective stroke is
`stroke-width × (rendered size ÷ viewBox size)`, and across the in-app icon set it is held at
about 1.22px. Any new icon has to be normalised the same way; matching the number in the
markup is not the same as matching the weight in the eye.

## A spoken chit stayed spoken — reversed

**This rule is gone.** The transcript is editable, a chit can hold both audio and text, and
there is no lock line. What follows is why it existed and why it did not survive, because the
argument for it was a good one and will be made again.

The argument was: a spoken chit is a recording of a moment, and a hand-corrected transcript is
a third thing — neither what was said nor what was written. Keeping the modes separate keeps
each honest, and keeps the data model simple; nothing straddles.

What it got wrong was who was being protected. The rule protected the *record* from the user,
and the user was not the threat. The engine was. Speech recognition mishears names, mishears
place names, and comes apart on English-Hindi switching, which is not an edge case here — it is
how people talk. A locked transcript means watching the app write down something you did not
say and having no way to fix it. "What was said is the record" is a fine principle right up
until the machine is the one deciding what was said.

The resolution is that the **audio** carries the moment, not the text. It is kept whatever
happens to the words, it is never editable and never removable, and it is always playable. With
the recording safe, correcting a word costs nothing that was worth protecting. Two records of
one moment: the audio is what was said, the text is what the chit says.

The cost is a schema where `text` and `audioPath` are both nullable with only "at least one"
enforced, and a `textOrigin` marker so a future re-transcription can tell the machine's words
from the user's. That is more state than `source: typed | spoken`, and it is the right trade.

## Failed transcription keeps the voice

When the engine returns nothing usable, the audio is kept and **nothing is written into the
field automatically.** Nothing partial or approximate.

A garbled transcript is worse than none: it is unsearchable, it misrepresents what was said,
and it sits in the archive looking like a record. The recording is the real artefact, and it
still plays. This matters most for Hindi, for code-switching, and for noisy places — which is
to say, for a large share of real use.

This rule survived the reversal above, because it was never about the lock. It constrains what
the **machine** writes, not what the user may. The field stays empty and stays theirs: they can
type into it, or save a chit that is only a recording. Refusing to auto-fill and refusing to
let anyone edit are two different rules, and only the second was wrong.

`text` and `audioPath` are therefore independently nullable in the schema, with at least one
always present.

The failure line lives *beside* the chit's body, never inside it. The distinction is not
cosmetic: anything sitting in the body is the chit's text, and the moment a state message is
written there it gets saved, indexed, and read back months later as though the user had said
it. A note about a chit and the content of a chit are different kinds of thing, and the
layout has to keep them apart.

Now that the body is an editable field this gets stricter, not looser. A note written into a
field is a note the user has to delete before they can write, and one they will sometimes
forget to delete. Placeholder text has the same problem in a milder form and is the tempting
shortcut here; it is not one.

## A past chit is not a control — yet

Saved chits **are** editable; §8.1 settled that when the transcript became editable, since
there is no principled reason the text stops being the user's the moment it is saved.

**Where has now been settled too** (14 September 2026, ADR-017): a screen of its own, not
inline in the thread. The deciding argument is the one this section is about. Today already
carries a live writing surface at the top of it, and putting a second editable field in the
rows below would mean the screen has two places a cursor can be and no way to tell which a tap
is aiming at. The thread is where chits are read. Reading surfaces that quietly become writing
surfaces are how a calm screen stops being one.

Leaving that editor with unsaved changes asks. That is not a general appetite for
confirmations — it is the difference between the two things being thrown away. Discarding an
open chit throws away something that was never a record, and §3.1 gives it no prompt on
purpose. Discarding an edit throws away a change to something that *is* a record, and the user
cannot get it back by remembering what they meant.

So the rule below still holds until the editor actually ships in M6, and for the same reason it
always did: nothing in the thread is dressed as pressable — no pointer cursor, no accent on hover, no button semantics, no
focus stop. The audio pill is the one control in the row.

An affordance that does nothing is worse than a missing one. It costs a tap to discover, it
teaches that taps here are ignored, and for anyone on a keyboard or a screen reader it is a
stop that leads nowhere. The affordance arrives with the editor, in the same change, and not
before it.

And wherever the editor lands, one thing does not move: **a chit's audio is not editable and
not removable.** Editing changes what the chit says, never what was said. A chit that is only a
recording can gain text; a chit with a recording cannot lose it.

## Motion has exactly two moments

One rule generates all of it: **things arrive from where they came from, and settle.** A
saved chit falls down into the thread because the composer is above it. A kept recording
rises up into the open chit because the sheet is below it. Direction is never decorative — it
is the only thing telling you where a thing came from.

Everything else is feedback rather than authorship, and is priced accordingly: 90ms for a
press, 200–300ms for a routine state change, and always faster leaving than arriving.

Two traps worth remembering:

**Press feedback is not optional on a phone.** Every hover state in the app is dead to a
finger. Without a depress on the primary controls, touch gets no acknowledgement at all.

**An entrance is not a transition.** The staggered arrival is a first impression; replaying
it whenever a tab regains visibility turns a routine switch into a 600ms wait, several dozen
times a day. It plays once, sheds itself, and runs again only when a render actually changes
what is on screen.

## Reduced motion is quieter, not silent

The easy implementation — collapse every duration to zero — is wrong, because it does not
distinguish movement from feedback. Fades, colour changes and the scrim are how the interface
confirms that something happened; deleting them along with the travel leaves a user with
vestibular sensitivity worse off than everyone else, not merely calmer.

So under `prefers-reduced-motion` the travel goes: no rise, no slide, no depress, no zoom, and
every ambient loop stops. The fades stay — 140ms on transitions, 220ms on arrivals, which
still announce themselves while going nowhere.

## Constraints to preserve

**`--ink-faint` sits on two surfaces.** It appears on both `--paper` and `--slip` and has to
clear 4.5:1 on both — which is why it is `#8F8879` and not something lighter. Changing the
chit surface or this token means rechecking both pairs.

**Functional text starts at 11.5px.** Quiet typography is not small typography. Restraint
lives in weight and colour; below about 11px, labels simply stop being readable on a real
handset in real light.

**Placeholder copy shapes how a design reads.** Sample chits should be four words long and
mundane — *"Train 20 late."* Literary sample entries make the whole screen read as a
demonstration rather than as a tool, and they set the wrong expectation for what a chit is.

**One accent, in two weights.** `--seal` earns its force by being the only colour in the app.
Every new element should reach for ink, hairline, or spacing first. Where the accent has to
be *read* rather than seen it lifts to `--seal-ink`: `--seal` measures 4.23:1 on a chit
surface, which is fine for a mark and short of the floor for a word. Marks, fills, borders
and icons take `--seal`; text takes `--seal-ink`. Keeping that split is what lets the accent
stay saturated instead of being compromised into a colour that is neither.

**Translucent surfaces are their own surface.** The audio pill washes 7% `--seal` over the
slip, which lifts the ground under it enough to drop `--ink-faint` from 4.71:1 to 4.36:1 —
a failure produced by a background that is barely visible. Contrast has to be measured
against the *composited* result, not against the token the element nominally sits on. Any new
tinted surface needs rechecking rather than an inherited assumption.

## Speech stays on the device

Recognition runs on the handset — the same on-device dictation a phone keyboard uses. An
earlier version of this design named Google Cloud Speech-to-Text, which would have been more
accurate and would also have meant every recorded thought leaving the device.

For a private journal that is the wrong default, and the accuracy argument is weaker than it
looks: the transcript is now editable, so the gap between a good engine and a fair one is a few
seconds of correction rather than a permanent error in the record. On-device also works with no
connection, which is where a lot of writing actually happens — a train, a basement, a flight.

The cost is real and should be stated plainly. On-device models are worse, they vary by
handset, and on some devices or some languages there will be no model at all. That last case is
not an error state of its own: it is the §3.5 failure path, the audio is kept, and the field is
empty and waiting.

A cloud engine is not ruled out forever. It is ruled out until someone can say what happens to
the audio, and that is a privacy decision rather than a technical one.

## Open threads

See OPEN-QUESTIONS.md §8. The one closest to the surface is re-transcription: a chit whose audio was kept
without text is a natural candidate for a second attempt — on a better model, or once a
language pack is installed. The data model already allows it, and `textOrigin` is there so that
an attempt can refuse to overwrite words the user typed themselves.
