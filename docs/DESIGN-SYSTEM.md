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
| `--slip` | `#211E1A` | a chit's surface |
| `--slip-under` | `#141210` | the pad beneath the open chit |
| `--ink` | `#EDE7DC` | primary text |
| `--ink-muted` | `#A39B8B` | secondary text — 6.49:1 on the ground, 6.02:1 on a chit |
| `--ink-faint` | `#8F8879` | metadata — 5.08:1 on the ground, 4.72:1 on a chit |
| `--hair` | `#2E2A25` | borders, rules |
| `--hair-soft` | `#252220` | inner dividers |
| `--seal` | `#C4664E` | the one accent — the stamp pressed onto a surface |
| `--seal-ink` | `#D2725A` | the same stamp when it has to be *read* as text |

**One accent, used sparingly.** `--seal` is the red of a stamp pressed onto paper: the caret,
the day-arc marks, the calendar heat field, the active tab dot, audio waveforms, the
microphone, and the Save button.

The accent is one colour in two weights, and which one to use is decided by the job, not by
taste. `--seal` is for marks, fills, borders and icons — anything read as a shape. Wherever
the accent has to carry *words* it lifts to `--seal-ink`, because `--seal` measures 4.23:1 on
a chit surface and text has to clear 4.5:1. That covers the **listening** label on the
recording sheet and the **now** cap on the day arc.

### 6.2 Typography

- **Newsreader** — the writing voice. Dates, entry text, section labels, tab labels.
- **Hanken Grotesk** — UI metadata, stamps, buttons.
- **Noto Serif Devanagari** — the चित्त mark.

Section labels are lowercase serif italic with a hairline running off to the right. Uppercase
appears in one place, the ambient stamp, because a stamp should look stamped.

Anything that counts or keeps time is set in tabular figures — the ambient stamps, chit
times, the recording clock and audio durations. A running timer whose digits change width
reads as unstable, and a column of times that does not align reads as careless.

Display-to-body ratio is roughly 2.3× (38px date over 16.5px entry text).

### 6.3 Spacing, shape, motion

- **Spacing** — 4px base: 4 / 8 / 12 / 16 / 24 / 32 / 48 / 72. Page gutter 26px.
- **Radius** — 2px almost everywhere; paper has cut edges. The recording sheet's top corners
  are the one exception at 14px.
- **Elevation** — hairlines carry the structure. The open chit has one faint shadow so it
  lifts off the pad behind it.
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
  *composited*. `--ink-faint` is tuned to pass on both `--paper` and `--slip`. Translucent
  surfaces count as their own surface: the audio pill's 7% `--seal` wash lifts the ground
  under it enough to fail `--ink-faint`, so its duration is set in `--ink-muted`. Any new
  tinted surface needs the same check rather than an inherited assumption.
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

`design/chit-app-v5.html` — one self-contained file, no build step.

`design/chit-app-v4.html` is kept beside it. v4 predates §3.2 and §3.4: it opens the chit with
Write and Speak as two exclusive buttons and locks a spoken chit's transcript. It is history,
not a second option.

Live in it:

- The field is a real editor from the moment the page loads; the 5-second prompt is genuine.
- The microphone opens the recording sheet and accrues a transcript. **Stop & keep** appends it
  to whatever is already in the field and leaves it editable, and the microphone retires.
- Recording into a chit that already has typed text works, and shows the append rule.
- Save adds the chit to today's thread and updates the count, the day arc, the calendar heat
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
| **Weather word**, **चित्त mark**, **Paper grain** | the three judgement calls still worth looking at both ways |
| **Idle prompt** | suppresses the 5-second prompt of §3.3 |

Deliberately not wired, because they belong to the real app rather than to a design review:

- **Month navigation.** The prototype holds September 2026 only. Both chevrons are shown
  disabled rather than offering a move that goes nowhere.
- **Opening a past chit.** §8.1 has settled that saved chits are editable, but not where that
  editor lives — so the thread still carries no affordance. It arrives with the editor.
- **A second recording on one chit.** One chit holds one recording (§3.2), so the microphone
  retires rather than offering a take that would destroy the first.

Sample content is placeholder and deliberately mundane — real chits are four words long.

