# Tasks — the current milestone, broken down

**M7 — Motion and the floors.** What [BUILD-PLAN.md](BUILD-PLAN.md) M7 says is *done*, cut into
five groups that can each be built and tested on their own. The last milestone of v1.

This file holds **one milestone at a time** and is replaced wholesale when the next one starts.
It is the working list; [PROGRESS.md](PROGRESS.md) is the handover.

**Cut on 18 September 2026, recut the same day.** The authority is DESIGN-SYSTEM.md §6.3 (the
pace table and the three authored moments) and §6.4 (the floors). What already exists:
`ChitMotion` carries the five paces, `fade`/`travel`/`loop` collapse under reduced motion and
`chit_motion_test.dart` holds the re-timing floors; `BranchFade` gives a returning tab its
200ms fade; the timeline rests at now; the record dot loops through `ChitMotion.loop`; the
prompt and Save fade. What M7 adds is the stagger, the two authored arrivals, focus rings and
the audit — *and a depress, which the owner had it take back out again.*

**Commits.** M7 was to be one commit at group E; the owner asked instead for the work to be
committed as it went, so the session could be picked up later. A commit when the owner asks for
one, not one per group.

**Deliberately not in M7:** anything from OPEN-QUESTIONS.md §9, migrations (open item 38), a
settings screen (item 22), the type comparison (item 1). M7 changes no schema and no behaviour;
it changes how the existing behaviour arrives.

---

## The decisions it turns on

| | Decision | Where |
|---|---|---|
| **D1** | **Reduced motion is one flag, already resolved.** `context.motion.reduceMotion` comes from `MediaQuery.disableAnimationsOf`; every new animation reads `context.motion` and nothing else, and no widget checks the platform itself | ADR-020, §6.4 |
| **D2** | ~~Press feedback is one widget and the depress is a token.~~ **There is no press feedback anywhere.** The owner took the wash off, then the depress, then the chit row's wash; `Pressable` and both depress tokens are deleted, four wash tokens with them, and every control is a plain tap. A held row is answered by the phone's tick | ADR-069, **ADR-070**, **ADR-071** |
| **D3** | **The stagger runs on a screen's first build only, and sheds itself.** One widget in `shared/widgets/` owns it; a tab regaining visibility gets `BranchFade` and nothing more; the archive re-runs it only when a tapped date rebuilds the list. The delay per row and the cap are pure functions. *The step is a `ChitMotion` token and the cap is the widget's — a count of children is not a duration, which is §6.3's own rule about where a loop's period lives* | §6.3 |
| **D4** | **The two authored arrivals travel from where they came from**: a saved chit falls down into the thread, a kept recording rises up into the open chit. Both are `ChitPace.arrival` and both become a plain 220ms fade under reduced motion (`ChitMotion.fade` already does this) | §6.3, ADR-020 |
| **D5** | **Focus rings are `--seal`, drawn by `FocusableActionDetector`, and only on keyboard or switch focus** — never on touch. One decoration in `shared/widgets/`, used by every control | §6.4 |
| **D6** | **Arithmetic floors are tests; perceptual floors are a handset.** The two depress factors and every named target are asserted in `chit_motion_test.dart` and `widget_constants_test.dart`; whether a target can be hit, whether the stagger reads as one movement and what a screen reader says are group E, written into PROGRESS.md as seen | ADR-031 |

---

## A. Press feedback ✅ done — by removing it

*Built, shown to the owner, and taken back out on their call. What is left of the group is the
tab bar off Material's `InkWell` and two bugs it flushed out.*

- [x] `Pressable`, `ChitMotion.buttonDepress`, `pillDepress` and `depress(scale)`: **deleted**.
      Every control is a plain `GestureDetector` again and no control draws a pressed wash.
- [x] The tab bar stays off `InkWell` — a ripple is a second design language (ADR-069).
- [x] **The chit row's wash is a colour on a box that is always there.** Adding the box on press
      changed the shape of the tree, so Flutter rebuilt the subtree and disposed the audio
      pill's recogniser on the frame the finger landed: a recording in the thread could not be
      played. The hold made it certain (ADR-070).
- [x] Docs: DESIGN-SYSTEM.md §6.1's wash table and §6.3's press row; README.md §10; ADR-069
      marked superseded and ADR-070 written.

## B. The staggered entrance ✅ done

- [x] `StaggeredEntrance` in `shared/widgets/`: fade plus a 6px rise per child,
      `ChitMotion.staggerStep` apart, capped at `StaggeredEntrance.cap`; plays on first build,
      then sheds itself — the run is left completed and `build` stops wrapping (D3).
- [x] Today's page and the archive use it; the open chit and the timeline are children of it,
      not exceptions to it. `BranchFade` is untouched. **It takes blocks, not a column's
      contents**, so Today's two `SizedBox` gaps became padding on the blocks below them — a
      spacer in the list would take a turn in the stagger.
- [x] The calendar runs **two**: the month arrives once, and the archive is keyed on the
      selected day so a tapped date replays it and paging does not. One entrance over both
      would re-run the grid under the finger that just tapped it.
- [x] Under reduced motion: one fade, together, no rise — `ChitMotion.stagger()` is zero and
      `fade(ChitPace.arrival)` is what is left (D1).
- [x] Tests: the delay for the n-th child, the cap, the run's length, and that an empty list
      takes no time so a run cannot shed before its content lands.
- [x] Docs: DESIGN-SYSTEM.md §6.3's stagger paragraph; README.md §10; D3 above, for where the
      cap lives.

## C. The two authored arrivals ✅ done

- [x] `shared/widgets/arrival.dart` — one widget for both moments: it comes in from an offset,
      settles at nothing, plays once and sheds. **`play` is read at mount and never again**, and
      the wrapper stays in the tree either way, which is ADR-070's rule.
- [x] **A saved chit falls down into the thread** from a step of the scale above it. `DayThread`
      keeps the ids it has drawn, so only the row that was not there a moment ago arrives — the
      rows a screen opened with were carried in by the page's entrance. The timeline's scroll to
      now is the same moment and was already built (ADR-024).
- [x] **A kept recording rises up into the open chit**, mounting when *Stop & keep* lands it.
      *§6.3 said "then its words landing in the field" — there are no words since ADR-058, so
      the pill is the whole of it and §6.3 is corrected.*
- [x] The editor's pill does the same **for a staged replacement only**: opening a chit that
      already had a recording is not an arrival.
- [x] Under reduced motion both are a fade at 220ms and nothing moves (D1, D4).
- [x] Tests: none beyond `chit_motion_test.dart`'s arrival floor — what is left is whether it
      *reads* as one movement, which is group E's.
- [x] Docs: DESIGN-SYSTEM.md §6.3's authored-arrival paragraph; README.md §10.

## D. The floors ✅ done

- [x] **Targets, and one was under.** `s3` around an 18px wave is **42px**, not the 44 a comment
      in `AudioPill` had claimed for two milestones, and §6.4 makes no exceptions — the pill
      carries a minimum height now. Everything else clears it: both button weights at 49px, the
      microphone at 54, the chevrons, tabs and back arrow sized to the target itself.
- [x] **Focus rings.** `shared/widgets/focus_ring.dart` — a `--seal` ring at the app's one 1.5px
      stroke, **only on keyboard or switch focus**, painted over the control so nothing moves
      when it arrives, and carrying Enter and Space with it (D5). On every control: both button
      weights, the microphone, the pill, the chevrons, the tabs, the back arrow and the chit row.
- [x] **Semantics**, read through: headings on the date line, the month bar, the archive's days,
      the editor's header and the prompt; labels on every icon-only control; `ExcludeSemantics`
      only under a labelled parent, and the two live regions still say what they said.
- [x] Tests: the floors that are arithmetic, in `widget_constants_test.dart` — the 44px token,
      the microphone above it, a button's padding clearing it, the pill's **not** clearing it,
      and the ring at the same stroke as the caret and the tick.
- [x] Docs: DESIGN-SYSTEM.md §6.4's focus line; README.md §10; ADR-071.

## E. The device pass, and the sign-off of v1

*What no test can settle. Seed first — `flutter run --dart-define=CHIT_SEED=seed`, `=clear`
after. Write what was seen into PROGRESS.md as it is seen.*

**The fifth look closed the last three** (ADR-072), and M7 is signed off with them — v1 with it
(ADR-073):

- [x] **A pill played, left for another, and come back to.** Its wave runs from the start with
      the sound, rather than sitting where it was left until the recording catches up to it.
- [x] **The strip never skates.** Open the app and watch the timeline: it is at today from the
      first thing you see, with no marks sliding across for a frame. Then save a chit and watch
      it again.
- [x] **The first chit written after opening the app falls in like every other one** — including
      the first one written on a day that had nothing on it.

Passed on the fourth look, 18 September 2026, and not to be re-checked unless something near
them moves:

- [x] The editor's pill above the words, Remove beside it, stored and staged alike.
- [x] A chit opens on a hold; a tap on the row does nothing and a tap on its pill still plays.
- [x] The first tap after launch makes a sound; a second pill lights and pauses.
- [x] No press effect anywhere, and it does not read as dead.
- [x] The stagger on Today, the tab switch costing a fade, the archive re-staggering on a
      tapped date with the month grid holding still.
- [x] A chit falling into the thread; a recording rising into the open chit.
- [x] Reduced motion, the whole app: nothing travels, every fade survives.
- [x] A screen reader, the whole app.
- [x] Every target hit with a thumb, the pill and the microphone included.

- [x] Then: BUILD-PLAN.md M7 signed off with what it taught; PROGRESS.md marks v1 done; this
      file is replaced by whatever comes after v1 — or by nothing.

**This file is replaced when the next milestone starts** (CLAUDE.md §2).
