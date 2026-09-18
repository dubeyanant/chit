# Tasks — the current milestone, broken down

**M7 — Motion and the floors.** What [BUILD-PLAN.md](BUILD-PLAN.md) M7 says is *done*, cut into
five groups that can each be built, tested and committed on their own. The last milestone of v1.

This file holds **one milestone at a time** and is replaced wholesale when the next one starts.
It is the working list; [PROGRESS.md](PROGRESS.md) is the handover.

**Cut on 18 September 2026.** The authority is DESIGN-SYSTEM.md §6.3 (the pace table and the
three authored moments) and §6.4 (the floors). Much of the groundwork exists: `ChitMotion`
carries the five paces, `fade`/`travel`/`loop` already collapse under reduced motion and
`chit_motion_test.dart` holds the re-timing floors; `BranchFade` gives a returning tab its
200ms fade; the timeline already scrolls to now (`animateTo`, `jumpTo` under reduced motion);
the record dot loops through `ChitMotion.loop`; the prompt and Save already fade. What is
missing is the depress, the stagger, the two authored arrivals, focus rings, and the audit.

**Deliberately not in M7:** anything from OPEN-QUESTIONS.md §9, migrations (open item 38), a
settings screen (item 22), the type comparison (item 1). M7 changes no schema and no behaviour;
it changes how the existing behaviour arrives.

---

## The decisions it turns on

| | Decision | Where |
|---|---|---|
| **D1** | **Reduced motion is one flag, already resolved.** `context.motion.reduceMotion` comes from `MediaQuery.disableAnimationsOf`; every new animation reads `context.motion` and nothing else, and no widget checks the platform itself | ADR-020, §6.4 |
| **D2** | **Press feedback is a depress on top of the wash, never instead of it.** 0.985 on the buttons and the microphone, 0.99 on the pill, at `ChitPace.press`; under reduced motion the depress collapses and the wash stays. The scale factors are named in `ChitMotion` and asserted in a test | §6.3's pace table |
| **D3** | **The stagger runs on a screen's first build only, and sheds itself.** One widget in `shared/widgets/` owns it; a tab regaining visibility gets `BranchFade` and nothing more; the archive re-runs it only when a tapped date rebuilds the list. The delay per row and the cap are a pure function | §6.3 |
| **D4** | **The two authored arrivals travel from where they came from**: a saved chit falls down into the thread, a kept recording rises up into the open chit. Both are `ChitPace.arrival` and both become a plain 220ms fade under reduced motion (`ChitMotion.fade` already does this) | §6.3, ADR-020 |
| **D5** | **Focus rings are `--seal`, drawn by `FocusableActionDetector`, and only on keyboard or switch focus** — never on touch. One decoration in `shared/widgets/`, used by every control | §6.4 |
| **D6** | **The caret (open item 14) is closed as a stated limit, not a fix.** Flutter offers no public way to steady the caret without hiding it, and the keyboard blinks regardless. §6.4 says so in one sentence, and the item closes. A framework issue is filed only if it costs nothing | §6.4, item 14 |
| **D7** | **Arithmetic floors are tests; perceptual floors are a handset.** Target sizes named in `ChitSpace` and the two scale factors are asserted in `widget_constants_test.dart`; whether a target can be hit, whether the stagger reads as one movement and what a screen reader says are group E, written into PROGRESS.md as seen | ADR-031 |

---

## A. Press feedback

*The smallest group and the one every later group is felt through, so it goes first.*

- [ ] `ChitMotion` gains the two scale factors, `pressDepress` (0.985) and `pillDepress`
      (0.99), and a `depress(ChitPace.press)` that is the full duration or zero under reduced
      motion (D1, D2).
- [ ] A `Pressable` in `shared/widgets/` — the depress, the wash callback and the tap in one
      place — that `PrimaryButton`, `QuietButton`, `Microphone` and `AudioPill` are built on.
      `ChitRow` keeps its hold and gains nothing here; its wash is its feedback.
- [ ] The calendar's day tile keeps its own `AnimatedScale` on selection — that is a state, not
      a press.
- [ ] Tests: the factors and the pace in `widget_constants_test.dart` and `chit_motion_test.dart`;
      that the depress is zero under reduced motion and the wash is not.
- [ ] Docs: DESIGN-SYSTEM.md §6.3 if a figure moved; ARCHITECTURE.md §2 for the new widget;
      README.md §10.

## B. The staggered entrance

- [ ] `StaggeredEntrance` in `shared/widgets/`: fade plus a 6px rise per child, 55–60ms apart,
      capped at a row count named in `ChitMotion`; plays on first build, then sheds itself so a
      rebuild costs nothing (D3).
- [ ] Today's page and the archive use it; the open chit and the timeline are children of it,
      not exceptions to it. `BranchFade` is untouched.
- [ ] The archive re-runs it when a tapped date rebuilds the list, and only then.
- [ ] Under reduced motion: a plain fade, no rise, `ChitMotion.fade(ChitPace.arrival)` (D1).
- [ ] Tests: the delay for the n-th child, the cap, and that a shed entrance schedules nothing.
- [ ] Docs: DESIGN-SYSTEM.md §6.3's stagger paragraph if anything about it moved; README.md §10.

## C. The two authored arrivals

- [ ] **A saved chit falls down into the thread**: the new row arrives from above at
      `ChitPace.arrival`, the rows below it settling, and the timeline's scroll to now is the
      same moment (already built, ADR-024).
- [ ] **A kept recording rises up into the open chit**: the pill arrives from below at
      `ChitPace.arrival` when the sheet's *Stop & keep* lands it (D4). *§6.3 says "then its
      words landing in the field" — there are no words since ADR-058; the pill is the whole of
      it, and §6.3 is corrected.*
- [ ] The editor's pill, arriving after a staged replacement, does the same.
- [ ] Under reduced motion both are a fade at 220ms and nothing moves (D1, D4).
- [ ] Tests: none beyond `chit_motion_test.dart`'s existing arrival floor; the rest is group E.
- [ ] Docs: DESIGN-SYSTEM.md §6.3 for the words that no longer land; BEHAVIOUR.md §3.4 if the
      moment is described there.

## D. The floors

- [ ] **Targets.** Every control at or above 44px: the back arrow, both button weights, the
      pill, Remove, the calendar's tiles and month arrows, the timeline if it is a control at
      all. Named dimensions go in `ChitSpace` and are asserted (D7).
- [ ] **Focus rings.** A `--seal` ring on every control on keyboard focus, through one
      decoration (D5). Never on touch.
- [ ] **Semantics.** Heading levels never skip; every icon-only control has a label; a control
      that does nothing is not marked up as one; `ExcludeSemantics` only under a labelled
      parent; the live regions still say the right thing.
- [ ] **The caret**: closed as D6 says, in §6.4 and PROGRESS.md item 14.
- [ ] Tests: the target arithmetic in `widget_constants_test.dart`; `contrast_test.dart` for any
      surface the depress or the ring touches.
- [ ] Docs: DESIGN-SYSTEM.md §6.4; BEHAVIOUR.md §4 if a control gained a label worth naming.

## E. The device pass and the sign-off of v1

*What no test can settle. Seed first — `flutter run --dart-define=CHIT_SEED=seed`, `=clear`
after. Write what was seen into PROGRESS.md group by group, not at the end.*

- [ ] **Carried from M6 (ADR-067):** the editor's pill sits between the stamp and the words,
      Remove beside it, on a stored recording and on a staged replacement alike.
- [ ] **Carried from M6:** a chit opens on a hold, not a tap — the wash on touch, gone on a
      scroll, a tick as it opens. A tap on the row does nothing; a tap on its pill still plays.
- [ ] **Carried from M6:** two recordings on Today; tap one, then the other while the first
      sounds. The second lights with the pause glyph, and the next tap pauses it.
- [ ] The depress on every control, and that a phone reads it as acknowledgement rather than
      as lag.
- [ ] The stagger on Today's first build, reading as one movement; a tab switch costing a fade
      and nothing more; the archive re-staggering on a tapped date and not on a scroll.
- [ ] A chit falling into the thread and the strip scrolling to now; a recording rising into
      the open chit.
- [ ] **Reduced motion on, the whole app**: nothing travels, every fade survives, the prompt
      still appears, the wave is a ragged static row, the record dot is still.
- [ ] **A screen reader, the whole app** (TalkBack): every screen in reading order, every
      control announced with what it does, headings never skipping, nothing announced that is
      decoration.
- [ ] Every target hit with a thumb, including the microphone with text in the field.
- [ ] Then: BUILD-PLAN.md M7 signed off with what it taught, PROGRESS.md marks v1 done, and
      this file is replaced by whatever comes after v1 — or by nothing.

**This file is replaced when the next milestone starts** (CLAUDE.md §2).
