# Progress

**Where the build is, and what to do next.** This is the handover: a session that has read only
this file and [CLAUDE.md](../CLAUDE.md) should be able to pick up the work.

Updated at the end of every working session, per the standing rules in CLAUDE.md §0 and §0.1 —
including sessions that ended mid-milestone.

**Last updated:** 16 September 2026, **at the end of M2 and after it was signed off on a
handset**. Today is a screen a person can use, and it has been used.

**This file is not a history.** Git is the history, and [TASKS.md](TASKS.md)'s table is the
ledger of what is done. What belongs here is the present: where the build is, what the next
session picks up, what has been seen on a device, and what is known-wrong and unscheduled. A
session that finishes a group **replaces** the *Next* section rather than appending to a log —
that is §0.1 applied to prose, and it is the reason this file is not 930 lines.

---

## Status board

| Milestone | State | Notes |
|---|---|---|
| **M0a** — project stops being a scaffold | ✅ done | 14 Sep 2026 |
| **M0b** — the design system in code | ✅ done | 14 Sep 2026 |
| **M1** — the data spine | ✅ done | 15 Sep 2026. ADR-021 |
| **M2** — Today, text only | ✅ done | 16 Sep 2026. ADR-023 onward |
| **M3** — ambient capture | ⬜ **next** | the two fakes come out. Cut into groups in [TASKS.md](TASKS.md) |
| M4 — calendar | ⬜ | |
| M5 — voice | ⬜ | |
| M6 — the chit editor | ⬜ | OPEN-QUESTIONS.md §8.1 settled 14 Sep 2026 (ADR-017) |
| M7 — motion and the floors | ⬜ | |

**232 tests, `flutter analyze` clean, `dart format` clean, debug APK builds.**

---

## What is on a handset today

The masthead on `--paper`, a two-tab bar, and the whole of BEHAVIOUR.md §4.1.

**The date**, one line: *Wednesday 16 September*. Under it **the timeline** — a hairline with a
7px ink mark for every chit where its time actually falls, a short `--seal` tick at now with the
word *now* over it, and a small tick below the line where one day ends and the next begins. One
day is one screen: it scrolls back a day at a time, rests with now in the middle of the
viewport, and crossing a day boundary gives a small haptic. Days with nothing written in them
are not drawn, so a quiet install opens on today alone and does not scroll at all. Nothing on it
moves.

**The open chit** — a slip with its tear edge and the pad behind it, its stamp reading
`8:46 pm   raining   ⌖` spaced and never separated, a blank page, and a microphone leading the
action row. **Nothing moves until you touch it** (ADR-028): no caret is drawn, and the one that
arrives on the first tap is the platform's. Leave it five seconds and a prompt fades in —
*"Rain tonight. How did the day go?"* — chosen from the stamp (ADR-029). Typing brings
**Discard** and **Save chit**, and both work: Save writes the row, the chit drops into the
thread under *earlier* with its count beside it, its mark appears on the strip, and a new blank
chit opens stamped at that moment.

Below the thread the चित्त mark closes the day. An empty day reads *"Nothing written yet
today."* with no rail and no count. Tapping *calendar* cross-fades to a placeholder line that M4
deletes.

*The weather word and the pin are fixed fakes until M3 and will always read `raining` at the
Royal Observatory — that is `FixedWeatherService` and `FixedLocationService` doing their job,
not a bug.*

**Signed off on a handset, 16 September**, at the end of the milestone: the palette, the slip,
the field, the stamp, Discard, the prompt, the thread, saving — including a long chit — the
strip's marks and their positions, horizontal scrolling and its back-stop, the day-boundary
tick, the empty-day trim, the tick at now in its final form, the haptic, and save-scrolls-to-now.

**And chits close together in time overlap on the strip rather than smearing**, which is what
§4.1 asks for in as many words: *four chits in an hour look like a burst, because they are one.*
That was tried on purpose and it reads. It is the first half of open item 15 — a dozen marks
across three days is still untried.

---

## The device is the other half of the suite

ADR-031 removed the widget tests, so what is only ever visible on a screen is only checked by
someone looking at one. **This list is the mitigation, and it is a weaker one than a test was**
— it works only if it is actually run. M2 produced three reversals that nothing but a device
would have caught (ADR-028, and ADR-036 twice), which is the argument for it.

Everything on it was run at the end of M2 and passed. It stays because it is a **standing**
list: these are the claims nothing else can hold, and they have to survive every milestone
after this one, not only the one that introduced them.

| Check | Why it is here |
|---|---|
| The keyboard does **not** come up on launch | ADR-023. Had a test; has none now |
| A chit left open across a minute boundary saves at the time it was **opened** | ADR-021. The stamp is held, and a stale one looks exactly like a fresh one |
| Discard, then read the stamp — it is the **new** time | ADR-026, same failure mode, opposite direction |
| A phone left open across midnight rolls the date, the thread **and** the strip together | ADR-033. The one thing on this screen no test can drive |
| The tear edge is holes in the pad, not a dotted border | DESIGN-LOG.md calls this load-bearing, and it is two characters of paint code from being wrong |
| Switching tabs and back does not reset the field | ADR-011 — a fade, not a rebuild |
| The microphone is still reachable and still an equal on a half-written chit | DESIGN-LOG.md's standing warning about it drifting into a toolbar of small grey icons |
| Reduced motion on: the prompt still fades, the tab still cross-fades, the strip **jumps** to now rather than sliding | §6.4 — movement collapses and feedback does not |
| Every target ≥44px | §6.4 |
| The tick at now still reads as a position, not an object | ADR-036, and it took three attempts to get there |
| The haptic fires once per day boundary, and is silent when a save scrolls the strip | ADR-034 |
| Saving scrolls the strip to now, smoothly | §4.1 |

---

## Next: M3 — ambient capture

The fakes come out. [BUILD-PLAN.md](BUILD-PLAN.md) M3 has the statement of done and
[TASKS.md](TASKS.md) is it cut into six groups, **A to F**. Start with A: four decisions, of
which *when location permission is asked for* is the one that is genuinely open and that changes
what group C builds. B — the WMO mapping — is pure and independent, so it is the thing to build
while A is still being argued.

**M3 draws nothing.** Every surface it touches exists; what changes is what those surfaces say.
The only new thing a user sees is a system permission dialog.

What it inherits:

- **`FixedWeatherService` and `FixedLocationService` are two lines in `main.dart`.** M3 deletes
  both files and changes those two lines; nothing above them moves. That was group D's whole
  point and it should stay true.
- **`WeatherService.currentCondition()` takes no position** — ADR-025. `OpenMeteoService` uses
  the device's *last known* fix and answers `null` when there is not one. Giving it coordinates
  would make the two signals sequential where ADR-007 promises parallel, and reversing it needs
  a new record.
- **ADR-007's shape is already in place**: both signals go out at once, each under its own
  timeout, and a signal that does not arrive is null and is not drawn. M3 swaps implementations
  in behind `AmbientCapture` and should not need to touch it.
- **The WMO mapping is a pure function and belongs in `domain`**, unit-tested against a table of
  codes — which under ADR-031 is exactly where the milestone's correctness should live.
- **The permission flow is new surface**, and it is the first thing in the app that can ask the
  user for something. §3.6 shows a pin and never a place name; ADR-016 stores a precise fix and
  states the tension plainly. Neither changes.

---

## Open items

Things a future session needs to know but that are not scheduled work. **Numbers are stable** —
they are cited from other documents — so a closed item keeps its number and shrinks to a line.

1. **Nobody has looked at the type on a handset, beside the prototype.** `ChitType._opticalSizeFor`
   converts logical pixels to points at 0.75, which is what the CSS spec says a browser does with
   `font-optical-sizing: auto`. If Newsreader looks heavier or lighter than
   `design/chit-app-v6.html` at the same size, that constant is the first suspect. There is now a
   screen full of real text to compare.
2. ~~Two colours with no token.~~ **Closed 15 Sep 2026 by v6** (ADR-022).
3. ~~`sqlite3_flutter_libs` resolves to `0.6.0+eol`.~~ **Closed 15 Sep 2026.** PACKAGES.md has
   the detail.
4. **`speech_to_text` applies the Kotlin Gradle Plugin,** and the build warns that future Flutter
   versions will fail on plugins that do. Harmless on 3.47.4. Check before any Flutter upgrade,
   since ADR-005 makes that package hard to swap.
5. **Developer Mode on Windows.** `flutter pub get` warns that plugin builds need symlink
   support. Not blocking — the APK builds.
6. **Font bundle is ~1.8 MB,** of which Noto Serif Devanagari is 758 KB to draw one word.
   PACKAGES.md suggests subsetting before shipping.
7. **`public_member_api_docs` is on.** Valuable in `domain`, `data` and `core`; noise on a
   zero-argument widget constructor. If it becomes a real tax the answer is a nested
   `analysis_options.yaml` under `lib/features/`, not turning it off everywhere.
8. **OPEN-QUESTIONS.md §8.2 (re-transcription) and §8.3 (does Today carry enough rhythm) are
   still open.** §8.3 is now answerable — the rhythm signal it is about exists and can be lived
   with for a week.
9. **Nothing deletes a chit yet,** so the orphan sweep has little to collect. When a delete
   arrives it goes in the repository, removes the row and the file together, and gets its own
   test.
10. **The debug seeder of DATA-MODEL.md §7 does not exist.** It is now worth more than it was:
    the timeline and the calendar both want several days of history, and ADR-035 means an empty
    yesterday is not even drawn. Worth writing at the start of M4, and it would have made M2
    group H easier to look at.
11. ~~Re-point `lib/core/theme/` at v6.~~ **Closed 15 Sep 2026.**
12. ### ⬜ **Today's ring fails its contrast floor on a busy day.** Wants a design answer.

    Today is ringed in `--seal` on the calendar; the tile under it is an ink wash whose strength
    depends on how much was written that day. As a non-text UI component the ring needs 3:1:

    | Tile | Ratio | |
    |---|---|---|
    | empty | 4.56:1 | passes |
    | one chit | 3.97:1 | passes |
    | two | 3.36:1 | passes |
    | three | **2.61:1** | fails |
    | four or more | **1.88:1** | fails |

    Three chits is an ordinary day in an app whose premise is several a day, so this is not a
    corner case. Do not fix it by nudging a token: the ring and the fill are the same lightness
    family by design (ADR-022). It probably wants a different *shape* for today — and M2 group I
    found the general form of that answer, which is §6.4's new **colour is never the only
    difference**: `--seal` is *less* contrasty on paper than `--ink-faint` is (4.56:1 against
    5.08:1), so the accent has never been carrying hierarchy on contrast anyway. It is M4's
    problem.

    The figures are asserted in `test/core/theme/contrast_test.dart`, **including the two that
    fail**. Fixing this breaks that test, which is deliberate.
13. ~~`--hair-soft` has collapsed on a chit.~~ **Closed 15 Sep 2026** by M2 decision A4. It
    turned up a second thing worth keeping: **`--ink-faint` fails on any wash at all**, so
    Discard's label lifts to `--ink` while the control is held.
14. **The framework's caret still blinks under reduced motion,** and it belongs to M7's floors
    pass. §6.4 lists the caret blink among the loops that stop outright, and since ADR-028 the
    only caret in the app is Flutter's. There is no public way to steady it:
    `TickerMode(enabled: false)` sets the cursor's opacity to **zero**, so it vanishes rather
    than resting, and `EditableText.debugDeterministicCursor` is a `debug`-prefixed global
    documented as being for tests. Perspective before anyone spends a day on it: a stock Android
    keyboard blinks whatever the animation setting says. The two honest ways forward are a
    framework issue, or writing it into §6.4 as a stated limit rather than a silent one.
15. **Crowding on the timeline is half answered.** Chits written minutes apart **overlap**, and
    that reads as the burst §4.1 wants rather than as a smear — tried deliberately at the end of
    M2. What is still untried is the case ADR-024 actually worried about: fifteen to twenty marks
    spread across three days, which is a different picture from four marks in an hour. The debug
    seeder of item 10 is how to produce it on purpose, and that is the reason to write it.
16. **What the strip says at its back-stop is now a smaller question than it was.** Two days back
    on a quiet day used to be a bare line with no mark, no boundary and — by §4.1's own decision —
    no label; ADR-035 removed most of that by not drawing empty leading days at all. What is left
    is the case where the oldest day *has* one chit and the rest is empty, which is honest and
    has not been looked at.
17. **`ChitMotion.loop` has no caller.** ADR-036 took the pulse off the strip, so nothing in the
    app loops. The rule is still right (ADR-027) and M5's record dot is its first user; this is
    here so that nobody deletes it as dead code in the meantime.
