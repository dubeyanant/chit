# Progress

**Where the build is, and what to do next.** This is the handover: a session that has read only
this file and [CLAUDE.md](../CLAUDE.md) should be able to pick up the work.

Updated at the end of every working session, per the standing rules in CLAUDE.md §0 and §0.1 —
including sessions that ended mid-milestone.

**Last updated:** 18 September 2026. **M5 is voice, and voice is now recording and playback
only — transcription was built, taken to a handset, and removed** (ADR-058). Groups A to F are
done; group G, the handset pass, is what is left. **Recording and playback are both confirmed
working on a phone.**

## Transcription is gone, and what that means

It recognised nothing on the first device it ran on. That is the cost ADR-005 stated when it
chose on-device recognition — models vary by handset, may not exist for a language, and are
worst at the English-Hindi code-switching that is ordinary speech here — and the owner's call
was to remove the feature rather than chase the engine. **A transcript that is usually absent
and occasionally wrong is a worse record than a recording that is simply kept.**

Deleted: `speech_to_text`, `SpeechRecognizer` and `OnDeviceSpeechRecognizer`, the sheet's
transcript and engine note, §3.5's failure note and `sttFailed`, the Android `<queries>` intent,
the iOS speech permission, and **`chits.text_origin`** — provenance existed only to say whether
words came from the recogniser, so with no recogniser it stored one value forever. That last one
was a **v2 → v3 migration** that rebuilt the table — *and then ADR-059 removed migrations
altogether*, since the app has never been installed anywhere but the owner's own phone and there
are no rows anybody would miss. `schemaVersion` is back to 1 and an older install is reinstalled.

Three things it took with it that were costing real risk: item 32 (could two plugins share one
microphone at all), item 33 (a recognition session ending mid-take), and item 36 (a second
permission dialog landing over the sheet). None of them can happen now.

**§3.5 and OPEN-QUESTIONS §8.2 are retired with their numbers unreused**, since both are cited
from elsewhere. **`design/chit-app-v6.html` was deliberately left alone** and still draws the
transcript in the sheet — where the prototype and BEHAVIOUR.md §3.4 disagree, §3.4 is right.

## Four handset bugs, all fixed

**The microphone opened and no sheet appeared.** `recordingControllerProvider` was auto-disposed
and nothing in the app watches it between the tap and the sheet being built, so Riverpod
collected it during the permission round-trip, `Ref.mounted` went false, and `start` cancelled
the take it had just begun. It is `keepAlive` now (**ADR-057**). *The test that should have
caught it added a listener for symmetry with the composer* — a lifetime the app does not have.

**No seeded recording played.** `DebugSeeder` wrote thirty-eight bytes of ASCII, which is a pill
that does nothing (§6.4) and is indistinguishable from broken playback. It writes a real tone
now, at the length each row claims.

**A take went on sounding after Save**, with the pill that could have stopped it no longer drawn
anywhere. `ComposerController` stops the player before the file moves — `stopIf(openChit)`, so a
chit playing in the thread is not silenced by somebody saving.

**Then no pill could be paused at all.** `playback` was a broadcast stream carrying only changes,
so any pill built after a recording started drew itself as though nothing were playing and its
one control became a play button that did nothing. Every listener gets the current state first
now, and the fake replays the same way.

**Both fake-related bugs are the same mistake**: a fake that behaves better than the real thing
turns a test into a claim about nothing. CLAUDE.md §4.1's Liskov rule now names both.

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
| **M5** — voice | 🔨 in progress | 18 Sep 2026: groups A to F done — **transcription removed** (ADR-058), **migrations removed** (ADR-059); the handset pass is left. ADR-052 to ADR-059 |
| M6 — the chit editor | ⬜ | OPEN-QUESTIONS.md §8.1 settled 14 Sep 2026 (ADR-017) |
| M7 — motion and the floors | ⬜ | |

**441 tests, `flutter analyze` clean, `dart format` clean.** *It was 473 before ADR-058 and 450
before ADR-059; what went was the recogniser's tests and the migration harness, not coverage of
anything the app still does.* **Schema is v1 again and there are no migrations** — an install
carrying an older shape is reinstalled. The release APK has not been rebuilt since M3's
sign-off.

---

## Next: M5 — voice, group G. The handset, and nothing else

[TASKS.md](TASKS.md) is M5's and groups A to F are ticked. **There is no more code to write
before a device sees this.** Two passes have happened and found four bugs; what is left is the
rest of group G's list.

**Uninstall the app first, then seed.** There are no migrations any more (ADR-059) and the
database on the phone is a v3 one with a `text_origin` column and its check constraint; the app
will refuse to open it and say so. After reinstalling, `--dart-define=CHIT_SEED=seed` — the old
seeded rows go with the old database, so there is nothing to clear.

1. **A recording that survives a restart.** Save one, kill the app, reopen, play it. Nothing has
   checked that the file survives `AudioStore.keep` and a cold start together.
2. **Does the wave answer a voice, or pin at the top?** Item 34, and the only thing left that
   could make the sheet read as broken. The -60 dBFS floor is arithmetic nobody has measured
   against a real microphone.
3. **A refused microphone** — the sheet stays closed, the line shows once, the microphone stays
   tappable. Needs a fresh install or a revoked permission.
4. **A typed chit recorded into**, keeping both. And **reduced motion**, where the dot rests and
   the wave freezes at v6's fixed heights.
5. **Item 18 on the same walk**, since one is being taken.

Items 32, 33 and 36 were retired with transcription — the risks they described cannot happen
with one plugin. **Item 35 went too**: Stop & keep no longer waits for a last word, so the sheet
closes as soon as the recorder does.

The old *Next* is in git under `065721b`; it said to take D1 to a handset, and D1 no longer
exists.
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
4. ~~`speech_to_text` applies the Kotlin Gradle Plugin.~~ **Closed 18 September 2026** — the
   package went with ADR-058. The Gradle warning it caused is gone with it. *Other plugins may
   do the same thing; check the build output before any Flutter upgrade rather than trusting
   this line.*
5. **Developer Mode on Windows.** `flutter pub get` warns that plugin builds need symlink
   support. Not blocking — the APK builds.
6. **Font bundle is ~1.8 MB,** of which Noto Serif Devanagari is 758 KB to draw one word.
   PACKAGES.md suggests subsetting before shipping.
7. **`public_member_api_docs` is on.** Valuable in `domain`, `data` and `core`; noise on a
   zero-argument widget constructor. If it becomes a real tax the answer is a nested
   `analysis_options.yaml` under `lib/features/`, not turning it off everywhere.
8. **OPEN-QUESTIONS.md §8.3 (does Today carry enough rhythm) is still open**, and now
   answerable — the rhythm signal it is about exists and can be lived with for a week. *§8.2,
   re-transcription, was retired with ADR-058.*
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
17. ~~`ChitMotion.loop` has no caller.~~ **Closed 18 September 2026** by M5 group D: the record
    dot on the recording sheet is its first and only user, at §6.3's 1.2s rather than v6's
    1.6s. The live wave is *not* a second caller and never will be — each bar is a level the
    recorder reported, so it is data rather than a loop (ADR-054). Nobody has seen the dot
    breathe on a handset.
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
31. ~~A chit with a recording and no words reads as an empty chit.~~ **Closed 18 September 2026**
    by M5 group E — the pill is drawn wherever a chit has audio, so the seeded 23:55 row of
    15 September is a recording rather than a blank. The third look's verdict was *an empty
    chit, not sure what it is*; **whether it now reads as a recording has not been looked at**,
    and it is on group G's seeded pass.
34. **Nobody knows whether the live wave answers a voice or just pins at the top.**
    `RecordAudioRecorder.levelOf` maps dBFS to 0–1 linearly from a **-60 dBFS floor**, and that
    floor is arithmetic rather than a measurement — no microphone has ever fed it. If a normal
    speaking voice sits around -15 dBFS the whole wave lives in its top quarter and reads as
    twenty bars at full height, which says nothing; if the plugin's `Amplitude.current` is
    already normalised on one platform and raw dBFS on the other, the two handsets draw
    different waves from the same voice. **Check it in group G by watching the sheet while
    speaking normally and while nearly silent.** If it pins, the fix is the floor — raising it
    toward -40 compresses the useful range into the visible one — and it is one constant with a
    test beside it (`record_audio_recorder_test.dart`).

**Items 32, 33, 35 and 36 are retired.** All four were about a recogniser — whether two plugins could
share a microphone, a session ending mid-take, the beat Stop & keep waited for a last word, and a
second permission dialog landing over the sheet. **ADR-058 removed the recogniser, and none of
them can happen now.** The numbers are not reused.

37. **The seeded recordings are WAVs wearing an `.m4a` extension, and iOS may refuse them.**
    ADR-008 fixes the stored extension and nothing encodes AAC in Dart, so `DebugSeeder` writes
    a valid WAV under the name the store keeps. Android's extractor sniffs the content and
    plays it; AVFoundation may pick its parser from the extension and fail, which would make
    every seeded pill silent on an iPhone for a reason that has nothing to do with the player.
    It costs nothing real — this is debug data that never ships, and a recording made on the
    device is a real `.m4a` — but a future session looking at a silent seeded pill on iOS
    should read this before suspecting `JustAudioPlayer`. If it matters, the answer is a small
    committed `.m4a` asset the seeder copies.
38. **There are no database migrations, and that reverses the day chit holds real data.**
    ADR-059 pinned `schemaVersion` at 1 and deleted the snapshots, the generated helpers and
    `migration_test.dart`; `onUpgrade` throws a message telling whoever hit it to reinstall.
    That is right while the app lives on one development phone and every schema change is
    answered by an uninstall. **The trigger to undo it is the first install that is not a
    development one** — somebody else's phone, or the owner's own once they start keeping chits
    they would miss. At that point `DATA-MODEL.md` §6 has the four rules the deleted harness
    taught, which is the expensive part; the code is a morning's work and is in git at
    `ff78077`. Leaving it until *after* that install is how a milestone ends with somebody's
    chits gone.
