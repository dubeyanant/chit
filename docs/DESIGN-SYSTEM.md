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
| `--scrim` | `#080706` at 72% | what the recording sheet lays over the page — the one translucent token, and the one that is *meant* to fail: ink behind it measures 2.07:1 |

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
| Microphone, pressed | `--ink` 10% | the open chit | prototype only — ADR-071 |
| Audio pill, pressed | `--ink` 8% | a chit, or the ground | prototype only — ADR-071 |
| The quiet button, pressed | `--ink` 6% | wherever one is | prototype only — ADR-071; the label lifted to `--ink` |
| A chit in the thread, pressed | `--ink` 6% | the ground | prototype only — ADR-071; the stamp lifted to `--ink-muted`, 4.42:1 against 5.65:1 |
| Calendar, one chit | `--ink` 6% | the ground | numeral in `--ink`, 12.66:1 |
| Calendar, two | `--ink` 12% | the ground | 10.69:1 |
| Calendar, three | `--ink` 20% | the ground | 8.31:1 |
| Calendar, four or more | `--ink` 30% | the ground | 5.99:1 |

Two weights, one system: the microphone and Save share a border, Save carries the brighter one
and a wash, and **the quiet button** drops its outline altogether — the recording sheet's
Discard, *Show every day*, and **Remove** on a pill. A solid `--seal` bar was the loudest thing
on the screen the moment a word was typed, and it made the outlined microphone beside it look
like a control borrowed from another app.

**The hover rows are the prototype's, not the app's.** `ChitColors` carries the resting and
pressed washes and no hover ones: a finger gets no hover, and pressure is the only feedback
touch has (the design log). The prototype runs in a browser and needs them; the phone app does
not, and web is after v1 (ADR-019). That is when they get added — and measured.

**Nothing draws the four pressed rows above** — ADR-070 and ADR-071. The app has no press
feedback at all: the owner saw a depress and a wash together on a handset, called the colour
artificial, and took the whole effect off over two looks, the chit row's included. A control's
answer is the thing it does, and a held row is answered by the phone's tick. The rows stay for
the reason the hover rows below them do — as the record, and as what a browser will want — and
`ChitColors` carries no token for any of them.

**And why text on a wash lifts.** `--ink-faint` clears the floor on a bare chit at 4.56:1 and
fails on *any* wash — 4.12:1 at even 4%. So wherever a wash is drawn, the text on it goes up
with it: the quiet button's label to `--ink`, a chit row's stamp to `--ink-muted`. *Neither wash
is drawn any more (ADR-071), so neither lift is;* the rule is kept because **any new tinted
surface inherits it**, and §6.4 makes no exception for a surface that is brief.

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
day should look empty (BEHAVIOUR.md §4.1). M4 added the summary's other half,
`monthSummaryStrong` — *22 chits* set upright at 500 in `--ink`, in tabular figures because it
counts — and `dayHeading`, the 16.5px upright serif over a day in the archive, which is the
day-heading place the paragraph above already names.

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

  *M2 group H added a fifth and then took it back.* The marker at now was v6's 11px ring, and it
  spent two builds trying to be an object on the strip before ADR-036 made it a **tick**: 1.5px
  wide — the field's caret weight — and `s3` tall, which is a step rather than a dimension. It is
  the one thing on the strip in `--seal` (ADR-022), and it is findable among a day's worth of 7px
  marks by being *taller and thinner* than they are rather than bigger. Both figures are asserted
  in `test/core/theme/widget_constants_test.dart`.

  **The day boundary is the same tick, hanging below the line** (ADR-050) — `s3` by 1.5px in
  `--ink-faint`, where the tick at now straddles the line in `--seal`. *It was 1px by `s1` for
  two milestones*, and a 7px mark reaching 3.5px below the line covered all but half a pixel of
  it: the first seeded strip, with a chit at 23:55, had no findable day end. At now's height
  8.5px of it clears the marks, which the same test asserts as *at least a mark's worth*. One
  tick in two places is a smaller vocabulary than two ticks of two sizes, and the strip is six
  pixels taller for it.

  M2 group G put a fourth back: the 5px between a saved chit's stamp and its words is `s1`.
  It also **derived the thread's mark rather than placing it**. *The prototype drops the node
  19px from the top of a row, which is 7px into the row's content;* here it is centred on the
  stamp line it belongs to, which lands it 3px higher and keeps it right when the stamp's type
  size moves. An absolute offset into a block of text is a number that is correct exactly once.

  **M5's three did not grow the list either**, on the same reading that keeps the perforation's
  1.55px off it: the record dot's 7px, the live wave's 38px and the pill's 18px are each one
  widget's geometry, named where they are drawn. Every gap around them is a step — the sheet is
  `s6` down to its state line and `s5` up from its foot, and the pill is padded `s3` where v6
  writes 13px by 12px, which lands it at exactly §6.4's 44px.

  M2 group C put three more of the prototype's odd numbers back on the scale, on that reading:
  the ambient stamp's 11px gaps are `s3`, the pad behind the open chit is offset by `s1` rather
  than 5px across and 6px down, and the perforation's inset from each end of the slip is `s2`.
  **The list of four dimensions did not grow**, and that was the test each of them had to pass.

  **The motion marks of ADR-039 did not grow it either.** The walking figure, the car and the
  plane are drawn at `s3` — the 12px the pin took, in the pin's 14-unit box (the pin itself is
  gone, ADR-066) — at its 1.42 stroke, which renders at about 1.22px and is what every icon in
  the app measures.
  One box, one stroke, one size: an icon set that agreed on none of those would be three
  drawings sharing a row, and §6.2's argument about the stamp not speaking a second dialect
  applies to what is drawn on it as much as to what is written.

  They are **strokes rather than silhouettes**, and that is a legibility floor rather than a
  taste. At 12px an outlined plane's wings and a walking figure's limbs are a unit and a half
  across, which a 1.22px stroke on each side closes into a blob. Three lines that suggest a
  plane survive the size; a traced one does not. A motion mark stands in for the word it
  displaced (ADR-038) and so takes the row's own colour — `--ink-muted` on the open chit,
  `--ink-faint` in the thread. *The pin, while it existed, was fixed at `--ink-faint` as an
  adornment beside the words; that distinction went with it.*

  The thread rail's own position is derived rather than declared: it runs down the centre of
  the 7px mark, so the mark's left edge is flush with the thread's. *The prototype puts the
  rail there and the node 2px to the left of it — a leftover from when the node was offset by
  the page gutter rather than by the thread's own inset. A node the rail does not come out of
  the middle of is a mark beside a line, which is not what "hanging off a rail" means.*

  v6 tightened the vertical rhythm above the slip so the composer sits higher: the timeline and
  the open chit each start one step closer to what precedes them (32 → 24), and the **earlier**
  heading closes up by one (48 → 32). Nothing about the scale changed; four gaps changed which
  step they take.
- **Haptics** — one, and it is the whole list. Scrolling the timeline past a day boundary gives
  a `selectionClick` (ADR-034), which is a detent going by rather than an event happening. A
  haptic is **not motion** and is not re-timed or removed by `prefers-reduced-motion`: §6.4's
  rule is that reducing motion costs a user animation, not confirmation that their action
  landed, and this is confirmation. A second haptic anywhere in the app needs its own argument.
- **Radius** — 2px almost everywhere; paper has cut edges. Two exceptions, both v6 and both
  tokens (`ChitSpace.sheetRadius`, `ChitSpace.tileRadius`): the recording sheet's top corners at
  **8px** (14px in v5 — a phone-OS sheet radius on a surface that is meant to be torn paper),
  and the calendar's day tiles at **4px**, which with a gap between them (5px in v6, 3px in
  v5) read as tiles rather than as a mosaic.

  **The gap between tiles is `s1`, not v6's 5px** — M4, and the rule at the head of this
  section: a gap is a relationship and stays on the scale. It lives *inside* each cell, half on
  each side, so the cell is the full seventh of the row and the tap target clears §6.4's 44px
  on a handset where seven targets and six gaps could not both fit between the gutters; what
  shrinks on a narrow screen is the tile that is drawn, never the one a finger can hit.
  **Today's ring carries one dimension of its own**: the **2px** of paper between the ring
  and the wash (ADR-046), a property of that one component and named where it lives,
  `DayTile.todayRingGap`, with the assertion in `widget_constants_test.dart`. The list of four
  dimensions still did not grow — this one is read by nothing but the tile.
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

  A saved chit falls *down* into the thread, because the composer sits above it — a step of the
  scale, and only the row that was not there a moment ago. A kept recording rises *up* into the
  open chit because the recording sheet sits below; in the editor a staged replacement does the
  same and a stored recording does not, since opening a chit is not an arrival. *This line read
  "the pill first, then the words it produced landing in the field" until ADR-058 — there are no
  words to land, and the pill is the whole of it.* A saved chit's mark also brings the
  **timeline** to it: the strip scrolls to now rather than jumping there, because a mark that
  appears where you were not looking is a mark you have to find (ADR-024). **That is why the
  strip is the one block the page's entrance draws straight through** (ADR-070): it already has
  an arrival, and two at once read as a fault.

  Both are `Arrival`, which is **told whether to play and never asked twice** — a wrapper that
  came and went would change the shape of the tree and rebuild everything under it, which is how
  a recording in the thread lost its tap (ADR-070).

  Those are the three moments in the app with any authorship; everything else is feedback. All
  three are travel, so all three collapse under reduced motion — the timeline jumps to now, and
  the jump is not a lesser version of the behaviour, it is the same behaviour without the
  movement.

  | Kind | Pace |
  |---|---|
  | Press feedback | 90ms, and **nothing draws it** — ADR-070 took the depress and the wash off together, so a control's answer is the thing it does. The pace stays because ADR-020's rule is argued from it: 90ms is already quicker than the reduced target, so it is the fade reducing motion must not slow down |
  | Routine state change | 200–300ms — switching tab, Save arriving once the chit holds something |
  | Authored arrival | 340–460ms — a chit landing, a recording settling |
  | The idle prompt | 700ms, deliberately slower than everything else (§3.3) |
  | Exits | always quicker than entrances; a slow dismissal reads as lag |

  **The prompt fades and does not rise.** *The prototype lifts it 2px as it arrives.* It has a
  pace of its own in that table rather than being filed under authored arrival, and M2 group E
  made the same call for the action row: a rise is what the three moments with any authorship
  are for, and borrowing it makes an offer look like an event. What the prompt does need is to
  **survive** reduced motion, which is why it is a fade — at 140ms it is still an offer, and at
  nothing it is not there at all (ARCHITECTURE.md §4.3).

  **An ambient loop has a period, not a pace, and the period belongs to the thing that loops.**
  A loop's period is a constant on the widget that loops, the way 54px is a constant on the
  microphone, and `ChitMotion.loop` applies §6.4's rule to it rather than holding the number.
  The loops §6.4 names are deliberately not rows above: the record dot runs at **1.2s**,
  which is longer than the prompt's 700ms without being slower motion, and one table holding
  both invites exactly that comparison. **ADR-027**.

  *The caret blink was the example that record was written from, and chit no longer draws a
  caret — **ADR-028**. The pulse at now was to have been the next, and **ADR-036** took the ring
  it came off the strip entirely, so nothing on Today loops at all.* **The record dot is the
  rule's first and only caller** (M5 group D), at the 1.2s above rather than the prototype's
  1.6s — where a doc and v6 disagree on a *pace*, this table is the authority.

  **The live waveform is not a loop and never was one.** v6 bobs twenty fixed bars because a
  browser has no microphone; here each bar is a level the recorder reported, so the wave is
  data and stops when the voice does (**ADR-054**). Under reduced motion it draws v6's fixed
  heights at rest — a ragged static row rather than a flat one, since every bar at the same
  height reads as broken — and does not answer the microphone at all, because a wave that moves
  with a voice is still a wave that moves.

  The staggered arrival (fade plus 6px rise, **55ms** apart, capped at **eight** blocks) plays
  when a screen is first built and then sheds itself — `StaggeredEntrance`, which takes a page's
  blocks rather than a column's contents, since a spacer in the list would take a turn in the
  stagger. The step is a token beside this table and the cap is the widget's, being a count of
  children rather than a duration. Returning to a tab costs a 200ms fade and nothing
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
  **One v6 pair did not clear its floor, and the answer was a shape — ADR-046.** Today's ring
  on the calendar was `--seal` against whatever density tile today happened to be. A ring is a
  non-text UI component, so the floor is 3:1 rather than 4.5:1 — it held on an empty tile
  (4.56:1) and at one or two chits (3.97:1, 3.36:1), and failed at three (2.61:1) and at four
  or more (**1.88:1**). A day with three chits in it is an ordinary day in a product whose
  premise is several a day, so that was not a corner, and OPEN-QUESTIONS.md item 12 carried it for
  two milestones rather than waving it through. M4 moved the ring: it now frames the tile at
  its edge with 2px of paper inside it, so both of its edges meet `--paper` and the pair that
  matters is 4.56:1 every day. `contrast_test.dart` asserts that pair, and keeps the four old
  figures as the record of why the ring moved.

- **Colour is never the only difference.** Found by M2 group I, by asserting the opposite and
  watching it fail: **`--seal` is *less* contrasty on `--paper` than `--ink-faint` is** — 4.56:1
  against 5.08:1. The accent reads as the accent because of its hue, and hue is exactly what a
  signal may not rest on alone. So the timeline's tick at now is **taller and thinner** than the
  chit marks around it (ADR-036), and the calendar's today is a ring where the other days are
  fills: in both, the shape carries the meaning and the colour confirms it. A future mark that
  matched its neighbours' shape and differed only in `--seal` would clear every ratio in
  `contrast_test.dart` and still be wrong.
- **A mark that is the whole of a fact is labelled.** ADR-039's three motion marks say
  *Walking*, *Travelling* and *Flying*. These are not decoration beside
  a word — since ADR-038 a motion mark **replaces** the weather word, so a reader who cannot
  see it is not missing an adornment, they are missing the fact. The test is whether removing
  the drawing removes information: if it does, it carries a `Semantics` label; if it does not,
  it carries `ExcludeSemantics` under a labelled parent, as the timeline's marks do.
- **Type** — functional text starts at **11.5px**. Quiet comes from weight and colour.
- **Touch targets** — ≥44px, with no exceptions. The microphone is 54px, and its target is not
  reduced when the field has text in it.
- **Focus** — every interactive element has a visible ring in `--seal`, at the app's one 1.5px
  stroke, and **only on keyboard or switch focus**. `FocusRing` draws it and gives the control
  Enter and Space with it; a finger leaves no focus behind, so on a phone it costs nothing and
  is drawn never. It is painted *over* the control rather than around it, so nothing moves when
  focus arrives.
- **Motion** — under `prefers-reduced-motion`, **movement collapses and feedback does not.**
  Travel, zoom and every ambient loop stop outright: the caret blink, the breathing record dot.
  **The live waveform stops too, and it is not a loop** — it is twenty levels the microphone
  reported (§6.3, ADR-054), and it freezes at v6's fixed heights rather than going on answering
  a voice, because a wave that moves with a voice is still a wave that moves. *This line used to
  file it under the loops.* What survives is opacity and colour — arrivals become a plain fade
  going nowhere, the scrim still dims, buttons still respond. Reducing motion should cost a user
  animation, not confirmation that their action landed.

  **A loop stops at rest, not at nothing.** Zero is the signal to start no ticker and draw the
  thing still — a mark that stops by disappearing has taken the signal away along with the
  movement, which is the opposite of the sentence above.

  **The caret is the one stated exception, and it is not ours** (ADR-068). chit draws no caret
  of its own (ADR-028), so the only one in the app is the framework's; Flutter offers no public
  way to steady it that does not also hide it, and a stock Android keyboard blinks its own
  whatever the setting says. It blinks, and this sentence is the whole of the answer.
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
  **The app no longer does this** — ADR-058 removed transcription, so Stop & keep attaches the
  recording and leaves the field alone. *The prototype was deliberately left showing the old
  behaviour*; where it and BEHAVIOUR.md §3.4 disagree about the sheet, §3.4 is right.
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

