# Tasks — the current milestone, broken down

**M2 — Today, text only. ✅ Done, 16 September 2026.**

This file holds **one milestone at a time** and is replaced wholesale when the next one starts.
M3 has not been cut into groups yet; until it is, this is the ledger of what M2 was and the list
of what it left behind. [BUILD-PLAN.md](BUILD-PLAN.md) M3 is what to cut from.

---

## What M2 was, group by group

The full account of each is in git — `git log --oneline` reads as the list. What each group
settled that could have gone another way is an ADR, which is where to look rather than here.

| | Group | Landed | What it decided |
|---|---|---|---|
| **A** | The five decisions | 15 Sep | Gaps always come off the scale; the field does not take focus (**ADR-023**); no settings control; Discard gets a pressed ink wash; the day arc becomes the timeline (**ADR-024**) |
| **B** | The shell and the frame | 15 Sep | `StatefulShellRoute` with two branches and a cross-fade (**ADR-011**), `routerProvider`, `ChitRoute` as the one list of destinations |
| **C** | The chit vocabulary | 16 Sep | `Slip`, `PerforatedEdge`, `AmbientStampRow`, `ThreadRail`. §6.3's 1.55px-at-8px figures became constants; three prototype numbers went back on the scale |
| **D** | Ambient stamp, faked | 16 Sep | The two interfaces and their fixed implementations; `AmbientCapture` as the whole of ADR-007; **ADR-025** — the weather service takes no position |
| **E** | The open chit | 16 Sep | `ComposerState`, `ComposerController` (synchronous, stamp held from open), `OpenChit`. **ADR-026** — Discard opens a new chit, so it takes a new stamp |
| **F** | The five-second prompt | 16 Sep | The timer in the controller; an overlay, not `hintText`. **ADR-028** — chit draws no caret. **ADR-029** — the prompt reads the stamp. **ADR-027** — an ambient loop is not a pace |
| **G** | The thread, and Save end to end | 16 Sep | `todayProvider`, `DayThread`, `ChitRow`, `save()` with the held stamp, `closingMark`. It also produced the record that became **ADR-031** |
| **H** | The timeline | 16 Sep | `watchDayRange`, `TimelineWindow`, `Timeline`. **ADR-032** — one day is one screen, now rests in the middle of it. **ADR-033** — Today re-reads the clock at midnight. **ADR-034** — a day passing is a haptic. **ADR-035** — days with nothing in them are not drawn. **ADR-036** — now is a tick, not a dot |
| **I** | The floors M2's surfaces can be held to | 16 Sep | The contrast floors the strip introduced, and one finding: **`--seal` is *less* contrasty on paper than `--ink-faint`**, so shape carries the accent and colour confirms it (§6.4) |
| **J** | Close the loop | 16 Sep | This, and everything in the table at CLAUDE.md §0 |

**232 tests, `flutter analyze` clean, `dart format` clean, debug APK builds.**

---

## What M3 inherits

Constraints that outlive this milestone. Anything not here is in an ADR or in the code.

- **`todayProvider` is the screen's one clock read**, and it re-reads itself at midnight
  (ADR-033). Anything on Today that needs the time watches it rather than the clock.
- **`TimelineWindow` is a plain value and that is where the strip's correctness lives.** Under
  ADR-031, arithmetic that can be tested belongs beside it rather than in a widget.
- **`DayThread` and `ChitRow` are M4's as well** — §4.2's archive uses the same thread treatment
  — which is when they move to `shared/widgets`.
- **`Slip` draws its own tear edge; `ThreadRail` does not draw its nodes.** Do not assemble
  either again.
- **The microphone is drawn, inert, and carries no semantics** until M5 gives it an action, a
  label and a pressed wash together.
- **The two fakes are `FixedWeatherService` and `FixedLocationService`, overridden in
  `main.dart`.** M3 deletes both files and changes those two lines; nothing above them moves.
  `WeatherService.currentCondition()` takes no position, and reversing that is ADR-025's to
  reverse.
- **New copy is tested, not just written.** `prompts_test.dart` holds the voice — questions
  only, nothing that shouts, nothing said twice, nothing long enough to wrap the field.
- **Component dimensions are named constants, and `widget_constants_test.dart` holds them.**
  A constant copied off the spacing scale still has to equal it.

## What M2 left open

Carried in [PROGRESS.md](PROGRESS.md) rather than here, because none of it is scheduled work:
the device checklist that has never been run end to end, open item 1 (the type on a handset),
open item 12 (today's ring on a busy calendar tile), open item 14 (the framework's caret under
reduced motion), and the two findings H produced — crowding, and what the strip says at its
back-stop.
