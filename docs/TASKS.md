# Tasks — the current milestone, broken down

**M4 — Calendar.** What [BUILD-PLAN.md](BUILD-PLAN.md) M4 says is *done*, cut into groups that
can each be built, tested and committed on their own.

This file holds **one milestone at a time** and is replaced wholesale when the next one starts.
It is the working list; [PROGRESS.md](PROGRESS.md) is the handover.

**Cut on 17 September 2026**, the day M3 was signed off. The order is deliberate and it turns
on one thing PROGRESS.md has said for two milestones: **nothing about a calendar can be looked
at empty.** The month grid, the summary and the archive all want several days of history, and
ADR-035 means an empty yesterday is not even drawn on Today — so the seeder of DATA-MODEL.md §7
comes *first*, the calendar is built against what it wrote, and the last group takes the
seeded days off the handset again.

**Deliberately not in M4:** the microphone and the audio pill (M5), opening a past chit (M6 —
the rows stay non-interactive, no affordance, no focus stop), the archive's stagger on a
re-render and every other motion in v6's calendar (M7), and the settings screen open item 22
wants.

---

## The decisions it turns on

| | Decision | Where |
|---|---|---|
| **D1** | **Today's ring sits on paper, not on the tile.** Open item 12: `--seal` fails 3:1 on the three- and four-chit washes. The answer is a *shape* rather than a token — the ring frames the tile at its edge with a strip of paper inside it, so both edges of the ring meet paper whatever density today carries | ADR-046 |
| **D2** | **The seeder identifies its own rows.** Every seeded id carries a fixed prefix, so seeding twice writes nothing new and clearing deletes exactly what was seeded and nothing a person wrote. No ledger, no preference, no schema change | DATA-MODEL.md §7 |
| **D3** | **The grid gap is `s1`, not the prototype's 5px.** A gap is a relationship and CLAUDE.md §4.2 keeps every one on the scale even where v6's CSS does not | DESIGN-SYSTEM.md §6.3 |
| **D4** | **"Show every day" is the quiet button**, the weight Discard has, and not v6's outlined bar. A fourth control weight for one control on one screen is a weight nobody else would use | BEHAVIOUR.md §4.2 |
| **D5** | **An empty archive draws nothing**, and only a filtered day that turns out empty says *"Nothing written that day."* A fresh install's calendar is the grid, today's ring, and *Nothing written this month* — the same reading of §4.1 the thread takes | BEHAVIOUR.md §4.2 |

---

## A. The seeder — DATA-MODEL.md §7, open item 10 ⬜

*Twenty chits over six weeks, every one of them four mundane words, behind a flag no release
build can reach.*

- [ ] `lib/data/dev/debug_seeder.dart` — `DebugSeeder(dao, audio, clock)` with `seed()` and
      `clear()`. Rows are dated **relative to the day it runs** so the last three days are
      always the busy ones, and every id starts with `seed-` (D2).
- [ ] The fixture covers all four shapes of README §5 — typed, transcript, transcript
      corrected, and **a recording with `NULL` text** (§3.5) — plus every weather word, a
      chit with no fix, a chit with no weather, and the three motion marks so that item 19 can
      finally be looked at.
- [ ] Two days with five chits each (density step four, and item 15's crowding on the strip),
      one with three, one with two, and singles, three of them in the previous month so the
      chevrons have somewhere to go.
- [ ] `ChitDao.rowsWithIdPrefix` and `deleteWithIdPrefix`. A seeded recording is a real file
      through `AudioStore.keep`, and `clear()` deletes it with the row.
- [ ] `main.dart` honours `--dart-define=CHIT_SEED=seed` and `=clear` in **debug only**, off
      the critical path, and says what it did on the console.
- [ ] `test/data/debug_seeder_test.dart` — idempotent, all four shapes present, clear removes
      exactly the seeded rows and files and leaves a written chit alone.

## B. The month's arithmetic ⬜

*Everything about a month that a test can hold without a widget — ADR-031 applied where it
bites.*

- [ ] `YearMonth` — a year and a month, `previous`, `next`, `firstDay` / `lastDay` as
      `yyyymmdd`, and the label *September 2026*.
- [ ] `MonthShape` — leading blanks (Sunday first, as v6), **the current month drawn up to
      today and no further**, a past month in full, the count per day, the density step
      (four, from `ChitColors.densitySteps`), and the summary in two parts so the strong half
      can be set upright.
- [ ] Day counts in words — *eleven days*, *one day* — and the archive's day label: *Today*,
      *Yesterday*, then *Friday 11 September*, with the year only when it is not this one.
- [ ] `Chit.dateOf(localDay)`, the inverse of `localDayOf`, beside it.
- [ ] `test/features/calendar/month_shape_test.dart`.

## C. The providers ⬜

- [ ] `visibleMonthProvider` — a notifier off `todayProvider`; `previous()` always,
      `next()` never past the current month.
- [ ] `monthSummariesProvider` — `watchDaySummaries` over the visible month, one query for
      the grid and the summary (DATA-MODEL.md §4).
- [ ] `monthShapeProvider` — the derived shape, null until the query has answered.
- [ ] `selectedDayProvider` — toggles, and **resets when the month changes**.
- [ ] `archivePagesProvider` and `archiveChitsProvider` — `watchDay` when a day is selected,
      `watchArchive` paged otherwise; `archiveDaysProvider` groups them newest first.
- [ ] `test/features/calendar/calendar_providers_test.dart` — on a bare `ProviderContainer`
      with real Drift: the month asks for exactly its own days, **a save on Today reaches the
      grid, the summary and the archive** (the milestone's statement of done, as far as a test
      can hold it), selecting narrows and clearing widens, and navigating re-queries.

## D. The screen ⬜

- [ ] `DayThread` and `ChitRow` move to `shared/widgets/day_thread.dart` — the archive is the
      second screen that wants them, which ARCHITECTURE.md §2 says is the moment.
- [ ] `ChitType.dayHeading` and `ChitType.monthSummaryStrong`.
- [ ] The month bar: the name, the year in `--ink-faint`, two chevrons at the 44px floor, the
      next one disabled at the current month.
- [ ] The weekday row and the grid: `SliverGrid`, seven across, `s1` gaps (D3), a number only
      where something was written, today always numbered and **ringed on paper** (D1), the
      selected tile framed in ink.
- [ ] The summary — *22 chits over eleven days* — and the archive under it: a day heading, a
      hairline fill, the count, and the same `DayThread` Today draws.
- [ ] Filtering: a tile narrows the archive to that day, the same tile or **Show every day**
      (D4) clears it. Paging as the reader nears the end.
- [ ] `contrast_test.dart` — the ring's assertion rewritten for its new shape.
- [ ] The placeholder line and the comment that promised M4 are deleted.

## E. The doc loop ⬜

- [ ] ADR-046. BEHAVIOUR.md §4.2, DESIGN-SYSTEM.md §6.2, §6.3, §6.4, ARCHITECTURE.md §2, §3
      and a §4.3 for the calendar's data flow, DATA-MODEL.md §4 and §7, README §10, and
      PROGRESS.md — the status board, what is on a handset, the standing device list, the
      open items (10 and 12 close, 15 and 19 become lookable), and *Next*.

## F. The device pass ⬜

*Seeded, then looked at. Nothing in this group can be checked by a test.*

```bash
flutter run --dart-define=CHIT_SEED=seed
```

- [ ] The grid reads as a shape — a number only where something was written, four steps of
      ink telling apart one, two, three and five chits at arm's length.
- [ ] Today is ringed **on paper** and reads as today on a busy tile as well as an empty one
      (D1). If the ring reads as a frame around a smaller tile rather than as today, that is
      the thing to say.
- [ ] The current month stops at today; the previous month draws in full; the next chevron is
      disabled at the current month and the previous one goes back.
- [ ] *17 chits over seven days* for the seeded September; *3 chits over three days* for
      August.
- [ ] Tapping a tile narrows the archive to that day and frames the tile; tapping it again,
      or **Show every day**, widens it.
- [ ] Every tile clears 44px on the handset it is checked on.
- [ ] **Saving a chit on Today changes the tile, the summary and the archive without a
      refresh** — the milestone's statement of done.
- [ ] Item 15: the strip with ten marks across two days and whatever today holds.
- [ ] Item 19: the three motion marks, drawn for the first time on a real device — walking on
      the 19:05 and 07:55 chits, travelling on 18:52 and 12:10, flying on the August one.
- [ ] The §3.5 chit — the 23:55 recording with no words — reads as a chit with a stamp and
      nothing under it, not as a broken row.

## G. The seeded days come off the handset ⬜

*The last group, and the one the milestone is not done without. The seeder stays — it is
DATA-MODEL.md §7's and M5 will want it — but the rows it wrote are scaffolding.*

```bash
flutter run --dart-define=CHIT_SEED=clear
```

- [ ] The console says twenty rows and four recordings went.
- [ ] Today, the strip and the calendar hold only what was actually written on this handset.
- [ ] `--dart-define=CHIT_SEED=clear` followed by `=seed` and `=clear` again leaves the same
      count — the flag is safe to use as many times as M5 needs it.
- [ ] PROGRESS.md records the pass, and M4 is signed off in BUILD-PLAN.md.
