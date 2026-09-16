# Tasks — the current milestone, broken down

**M3 — Ambient capture.** What [BUILD-PLAN.md](BUILD-PLAN.md) M3 says is *done*, cut into groups
that can each be built, tested and committed on their own.

This file holds **one milestone at a time** and is replaced wholesale when the next one starts.
It is the working list; [PROGRESS.md](PROGRESS.md) is the handover.

> **M3 is done**, signed off in release on a handset on 17 September. This file is kept as the
> record of it until somebody cuts M4 and replaces it.

**M3 grew twice while it was being built.** *It was six groups, A to F, and it drew nothing at
all.* Motion arrived first (ADR-037, ADR-038, ADR-039), then the first-run screen and the
capture lifecycle (ADR-040, ADR-041, ADR-042) — which gave the milestone its first new screen
and **reversed ADR-021**, so a chit is stamped when it is *saved*. The weather mapping closed it
(ADR-043).

**Deliberately not in M3:** the calendar (M4), anything to do with the microphone (M5), the
editor (M6), and re-transcription (OPEN-QUESTIONS.md §8.2).

---

## What was built ✅

| | Group | What landed |
|---|---|---|
| **A** | The motion decisions | ADR-037, ADR-038, ADR-039 |
| **B** | The motion ladder | `motion_state.dart`, `motion_ladder.dart`. Four states, closed set — no `running`, no `cycling` |
| **C** | The precedence ladder and the stamp | `ambient_fact.dart` sealed, `motion_icon.dart`, the stamp row. The three marks were drawn into v6 first |
| **D** | Persistence | `chits.motion`, schema v2 with a real migration, and a chit written at v1 still readable after it |
| **E** | The prompt book | Motion scored above weather and the hour; nothing for `stationary` |
| **F** | The four decisions | All settled — ADR-041, ADR-042, and ADR-043 for the last two |
| **F2** | First run, and the capture lifecycle | `first_run_store`, `ambient_signals`, `updateAmbient`, `features/onboarding/`, the router's one redirect |
| **G** | The WMO mapping | `wmo_mapping.dart` — every published code resolves, `windy` at 7.0 m/s, `is_day` trusted |
| **H** | `GeolocatorLocationService` | The fix, its kinematics, and the one permission ask. **`currentFix` never raises a dialog** |
| **I** | `OpenMeteoService` | One call, `wind_speed_unit=ms`, last-known fix only. Never throws |
| **J** | The swap | `main.dart` wires the real pair; both fakes deleted. **Nothing above `main.dart` changed** |
| **K** | The doc loop | ADR-040 through ADR-045, and every document they made untrue |

**327 tests, `flutter analyze` clean, `dart format` clean, debug and release APKs build.**
Ambient capture has been seen working on a handset — see PROGRESS.md.

---

## L. The device pass ✅

*Run in release on a handset, 17 September. All of it passed, and the four things it found
before it did are PROGRESS.md open items 25 to 28.*

- [x] A fresh install opens on the first-run screen, and **Allow** raises the real system dialog.
- [x] The second launch opens on Today.
- [x] A release build renders. *It did not on 16 September; the router's `redirect` was reaching
      for a `Ref` that had finished building.*
- [x] **The pin appears.** *It did not until ADR-044 gave the fix time to arrive — two seconds is
      not a GPS fix indoors.*
- [x] With the network on: the word matches the actual weather, and the prompt reads the stamp.
- [x] Tapping away from the field puts the keyboard down. *It did not; `onTapOutside` now does.*

**Still untried, and carried into M4's inherited list rather than held here:** a walk outdoors
(the motion marks have never been drawn on a real device), a chit sat on across a minute
boundary, the network off, and a sitting long enough to cross ADR-045's five-minute window.
PROGRESS.md's standing list is where those live now.

---

M3 is done. [BUILD-PLAN.md](BUILD-PLAN.md) M3 carries what the milestone taught, and **this file
is replaced by M4's groups the moment somebody cuts them** — which has deliberately not been
done yet.
