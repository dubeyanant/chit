# Tasks — the current milestone, broken down

**M3 — Ambient capture.** What [BUILD-PLAN.md](BUILD-PLAN.md) M3 says is *done*, cut into groups
that can each be built, tested and committed on their own.

This file holds **one milestone at a time** and is replaced wholesale when the next one starts.
It is the working list; [PROGRESS.md](PROGRESS.md) is the handover. Nothing here needs to survive
M3 — so anything worth knowing after M3 belongs in an ADR, in ARCHITECTURE.md or in the README,
not in a bullet here.

**Order:** A → B → C → D → E → F. B is independent of everything and can be built first if a
decision in A is still open; D needs C.

**M3 draws nothing.** Every surface it touches was built in M2 and is not to be redesigned: the
stamp row, the pin, the prompt. What changes is what they *say*. The only new thing a user sees
is a system permission dialog, and where that appears is group A's first decision.

**Deliberately not in M3**, so it does not creep in: the calendar (M4), anything to do with the
microphone (M5), the editor (M6), and re-transcription (OPEN-QUESTIONS.md §8.2).

---

## A. The decisions M3 turns on ⬜

*They come first because each one changes what gets built. Each becomes an ADR if it could have
gone another way, per CLAUDE.md §0.*

- [ ] **When location permission is asked for, and what happens when it is refused for good.**
      README §1 says opening the app costs nothing and §3.1 says six opens leave nothing behind;
      a system dialog over a blank page on first launch is a cost. The candidates are: on first
      chit open, on first *save*, or never proactively. ADR-016 already forbids nagging, so a
      `deniedForever` has to be remembered rather than re-asked. **This is the one that is
      genuinely open.**
- [ ] **Whether the weather answer is cached, and for how long.** Every chit open asks, and
      ADR-026 makes Discard open a new chit — so a user tapping Discard four times makes four
      network calls. ADR-026 says M3's implementation *"should be as unbothered by that as the
      fakes are"*, which is a requirement without a mechanism. A short time-to-live is the
      obvious answer; what is not obvious is whether the cache lives in the service or in
      `AmbientCapture`.
- [ ] **The wind threshold, and the `is_day` rule.** §3.6 says `windy` is *"our own threshold on
      wind speed rather than a WMO code"*, and `WeatherCondition` says it *"wins over `clear` and
      never over `raining`"*. The number is a product decision and belongs in `domain`. Same for
      the boundary between `clear` and `clearNight` — Open-Meteo's `is_day` flag answers it, and
      whether we trust it or compute our own is the question.
- [ ] **What a fresh install gets.** ADR-025 has weather reading the device's *last known* fix,
      so on a phone that has never had one there is no weather — the first chit on a new install
      can carry a time and nothing else, with permission granted and the network up. Decide
      whether that is simply correct (it is defensible) or whether the first call may wait for a
      fix.

## B. The WMO mapping ⬜

*Pure, and the whole of the milestone's arithmetic. Build it first — under ADR-031 this is where
M3's correctness can actually live.*

- [ ] `domain/weather/wmo_mapping.dart` — WMO code + `is_day` + wind speed → `WeatherCondition`,
      one pure function, no I/O and no Flutter.
- [ ] Every WMO code in the published table maps to one of the five words of §3.6, and **nothing
      maps to null because it was forgotten** — an unknown code is a stated outcome, not a gap.
- [ ] The precedence of A3: `raining` beats `windy` beats `clear`/`clearNight`.
- [ ] Tests: the full code table, both sides of the wind threshold, both sides of `is_day`, and
      the precedence at each boundary. A table-driven test, not an example each.

## C. `GeolocatorLocationService` ⬜

*The first thing in the app that asks the user for something.*

- [ ] `data/location/geolocator_location_service.dart` — high accuracy, **accepting the coarse
      fix when that is all that was granted** (ADR-016). Both are a successful capture.
- [ ] The permission flow decided in A1, including service-disabled and `deniedForever`.
- [ ] **It never throws.** A refusal, a disabled service, a timeout and a platform error are all
      `null`, which is the ordinary outcome and not the error one (ADR-007).
- [ ] A `lastKnown` path for D to use, because ADR-025 keeps the two signals parallel by never
      making weather wait on a fresh fix.
- [ ] Tests: what can be tested without a device is the *mapping of outcomes to null* and the
      precedence of ADR-016's two accuracies. The permission dialog itself is a device check and
      goes on PROGRESS.md's list.

## D. `OpenMeteoService` ⬜

*One endpoint, no key, no account. Needs C.*

- [ ] `data/weather/open_meteo_service.dart` — current-conditions over `http`, parsed, mapped
      through B, under ADR-007's timeout.
- [ ] Position from `LocationService`'s **last known** fix (ADR-025). No fix, no weather, and
      that is an ordinary `null`.
- [ ] The cache decided in A2.
- [ ] **It never throws.** Offline, rate-limited, 500, malformed JSON and a code outside the
      table are all `null`.
- [ ] Tests: the parse against recorded responses, every failure shape resolving to `null`, and
      the cache — all against a fake `http` client, with no network in the suite.

## E. The swap, and offline ⬜

*Where the milestone becomes true. Two lines and two deletions.*

- [ ] `main.dart` — `OpenMeteoService` and `GeolocatorLocationService` replace the two fixed
      values. **Nothing above `main.dart` changes**; if something has to, group D of M2 got the
      interface wrong and that is the finding.
- [ ] **Delete `fixed_weather_service.dart` and `fixed_location_service.dart`** — CLAUDE.md §0.1.
      They are not fallbacks and not test doubles; `null` is the honest answer and ADR-007 has it.
- [ ] Remove the M2-only lines that name them: ARCHITECTURE.md §2, PROGRESS.md's *fixed fakes*
      note, and the composer's own doc comment.
- [ ] **Done when**, on a device: the composer opens instantly with the network off, a chit saved
      offline carries a time and no weather word and no pin, and **nothing in the UI mentions the
      absence** — no placeholder, no dash, no "unavailable".
- [ ] And with the network on: the word is right for the actual weather, and the prompt stops
      being the rain one — M2 could only ever show those (ADR-029).

## F. Close the loop ⬜

Per CLAUDE.md §0 and §0.1, in the same commits as the work rather than after it.

- [ ] An ADR for each of group A's decisions that could have gone another way.
- [ ] BEHAVIOUR.md §3.6 — if the permission flow puts anything on screen.
- [ ] ARCHITECTURE.md §4.2, which describes ambient capture and currently describes it with
      fakes underneath.
- [ ] PACKAGES.md — if `geolocator` or `http` needed anything not already written down.
- [ ] README.md §10.3 for new suites; §10.6 if any platform config moved.
- [ ] PROGRESS.md — the status board, *What is on a handset today*, the device checklist (the
      permission flow is a new standing row), and any new open item.
- [ ] BUILD-PLAN.md — M3 ✅ and what the milestone taught.
- [ ] `flutter build apk --debug`, and a look at it on the device with the network off and on.
