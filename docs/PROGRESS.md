# Progress

**Where the build is, and what to do next.** This is the handover: a session that has read only
this file and [CLAUDE.md](../CLAUDE.md) should be able to pick up the work.

Updated at the end of every working session, per the standing rules in CLAUDE.md §0 and §0.1 —
including sessions that ended mid-milestone.

**Last updated:** 18 September 2026. **M6 — the chit editor — is under way; groups A and B are
done.**
[TASKS.md](TASKS.md) is cut for it, in seven groups, and the cut is **wider than
[BUILD-PLAN.md](BUILD-PLAN.md) M6 as written** — the owner asked for three things the plan did
not have. A chit's recording becomes removable and replaceable, which **reverses ADR-014's
second half**; a chit can be deleted, which closes open item 9; and **the open chit's Discard is
gone**, which was group A. Read TASKS.md's decision table D1–D12 before writing any of the rest;
it is where the session's answers live.

**Group A is committed.** Today's action row is the microphone and Save, and a kept take is
dropped by **Remove** beside the pill (ADR-060) — one control that the editor will reuse, rather
than a Discard on one screen and something else on the other. `ComposerController.discard()` is
`removeTake()`; it leaves the words alone, does not re-take the stamp, and re-arms the prompt on
a chit it empties. The recording sheet keeps its own Discard (ADR-055); the word means *throw
away the take in progress* and that still happens. **Nobody has looked at any of this on a
handset** — group G.

**Group B is committed.** A chit in the thread is now a button — the whole row, on Today and in
the archive, since it is one widget (ADR-061) — and it opens the editor, a route **above** the
tab shell (ADR-062). The screen only reads so far: back arrow, the chit's day, and the chit on
the same slip under the same saved stamp. It cannot move the stamp and never will be able to;
that is the *no metadata* rule made structural.

**Group B's one real design finding is in `contrast_test.dart`, which decided rather than
checked.** The row's 6% pressed wash puts `--ink-faint` at **4.42:1**, under §6.4's floor, so
the stamp lifts to `--ink-muted` (5.65:1) while the row is held — the same rule §6.1 already
had for the quiet button's label, now in its second place. A future session raising
`rowPressedWash` has to move the stamp again or drop below the floor, and the test says so.

**Next is group C** — editing the text: `EditorController`'s dirty rule, and
`ChitRepository.updateText` becoming one transactional `update` that takes a sealed `AudioEdit`
(TASKS.md C). Group D's prompt sheet follows it, and **the sheet is the app's first
confirmation of any kind** — there is still no `showDialog` and no `SnackBar` anywhere.

*M5 — voice — was signed off on a handset earlier the same day.* A chit can be spoken as well as
typed: the microphone opens a recording sheet, the take is attached to the open chit, and it
plays back from a pill on Today, in the calendar's archive and on the open chit itself.

**Voice is recording and playback. There is no transcription** (ADR-058): it was built, taken to
a handset, recognised nothing, and removed — the cost ADR-005 had stated two milestones earlier.
A chit holds words you typed, a recording you made, or both, and neither pretends to be the
other. **There are no database migrations either** (ADR-059), while the app lives on one
development phone: a schema change means uninstalling, and the app says so rather than opening a
database it cannot trust.

What the handset confirmed, over three passes: a recording that survives a restart, a wave that
answers loudness, a refused microphone that explains itself and leaves the composer usable,
recording into a chit that already had words, and reduced motion holding the dot still and the
wave frozen. **BUILD-PLAN.md M5 carries what the milestone taught**, and two of its four lessons
are about fakes rather than features.

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
| **M5** — voice | ✅ done | 18 Sep 2026, signed off on a handset on the third look. **Transcription removed** (ADR-058), **migrations removed** (ADR-059). ADR-052 to ADR-059 |
| **M6** — the chit editor | 🔨 in progress | TASKS.md cut 18 Sep 2026 in seven groups, **A and B done**. ADR-017, ADR-060 to ADR-062. Wider than BUILD-PLAN.md M6: audio becomes editable, a chit becomes deletable |
| M7 — motion and the floors | ⬜ | |

**456 tests, `flutter analyze` clean, `dart format` clean.** *It was 473 before ADR-058 and 450
before ADR-059; what went was the recogniser's tests and the migration harness, not coverage of
anything the app still does.* **Schema is v1 again and there are no migrations** — an install
carrying an older shape is reinstalled.

**Both APKs build at M5's sign-off**, release included — which matters because item 25 was a
release-only failure that a debug build could not see. The release APK is **59 MB as a fat APK
across three ABIs**, of which any one device's share is about 22 MB: three copies of
`libflutter.so`, `libapp.so` and `libsqlite3.so` are nearly all of it, and the 1.8 MB font
bundle of item 6 is the only part chit chose. Nothing about shipping has been decided, so no
`--split-per-abi` and no bundle yet.

---

## Next: M6 group C — editing the text

**Groups A and B are done and nothing is half-built.** [TASKS.md](TASKS.md) is the working
list; its **D1–D12 table is where this milestone's answers live** and is worth reading before
the code. The session that picks up group C:

1. **Gives `EditorController` the field and a dirty rule.** Dirty is *differs from what was
   loaded*, not *was typed in* — typing a character and deleting it again is not a change, and
   it is the difference between a prompt that means something and one people learn to dismiss.
   The controller decides; the widget draws (D11), because ADR-031 means nothing decided in a
   widget can be tested at all.
2. **Turns `ChitRepository.updateText` into one transactional `update`** taking the text and a
   sealed `AudioEdit` — `Keep`, `Remove`, `Replace`. Its old guarantee was that an edit could
   not touch audio, and D5 takes that away; what replaces it is one write, exhaustively
   switched, with the invariant asserted in one place. **`updatedAt` moves and nothing else
   does** (D4) — that is the owner's *no metadata* rule, and there is already a test shape for
   it in `chit_repository_test.dart`.
3. **Shows Save only once something has changed** (D7), in `PrimaryButton`'s weight. Cancel
   arrives beside it in group D, with the prompt it raises.
4. **Reads BUILD-PLAN.md M5's four lessons before writing a fake.** Two of M5's four handset
   bugs were a fake or its harness behaving better than the real thing.

**What groups A and B left for a device, not for a test** (ADR-031) — all on group G's list:
that a row of microphone and Save reads as complete without Discard; that Remove beside the
pill is findable; that a chit row reads as tappable at all, since the only affordance is the
press; and that the pressed wash is visible without being loud.

**M6 changes no schema**, so unlike ADR-059's usual cost nobody has to uninstall. Seed before
looking at anything — `flutter run --dart-define=CHIT_SEED=seed`, `=clear` after.

The old *Next* is in git under `ff15d5c`; it said to build group B, and group B is built.

Everything else that is known and unscheduled is in the open items below. Nothing there blocks
M6.

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
    the OS. **M5 narrowed this to location.** A refused *microphone* now says so and names the
    phone's settings (ADR-056), which is the honest interim; location still says nothing at all,
    because the refusal happened on a screen the user will never see again. That is the correct
    trade today and it stops being correct the moment there is anywhere sensible to put a
    control. BEHAVIOUR.md §4.1's settings sketch is where it lands.
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
34. ~~Nobody knows whether the live wave answers a voice or just pins at the top.~~ **Closed
    18 September 2026 on a handset** — it answers loudness. `RecordAudioRecorder.levelOf`'s
    -60 dBFS floor was arithmetic nobody had measured against a real microphone, and it happens
    to be right. If a future handset draws twenty bars at full height whatever is said, that
    constant is the first suspect and raising it toward -40 is the fix.

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
