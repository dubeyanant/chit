# Progress

**Where the build is, and what to do next.** This is the handover: a session that has read only
this file and [CLAUDE.md](../CLAUDE.md) should be able to pick up the work.

Updated at the end of every working session, per the standing rules in CLAUDE.md §0 and §0.1 —
including sessions that ended mid-milestone.

**Last updated:** 17 September 2026, **with M5 under way — group A done**. M5's
[TASKS.md](TASKS.md) was cut, in seven groups, and group A landed: the `AudioRecorder`
interface in `domain`, `RecordAudioRecorder` over `record` in `data`, and the root wiring. The
cut surfaced one risk no test can settle — whether Android lets `record` capture beside the
recognition service — and it is open item 32, the first thing group G checks on a handset.
Nothing has been run on a device this milestone yet.

Earlier the same day, **M4 was signed off on a handset**. The fourth seeded look checked the
third look's six fixes and everything else in M4's groups F and G, and the owner's verdict was
*everything works fine*; the seeded rows are cleared.

Several docs-only sessions the same day, all aimed at working-session context cost. CLAUDE.md
gained §0.2 (an ADR is one short paragraph, no headed sections — edited in place on a later
change or supersession rather than left beside a new record) and §0.3 (every doc and comment
written short, going forward). README.md §0's restatement of CLAUDE.md §0/§0.1 was cut to a
pointer. `test/docs/readme_maps_everything_test.dart` was deleted — README's file map and the
ADR index are kept true by hand now, not by a test (CLAUDE.md §4.2); `no_widget_tests_test.dart`
stays, since it guards ADR-031, not a document. Test count is 402. `docs/ARCHITECTURE.md` was
rewritten for length (634→467 lines, its folder tree in §2 also collapsed to folders with no
individual filenames) and `docs/BEHAVIOUR.md` likewise (507→398 lines) — every section number,
table, ADR reference and ASCII mockup preserved throughout. PROGRESS.md itself dropped *What is
on a handset today* and *The device is the other half of the suite*. Last, and the biggest
single cut: **every ADR in DECISIONS.md was rewritten to §0.2's one-paragraph form**, including
ADR-001 through ADR-050, the one retroactive exception to the going-forward-only rule — 2163
lines fell to 799. What each record decided is unchanged; the fuller argument for any of them is
in git history at the commit before this pass.

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
| **M4** — calendar | ✅ done | 17 Sep 2026, signed off on a handset on the fourth look. ADR-046 to ADR-050 |
| **M5** — voice | 🔨 in progress | 17 Sep 2026: TASKS.md cut, group A of seven done. ADR-052 |
| M6 — the chit editor | ⬜ | OPEN-QUESTIONS.md §8.1 settled 14 Sep 2026 (ADR-017) |
| M7 — motion and the floors | ⬜ | |

**410 tests, `flutter analyze` clean, `dart format` clean.** The debug APK was last built at
M4's sign-off, before group A; the release APK has not been rebuilt since M3's sign-off.

---

## Next: M5 — voice, group B

[TASKS.md](TASKS.md) is M5's and group A is ticked. The next session:

1. **Builds group B**, the recogniser: the `SpeechRecognizer` interface, the one
   `onDevice: true` call site (ADR-005), and the plugin's error codes mapped to the single
   §3.5 branch. Its shape should mirror group A's — never throws, a fake refuses the same way.
2. **Then group C**, the logic bare, before any widget: the recording controller, the append and
   the origin slide in `ComposerController`, the two fakes in `test/support/`, and the tests.
   Every rule in §3.4 and §3.5 passes before group D draws anything.
3. **Takes the first build to a handset with item 32 in hand** — whether two plugins can share
   the microphone decides the shape of everything after it, and it is a fact only a device can
   give. Item 18 goes on the same walk.
4. **Seeds when it needs to look at anything** — `flutter run --dart-define=CHIT_SEED=seed`
   is idempotent and `=clear` takes it off; both were exercised at the end of M4.

The old *Next* is in git under `a5fbb19`; it said to cut TASKS.md, and it is cut.

Everything else that is known and unscheduled is in the open items below. Nothing there blocks
M5.

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
    record of why. The smaller wash was seen on the fourth look and not remarked on, which
    was the outcome the record could not settle at a desk.
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
15. ~~Crowding on the timeline is half answered.~~ **Closed 17 September 2026** by M4's device
    pass. Chits minutes apart overlap and read as a burst (seen at the end of M2), and the
    seeded ten marks across two days — the case ADR-024 worried about — read as marks. The one
    thing that did not was the day end under a mark written near midnight, which is ADR-050.
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
19. ~~The three motion marks have never been looked at, at 12px, by anyone.~~ **Closed
    17 September 2026**: the seeder drew all three on the fourth look and none was remarked on.
    The reasoning stays on record because it was never tested any harder than that — strokes
    rather than silhouettes because an outlined plane blobs under a 1.22px stroke, and the
    walking figure the likeliest to want redrawing, in `design/chit-app-v6.html` first if it
    ever does. ADR-039 carries the cost.
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
30. ~~The haptic fires when the boundary tick passes the middle of the screen, and the thumb
    could not tell what it was marking.~~ **Closed 17 September 2026** on the fourth look:
    with the taller boundary tick the owner checked it again and raised nothing, so the strip
    stays as ADR-034 wrote it. The analysis is kept because the alternative is real and the
    reason it was not taken is easy to lose. Asked on the third look: *two vibrations, which
    is correct, but I'm not sure exactly when.* The answer, re-derived from `Timeline._onScroll`
    and `TimelineWindow.dayAt`: the strip is one screen per day, and the haptic fires at the
    instant the day under the **middle** of the viewport changes — which is when the boundary
    tick crosses the centre of the screen, half a screen into a scroll, and during a fling
    rather than at its end. That is ADR-034 as written (*keyed to the middle — the day the
    reader is looking at*) and it is the moment a picker clicks, but a picker also snaps and
    the strip does not, so nothing visible coincides with the buzz. ADR-050's taller boundary
    makes the tick easier to see at that instant, which may be enough. If it is not, the
    honest alternative is to fire when a whole day comes into frame — the boundary reaching
    the viewport's edge — and the reason ADR-034 did not is real: at rest the strip is clamped
    with a boundary *on* the left edge, so an edge-keyed haptic fires on the first pixel of
    every scroll back. Either way it is a decision for a thumb, not a desk; the strip is
    unchanged until one is made.
31. **A chit with a recording and no words reads as an empty chit, until M5.** The seeded
    23:55 row on 15 September is §3.5's case — a recording in which nothing was recognised —
    and it draws as a stamp with nothing under it, which is exactly what BEHAVIOUR.md says
    until the audio pill exists. The third look read it as *an empty chit, not sure what it
    is*, which is the honest verdict on the row as it stands: correct, and unexplained. The
    pill is M5's first job on the thread; nothing is drawn in its place now, because a
    placeholder for a control is a control that does nothing (§6.4).
32. **Two plugins want one microphone, and nothing in the suite can say whether Android will
    let them share it.** `speech_to_text` takes no file and no stream, so the only way to keep
    the audio *and* recognise it is to run `record` and the recogniser at the same time
    (TASKS.md D1). On Android the recognition service is another app's process, and since
    Android 10 the platform silences the earlier of two ordinary captures — which would leave
    the kept file silent while the transcript looks fine. iOS has no such rule. **Check it
    first, in group G, by playing a take back**; if the file is silence, the fallback is a
    decision for an ADR — recognition without a kept file, or a file without live words —
    and not a fix to make on the spot.
