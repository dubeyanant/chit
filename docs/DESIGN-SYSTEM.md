# Design system

**The palette, the three faces, the spacing, the motion and the accessibility floors.** Every token
exists in code as one of the four `ThemeExtension`s in `lib/core/theme/`, and the floors of §6.4
exist as tests; a colour, `TextStyle`, duration or padding written literally in a widget is a
design-system leak (ADR-010). This file and [BEHAVIOUR.md](BEHAVIOUR.md) are the design authority
alongside the [README](../README.md).

## 6. Design system

Dark, single palette.

### 6.1 Colour

| Token | Value | Role |
|---|---|---|
| `--paper` | `#191714` | the ground |
| `--slip` | `#24211C` | a chit's surface |
| `--slip-under` | `#141210` | the pad beneath the open chit |
| `--ink` | `#EDE7DC` | primary text — 14.54:1 on the ground, 13.03:1 on a chit |
| `--ink-muted` | `#A39B8B` | secondary text — 6.49:1 / 5.82:1 |
| `--ink-faint` | `#8F8879` | metadata — 5.08:1 / 4.56:1 |
| `--ink-disabled` | `#5A554C` | a control drawn and not usable — 2.4:1, **under the 3:1 floor on purpose** (ADR-088) |
| `--hair` | `#2E2A25` | borders, rules |
| `--hair-soft` | `#252220` | inner dividers, **on the ground only** — 1.01:1 on a chit, where it is not drawn |
| `--seal` | `#C4664E` | the one accent — the stamp pressed onto a surface |
| `--seal-ink` | `#D2725A` | the same stamp when it has to be *read* as text |
| `--scrim` | `#080706` at 72% | what the recording sheet lays over the page — the one token *meant* to fail, at 2.07:1 |

`--ink` is also exposed as its components so a surface can be tinted at a stated alpha; every tinted
surface is `--ink` or `--seal` over `--paper` or `--slip`, and §6.4 requires each composite to be
measured rather than assumed.

**The seal means now.** One accent, one job: it marks what is live — the tick at `now`, the caret,
the record dot, the ring around today, the pill *while it is playing*. Nothing else. Everything that
is a record rather than a happening is ink: the strip's marks, past's density, the tab pip,
the pill at rest, the microphone, Save (ADR-022). `--seal` is for marks, fills, borders and icons;
wherever the accent carries **words** it lifts to `--seal-ink`, `--seal` measuring 4.09:1 on a chit
where text must clear 4.5:1.

**The ink washes** — hierarchy comes from weight, not colour. The audio pill at rest is `--ink`
3.5%, carrying its duration in `--ink-muted`; **Save** is `--ink` 7% with an `--ink-muted` border
and its label at 10.85:1; past's four density steps are 6 / 12 / 20 / 30%, their numerals
running 12.66:1 down to 5.99:1. Two weights, one system: the microphone and Save share a border,
Save carrying the brighter one and a wash, and **the quiet button** drops its outline altogether —
the sheet's Discard, *Show every day*, Remove, and the editor's Cancel.

**The launcher icon is `--ink` on `--paper` and nothing else** — an opening quote, drawn as artwork
rather than assembled from tokens (ADR-075), so that the icon and the first screen it opens are one
colour. **The launch screen is that same drawing, held as a vector** (ADR-090): Android 12 draws the
icon at 288dp, where the generated bitmap tops out at 432px and arrives soft. The ground under it is
`--paper` at every API level, there being no light theme to flash.

**The map behind find is four washes of `--ink` on `--paper`** (ADR-089): `map-line` 7% for the
towns and rivers, `map-water` 10% for the coast and the lakes, `map-fill` 10% for the city being
stood in, and `map-host` 13% for its edge. **Each is composited, not drawn translucent**, so two
shapes crossing never stack into a fifth surface nobody measured. **`map-host` is the ceiling, and
the text above it set the number** — it is the lightest thing a word comes to rest on, so §6.4 holds
both the column and the quote to 4.5:1 against it, and `contrast_test.dart` asserts that and that
nothing on the map is brighter. **The fix is `map-pin` at 42% on its own disc of `--paper`**, which
is what makes it the same mark whether it lands on the city or off it — and the only number on this
surface measured against paper rather than against the map.

### 6.2 Typography

**Newsreader** is the writing voice — dates, entry text, section labels, tab labels. **Hanken
Grotesk** is UI metadata, stamps and buttons. **Noto Serif Devanagari** is the word चित्त — the
wordmark, and the mark closing Today — and nothing else. Section labels are lowercase serif italic with a hairline running off to the right.

**The wordmark is चित्त and nothing beside it** — 19px in `--ink-muted` (ADR-074). **19, not 16.5**:
Devanagari sets visibly smaller than Latin at a given size, so the size that carries a masthead here
was read off a handset rather than computed. **The same word closes Today** at 13px and half
`--ink-faint` — a full stop on the day, quieter so it is not read twice. That is the one place a
colour token is used at part strength, allowed because the mark is decoration and excluded from
semantics, so §6.4's floor for *functional* text does not reach it. **The wordmark reads as
*Chitt* to a screen reader** and the closing mark is excluded outright, neither being a word
anybody needs pronounced at them.

**Uppercase appears in one place: `LISTENING`** on the recording sheet — a state, shown while a
thing is happening, which should read as a signal rather than as words. The ambient stamp is
lowercase everywhere, in the same words and case wherever a word appears twice, the open chit being
distinguished by being *brighter* rather than by speaking differently; **it is the one place that
carries no time** (ADR-080), so it is one word where the thread is two. Its facts are **spaced
apart, not strung on middle dots**, three items at 11px with a separator between each being five
things to read where there are three — and three is the ceiling, which `edited` reaches and nothing
may pass. Anything that counts or keeps time is **tabular** — a running
timer whose digits change width reads as unstable.

**The date is a label, not a masthead**: weekday and date on one 26px line, the weekday italic in
`--ink-faint` and the date in `--ink`, a display-to-body ratio of 1.58× over 16.5px entry text. The
open chit's field is **17.5px**, where a line inside the slip holds about 40 characters and a serif
starts reading as a page rather than a column; everything that is not the date, the field or the
wordmark is 16.5px. **15px is the exception, and it is one voice rather than a size** — the month
summary and the empty notes are the app speaking *about* a day rather than reporting one, set a step
below chit text in serif italic so they read as an aside.

**A tag is chit text differing in exactly one way** (ADR-082, BEHAVIOUR §3.7). `chitPerson` is
`chitText` in the real italic face — same size, weight, colour and line — and `chitTopic` is
`chitText` in `--ink-faint`, same everything else. **That is why a person drops its `@` and a topic
keeps its `#`**: the slope is a difference §6.4 accepts on its own, and colour is not, so the topic
needs the glyph beside it. Newsreader ships a true italic (`Newsreader-Italic-VF`), so the slope is
drawn rather than sheared.

**`filterWord` is find's column** (ADR-084) — 16.5px Hanken in `--ink`, each word its own
`minTouchTarget` row. **It is the one thing in the app set flush right**: everything else hangs off
the left gutter, and this column is a set of targets rather than prose, sitting where a right thumb
already is. **`quote` is the line above it** — 15px serif italic, §6.2's voice for an aside, which is
what a line nobody signed is. **`--ink-muted`, not `--ink-faint`**: it sits over the map (§6.1,
ADR-089), where `--ink-faint` falls under the floor, and the pill's duration made the same move for
the same reason. The aside survives it — size, face and slope were never resting on colour.

### 6.3 Spacing, shape, motion

**Spacing — 4px base:** 4 / 8 / 12 / 16 / 24 / 32 / 48 / 72. Page gutter 26px. **Every gap and
padding comes off that scale — there are no one-off spacings.** What may sit off it is a
**dimension**: how big a thing is, rather than how far it is from its neighbour. There are four,
each named and each with a reason — the page gutter (26px), the minimum touch target (44px), the
microphone (54px), and the 7px marks on the timeline and thread rail. A dimension is a property of
one component; a gap is a relationship, and relationships are what a scale exists to keep
consistent. A dimension read by exactly one widget stays a constant where it is drawn rather than
entering `ChitSpace`, a token nothing reads being a token nobody checks — and **a constant copied
off the scale still equals it**, which a test asserts. Derived beats placed: the rail runs down the
centre of its mark, and the node is centred on the stamp line it belongs to, an absolute offset into
a block of text being a number that is correct exactly once.

**A screen's heading is one row, `minTouchTarget` tall**, with its words centred in it — `HeadingRow`,
used by Today's date and past's month bar. 44 because a heading row may carry a control and
past's chevrons do; fixed because a row that grows a chevron would otherwise move the words
under it, and switching tab would shift the heading. The editor's header is the same height for the
same reason, off its back arrow. **Every tab opens `s3` under the masthead** (ADR-087) — one value,
in all three, because the rule that a tab switch does not move the heading only holds while they
agree; the masthead's own `s3` sits above it, so the wordmark and the heading are 24px apart.

**Haptics** — three steps, and every one of them goes through `ChitHaptics` (ADR-096), never a bare
`HapticFeedback` call:

| | What it means | Where it fires |
|---|---|---|
| `selected` | something is now chosen or reached | the strip crossing a day boundary (ADR-034) · a hold landing on a chit (ADR-071) · a recording actually starting · a tag tapped (ADR-086) · a date tapped in past |
| `committed` | something now exists | **Save** · **Stop & keep** |
| `destroyed` | something is now gone | deleting a chit, which has no undo |

**The app never buzzes for something it did itself** — the strip is silent when it moves itself, and
that is the rule and not that one case. **Nor for a tab switch**, three tabs tapped all day being
where a vocabulary turns into noise, **nor for a dimmed chevron** (ADR-088), where silence is the
honest answer that nothing happened. A haptic is **not motion** and is not removed by reduced
motion, which costs a user animation and not confirmation that their action landed.

**Radius** — 2px almost everywhere; paper has cut edges. Two exceptions, both tokens: the recording
sheet's top corners at 8px, and past's day tiles at 4px with `s1` between them, the gap
living *inside* each cell so the tap target clears 44px however narrow the screen. **Elevation** —
hairlines carry the structure, the open chit's one faint shadow only seating it against the pad
behind. **The perforation** is holes in the colour of the surface *beneath* the slip, never a dotted
border, 1.55px radius at an 8px pitch, centred so only whole holes are drawn. **Paper grain** is on,
at 5%.

**Motion** — 220ms `cubic-bezier(.2,0,0,1)` is the house pace, and one rule governs the rest:
**things arrive from where they came from, and settle.** A saved chit falls *down* into the thread
because the composer is above it; a kept recording rises *up* because the sheet is below it, and in
the editor a staged replacement does the same while a stored recording does not, opening a chit not
being an arrival. Both are `Arrival`, **told whether to play and never asked twice** — a wrapper
that comes and goes changes the shape of the tree and rebuilds everything under it (ADR-070).

| Kind | Pace |
|---|---|
| Press feedback | 90ms, and **nothing draws it** (ADR-070). The pace stays because ADR-020's rule is argued from it |
| Routine state change | 200–300ms — switching tab, Save arriving |
| Authored arrival | 340–460ms — a chit landing, a recording settling |
| The idle prompt | 700ms, deliberately slower than everything else (§3.3) |
| Exits | always quicker than entrances; a slow dismissal reads as lag |

**The prompt fades and does not rise** — a rise is what the authored moments are for, and borrowing
it makes an offer look like an event; what the prompt needs is to *survive* reduced motion, which is
why it is a fade. **The strip does not travel**: it jumps to now (ADR-071) and is drawn straight
through the page's entrance (ADR-070), a widget being unable to fade, rise and scroll at once and
still look like one thing. **An ambient loop has a period, not a pace, and the period belongs to the
thing that loops** — `ChitMotion.loop` applies §6.4's rule to it rather than holding the number; the
record dot runs at 1.2s and is the only caller. **The live waveform is not a loop**: each bar is a
level the recorder reported, so the wave is data and stops when the voice does (ADR-054).

**The staggered arrival** — fade plus 6px rise, 55ms apart, capped at eight blocks — plays when a
screen is first built and then sheds itself, taking a page's *blocks* since a spacer in the list
would take a turn in the stagger. Returning to a tab costs a 200ms fade and nothing more, Today
being opened many times a day; it does run again when a tapped date rebuilds the archive, because
there it explains why the list changed.

### 6.4 Accessibility floors

- **Contrast** — every text colour clears 4.5:1 against the surface it actually sits on,
  *composited*. `--ink-faint` is tuned to pass on both `--paper` and `--slip` (4.56:1, the tightest
  pair in the app). **Translucent surfaces count as their own surface**: the pill's 3.5% wash drops
  `--ink-faint` to 4.17:1, so the pill's duration is `--ink-muted`. **Any new tinted surface gets
  measured, never inherited.** A ring is a non-text component with a 3:1 floor, which is why today's
  the ring on today sits on paper rather than on the density wash (ADR-046).
- **Colour is never the only difference.** `--seal` is *less* contrasty on `--paper` than
  `--ink-faint` is — 4.56:1 against 5.08:1 — so the accent reads as the accent because of hue, and
  hue is exactly what a signal may not rest on alone. The tick at now is **taller and thinner** than
  the marks around it, and today is a **ring** where other days are fills; a mark differing only in
  `--seal` would clear every ratio and still be wrong.
- **A mark that is the whole of a fact is labelled.** The motion marks say *Walking*, *Travelling*
  and *Flying*, because a motion mark **replaces** a word (ADR-038) — a reader who cannot see it is
  missing the fact, not an adornment. The test is whether removing the drawing removes information;
  if it does not, it carries `ExcludeSemantics` under a labelled parent, as the strip's marks do.
- **Type** — functional text starts at **11.5px**. Quiet comes from weight and colour.
- **Touch targets** — ≥44px, no exceptions. The microphone is 54px, and its target does not shrink
  when the field has text in it.
- **Focus** — a visible ring in `--seal` at the app's one 1.5px stroke, **only on keyboard or switch
  focus**. `FocusRing` draws it and gives the control Enter and Space with it, painted *over* the
  control so nothing moves when focus arrives.
- **Motion** — **movement collapses and feedback does not.** Travel, zoom and every ambient loop
  stop outright, the live waveform included; what survives is opacity and colour. **A loop stops at
  rest, not at nothing**, a mark that stops by disappearing having taken the signal away along with
  the movement. **The caret is the one stated exception, and it is not ours** (ADR-068).
- **Semantics** — heading levels never skip, and controls that do nothing are not marked up as
  controls.
