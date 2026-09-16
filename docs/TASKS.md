# Tasks — the current milestone, broken down

**M3 — Ambient capture.** What [BUILD-PLAN.md](BUILD-PLAN.md) M3 says is *done*, cut into groups
that can each be built, tested and committed on their own.

This file holds **one milestone at a time** and is replaced wholesale when the next one starts.
It is the working list; [PROGRESS.md](PROGRESS.md) is the handover.

> **Every group is built.** What M3 has left is **a device**, and nothing else. The list below
> is kept only until that pass is done and M4 replaces this file.

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
| **K** | The doc loop | ADR-040 through ADR-043, and every document they made untrue |

**323 tests, `flutter analyze` clean, `dart format` clean, debug and release APKs build.**

---

## L. The device pass ⬜

*The only thing between M3 and done. None of what follows can be held by a test — ADR-031.*

- [ ] **A fresh install opens on the first-run screen, and tapping Allow raises the real system
      dialog.** *It did not before group H: the fake location service answered `granted` without
      asking anything, which is what was seen on a handset and was the fake doing its job.*
- [ ] The second launch opens on Today. Refusing, then relaunching, does **not** ask again.
- [ ] **Release mode.** A release build showed a bare `--paper` screen and nothing else; the
      router's redirect has since been rewritten off `ref.watch` — which reaches for a `Ref`
      that has finished building — onto a `refreshListenable`. **Unconfirmed as the cause.** If
      it recurs, run `flutter run --release` and read the Dart exception, because the release
      `ErrorWidget` draws nothing useful on its own.
- [ ] With the network off: the composer opens instantly, and a chit saved offline carries a
      time and no word, no pin, no motion — **and nothing in the UI mentions the absence**.
- [ ] With the network on: the word matches the actual weather, and the prompt stops being the
      rain one (ADR-029).
- [ ] A chit sat on for a minute saves at the time it was **saved** (ADR-040).
- [ ] A walk outdoors produces the walking mark **in place of** the weather word (ADR-038).
- [ ] **`Position.speedAccuracy` is not reported as `0.0` for *unknown*.** `MotionLadder` reads
      zero as unknown; if a platform means it literally, motion sticks at `stationary` for ever
      and looks like a feature that does not work. **The single most likely thing to be wrong
      about motion**, and nothing in the suite can settle it.
- [ ] The rest of PROGRESS.md's standing list, which every milestone inherits.

Then M3 is done, BUILD-PLAN.md M3 gets its ✅ and what it taught, and this file becomes M4's.
