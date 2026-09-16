# Tasks — the current milestone, broken down

**M2 — Today, text only.** What [BUILD-PLAN.md](BUILD-PLAN.md) M2 says is *done*, cut into
groups that can each be built, tested and committed on their own.

This file holds **one milestone at a time** and is replaced wholesale when the next one starts.
It is the working list; [PROGRESS.md](PROGRESS.md) is the handover. Nothing here needs to survive
M2 — so anything worth knowing after M2 belongs in an ADR, in ARCHITECTURE.md or in the README,
not in a bullet here.

**Order:** A → B → C → D → E → F → G → H → I → J. **A to G are done; H is next.**

**Deliberately not in M2**, so it does not creep in: the audio pill and recording sheet (M5),
calendar content (M4), real weather and location (M3), the editor affordance (M6), and the
staggered entrance, press-feedback motion and the full accessibility audit (M7).

---

## Done: A to G

The full account of each is in git — `git log --oneline` reads as the list, one commit per
group. What each group settled that could have gone another way is an ADR, which is where to
look rather than here.

| | Group | Landed | What it decided |
|---|---|---|---|
| **A** | The five decisions | 15 Sep | Gaps always come off the scale; the field does not take focus (**ADR-023**); no settings control; Discard gets a pressed ink wash; the day arc becomes the timeline (**ADR-024**) |
| **B** | The shell and the frame | 15 Sep | `StatefulShellRoute` with two branches and a cross-fade (**ADR-011**), `routerProvider`, `ChitRoute` as the one list of destinations |
| **C** | The chit vocabulary | 16 Sep | `Slip`, `PerforatedEdge`, `AmbientStampRow`, `ThreadRail`. §6.3's 1.55px-at-8px figures became constants; three more prototype numbers went back on the scale |
| **D** | Ambient stamp, faked | 16 Sep | The two interfaces and their fixed implementations; `AmbientCapture` as the whole of ADR-007; **ADR-025** — the weather service takes no position |
| **E** | The open chit | 16 Sep | `ComposerState`, `ComposerController` (synchronous, stamp held from open), `OpenChit`. **ADR-026** — Discard opens a new chit, so it takes a new stamp |
| **F** | The five-second prompt | 16 Sep | The timer in the controller; an overlay, not `hintText`. **ADR-028** — chit draws no caret. **ADR-029** — the prompt reads the stamp. **ADR-027** — an ambient loop is not a pace |
| **G** | The thread, and Save end to end | 16 Sep | `todayProvider`, `DayThread`, `ChitRow`, `save()` with the held stamp, `closingMark`. **ADR-030**, since superseded by **ADR-031** |

**What H, I and J still have to honour from all of that:**

- **`todayProvider` is the screen's one clock read.** Two reads a millisecond apart are two
  different days at midnight.
- **`DayThread` and `ChitRow` are M4's as well** — §4.2's archive uses the same thread treatment
  — which is when they move to `shared/widgets`.
- **`Slip` draws its own tear edge; `ThreadRail` does not draw its nodes.** Do not assemble
  either again.
- **The microphone is drawn, inert, and carries no semantics** until M5 gives it an action, a
  label and a pressed wash together.
- **New copy is tested, not just written.** `prompts_test.dart` holds the voice — questions
  only, nothing that shouts, nothing said twice, nothing long enough to wrap the field.

---

## H. The timeline ⬜

*Reshaped by ADR-024, and the largest piece left. It reads across three days, so it needs a
query the repository does not have yet.*

- [ ] `ChitRepository.watchDayRange(fromDay, toDay)` and the DAO method under it — DATA-MODEL.md
      §4. The thread still reads one day; only the timeline needs the range.
- [ ] `features/today/application/timeline_provider.dart` — **pure**: an instant to a position
      within the three-day window, proportional to real time. Under ADR-031 this is where the
      group's correctness actually gets checked, so keep it free of anything that needs a widget.
- [ ] The line, marks in `--ink-faint`, the ring at now in `--seal`, the `now` cap in
      `--seal-ink`.
- [ ] Horizontal scroll across the window, resting at now, scrollable back two days and no
      further.
- [ ] Saving places the mark at the current time and **scrolls smoothly to it** — an authored
      arrival, so it collapses to a jump under reduced motion (§6.4).
- [ ] The window follows the clock: when the local day changes, it slides (ADR-024).
- [ ] **A day ends with a small upward mark below the line** — unlabelled, `--ink-faint`, two of
      them in a three-day window. Answered 15 September 2026 and written into BEHAVIOUR.md §4.1;
      it is meant to be noticed rather than read, so resist adding the weekday to it.
- [ ] Tests — the position function across a day and at both bounds; three days of marks from a
      range query; the window sliding at midnight. **No widget test** (ADR-031): the ring's
      position is a function of the clock and is tested as one, and how the strip *looks* is a
      device check.
- [ ] Build it and look at it on a handset, then update PROGRESS.md's *What is on a handset
      today*.

**Still open inside this group** — decide it with the screen in front of you, not in advance:

- **Crowding.** Several chits a day over three days is fifteen to twenty marks in one strip. If
  it reads as a smear, that is a finding worth recording rather than tuning away quietly.

## I. The floors M2's surfaces can already be held to ⬜

*A device pass, not M7's full audit — and since ADR-031 it is a device pass rather than a
test-writing session. Take the handset, work down the list, and write what you saw into
PROGRESS.md.*

- [ ] Touch targets ≥44px, the microphone included.
- [ ] Semantics with TalkBack on: heading levels do not skip, the field carries a label, and
      nothing that does nothing is announced as a control.
- [ ] Reduced motion across what M2 actually draws — the prompt's fade, the tab cross-fade,
      Discard's wash and the timeline's scroll-to-now. *The caret blink is not on this list:
      chit draws no caret (ADR-028) and the framework's cannot be steadied — open item 14
      carries it to M7.*
- [ ] The contrast test gains any new composited surface M2 introduced. **This one is still a
      test** — contrast is arithmetic over tokens and needs no widget tree.
- [ ] Run PROGRESS.md's *The device is the other half of the suite* table end to end. It has
      never been run in full.

## J. Close the loop ⬜

Per CLAUDE.md §0, in the same commits as the work rather than after it.

- [ ] PROGRESS.md — the status board, *What is on a handset today*, and any new open item.
      Replace the *Next* section; do not append to it.
- [ ] BUILD-PLAN.md — M2 ✅, and anything the build taught about what "done" should have said.
- [ ] README.md §10.3 — a row per new test suite. There is a test for it.
- [ ] ARCHITECTURE.md — if the providers differ from §3's table, or a file moved.
- [ ] BEHAVIOUR.md §4.1 — anything that changed on the screen.
- [ ] An ADR for anything decided along the way that could reasonably have gone another way.
- [ ] **Open item 1** — look at Newsreader on the handset beside v6. M2 is the first time there
      is real text to compare, which is what that item has been waiting for.
- [ ] `flutter build apk --debug`, and a proper look at it on the device.
