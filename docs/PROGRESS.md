# Progress

**Where the build is, and what to do next.** This is the handover: a session that has read only
this file and [CLAUDE.md](../CLAUDE.md) should be able to pick up the work.

Updated at the end of every working session, per the standing rules in CLAUDE.md §0 and §0.1 —
including sessions that ended mid-milestone.

**Last updated:** 16 September 2026, **part way into M3**. Motion is captured, stored, ranked,
drawn and prompted on; a fresh install now asks for location behind a screen of its own; and a
chit is stamped when it is **saved** rather than when it was opened. **None of it has been on a
device yet.** The milestone's two real services are not written and the fakes are still wired in.

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
| **M1** — the data spine | ✅ done | 15 Sep 2026. ADR-021, since **superseded by ADR-040** |
| **M2** — Today, text only | ✅ done | 16 Sep 2026. ADR-023 onward |
| **M3** — ambient capture | 🔶 **in progress** | motion, first run and the capture lifecycle are done (A–F2); the two real services and the swap are not (G–K). [TASKS.md](TASKS.md) |
| M4 — calendar | ⬜ | |
| M5 — voice | ⬜ | |
| M6 — the chit editor | ⬜ | OPEN-QUESTIONS.md §8.1 settled 14 Sep 2026 (ADR-017) |
| M7 — motion and the floors | ⬜ | |

**290 tests, `flutter analyze` clean, `dart format` clean, debug APK builds.** *But **nothing
below marked 🔶 has been looked at on a screen.** Motion compiles, is tested, and cannot fire —
the fakes carry no speed. The first-run screen has never been rendered.*

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

*The weather word and the pin are fixed fakes until M3's group J and will always read `raining`
at the Royal Observatory — that is `FixedWeatherService` and `FixedLocationService` doing their
job, not a bug. `FixedLocationService` carries no speed, so **motion is always absent on a
handset today** and the stamp looks exactly as it did at the end of M2.*

**Signed off on a handset, 16 September**, at the end of the milestone: the palette, the slip,
the field, the stamp, Discard, the prompt, the thread, saving — including a long chit — the
strip's marks and their positions, horizontal scrolling and its back-stop, the day-boundary
tick, the empty-day trim, the tick at now in its final form, the haptic, and save-scrolls-to-now.

**And chits close together in time overlap on the strip rather than smearing**, which is what
§4.1 asks for in as many words: *four chits in an hour look like a burst, because they are one.*
That was tried on purpose and it reads. It is the first half of open item 15 — a dozen marks
across three days is still untried.

### 🔶 And since 16 September — built, not yet seen

**Motion.** A chit records what the phone was doing: `stationary`, `walking`, `traveling` or
`flying`, read off the speed of the same fix the pin uses (ADR-037). The stamp draws **one**
ambient fact rather than two (ADR-038) — a ranked ladder, with a motion icon displacing the
weather word when it outranks it, and `stationary` drawing nothing at all. The icon appears
under saved chits in the thread as well, where the pin does not (ADR-039).

**The ordinary chit is unchanged by all of it**, which is the claim the whole design rests on:
at a desk in the rain the row still reads `8:46 pm   raining   ⌖`. That is asserted in
`ambient_fact_test.dart` and in `prompts_test.dart`, and it is the first thing to confirm on a
screen.

`design/chit-app-v6.html` has the three marks and a **Motion** control in its tweaks panel —
they were drawn there first and the app followed, which is the only reason they have a source.
**Open it in a browser before judging them in Flutter.**

**A first-run screen** (ADR-041). A fresh install opens on a page of chit's own furniture — the
wordmark, a slip with its tear edge, **Allow** and **Not now** — explaining that a chit is
stamped with the time, the weather, whether you were moving, and that a place was recorded, and
that none of it leaves the phone. **Allow** raises the system location dialog; **Not now** raises
nothing at all. Either spends the app's one ask, and neither is ever shown again. The microphone
is not asked for: that is M5's, at the moment somebody taps it.

**And the capture lifecycle changed under all of it.** Ambience is read **at launch and at save,
never in between** (ADR-042) — no timer, no expiry, no refresh on resume — where it used to be
read on every chit open. A chit is **stamped when it is saved** (ADR-040), which reverses ADR-021
and makes the wrong-day case unreachable rather than defended against. Saving writes the row at
once and patches the fresh reading in a moment later, so nothing about a save is behind a
network call.

**The visible consequence, and the thing to look for first:** the stamp on the open chit is now
a **preview**. It shows the time the chit was opened, it does not tick, and a chit sat on for
twenty minutes lands in the thread carrying a later time than the slip showed.

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
| **🔶 A chit left open across a minute boundary saves at the time it was _saved_** | **ADR-040, the reversal.** This row is the old one inverted — it used to read *opened*. A stamp taken at the wrong moment is still a plausible time, so this is the only place it can be seen |
| Discard, then read the stamp — it is the **new** time | The preview must not sit there showing a time that has passed (ADR-040) |
| A phone left open across midnight rolls the date, the thread **and** the strip together | ADR-033. The one thing on this screen no test can drive |
| The tear edge is holes in the pad, not a dotted border | DESIGN-LOG.md calls this load-bearing, and it is two characters of paint code from being wrong |
| Switching tabs and back does not reset the field | ADR-011 — a fade, not a rebuild |
| The microphone is still reachable and still an equal on a half-written chit | DESIGN-LOG.md's standing warning about it drifting into a toolbar of small grey icons |
| Reduced motion on: the prompt still fades, the tab still cross-fades, the strip **jumps** to now rather than sliding | §6.4 — movement collapses and feedback does not |
| Every target ≥44px | §6.4 |
| The tick at now still reads as a position, not an object | ADR-036, and it took three attempts to get there |
| The haptic fires once per day boundary, and is silent when a save scrolls the strip | ADR-034 |
| Saving scrolls the strip to now, smoothly | §4.1 |
| **🔶 A fresh install opens on the first-run screen; the second launch opens on Today** | ADR-041, the whole flow — and the thing a stale preference breaks silently |
| **🔶 Refusing, then relaunching, does *not* ask again** | ADR-016 forbids nagging. Tested in a container; never seen against real `shared_preferences` |
| **🔶 Refusing leaves an app that works and says nothing about it** | ADR-007. No pin, no motion, no placeholder, no apology |
| **🔶 The first-run screen reads as chit, not as a system prompt** | It is the reason it exists instead of a bare dialog. Nothing on it is a new kind of object |
| **🔶 Nothing at launch delays the first paint** | README §1, and why `prime()` runs from a post-frame callback and is never awaited |
| **🔶 A chit appears in the thread instantly on Save, with the network off** | ADR-042 — the write is never behind a capture |
| **🔶 At a desk in the rain the stamp is byte-for-byte what M2 signed off** | ADR-038's safety claim. If this moved, the ladder is wrong and everything below is moot |
| **🔶 The three marks read at 12px beside 11.5px text, and weigh what the pin weighs** | ADR-039. They are strokes because an outline blobs at this size — that judgement has not been checked by eye |
| **🔶 A walk produces the figure, and the weather word goes** | The displacement *is* the design. Needs group J and a walk outdoors |
| **🔶 TalkBack / VoiceOver reads *Walking*, *Travelling*, *Flying*** | §6.4 — the mark is the whole of the fact, not an adornment beside it |
| 🔶 Location refused → no pin **and** no motion, and nothing says so | ADR-007, and ADR-037's one real coupling: they are a single signal |
| 🔶 The mark does not flicker between two states while a chit is open | The app captures at launch and at save, never in between (ADR-042) |

---

## Next: M3 — the two services, and the swap

Motion, first run and the capture lifecycle are finished (TASKS.md A–F2). **What is left is what
M3 always was**, and it is gated on the **two** decisions still open in group F: the wind
threshold with the `is_day` rule, and what a fresh install gets before it has ever had a fix.

**Group G — the WMO mapping — needs only the first of those**, and it is the thing to build
next. It has a worked example sitting beside it: `domain/motion/motion_ladder.dart` is the same
shape, the same layer, the same kind of table-driven test.

Then H (`GeolocatorLocationService`), I (`OpenMeteoService`), J (the swap and the two deletions)
and K (the doc loop).

**Three things to carry into H**, all of which the work since M2 put there:

- **`GeoFix` is a class now, not a record.** It carries `speed`, `speedAccuracy` and `altitude`
  beside the coordinate, all nullable. `GeolocatorLocationService` fills them from `Position`
  **untouched and unjudged** — the ladder in `domain` decides what they mean.
- **`LocationService.requestPermission()` is already on the interface**, and the first-run screen
  is already calling it. H implements it over geolocator; nothing above `data` changes.
  **`currentFix()` must never raise a dialog** — a capture that could is a system prompt over a
  chit somebody is writing.
- **`Position.speedAccuracy` may be `0.0` for *unknown*.** `MotionLadder` reads zero as unknown,
  which is the conservative reading; if a platform means it literally, motion sticks at
  `stationary` forever and looks like a feature that does not work. **This is the single most
  likely thing to be wrong about motion**, and nothing in the suite can settle it.

**And one thing to do before any of that, because it costs ten minutes:** build the APK and look
at it. Two of the three claims worth checking are available today even with the fakes in — that
a fresh install opens on the first-run screen and the second launch does not, and that a chit
sat on for a minute saves at the time it was *saved*. The rest waits for group J.

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
18. **`Position.speedAccuracy` may mean *unknown* when it says `0.0`, and the ladder bets that
    it does.** This is **the single most likely thing to be wrong about motion**, and nothing in
    the suite can settle it — it is a fact about two platform implementations. `MotionLadder`
    refuses to claim any state above `stationary` without a usable accuracy, and reads zero as
    absent rather than as perfect, because the other reading inverts the gate exactly where it
    matters. If a platform turns out to mean `0.0` literally, motion will be stuck at
    `stationary` forever and look like a feature that simply does not work. **Check it in
    TASKS.md group H**, against a real `Position`, before concluding anything else is broken.
19. **The three motion marks have never been looked at, at 12px, by anyone.** They are drawn as
    strokes rather than as silhouettes because an outlined plane's wings close into a blob under
    a 1.22px stroke — that is reasoning, not evidence. The walking figure is the weakest of the
    three and the most likely to need redrawing; it is four strokes and a circle in a 14-unit
    box, and `design/chit-app-v6.html` is where to change it first. ADR-039 carries the cost.
20. **`flying` will almost never fire, and that is expected rather than broken.** Most devices
    disable GPS in airplane mode, so there is no fix, so there is no speed. The state is correct
    when it does fire and it is cheap to keep. This is here so that a future session does not
    spend a day debugging a state that was never going to appear — ADR-037 states it as a cost.
    If it turns out to matter, the honest routes are a barometer (cabin pressure is a real
    signal that survives airplane mode) or accepting it as a state that only shows up on the
    rare flight with location services left on.
21. **Nothing tunes the motion thresholds.** 0.7, 3.0 and 55 m/s and the 2000 m ceiling are
    defensible arithmetic, not measurements — nobody has walked, driven or flown with this
    build. The boundary most likely to read wrong in practice is `walking` against `traveling`
    at 3.0 m/s: a cyclist and a car in heavy traffic both sit near it, and both are `traveling`
    by design (ADR-037 refuses `cycling` because speed cannot defend it).
22. **A refusal is a dead end, and a way back is owed.** ADR-041 spends the app's one permission
    ask on the first-run screen and never asks again (ADR-016). There is no settings screen, so
    an install that refused — or that tapped **Not now** — can only re-enable location through
    the OS. That is the correct trade today and it stops being correct the moment there is
    anywhere sensible to put a control. BEHAVIOUR.md §4.1's settings sketch is where it lands.
23. **The preview on the open chit goes stale without bound.** ADR-042 captures at launch and at
    save and never in between, so a phone left open all day draws the launch weather on the slip.
    **No chit is ever recorded with it** — save re-reads — but a user could reasonably look at a
    word that is six hours old. If that turns out to matter on a device, the smallest honest fix
    is a refresh when the app returns to the foreground after a long absence, which is the option
    ADR-042 considered and did not take.
24. **The stamp's time does not tick.** It shows when the chit was opened and the row carries when
    it was saved (ADR-040), so the two drift apart the longer a chit sits. A self-updating clock
    was refused because it is an ambient loop (ADR-027, §6.4), and a clock re-read on every
    rebuild would be unpredictable rather than merely stale. A middle option nobody has tried:
    re-read the preview on the *first keystroke*, which is one event rather than a loop.
