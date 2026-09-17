# Progress

**Where the build is, and what to do next.** This is the handover: a session that has read only
this file and [CLAUDE.md](../CLAUDE.md) should be able to pick up the work.

Updated at the end of every working session, per the standing rules in CLAUDE.md §0 and §0.1 —
including sessions that ended mid-milestone.

**Last updated:** 17 September 2026, **with M4 built and its device pass owed**. The calendar
is written, tested and compiles into a debug APK, but **nobody has looked at it on a handset
yet** — [TASKS.md](TASKS.md) groups F and G are the pass and the clean-up after it, and they
are the two things standing between this and *done*.

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
| **M3** — ambient capture | ✅ done | 17 Sep 2026, signed off on a handset. ADR-037 onward |
| **M4** — calendar | 🔶 built, device pass owed | 17 Sep 2026. ADR-046. TASKS.md groups A–E done; F and G are the handset |
| M5 — voice | ⬜ | |
| M6 — the chit editor | ⬜ | OPEN-QUESTIONS.md §8.1 settled 14 Sep 2026 (ADR-017) |
| M7 — motion and the floors | ⬜ | |

**387 tests, `flutter analyze` clean, `dart format` clean, the debug APK builds.** The release
APK has not been rebuilt since M3's sign-off.


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
today."* with no rail and no count.

**The calendar — built on 17 September and not yet seen on a handset.** Tapping *calendar*
cross-fades to the month bar (*September 2026*, two chevrons, the next one faint at the current
month), the weekday row, and the grid: a number only where something was written, four steps
of ink, the month drawn up to today and no further, and **today ringed on paper** with a strip
of paper between the ring and its wash (ADR-046). Under a hairline, *17 chits over seven days*
when seeded; under that, the archive — every day newest first, headed *Today* / *Yesterday* /
*Friday 11 September*, drawn by the same `DayThread` Today uses. A tile narrows the archive to
its day and takes an ink frame; the same tile, or **Show every day**, widens it. Everything
here is a stream off the one table, so a save on Today reaches the tile, the total and the
archive together — the suite holds that claim; the handset has not yet.

The screen was built against `--dart-define=CHIT_SEED=seed`'s twenty chits, and **those rows
are still to be cleared** off whichever handset runs the pass — TASKS.md group G.

**The first look at it, 17 September, found two things before the pass proper began.** The
seeder did nothing on the handset: it was gated on `kDebugMode` as well as on the define, and a
release run ignored the flag without a word; and it wrote its placeholder recordings to
`Directory.systemTemp`, which Android does not let an app write to. Both are fixed — the flag
works in any build mode, and the files go to the app cache like a real recording. The same look
raised the two empty rows above a fresh install's 17th; that is the grid keeping the month's
geometry, and BEHAVIOUR.md §4.2 now says so. Today's ring on paper, on an empty tile, read as
today.

*Weather, the pin and motion are **real** as of 17 September — `OpenMeteoService` and
`GeolocatorLocationService` replaced the two fixed fakes, which are deleted. Nothing above
`main.dart` changed when they came out, which was the whole point of M2 group D.*

**Signed off on a handset, 16 September**, at the end of the milestone: the palette, the slip,
the field, the stamp, Discard, the prompt, the thread, saving — including a long chit — the
strip's marks and their positions, horizontal scrolling and its back-stop, the day-boundary
tick, the empty-day trim, the tick at now in its final form, the haptic, and save-scrolls-to-now.

**And chits close together in time overlap on the strip rather than smearing**, which is what
§4.1 asks for in as many words: *four chits in an hour look like a burst, because they are one.*
That was tried on purpose and it reads. It is the first half of open item 15 — a dozen marks
across three days is still untried.

**The first-run screen**, shown once in the life of an install: the wordmark, a slip carrying
what is captured and that none of it leaves the phone, **Allow** and **Not now**. Allow raises
the system location dialog; Not now raises nothing. Neither is ever shown again (ADR-041).

**Signed off on a handset in release, 17 September.** It asked for location once, the pin
appeared, and the weather word was right for the actual sky — `GeolocatorLocationService`,
`OpenMeteoService` and `WmoMapping` working end to end.

**That pass found three things**, all now closed and all recorded rather than smoothed over: a
release build that drew nothing (item 25), a permission dialog that never appeared (item 26),
and a pin that never appeared (item 27). The fourth is accepted rather than fixed — `clear
night` is drawn where a stock weather app says *partly cloudy* (item 28).

### What ambient capture does, now that it is real

A chit records the **weather** as one of five words, the **fact of a place** as a pin, and
**what the phone was doing** — `stationary`, `walking`, `traveling` or `flying` (ADR-037), read
off the speed of the same fix the pin uses. The stamp draws **one** ranked ambient fact rather
than two (ADR-038): a motion icon displaces the weather word when it outranks it, and
`stationary` draws nothing at all. The icon appears under saved chits in the thread as well,
where the pin does not (ADR-039).

**The ordinary chit is unchanged by all of it**, which is the claim the design rests on: at a
desk in the rain the row reads `8:46 pm   raining   ⌖`, exactly as M2 left it.

**A chit is stamped when it is saved** (ADR-040), so the stamp on the open chit is a *preview* —
it shows when the chit was opened and does not tick. **Ambience is read at launch and at a save
holding something over five minutes old** (ADR-042, ADR-045), so a burst of chits in one sitting
costs one capture.

`design/chit-app-v6.html` has the three motion marks and a **Motion** control in its tweaks
panel. They were drawn there first and the app followed, which is the only reason they have a
source — **open it in a browser before judging them in Flutter.**

---

## The device is the other half of the suite

ADR-031 removed the widget tests, so what is only ever visible on a screen is only checked by
someone looking at one. **This list is the mitigation, and it is a weaker one than a test was**
— it works only if it is actually run. M2 produced three reversals that nothing but a device
would have caught (ADR-028, and ADR-036 twice), and M3 produced four more — a release build that
drew nothing, a dialog that never appeared, a pin that never appeared, and a keyboard that never
went down. **Not one of them was a test failure**, and that is the argument for this list.

Everything on it was run at the end of M3 and passed. It stays because it is a **standing**
list: these are the claims nothing else can hold, and they have to survive every milestone
after the one that introduced them.

*M3 added five rows and they are the ones with the least mileage on them.* The last three in
particular were checked once, on one handset, on one evening in Mumbai — a walk outdoors and a
long sitting have still never been tried. **M4 added seven more, at the foot of the table, and
not one of them has been run** — that is TASKS.md group F, and it is the next thing to do.

| Check | Why it is here |
|---|---|
| The keyboard does **not** come up on launch | ADR-023. Had a test; has none now |
| Tapping the page raises the keyboard; tapping away puts it down | §3.2. Flutter leaves a mobile field focused on an outside tap, so this behaviour is ours rather than the platform's |
| A chit sat on across a minute boundary saves at the time it was **saved** | **ADR-040, the reversal.** This row is the old one inverted — it used to read *opened*. A stamp taken at the wrong moment is still a plausible time, so a device is the only place it can be seen |
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
| **A fresh install asks for location once; the second launch does not ask** | ADR-041 and ADR-016. A stale preference breaks this silently, and it is the first thing a new install sees |
| Refusing leaves an app that works and says nothing about it | ADR-007. No pin, no motion, no placeholder, no apology |
| The first-run screen reads as chit, not as a system prompt | It is the reason it exists instead of a bare dialog. Nothing on it is a new kind of object |
| Nothing at launch delays the first paint | README §1, and why `prime()` runs from a post-frame callback and is never awaited |
| **A release build renders at all** | It once did not, and the release `ErrorWidget` paints nothing legible — `flutter run --release` and the console is the only place a cause appears |
| **The pin appears**, within about ten seconds of a cold launch | ADR-044. A GPS fix is not instant, and a stamp filling in late is ADR-007 behaving rather than stalling |
| Location refused → no pin **and** no motion, and nothing says so | ADR-007, and ADR-037's one real coupling: they are a single signal |
| A chit appears in the thread instantly on Save, with the network off | ADR-042 — the write is never behind a capture |
| At a desk in the rain the stamp is byte-for-byte what M2 signed off | ADR-038's safety claim. If this moved, the ladder is wrong and everything after it is moot |
| Five chits in one sitting cost **one** capture | ADR-045, and the only way to see it is a network or GPS indicator — the rows look identical either way |
| **A walk outdoors produces the walking mark, in place of the weather word** | ADR-038 and ADR-039. **Never once seen** — the motion marks have not been drawn on a real device at all |
| The three marks read at 12px beside 11.5px text, and weigh what the pin weighs | ADR-039. They are strokes because an outline blobs at this size, and that judgement has not been checked by eye |
| TalkBack / VoiceOver reads *Walking*, *Travelling*, *Flying* | §6.4 — the mark is the whole of the fact, not an adornment beside it |
| The mark does not flicker between two states while a chit is open | The app captures at launch and at a stale save, never in between (ADR-042, ADR-045) |
| **Today's ring reads as *today* on a five-chit tile, not as a fainter day** | **ADR-046, unseen.** The ring on paper costs today's wash six pixels of size, and whether that reads is the one thing the decision could not settle at a desk |
| The four density steps tell apart one, two, three and five chits at arm's length | §4.2. The ratios are asserted; whether 6% and 12% *look* different on a handset in real light is not |
| A tile takes a tap anywhere in its cell, and every cell clears 44px | §6.4, and §6.3's reason for putting the gap inside the cell rather than between them |
| **Saving on Today changes the tile, the summary and the archive without a refresh** | BUILD-PLAN.md M4's statement of done. Held by `calendar_providers_test.dart`; a handset is where *without a refresh* is seen rather than inferred |
| The previous chevron goes back a month and the archive still reads every day; the next one is faint and dead at the current month | §4.2. A disabled control drawn at 30% is a claim about legibility nobody has checked |
| The archive pages in before the reader reaches the join | `CalendarScreen._pageAhead`, a number with nothing behind it but a guess at a screen's height |
| `CHIT_SEED=clear` leaves exactly what was written by hand | DATA-MODEL.md §7. The suite proves it in memory; the handset is where a wrong prefix would cost somebody's chits |

---

## Next: M4, groups F and G — the handset

**Everything that can be done at a desk is done.** [TASKS.md](TASKS.md) groups A to E are
ticked: the seeder, the month's arithmetic, the providers, the screen and the docs. What is
left is the two groups only a phone can do, and they are written out as checklists there:

1. **Group F** — `flutter run --dart-define=CHIT_SEED=seed`, then look. The grid as a shape,
   today's ring on paper on a busy tile (ADR-046 — the one decision this session could not
   settle at a desk), the chevrons, the summary's wording, filtering, the 44px floor, and the
   milestone's statement of done: a save on Today reaching the calendar without a refresh.
   It also finally puts open items 15 and 19 in front of somebody.
2. **Group G** — `flutter run --dart-define=CHIT_SEED=clear`, and confirm the console says
   twenty rows and four recordings went and that nothing written by hand did. Then M4 is
   signed off here and in BUILD-PLAN.md.

If the pass finds something, the shape of the answer is the one M3 used: fix it, record it as
a numbered item below if it is accepted rather than fixed, and re-run the row it broke.

Everything else that is known and unscheduled is in the open items below. Nothing there blocks
M4.

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
10. ~~The debug seeder of DATA-MODEL.md §7 does not exist.~~ **Closed 17 September 2026** by
    M4 group A. `flutter run --dart-define=CHIT_SEED=seed` writes twenty chits over six weeks,
    `=clear` takes them off again; DATA-MODEL.md §7 has the shape of the fixture.
11. ~~Re-point `lib/core/theme/` at v6.~~ **Closed 15 Sep 2026.**
12. ~~Today's ring fails its contrast floor on a busy day.~~ **Closed 17 September 2026 by
    ADR-046**, with the shape answer the item asked for: the ring frames the tile with 2px of
    paper inside it, so both edges meet `--paper` at 4.56:1 whatever today holds. The old
    figures — 2.61:1 at three chits, 1.88:1 at four — stay in `contrast_test.dart` as the
    record of why. **Whether the smaller wash reads as *today* is unseen**; it is the first row
    M4 added to the device list.
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
    spread across three days, which is a different picture from four marks in an hour. **The
    seeder now produces it on purpose** — five marks on each of the two days before today,
    including a six-minute pair — and TASKS.md group F is where it gets looked at.
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
    **The seeder draws all three** — walking twice, travelling twice, flying once — so group F
    is the first time anyone can look without taking a walk first.
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
    a stale save, so a phone left open all day with nothing written draws the launch weather on
    the slip indefinitely. A chit *written* on it is fine — ADR-045's window will have expired,
    so the save re-reads — but somebody could sit looking at a word six hours old. If that
    matters on a device, the smallest honest fix is a refresh when the app returns to the
    foreground after a long absence, which ADR-042 considered and did not take.
24. **The stamp's time does not tick.** It shows when the chit was opened and the row carries when
    it was saved (ADR-040), so the two drift apart the longer a chit sits. A self-updating clock
    was refused because it is an ambient loop (ADR-027, §6.4), and a clock re-read on every
    rebuild would be unpredictable rather than merely stale. A middle option nobody has tried:
    re-read the preview on the *first keystroke*, which is one event rather than a loop.
25. ~~**A release build showed a bare `--paper` screen and nothing else.**~~ **Closed 17 September.** Seen 16 September;
    fixed by taking the router's `redirect` off `ref.watch`, which reaches for a `Ref` that has
    finished building. A release build has since run on a handset and drawn everything.

    The same build in **debug** reached the first-run screen and worked. The brown is `--paper`
    (`#191714`), and the Android launch background is white — so Flutter *did* boot and paint a
    surface, and it is the content that is missing rather than the app failing to start.

    **One real bug in that area has been fixed since:** the router's `redirect` called
    `ref.watch`, which reaches for a `Ref` that has finished building. It now reads once and
    drives go_router's `refreshListenable`, which is both correct and cheaper — the old shape
    would have rebuilt the provider and constructed a second `GoRouter` with empty navigation
    stacks. **Whether that was *this* failure is unconfirmed**, and saying otherwise would be a
    guess dressed as a diagnosis.

    **How to settle it in one run:** `flutter run --release` and read the Dart exception. The
    release `ErrorWidget` paints nothing legible, so the console is the only place the cause
    appears. That is the first thing to do with a device.
26. ~~**Tapping Allow raised no system dialog.**~~ **Closed 17 September** by group H. It was
    `FixedLocationService` answering `granted` without asking anything — the fake doing its job,
    since `GeolocatorLocationService` did not exist yet. The real one raises the dialog.
27. ~~**The pin never appeared, though weather did.**~~ **Closed 17 September** by ADR-044, and
    worth keeping as a line because of how it read. Every piece was working: the weather word
    proved `lastKnownFix()` was answering, and the pin's absence proved `currentFix()` was not.
    The cause was the **budget**, not the plumbing — a high-accuracy fix is a GPS fix, and
    ADR-007's two seconds was sized when the composer was still waiting on a capture. Since
    ADR-042 nothing waits, so the ceiling was protecting nothing and cutting off the fix.
28. **`clear night` is drawn for Open-Meteo's *partly cloudy*.** Seen on a handset,
    17 September, beside a stock weather app reading *partly cloudy* — and accepted rather than
    called a bug. WMO code 2 is *partly cloudy*, and §3.6's word is *"clear or nearly clear"*,
    so code 2 sits with 0 and 1. It is defensible and it is also the loosest call in
    `WmoMapping`. If chits start reading `clear night` on nights that were plainly not clear,
    moving code 2 to `overcast` is a one-line change and the test walks the table either way.
29. **A chit can be written from a reading up to five minutes old** — ADR-045, and the cost of
    it lands hardest on motion. A speed five minutes stale is exactly the claim ADR-037's
    accuracy gate refuses everywhere else, and here it reaches a row: a chit written on a train
    five minutes after the launch capture says `stationary`, because that is what the phone was
    doing on the platform. **Untested against a real journey.** If it reads wrong, the honest
    fix is a shorter window for motion than for the other two rather than a shorter one for all
    three — the place and the weather are genuinely fine at five minutes.
