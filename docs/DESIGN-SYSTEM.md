# Design system

**The palette, the three faces, the spacing, the motion and the accessibility floors** (§6),
and the prototype they were read from (§7).

Every token here exists in code as one of the four `ThemeExtension`s in `lib/core/theme/`, and
the floors of §6.4 exist as tests. A colour, a `TextStyle`, a duration or a padding written
literally in a widget is a design-system leak — ADR-010 says why, and [CLAUDE.md](../CLAUDE.md)
§4.2 forbids it.

This document and [BEHAVIOUR.md](BEHAVIOUR.md) are the design authority alongside the
[README](../README.md). Section numbers are stable across the split: §6.1 is §6.1 wherever it
is cited from, and it lives here. [README §10](../README.md#10-the-map) maps every section to
its file.

---

## 6. Design system

Dark, single palette.

### 6.1 Colour

| Token | Value | Role |
|---|---|---|
| `--paper` | `#191714` | the ground |
| `--slip` | `#24211C` | a chit's surface |
| `--slip-under` | `#141210` | the pad beneath the open chit |
| `--ink` | `#EDE7DC` | primary text — 14.54:1 on the ground, 13.03:1 on a chit |
| `--ink-muted` | `#A39B8B` | secondary text — 6.49:1 on the ground, 5.82:1 on a chit |
| `--ink-faint` | `#8F8879` | metadata — 5.08:1 on the ground, 4.56:1 on a chit |
| `--hair` | `#2E2A25` | borders, rules — 1.26:1 on the ground, 1.13:1 on a chit |
| `--hair-soft` | `#252220` | inner dividers, **on the ground only** — 1.13:1 there, and 1.01:1 on a chit, where it is not drawn |
| `--seal` | `#C4664E` | the one accent — the stamp pressed onto a surface |
| `--seal-ink` | `#D2725A` | the same stamp when it has to be *read* as text |

`--ink` is also exposed as its three components (`--ink-rgb`) so that a surface can be tinted
with it at a stated alpha. That is not an eleventh colour: every tinted surface in the app is
`--ink` or `--seal` at some percentage over `--paper` or `--slip`, and §6.4 requires each
composite to be measured rather than assumed.

***`--slip` moved from `#211E1A` to `#24211C` in v6*** — four points brighter, so a chit reads
as a surface lifted off the ground rather than as a rectangle described by its border. The
hairline and the shadow are unchanged; they no longer have to do the work alone. A chit now
separates from the ground at 1.12:1 where it managed 1.08:1 before.

**Every ratio measured against a chit moved with it**, which is why the figures above are not
the ones this table carried in M0b — and one of them moved through the floor. `--hair-soft` and
`--slip` ended up four points apart, so the divider disappeared on a chit surface. The answer
was not to nudge the token: `--hair-soft` divides on the ground, where it always did and where
it still measures 1.13:1, and the one thing that put it on a chit — Discard's pressed
background — takes an ink wash instead. It is exactly what the design log means by *a surface
token is never a local change*.

#### The seal means now

**One accent, and it has one job: it marks what is live.** The ring at `now` on the timeline,
the caret in the field, the record dot on the recording sheet, the ring around today on the
calendar, and the audio pill *while it is playing*. Nothing else.

*This replaces the v5 rule, which read: "the caret, the day-arc marks, the calendar heat field,
the active tab dot, audio waveforms, the microphone, and the Save button."* Spread that wide,
the accent stopped meaning anything — a thread with three recordings in it ran orange down its
whole left side, and a calendar of a busy month was a field of orange in which today's ring was
just more orange. Everything on that list that is a record rather than a happening is now ink:
the timeline's marks, the calendar's density, the tab pip, the pill at rest, the microphone, and
Save. ADR-022 has the argument.

The accent is still one colour in two weights, and which one to use is decided by the job, not
by taste. `--seal` is for marks, fills, borders and icons — anything read as a shape. Wherever
the accent has to carry *words* it lifts to `--seal-ink`, because `--seal` measures **4.09:1**
on a chit surface and text has to clear 4.5:1. That covers the **listening** label on the
recording sheet and the **now** cap on the timeline. The split survives v6 intact; only the
figure behind it moved, because the surface under it did.

#### The ink washes

Hierarchy that used to come from colour now comes from weight, and the weights are these:

| Surface | Wash | Sits on | What it carries |
|---|---|---|---|
| Audio pill, at rest | `--ink` 3.5% | a chit, or the ground | duration in `--ink-muted` — §6.4 |
| Save | `--ink` 7%, border `--ink-muted` | the open chit | label in `--ink`, 10.85:1 |
| Save, hover | `--ink` 13%, border `--ink` | the open chit | prototype only |
| Microphone, hover | `--ink` 5% | the open chit | prototype only |
| Microphone, pressed | `--ink` 10% | the open chit | |
| Audio pill, pressed | `--ink` 8% | a chit, or the ground | |
| **Discard**, pressed | `--ink` 6% | the open chit | **label lifts to `--ink`** — see below |
| Calendar, one chit | `--ink` 6% | the ground | numeral in `--ink`, 12.66:1 |
| Calendar, two | `--ink` 12% | the ground | 10.69:1 |
| Calendar, three | `--ink` 20% | the ground | 8.31:1 |
| Calendar, four or more | `--ink` 30% | the ground | 5.99:1 |

Three controls, one system: the microphone and Save share a border, Save carries the brighter
one and a wash, and **Discard** drops its outline altogether. A solid `--seal` bar was the
loudest thing on the screen the moment a word was typed, and it made the outlined microphone
beside it look like a control borrowed from another app.

**The hover rows are the prototype's, not the app's.** `ChitColors` carries the resting and
pressed washes and no hover ones: a finger gets no hover, and pressure is the only feedback
touch has (the design log). The prototype runs in a browser and needs them; the phone app does
not, and web is after v1 (ADR-019). That is when they get added — and measured.

**A pressed wash is not decoration.** Under `prefers-reduced-motion` the 0.985 depress is gone
(§6.4), so the wash is the *entire* acknowledgement a press produces, and one that cannot be
seen makes a working control read as a dead one. That is why Discard has a wash at all: v6
pressed it in `--hair-soft`, which measures 1.0145:1 on a chit and is not drawn.

**And why Discard's label lifts.** Its label is `--ink-faint`, which clears the floor on a bare
chit at 4.56:1 and fails on *any* wash — 4.12:1 at even 4%, and the wash is 6%. So while it is
held, the label goes to `--ink`. The prototype already brightens it on hover for the same
reason; this is that rule applied to the state a phone actually has. A pressed state is a
surface text sits on, and §6.4 does not make exceptions for surfaces that are brief.

### 6.2 Typography

- **Newsreader** — the writing voice. Dates, entry text, section labels, tab labels.
- **Hanken Grotesk** — UI metadata, stamps, buttons.
- **Noto Serif Devanagari** — the चित्त mark, and nothing else in the app.

Section labels are lowercase serif italic with a hairline running off to the right.

**The चित्त mark is two styles, because it does two jobs.** `devanagariMark` is 11.5px in
`--ink-faint` beside the wordmark, where it is a name. `closingMark` is **13px at half that
strength**, centred at the foot of Today, where it is a full stop on the day (BEHAVIOUR.md
§4.1) — larger so it is noticed, quieter so it is not read. It is the one place in the app a
colour token is used at part strength, and it is allowed because the mark is decoration: the
prototype marks it `aria-hidden` and the app excludes it from semantics, so §6.4's 4.5:1 floor
for *functional* text does not reach it. M2 group G added it, taking the scale to twenty-six.

**Uppercase appears in one place: `LISTENING` on the recording sheet.** It is a state, it is
shown while a thing is happening, and it is the one label in the app that should read as a
signal rather than as words.

*It used to appear in two. v5 also set the ambient stamp in 11.5px uppercase at `.1em`, on the
argument that a stamp should look stamped.* That gave the open chit a second dialect: the same
three facts were shouted at the top of the slip and murmured under every chit below it, in
different cases and different letter-spacing. v6 sets both in the same words, the same case
and the same size — the open chit is distinguished by being *brighter* (`--ink-muted` against
the thread's `--ink-faint`), not by speaking differently. The weather word is lowercase in both
places: `raining`, not `RAINING`.

*This paragraph read "there is no uppercase" when §6 was first rewritten for v6, which was
wrong — the claim was checked against the ambient stamp and not against the sheet.*

The facts in that line are **spaced apart, not strung on middle dots.** Three items at 11px
with a separator between each is five things to read where there are three.

Anything that counts or keeps time is set in tabular figures — the ambient stamps, chit
times, the recording clock and audio durations. A running timer whose digits change width
reads as unstable, and a column of times that does not align reads as careless.

**The date is a label, not a masthead.** *v5 stacked an italic weekday over a 38px date, a
display-to-body ratio of roughly 2.3×.* It was the largest thing on the home screen and the
first thing the eye landed on, which put the emphasis on what day it is rather than on the
blank slip waiting to be written in. v6 sets weekday and date on **one 26px line** — the
weekday italic in `--ink-faint`, the date in `--ink` — at the same scale and weight as the
month name on the other tab. Display-to-body is now **1.58×** (26px date over 16.5px
entry text), and the slip starts higher up the screen.

Body sizes moved with it. The open chit's field is **17.5px**, down from 19px: at 19px a line
inside the slip held about 34 characters, and 17.5 lands near 40, which is where a serif starts
reading as a page rather than as a column. Saved chit text stays at 16.5px, and the several
places that were set at 16px — section labels, day headings, tab labels, calendar numerals —
are 16.5px too, so that one size covers everything that is not the date or the field.

**15px is the exception, and it is one voice rather than a size.** The month summary and the
empty note — *"Nothing written yet today."*, *"Nothing written that day."* — are the app
speaking about a day rather than reporting one, and they are set a step below chit text in
serif italic so they read as an aside. M2 group C added `emptyNote` to the scale for the
second of them; it is `--ink-faint` where the month summary is `--ink-muted`, because an empty
day should look empty (BEHAVIOUR.md §4.1).

### 6.3 Spacing, shape, motion

- **Spacing** — 4px base: 4 / 8 / 12 / 16 / 24 / 32 / 48 / 72. Page gutter 26px.

  **Every gap and every padding comes off that scale — there are no one-off spacings.** A
  measurement that is not a step is a measurement nobody can reason about later, and the second
  one is always easier to justify than the first. The wordmark's gap is `s2` where the
  prototype sets 7px, because a 1px departure on a baseline-aligned pair is not a departure
  anybody can see and a ninth step would be.

  What may sit off the scale is a **dimension** — how big a thing is, rather than how far it is
  from its neighbour. There are four, each named and each with a reason: the page gutter (26px),
  the minimum touch target (44px), the microphone (54px), and the 7px marks on the timeline and
  the thread rail. A dimension is a property of one component; a gap is a relationship between
  two, and relationships are what a scale exists to keep consistent.

  M2 group G put a fourth back: the 5px between a saved chit's stamp and its words is `s1`.
  It also **derived the thread's mark rather than placing it**. *The prototype drops the node
  19px from the top of a row, which is 7px into the row's content;* here it is centred on the
  stamp line it belongs to, which lands it 3px higher and keeps it right when the stamp's type
  size moves. An absolute offset into a block of text is a number that is correct exactly once.

  M2 group C put three more of the prototype's odd numbers back on the scale, on that reading:
  the ambient stamp's 11px gaps are `s3`, the pad behind the open chit is offset by `s1` rather
  than 5px across and 6px down, and the perforation's inset from each end of the slip is `s2`.
  **The list of four dimensions did not grow**, and that was the test each of them had to pass.

  The thread rail's own position is derived rather than declared: it runs down the centre of
  the 7px mark, so the mark's left edge is flush with the thread's. *The prototype puts the
  rail there and the node 2px to the left of it — a leftover from when the node was offset by
  the page gutter rather than by the thread's own inset. A node the rail does not come out of
  the middle of is a mark beside a line, which is not what "hanging off a rail" means.*

  v6 tightened the vertical rhythm above the slip so the composer sits higher: the timeline and
  the open chit each start one step closer to what precedes them (32 → 24), and the **earlier**
  heading closes up by one (48 → 32). Nothing about the scale changed; four gaps changed which
  step they take.
- **Radius** — 2px almost everywhere; paper has cut edges. Two exceptions, both v6 and both
  tokens (`ChitSpace.sheetRadius`, `ChitSpace.tileRadius`): the recording sheet's top corners at
  **8px** (14px in v5 — a phone-OS sheet radius on a surface that is meant to be torn paper),
  and the calendar's day tiles at **4px**, which with a 5px gap (3px in v5) read as tiles
  rather than as a mosaic.
- **Elevation** — hairlines carry the structure. The open chit keeps its one faint shadow, but
  it is no longer doing the separating: `--slip` is bright enough in v6 that the slip reads as
  a surface on its own, and the shadow only seats it against the pad behind.
- **The perforation** — the holes are **1.55px at an 8px pitch** (1.2px at 6px in v5). At the
  smaller size, in a colour four points off the slip, they were invisible at arm's length; a
  detail nobody sees is a detail not worth drawing. They are still holes in the colour of the
  surface *beneath* the slip, never a dotted border — the design log is emphatic and the
  metaphor rests on it.

  These two figures are not tokens. They are one widget's geometry and they are constants in
  `shared/widgets/perforated_edge.dart`, written there by M2 group C — not in `ChitSpace`,
  because a token nothing reads is a token nobody checks. **The 1.55px is a radius**, which is
  what the CSS gradient stop it was read from measures.

  *The prototype tiles the holes from the left edge and lets the right-hand end clip, which
  leaves a nick at some widths. The widget centres the run instead and draws whole holes only:
  a torn edge is symmetric or it is not a torn edge.*
- **Paper grain** — on by default in v6, at 5% (it was off by default at 9%). Loud enough to
  be seen and quiet enough not to be looked at.
- **Motion** — 220ms `cubic-bezier(.2,0,0,1)` is the house pace. One rule governs the rest:
  **things arrive from where they came from, and settle.**

  A saved chit falls *down* into the thread, because the composer sits above it. A kept
  recording rises *up* into the open chit — the pill first, then the words it produced landing
  in the field — because the recording sheet sits below. A saved chit's mark also brings the
  **timeline** to it: the strip scrolls to now rather than jumping there, because a mark that
  appears where you were not looking is a mark you have to find (ADR-024).

  Those are the three moments in the app with any authorship; everything else is feedback. All
  three are travel, so all three collapse under reduced motion — the timeline jumps to now, and
  the jump is not a lesser version of the behaviour, it is the same behaviour without the
  movement.

  | Kind | Pace |
  |---|---|
  | Press feedback | 90ms; a 0.985 depress, 0.99 on the audio pill. On a phone there is no hover, so this is the only acknowledgement a finger gets |
  | Routine state change | 200–300ms — switching tab, Discard and Save arriving once the chit holds something |
  | Authored arrival | 340–460ms — a chit landing, a recording settling |
  | The idle prompt | 700ms, deliberately slower than everything else (§3.3) |
  | Exits | always quicker than entrances; a slow dismissal reads as lag |

  **The prompt fades and does not rise.** *The prototype lifts it 2px as it arrives.* It has a
  pace of its own in that table rather than being filed under authored arrival, and M2 group E
  made the same call for Discard and Save: a rise is what the three moments with any authorship
  are for, and borrowing it makes an offer look like an event. What the prompt does need is to
  **survive** reduced motion, which is why it is a fade — at 140ms it is still an offer, and at
  nothing it is not there at all (ARCHITECTURE.md §4.3).

  **An ambient loop has a period, not a pace, and the period belongs to the thing that loops.**
  A loop's period is a constant on the widget that loops, the way 54px is a constant on the
  microphone, and `ChitMotion.loop` applies §6.4's rule to it rather than holding the number.
  The loops §6.4 names are deliberately not rows above: the pulse at now runs at **5.2s**,
  which is longer than the prompt's 700ms without being slower motion, and one table holding
  both invites exactly that comparison. **ADR-027**.

  *The caret blink was the example that record was written from, and chit no longer draws a
  caret — **ADR-028**. The rule stands and its first user is now M5's record dot; the loops
  left to build are the pulse at now, the record dot and the live waveform.*

  The staggered arrival (fade plus 6px rise, 55–60ms apart, capped) plays when a screen
  is first built and then sheds itself. Returning to a tab costs a 200ms fade and nothing
  more — Today is opened many times a day, and a re-run entrance would turn that into waiting.
  The stagger does run again when a tapped date actually rebuilds the archive, because there
  it explains why the list changed.

### 6.4 Accessibility floors

Enforced, and verified on every revision:

- **Contrast** — every text colour clears 4.5:1 against the surface it actually sits on,
  *composited*. `--ink-faint` is tuned to pass on both `--paper` (5.08:1) and `--slip`
  (**4.56:1** after v6 brightened the slip — still clear, and now the tightest pair in the
  app; it is why `--ink-faint` is `#8F8879` and not something lighter).

  Translucent surfaces count as their own surface. The audio pill's wash is **3.5% `--ink`** in
  v6, not 7% `--seal`, and it produces the same verdict for a different reason: on a chit it
  drops `--ink-faint` to **4.17:1**, so the pill's duration is set in `--ink-muted` (5.33:1).
  *The v5 figure for this was 4.36:1 under a 7% seal wash.* The rule it taught is unchanged and
  is the reason the table in §6.1 exists: **any new tinted surface gets measured, never
  inherited.**

  The v6 washes were checked in full and all pass: Save's label is 10.85:1 on its 7% wash, and
  the calendar's numerals run 12.66:1 down to 5.99:1 across the four density steps. That last
  figure is why the near-white numeral is gone — see §6.1's note and BEHAVIOUR.md §4.2.
  **One v6 pair does not clear its floor, and it is written down rather than waved through.**
  Today's ring on the calendar is `--seal` against whatever density tile today happens to be.
  A ring is a non-text UI component, so the floor is 3:1 rather than 4.5:1 — it holds on an
  empty tile (4.56:1) and at one or two chits (3.97:1, 3.36:1), and it fails at three
  (2.61:1) and at four or more (**1.88:1**). A day with three chits in it is an ordinary day
  in a product whose premise is several a day, so this is not a corner. PROGRESS.md open
  item 12 carries it; it wants a design answer, not a token nudge.

- **Type** — functional text starts at **11.5px**. Quiet comes from weight and colour.
- **Touch targets** — ≥44px, with no exceptions. The microphone is 54px, and its target is not
  reduced when the field has text in it.
- **Focus** — every interactive element has a visible `:focus-visible` ring in `--seal`.
- **Motion** — under `prefers-reduced-motion`, **movement collapses and feedback does not.**
  Travel, zoom and every ambient loop stop outright: the caret blink, the pulse at now, the
  breathing record dot, the live waveform. What survives is opacity and colour — arrivals
  become a plain fade going nowhere, the scrim still dims, buttons still respond. Reducing
  motion should cost a user animation, not confirmation that their action landed.

  **A loop stops at rest, not at nothing.** Zero is the signal to start no ticker and draw the
  thing still — a mark that stops by disappearing has taken the signal away along with the
  movement, which is the opposite of the sentence above.

  **The caret is the one place this is currently not honoured, and it is not ours.** chit draws
  no caret of its own (ADR-028), so the only one in the app is the framework's, and Flutter
  offers no way to steady it that does not also hide it. PROGRESS.md open item 14 carries the
  detail; M7's pass owns it. Worth knowing before anyone spends a day on it: a stock Android
  keyboard blinks its caret whatever the animation setting says.
- **Semantics** — heading levels never skip, controls that do nothing are not marked up as
  controls, and anything the user typed is escaped before it reaches the DOM.

---

## 7. The prototype

`design/chit-app-v6.html` — one self-contained file, no build step. **This is the visual
target, and it is the only prototype.** When in doubt about a pixel, open it.

*v5 and v4 sat beside it until 16 September 2026 and were deleted.* v5 was superseded by v6 on
15 September — same behaviour, different surface, and §6 above is the list of what changed; v4
was superseded by v5 and predates §3.2 and §3.4 entirely. A superseded prototype beside the
live one is a second option nobody meant to offer, so they are in git and not in `design/`:
`git log --oneline -- design/` finds the commit that removed them. The *before* half of
ADR-022's argument is the only thing either was still good for, and the ADR makes it in words.

**v6 changed nothing about what the app does**, with four exceptions that are screen changes
rather than behaviour changes, all recorded in BEHAVIOUR.md §4: the calendar legend is gone,
the month grid draws only up to today, the pin appears on the open chit alone, and the चित्त
closing mark appears at the foot of Today alone.

> ⚠ **Two places where the specification now leads the prototype.** "When in doubt about a
> pixel, open v6" is otherwise a trap, so they are named here:
>
> - **The timeline.** v6 draws the old day arc — one day, 5am to midnight, fixed width, no
>   scroll. ADR-024 replaced it, and nothing has been drawn of the replacement yet. BEHAVIOUR.md
>   §4.1 is the description; the screen is M2's to invent, and how one day is separated from the
>   next is deliberately still open.
> - **The settings control.** v6 draws a gear and gives it nothing to do. v1 has none.
>
> Everything else in v6 is still the target.

Live in it:

- The field is a real editor from the moment the page loads; the 5-second prompt is genuine.
- The microphone opens the recording sheet and accrues a transcript. **Stop & keep** appends it
  to whatever is already in the field and leaves it editable, and the microphone retires.
- Recording into a chit that already has typed text works, and shows the append rule.
- Save adds the chit to today's thread and updates the count, the timeline, the calendar density
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
| **Weather word**, **चित्त mark**, **Paper grain** | the three judgement calls still worth looking at both ways. Grain now starts **on**, which is the v6 default |
| **Idle prompt** | suppresses the 5-second prompt of §3.3 |

Deliberately not wired, because they belong to the real app rather than to a design review:

- **Month navigation.** The prototype holds September 2026 only. Both chevrons are shown
  disabled rather than offering a move that goes nowhere. v6's grid stops at today for the same
  honesty — a current month drawn to its end is a fortnight of tiles standing for days that
  have not happened. A past month draws in full.
- **Opening a past chit.** §8.1 has settled that saved chits are editable, but not where that
  editor lives — so the thread still carries no affordance. It arrives with the editor.
- **A second recording on one chit.** One chit holds one recording (§3.2), so the microphone
  retires rather than offering a take that would destroy the first.

Sample content is placeholder and deliberately mundane — real chits are four words long.

