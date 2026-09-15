# Design system

**The palette, the three faces, the spacing, the motion and the accessibility floors** (§6),
and the prototype they were read from (§7).

Every token here exists in code as one of the four `ThemeExtension`s in `lib/core/theme/`, and
the floors of §6.4 exist as tests. A colour, a `TextStyle`, a duration or a padding written
literally in a widget is a design-system leak — ADR-010 says why, and [CLAUDE.md](../CLAUDE.md)
§4.2 forbids it.

> ⚠ **This document describes v6. The code still carries v5.**
>
> `design/chit-app-v6.html` replaced v5 as the visual target on 15 September 2026, and this
> document was rewritten to match it the same day. The four theme extensions in
> `lib/core/theme/` were written against v5 in M0b and **have not been re-pointed yet** — so
> `ChitColors.slip` is still `#211E1A`, `ChitType.date` is still 38px, and
> `test/core/theme/contrast_test.dart` still asserts the v5 ratios.
>
> This is the one divergence between a document and the code that is deliberate, and it is
> written down rather than hidden. **[PROGRESS.md](PROGRESS.md) open item 11 is the work**: it
> lists every constant that has to move, and until it is done, this document is the target and
> the code is the past. Nothing else in the repository may be changed to match the code.

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
| `--hair` | `#2E2A25` | borders, rules |
| `--hair-soft` | `#252220` | inner dividers |
| `--seal` | `#C4664E` | the one accent — the stamp pressed onto a surface |
| `--seal-ink` | `#D2725A` | the same stamp when it has to be *read* as text |

`--ink` is also exposed as its three components (`--ink-rgb`) so that a surface can be tinted
with it at a stated alpha. That is not an eleventh colour: every tinted surface in the app is
`--ink` or `--seal` at some percentage over `--paper` or `--slip`, and §6.4 requires each
composite to be measured rather than assumed.

***`--slip` moved from `#211E1A` to `#24211C` in v6*** — four points brighter, so a chit reads
as a surface lifted off the ground rather than as a rectangle described by its border. The
hairline and the shadow are unchanged; they no longer have to do the work alone. Every ratio
measured against a chit surface moved with it, which is why the figures above are not the ones
this table carried in M0b.

#### The seal means now

**One accent, and it has one job: it marks what is live.** The ring at `now` on the day arc,
the caret in the field, the record dot on the recording sheet, the ring around today on the
calendar, and the audio pill *while it is playing*. Nothing else.

*This replaces the v5 rule, which read: "the caret, the day-arc marks, the calendar heat field,
the active tab dot, audio waveforms, the microphone, and the Save button."* Spread that wide,
the accent stopped meaning anything — a thread with three recordings in it ran orange down its
whole left side, and a calendar of a busy month was a field of orange in which today's ring was
just more orange. Everything on that list that is a record rather than a happening is now ink:
the arc's marks, the calendar's density, the tab pip, the pill at rest, the microphone, and
Save. ADR-022 has the argument.

The accent is still one colour in two weights, and which one to use is decided by the job, not
by taste. `--seal` is for marks, fills, borders and icons — anything read as a shape. Wherever
the accent has to carry *words* it lifts to `--seal-ink`, because `--seal` measures **4.09:1**
on a chit surface and text has to clear 4.5:1. That covers the **listening** label on the
recording sheet and the **now** cap on the day arc. The split survives v6 intact; only the
figure behind it moved, because the surface under it did.

#### The ink washes

Hierarchy that used to come from colour now comes from weight, and the weights are these:

| Surface | Wash | Sits on | What it carries |
|---|---|---|---|
| Audio pill, at rest | `--ink` 3.5% | a chit, or the ground | duration in `--ink-muted` — §6.4 |
| Save | `--ink` 7%, border `--ink-muted` | the open chit | label in `--ink`, 10.85:1 |
| Save, hover | `--ink` 13%, border `--ink` | the open chit | |
| Microphone, hover | `--ink` 5% | the open chit | |
| Calendar, one chit | `--ink` 6% | the ground | numeral in `--ink`, 12.66:1 |
| Calendar, two | `--ink` 12% | the ground | 10.69:1 |
| Calendar, three | `--ink` 20% | the ground | 8.31:1 |
| Calendar, four or more | `--ink` 30% | the ground | 5.99:1 |

Three controls, one system: the microphone and Save share a border, Save carries the brighter
one and a wash, and **Discard** drops its outline altogether. A solid `--seal` bar was the
loudest thing on the screen the moment a word was typed, and it made the outlined microphone
beside it look like a control borrowed from another app.

### 6.2 Typography

- **Newsreader** — the writing voice. Dates, entry text, section labels, tab labels.
- **Hanken Grotesk** — UI metadata, stamps, buttons.
- **Noto Serif Devanagari** — the चित्त mark.

Section labels are lowercase serif italic with a hairline running off to the right.

**There is no uppercase.** *v5 set the ambient stamp in 11.5px uppercase at `.1em`, on the
argument that a stamp should look stamped.* It gave the open chit a second dialect: the same
three facts were shouted at the top of the slip and murmured under every chit below it, in
different cases and different letter-spacing. v6 sets both in the same words, the same case
and the same size — the open chit is distinguished by being *brighter* (`--ink-muted` against
the thread's `--ink-faint`), not by speaking differently. The weather word is lowercase in both
places: `raining`, not `RAINING`.

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
month name on the other tab. Display-to-body is now roughly **1.6×** (26px date over 16.5px
entry text), and the slip starts higher up the screen.

Body sizes moved with it. The open chit's field is **17.5px**, down from 19px: at 19px a line
inside the slip held about 34 characters, and 17.5 lands near 40, which is where a serif starts
reading as a page rather than as a column. Saved chit text stays at 16.5px, and the several
places that were set at 16px — section labels, day headings, tab labels, calendar numerals —
are 16.5px too, so that one size covers everything that is not the date or the field.

### 6.3 Spacing, shape, motion

- **Spacing** — 4px base: 4 / 8 / 12 / 16 / 24 / 32 / 48 / 72. Page gutter 26px.

  v6 tightened the vertical rhythm above the slip so the composer sits higher: the day arc and
  the open chit each start one step closer to what precedes them (32 → 24), and the **earlier**
  heading closes up by one (48 → 32). Nothing about the scale changed; four gaps changed which
  step they take.
- **Radius** — 2px almost everywhere; paper has cut edges. Two exceptions, both v6: the
  recording sheet's top corners at **8px** (14px in v5 — a phone-OS sheet radius on a surface
  that is meant to be torn paper), and the calendar's day tiles at **4px**, which with a 5px
  gap (3px in v5) read as tiles rather than as a mosaic.
- **Elevation** — hairlines carry the structure. The open chit keeps its one faint shadow, but
  it is no longer doing the separating: `--slip` is bright enough in v6 that the slip reads as
  a surface on its own, and the shadow only seats it against the pad behind.
- **The perforation** — the holes are **1.55px at an 8px pitch** (1.2px at 6px in v5). At the
  smaller size, in a colour four points off the slip, they were invisible at arm's length; a
  detail nobody sees is a detail not worth drawing. They are still holes in the colour of the
  surface *beneath* the slip, never a dotted border — the design log is emphatic and the
  metaphor rests on it.
- **Paper grain** — on by default in v6, at 5% (it was off by default at 9%). Loud enough to
  be seen and quiet enough not to be looked at.
- **Motion** — 220ms `cubic-bezier(.2,0,0,1)` is the house pace. One rule governs the rest:
  **things arrive from where they came from, and settle.**

  A saved chit falls *down* into the thread, because the composer sits above it. A kept
  recording rises *up* into the open chit — the pill first, then the words it produced landing
  in the field — because the recording sheet sits below. Those are the two moments in the app
  with any authorship; everything else is feedback.

  | Kind | Pace |
  |---|---|
  | Press feedback | 90ms; a 0.985 depress, 0.99 on the audio pill. On a phone there is no hover, so this is the only acknowledgement a finger gets |
  | Routine state change | 200–300ms — switching tab, Discard and Save arriving once the chit holds something |
  | Authored arrival | 340–460ms — a chit landing, a recording settling |
  | The idle prompt | 700ms, deliberately slower than everything else (§3.3) |
  | Exits | always quicker than entrances; a slow dismissal reads as lag |

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
- **Semantics** — heading levels never skip, controls that do nothing are not marked up as
  controls, and anything the user typed is escaped before it reaches the DOM.

---

## 7. The prototype

`design/chit-app-v6.html` — one self-contained file, no build step. **This is the visual
target.** When in doubt about a pixel, open it.

Two earlier versions are kept beside it. Both are history, not second options:

- **`design/chit-app-v5.html`** — superseded by v6 on 15 September 2026. v5's *behaviour* is
  v6's behaviour exactly; what changed is how it looks, and §6 above is the list. Its value now
  is as the before half of that comparison: open the two side by side and the accent rule of
  ADR-022 is the first thing you see.
- **`design/chit-app-v4.html`** — superseded by v5. It predates §3.2 and §3.4: it opens the
  chit with Write and Speak as two exclusive buttons and locks a spoken chit's transcript.

**v6 changed nothing about what the app does**, with four exceptions that are screen changes
rather than behaviour changes, all recorded in BEHAVIOUR.md §4: the calendar legend is gone,
the month grid draws only up to today, the pin appears on the open chit alone, and the चित्त
closing mark appears at the foot of Today alone.

Live in it:

- The field is a real editor from the moment the page loads; the 5-second prompt is genuine.
- The microphone opens the recording sheet and accrues a transcript. **Stop & keep** appends it
  to whatever is already in the field and leaves it editable, and the microphone retires.
- Recording into a chit that already has typed text works, and shows the append rule.
- Save adds the chit to today's thread and updates the count, the day arc, the calendar density
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

