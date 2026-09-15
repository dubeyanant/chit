# Tasks — the current milestone, broken down

**M2 — Today, text only.** What [BUILD-PLAN.md](BUILD-PLAN.md) M2 says is *done*, cut into
groups that can each be built, tested and committed on their own.

This file holds **one milestone at a time** and is replaced wholesale when the next one starts.
It is the working list; [PROGRESS.md](PROGRESS.md) is the handover and keeps the history, so
nothing here needs to survive M2. Tick as you go — a group with an unticked box is a group that
is not done, whatever the code looks like.

**Order:** A → B → C → D → E → F → G → H → I → J. C and D are independent of each other and
both block E. The shortest path to something you can hold is B → C → D → E → G.

**Deliberately not in M2**, so it does not creep in: the audio pill and recording sheet (M5),
calendar content (M4), real weather and location (M3), the editor affordance (M6), and the
staggered entrance, press-feedback motion, goldens and the full accessibility audit (M7).

---

## A. The five decisions ✅ settled 15 September 2026

They came first because each one changes what gets built.

| | Decision | Recorded in |
|---|---|---|
| 1 | **Gaps and paddings come from the scale, always.** The wordmark gap snaps 7px → `s2` (8px) and no token is added for it | DESIGN-SYSTEM.md §6.3, CLAUDE.md §4.2 |
| 2 | **The field does not take focus at launch.** The app opens showing the whole screen; the first tap is the user's | **ADR-023** |
| 3 | **No settings control.** v1 has no settings, and an affordance that leads nowhere is worse than a missing one | BEHAVIOUR.md §4.1, DESIGN-SYSTEM.md §7 |
| 4 | **Discard gets a pressed ink wash** rather than `--hair-soft`, which has collapsed on a chit. Closes open item 13 | DESIGN-SYSTEM.md §6.1 |
| 5 | **The day arc becomes the timeline**: a full day, three days of span, proportional, scrollable, resting at now | **ADR-024** |

Decision 5 is the big one and it reshapes group **H** below. It also renames a thing the whole
specification referred to — see the ADR.

---

## B. The shell and the frame ✅ done 15 September 2026

*Nothing works until the app routes. One commit.*

- [x] `app/router.dart` — `StatefulShellRoute` with two branches (ADR-011).
- [x] `app/chit_app.dart` — `MaterialApp.router`; retire the temporary `_Masthead`.
- [x] `features/shell/presentation/shell_screen.dart` — the persistent top row (wordmark +
      चित्त, **no settings control** — decision 3) and the bottom tab bar. Pip in `--ink`, not
      seal (ADR-022); labels 16.5px serif.
- [x] `features/calendar/presentation/calendar_screen.dart` — a placeholder body.
- [x] Test: switching tabs and returning costs a fade, not a rebuild — ADR-011's actual claim.

**go_router and Riverpod carry as much of this as they can** — ARCHITECTURE.md §3 and CLAUDE.md
§4.2 now say so as a house rule. The router lives in `routerProvider` rather than in a widget,
`ChitRoute` is the one list of destinations and the tab bar is built from it, and `BranchFade`
is written into go_router's own extension point rather than beside it.

Four things worth knowing before the next group touches this:

- **It is a plain `StatefulShellRoute`, not `.indexedStack`.** An `IndexedStack` swaps
  instantly and there is nowhere in it to put §6.3's 220ms, so the branches are stacked by a
  `navigatorContainerBuilder` and cross-faded. State is preserved either way; the fade is what
  `.indexedStack` cannot give.
- **A branch is built lazily** — the calendar is not in the widget tree at all until it is
  first shown. Anything that expects both branches to exist has to visit both first.
- **The tab is sized to §6.4's 44px rather than to its contents.** The prototype's tab measures
  43.5px, half a pixel under a floor that says "no exceptions".
- **`ChitApp` is a `ConsumerWidget` and holds nothing.** Anything that has to survive a rebuild
  belongs in a provider, which is ADR-001 rather than a preference.

## C. The chit vocabulary ✅ done 16 September 2026

*Shared widgets, no data. The composer and the thread both need these.*

- [x] `shared/widgets/slip.dart` — surface, hairline, radius, the one faint shadow, and the
      offset pad behind it.
- [x] `shared/widgets/perforated_edge.dart` — a painter; holes in `slipUnder`, never a dotted
      border. **DESIGN-SYSTEM.md §6.3's 1.55px-at-8px figures become constants here**, which is
      what that section says is meant to happen.
- [x] `shared/widgets/ambient_stamp_row.dart` — one line, spaced not separated, two colour
      weights (open chit `--ink-muted`, thread `--ink-faint`), pin on the open chit only (§3.6).
- [x] `shared/widgets/thread_rail.dart` — the 1px rail and the 7px node with its `--paper` halo.
- [x] **Add `emptyNote` to `ChitType`** — 15px serif italic, `--ink-faint`. The scale has no
      style for it, and `chit_type.dart` says a new style must join `styles`, `copyWith` and
      `lerp` or nothing checks it.
- [x] Tests: the edge draws holes rather than a border; a null signal is not drawn (ADR-007);
      the pin appears only where §3.6 allows.

Four things group E and group G inherit from this, and should not re-litigate:

- **`Slip` draws its own tear edge, and `ThreadRail` does not draw its nodes.** A slip and the
  tear that made it are one object; where a node falls depends on what the row says, which is
  the screen's business. ARCHITECTURE.md §2 now records both.
- **The rail comes out of the middle of the mark.** The prototype has the node 2px to its left;
  `ThreadRail.centre` is derived from `ThreadNode.markSize` so the two cannot drift apart, and
  §6.3 carries the departure.
- **Three more of the prototype's odd numbers went back on the scale** — the stamp's 11px gaps
  to `s3`, the pad's 5/6px offset to `s1`, the perforation's inset to `s2` — and the list of
  four permitted dimensions did not grow. That was the test each had to pass.
- **`AmbientStampRow` has two named constructors and no third.** `.open` carries the pin,
  `.saved` cannot; there is no way to ask for a pinned row in the thread.

## D. Ambient stamp, faked ⬜

*Small, and it unblocks E. Do it before the composer rather than during.*

- [ ] `domain/services/weather_service.dart` and `location_service.dart` — the interfaces. Their
      placeholders say M3; the interfaces arrive now so the composer's shape is final.
- [ ] Fixed-value implementations for M2, supplied at the root the way `ChitRepository` is.
- [ ] `AmbientStamp` assembled once at open from the clock and the two services, with ADR-007's
      timeout shape already in place so M3 only swaps implementations in.
- [ ] Test: a signal that does not arrive is null, and a null is not drawn.

## E. The open chit ⬜

*The big one. Needs C and D.*

- [ ] `domain/models/composer_state.dart` — the record in ARCHITECTURE.md §4.1, plus `canSave`.
- [ ] `features/composer/application/composer_controller.dart` — the stamp held from open and
      **never re-read** (ADR-021); text edits; `textOrigin: typed`.
- [ ] `features/composer/presentation/open_chit.dart` — `Slip` + stamp row + field + action row.
      The tear edge and the pad come with the slip; do not assemble them again.
- [ ] The field at 17.5px, `cursorColor: seal`, no decoration, **and no autofocus** (ADR-023).
- [ ] The microphone in its final position and size, ≥44px target that does not shrink when
      text appears, inert until M5.
- [ ] Discard and Save appear only when `canSave`; Discard carries decision 4's pressed wash.
- [ ] Tests: `canSave`; an untouched chit shows neither control; the stamp is captured once.

## F. The five-second prompt ⬜

*Separable from E, and worth its own commit because it is all timing.*

- [ ] The timer lives in the controller, not the widget (ARCHITECTURE.md §4.3). First character
      cancels it; clearing the field starts it again.
- [ ] 700ms appearance, and it **survives reduced motion at 140ms** — `ChitMotion.fade`, never
      `travel`.
- [ ] **Not `hintText`.** An overlay, because §3.5 warns that placeholder text is the tempting
      shortcut here and M5's failure note lands in the same place.
- [ ] The caret blink stops under reduced motion — §6.4 lists it as an ambient loop.
- [ ] Tests: the five seconds, the cancel, and the restart, against a fake clock.

## G. The thread, and Save end to end ⬜

*Where M2 becomes an app somebody could use.*

- [ ] `features/today/application/today_controller.dart` — `watchDay` off the repository.
- [ ] `features/today/presentation/today_screen.dart` — the date line, `earlier` and its count,
      the thread, the चित्त closing mark.
- [ ] The chit row: rail node, stamp row, text.
- [ ] The empty state — *"Nothing written yet today."*, no rail, no placeholder row, and the
      count beside **earlier** omitted.
- [ ] Save → `ChitRepository.save()` with the held stamp. Discard returns the chit to empty.
- [ ] Tests: type → save → it is in the thread; restart → it is still there; an empty day
      looks empty.

## H. The timeline ⬜

*Reshaped by ADR-024, and now the largest piece after E. It reads across three days, so it
needs a query the repository does not have yet.*

- [ ] `ChitRepository.watchDayRange(fromDay, toDay)` and the DAO method under it — DATA-MODEL.md
      §4. The thread still reads one day; only the timeline needs the range.
- [ ] `features/today/application/timeline_provider.dart` — pure: an instant to a position
      within the three-day window, proportional to real time.
- [ ] The line, marks in `--ink-faint`, the ring at now in `--seal`, the `now` cap in
      `--seal-ink`.
- [ ] Horizontal scroll across the window, resting at now, scrollable back two days and no
      further.
- [ ] Saving places the mark at the current time and **scrolls smoothly to it** — an authored
      arrival, so it collapses to a jump under reduced motion (§6.4).
- [ ] The window follows the clock: when the local day changes, it slides (ADR-024).
- [ ] Tests: the position function across a day and at both bounds; three days of marks from a
      range query; the ring's position from a fake clock; the window sliding at midnight.

- [ ] **A day ends with a small upward mark below the line** — unlabelled, `--ink-faint`, two of
      them in a three-day window. Answered 15 September 2026 and written into BEHAVIOUR.md §4.1;
      it is meant to be noticed rather than read, so resist adding the weekday to it.

**Still open inside this group** — decide it with the screen in front of you, not in advance:

- **Crowding.** Several chits a day over three days is fifteen to twenty marks in one strip.
  If it reads as a smear, that is a finding worth recording rather than tuning away quietly.

## I. The floors M2's surfaces can already be held to ⬜

*A short sweep, not M7's pass.*

- [ ] Touch targets ≥44px, the microphone included.
- [ ] Semantics: heading levels do not skip, the field carries a label, and nothing that does
      nothing is marked up as a control.
- [ ] Reduced motion across what M2 actually draws — the caret blink, the prompt's fade, and
      the timeline's scroll-to-now.
- [ ] The contrast test gains any new composited surface M2 introduced.

## J. Close the loop ⬜

Per CLAUDE.md §0, in the same commits as the work rather than after it.

- [ ] PROGRESS.md — M2 done, what moved, any new open item.
- [ ] BUILD-PLAN.md — M2 ✅, and anything the build taught about what "done" should have said.
- [ ] README.md §10.3 — a row per new test suite. There is a test for it.
- [ ] ARCHITECTURE.md — if the providers differ from §3's table, or a file moved.
- [ ] BEHAVIOUR.md §4.1 — the day-delineation answer from group H, and anything else that
      changed on the screen.
- [ ] An ADR for anything decided along the way that could reasonably have gone another way.
- [ ] **Open item 1** — look at Newsreader on the handset beside v6. M2 is the first time there
      is real text to compare, which is what that item has been waiting for.
- [ ] `flutter build apk --debug`, and a look at it on the device.
