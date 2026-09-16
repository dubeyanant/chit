# Tasks — the current milestone, broken down

**M3 — Ambient capture.** What [BUILD-PLAN.md](BUILD-PLAN.md) M3 says is *done*, cut into groups
that can each be built, tested and committed on their own.

This file holds **one milestone at a time** and is replaced wholesale when the next one starts.
It is the working list; [PROGRESS.md](PROGRESS.md) is the handover. Nothing here needs to survive
M3 — so anything worth knowing after M3 belongs in an ADR, in ARCHITECTURE.md or in the README,
not in a bullet here.

**M3 grew on 16 September 2026, twice.** *This file used to have six groups, A to F, and the
milestone drew nothing at all.* Both are now false. **Motion** arrived first (ADR-037, ADR-038,
ADR-039) — groups A to E. Then the first-run screen and the capture lifecycle (ADR-040,
ADR-041, ADR-042) — groups F and F2, which also drew M3 its first new screen and **reversed
ADR-021**: a chit is stamped when it is *saved*.

All of that is finished. What is left is what M3 always was: the two real services and the swap,
gated on the **two** decisions in group F that are still open.

**Deliberately not in M3**, so it does not creep in: the calendar (M4), anything to do with the
microphone (M5), the editor (M6), and re-transcription (OPEN-QUESTIONS.md §8.2).

---

## A. The motion decisions ✅

*Settled 16 September 2026, and each one is a record because each could have gone another way.*

- [x] **ADR-037 — motion is read off the position fix, not off a motion sensor.** An
      accelerometer cannot measure speed and a gyroscope measures rotation; the fix already
      carries `speed`, `speedAccuracy` and `altitude`. No new package, no new permission, no
      third call.
- [x] **ADR-038 — the stamp carries one ambient fact, ranked.** Weather and motion share one
      slot. `stationary` is stored and never drawn.
- [x] **ADR-039 — motion is an icon where weather is a word, and it is drawn in the thread.**

## B. The motion ladder ✅

- [x] `domain/models/motion_state.dart` — four states, closed set. No `running`, no `cycling`.
- [x] `domain/motion/motion_ladder.dart` — one pure function, no I/O and no Flutter.
- [x] `test/domain/motion/motion_ladder_test.dart` — every band, both sides of every floor, the
      altitude rule, the accuracy gate, and the three ways a platform says *no reading*.

## C. The precedence ladder and the stamp ✅

- [x] `domain/ambient/ambient_fact.dart` — sealed, so the widget switches exhaustively.
- [x] `shared/widgets/motion_icon.dart` — three marks, pin's box, pin's stroke, row's colour.
- [x] `shared/widgets/ambient_stamp_row.dart` — draws the ranked fact, and the thread draws
      motion where it still refuses a pin.
- [x] `design/chit-app-v6.html` first, then the app followed it — the icons had no source
      otherwise, which is how the pin's 14-unit path came to exist.
- [x] `test/domain/ambient/ambient_fact_test.dart` — the whole cross product.

## D. Persistence ✅

- [x] `chits.motion`, `textEnum`, nullable. No index, no check constraint — DATA-MODEL.md §1
      says why for both.
- [x] `schemaVersion` 1 → 2 with a real `onUpgrade`, the snapshot dumped and the fixtures
      regenerated.
- [x] `migration_test.dart` — the v2 shape, **and** a chit written at v1 still readable with a
      null motion, which `migrateAndValidate` does not check.
- [x] `Chit`, `AmbientStamp`, `AmbientCapture` and the repository, both directions.

## E. The prompt book ✅

- [x] `_Entry` gains a motion, scored above weather and the hour.
- [x] Nine new prompts, none for `stationary` — a question about sitting still is a question
      about nothing.
- [x] Tests, including the one that keeps it safe: `stationary` is asked exactly what a chit
      with no motion at all is asked.

---

## F. The decisions M3 turns on 🔶

*Two of the four are settled and built. The remaining two gate G and I.*

- [x] **When location permission is asked for — ADR-041.** On **first run**, behind a screen of
      our own, shown once in the life of an install. Location only; the microphone waits for M5
      and is asked for when the microphone is first tapped. Either button spends the one ask, so
      an install that refused is never asked again (ADR-016).
- [x] **Whether the ambient answer is cached — ADR-042.** Read at **launch** and at **save**, and
      never in between: no timer, no time-to-live, no refresh on resume. `AmbientSignals` in
      `domain/services` holds it. This also answered a question the file did not know it was
      asking — **ADR-040**, which stamps a chit when it is *saved* rather than when it was
      opened, and makes the save write the row first and patch the fresh reading in after.
- [ ] **The wind threshold, and the `is_day` rule.** §3.6 says `windy` is *"our own threshold on
      wind speed rather than a WMO code"*, and `WeatherCondition` says it *"wins over `clear` and
      never over `raining`"*. The number is a product decision and belongs in `domain`. Same for
      the boundary between `clear` and `clearNight` — Open-Meteo's `is_day` flag answers it, and
      whether we trust it or compute our own is the question. **This gates G.**
- [ ] **What a fresh install gets.** ADR-025 has weather reading the device's *last known* fix,
      so on a phone that has never had one there is no weather — the first chit on a new install
      can carry a time and nothing else, with permission granted and the network up. Decide
      whether that is simply correct (it is defensible) or whether the first call may wait for a
      fix. **Motion has the same shape and a harsher version of it:** a *last known* speed is a
      lie in a way a last known coordinate is not, which is why motion reads the current fix.
      **This gates H and I.**

## F2. First run, and the capture lifecycle ✅

*Built with the two decisions above. Draws the first new screen M3 has.*

- [x] `domain/services/first_run_store.dart` and `data/preferences/prefs_first_run_store.dart` —
      two booleans, `shared_preferences`, loaded in `main()` before `runApp`.
- [x] `LocationService.requestPermission()` and `LocationPermissionOutcome`, so `features` raises
      a dialog without importing geolocator.
- [x] `features/onboarding/` — the screen and its controller. Built from `Wordmark`, `Slip`,
      `PerforatedEdge` and the two button weights; `wordmark.dart` and `buttons.dart` **moved out
      of the features that owned them** into `shared/widgets/`.
- [x] A top-level route and the app's one `redirect`. **Not a `ChitRoute`** — that enum is what
      the tab bar is built from.
- [x] `domain/services/ambient_signals.dart` — holds the reading, primed after the first frame
      and refreshed by save. `AmbientCapture` loses its clock and its `open()`/`settle()` pair.
- [x] `ChitRepository.updateAmbient` and `ChitDao.updateAmbientOf` — the three ambient fields and
      nothing else, moving neither `createdAt` nor `updatedAt`.
- [x] Tests: the ask happens once whichever button ends the screen, **Not now** never raises a
      dialog, capture is counted rather than assumed, and the save is driven across a moving
      clock — which is the only thing that can see ADR-040.

## G. The WMO mapping ⬜

*Pure, and gated only on F3 — the wind threshold. **This is the next work.***

- [ ] `domain/weather/wmo_mapping.dart` — WMO code + `is_day` + wind speed → `WeatherCondition`,
      one pure function, no I/O and no Flutter. Same shape as `motion_ladder.dart`, which is now
      the worked example sitting next to it.
- [ ] Every WMO code in the published table maps to one of the five words of §3.6, and **nothing
      maps to null because it was forgotten** — an unknown code is a stated outcome, not a gap.
- [ ] The precedence: `raining` beats `windy` beats `clear`/`clearNight`.
- [ ] Tests: the full code table, both sides of the wind threshold, both sides of `is_day`, and
      the precedence at each boundary. Table-driven, not an example each.

## H. `GeolocatorLocationService` ⬜

*The first thing in the app that asks the user for something. Needs F1.*

- [ ] `data/location/geolocator_location_service.dart` — high accuracy, **accepting the coarse
      fix when that is all that was granted** (ADR-016). Both are a successful capture.
- [ ] **It fills in `GeoFix`'s kinematics** — `speed`, `speedAccuracy`, `altitude` — from
      `Position`, untouched and unjudged. The ladder decides what they mean, not this class.
      **Verify on a device that `speedAccuracy` is not reported as `0.0` for *unknown***; the
      ladder reads zero as unknown for exactly that reason, and if a platform instead means it
      literally the gate has to change.
- [ ] The permission flow decided in F1, including service-disabled and `deniedForever`.
- [ ] **It never throws.** A refusal, a disabled service, a timeout and a platform error are all
      `null`.
- [ ] A `lastKnown` path for I to use, because ADR-025 keeps the two signals parallel by never
      making weather wait on a fresh fix. **Motion does not use it** — a stale speed is a lie.
- [ ] Tests: the mapping of outcomes to `null` and ADR-016's two accuracies. The permission
      dialog itself is a device check and goes on PROGRESS.md's list.

## I. `OpenMeteoService` ⬜

*One endpoint, no key, no account. Needs H.*

- [ ] `data/weather/open_meteo_service.dart` — current conditions over `http`, parsed, mapped
      through G, under ADR-007's timeout.
- [ ] Position from `LocationService`'s **last known** fix (ADR-025). No fix, no weather, and
      that is an ordinary `null`.
- [ ] The cache decided in F2.
- [ ] **It never throws.** Offline, rate-limited, 500, malformed JSON and a code outside the
      table are all `null`.
- [ ] Tests: the parse against recorded responses, every failure shape resolving to `null`, and
      the cache — all against a fake `http` client, with no network in the suite.

## J. The swap, and offline ⬜

*Where the milestone becomes true. Two lines and two deletions.*

- [ ] `main.dart` — `OpenMeteoService` and `GeolocatorLocationService` replace the two fixed
      values. **Nothing above `main.dart` changes**; if something has to, M2 group D got the
      interface wrong and that is the finding.
- [ ] **Delete `fixed_weather_service.dart` and `fixed_location_service.dart`** — CLAUDE.md §0.1.
      They are not fallbacks and not test doubles; `null` is the honest answer and ADR-007 has it.
- [ ] Remove the M2-only lines that name them: ARCHITECTURE.md §2, PROGRESS.md's *fixed fakes*
      note, and the composer's own doc comment.
- [ ] **Done when**, on a device: the composer opens instantly with the network off, a chit saved
      offline carries a time and no weather word and no pin and no motion, and **nothing in the
      UI mentions the absence** — no placeholder, no dash, no "unavailable".
- [ ] And with the network on: the word is right for the actual weather, the prompt stops being
      the rain one (ADR-029), and a walk produces the walking mark.

## K. Close the loop ⬜

Per CLAUDE.md §0 and §0.1, in the same commits as the work rather than after it.

- [ ] An ADR for each of group F's two remaining decisions, if either could have gone another way.
- [ ] BEHAVIOUR.md §3.6 — if the permission flow puts anything on screen.
- [ ] ARCHITECTURE.md §4.2, for the fakes coming out from under it.
- [ ] PACKAGES.md — if `geolocator` or `http` needed anything not already written down.
- [ ] README.md §10.3 for new suites; §10.6 if any platform config moved.
- [ ] PROGRESS.md — the status board, *What is on a handset today*, the device checklist (the
      permission flow is a new standing row), and any new open item.
- [ ] BUILD-PLAN.md — M3 ✅ and what the milestone taught.
- [ ] `flutter build apk --debug`, and a look at it on the device with the network off and on.
