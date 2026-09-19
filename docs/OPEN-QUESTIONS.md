# Open questions and the backlog

**What is not settled** (§8), **what is not built** (§9), and what a session has to know before it
changes anything near them. The nearest thing to a plan the repository still has.

## 8. One hard question

Numbering is stable — an answered question keeps its number, because it is cited.

**8.3 Does Today carry enough rhythm? — open.** The timeline is the only rhythm signal on the home
screen. Answerable by living with the app for a week rather than by more design.

## 9. Feature backlog

Ordered by how much each reinforces what chit already is, not by appetite.

3. **Resurfacing** — a chit from a year ago on the home screen.
4. **Adapt the prompt to time-to-first-word.**
7. **Chit threading** — one chit replying to another. Hold until real usage shows people write in
   chains.

**3** makes the app stickier. **1 and 5 are dropped**, not deferred (ADR-101).

**v1.1 is planned** and holds **an export format** — restore-only and text-only, which ADR-100 makes
the only way a chit survives a lost phone — plus **resurfacing** (3), a **photo per chit** if its
shape survives the deciding, and three fixes to what v1 shipped: the location ask, the audio pill's
playhead, and the stale sky of item 23. After it: §8.3 answered with real usage, then the backlog
above, then responsive web. Deliberately not on the list: **any speech engine, cloud or on-device**
(ADR-005, ADR-058).

## Known and unscheduled

Things a future session needs to know that are not work anybody has planned. **Numbers are stable**
— they are cited from the other documents and from the source, so a closed item keeps its number and
nothing is renumbered. **Closed: 2, 3, 4, 9–15, 17, 19, 20, 23, 24, 25–27, 30, 31, 34, 38, 39, 40, 43, 44, 47, 48,
52, 53, 63, 66; retired: 32, 33, 35, 36.**

1. **Nobody has looked at the type on a handset beside the original prototype.**
   `ChitType._opticalSizeFor` converts logical pixels to points at 0.75, which is what a browser does
   with `font-optical-sizing: auto`. If Newsreader looks heavier or lighter than intended, that
   constant is the first suspect.
5. **Developer Mode on Windows.** `flutter pub get` warns that plugin builds need symlink support.
   Not blocking — the APK builds.
6. **Font bundle is ~1.8 MB,** of which Noto Serif Devanagari is 758 KB to draw one word.
8. **§8.3 is open**, and answerable by living with the app for a week.
16. **The strip's back-stop is unseen** in the one case that remains: the oldest day has one chit
    and the rest is empty, so the strip is a bare line with one mark. Honest, and never looked at.
18. **Answered, and it was the bug it predicted.** `Position.speedAccuracy` *is* `0.0` when the
    platform has none — geolocator's Android mapper only sends the field when
    `Location.hasSpeedAccuracy()` — and the old gate read that as noise, which is why a train said
    nothing. The ladder now believes a speed that arrives without an error beside it (ADR-078). What
    is still unwatched: whether a bad fix ever reports a *spurious* high speed with no accuracy, the
    case that trade accepts.
21. **The motion thresholds now have a source, not a measurement.** 0.7, 3.0, 55 m/s and the 2000 m
    ceiling sit inside what the trajectory-classification literature uses — walking is usually cut at
    a 95th-percentile 3.0 m/s, and air travel at 40–80 m/s — but nobody has walked, ridden or flown
    with this app and checked. The boundary most likely to read wrong is still `walking` against
    `traveling` at 3.0 m/s, where a runner is filed as walking on purpose.
22. **A refused location permission is a dead end** — and less of one than it was (ADR-094). The OS
    now gets its two asks rather than the app spending one, so a first refusal is recoverable by
    saving another chit. After the second there is still no settings screen and no line anywhere
    saying what was lost, so it can only be undone through the OS. A refused *microphone* names the
    phone's settings; location still says nothing, deliberately. **A refused location *switch* is
    the softer case** (ADR-102): it is offered again on the next launch, so it is spent for a run
    and never for good.
23. **— closed by the fix it named** (ADR-104). *The open chit's preview went stale without bound.*
    Coming back to the app re-reads when what is on screen is half an hour old. **What it leaves
    behind is the number**: thirty minutes is a judgement like ADR-078's 60% cloud cover, picked so
    a glance away costs nothing and a pocketed phone catches up, and measured against nothing. Move
    it if a sky word still reads wrong on returning, or if the fixes show up in the battery — item
    29 is the other half of that ledger. **The window a save uses is still one minute** and the two
    must not be merged: they answer different questions.
28. **Answered by measuring instead of classifying** (ADR-078). Partly cloudy is no longer a code
    question: `cloud_cover >= 60%` is overcast and below it is clear, and code 2 only decides when
    the quantity is missing. **60 is a judgement, not a measurement** — the okta scale calls 50–84%
    "mostly cloudy", and this puts the boundary inside that band. Move it if a grey day reads clear.
29. **A chit can be written from a reading up to one minute old** (ADR-045, five minutes until the
    owner walked it back), which lands hardest on motion: a chit written on a train a minute after
    launch still says `stationary`. Untested against a real journey. **What nobody has measured is
    the other side of the shorter window** — a burst of chits now buys roughly a fix a minute where
    it used to buy one for the sitting, and a high-accuracy fix is not free. If the battery shows
    up before the staleness does, a window per signal is the next shape, the place being the only
    one that needed the minute.
37. **The seeded recordings are WAVs wearing an `.m4a` extension, and iOS may refuse them** — Android
    sniffs the content and plays it, while AVFoundation may pick its parser from the extension,
    making every seeded pill silent on an iPhone for a reason unrelated to the player.
38. **— closed, by the trigger it named.** *There are no database migrations.* v1 ships, so there
    are: `schemaVersion` 1 has a committed snapshot, the ladder is in place and empty, and a bump
    without its step throws at `open` (ADR-099). **What is not closed is the other half of 004's
    cost** — with ADR-100 turning Android's backup off, a lost phone is lost chits and there is
    still no export format. That is the backlog item that now has teeth.
41. **One stored name still says `chit`, and that is on purpose** (ADR-074). The package is `chitta`
    — `pubspec.yaml`, `applicationId`, the iOS bundle id — but `driftDatabase(name: 'chit')` is not,
    so that an applicationId reversed later still finds the chits somebody wrote. Rename it only
    once nothing could be carrying data under the old id. *The two `chit.firstRun.*` preference keys
    were the other one, and went with ADR-094's screen.* The `Chit` classes and the repository
    directory keep the short name for their own reasons: an entry *is* a chit.
42. **Nobody has seen the icon on an iPhone.**
44. **— closed.** *The first-run screen has a copy ceiling, because it does not scroll.* There is no
    first-run screen (ADR-094), so there is no ceiling. **The item it leaves behind**: the hold
    gesture and the tag syntax were taught there and are now taught only by find's hints, which come
    round every fourth visit and may never be seen by somebody who does not open that tab. If the
    app has to teach them again, the place is where they are used, not a screen in front of Today.
45. **Today's thread is still built eagerly**, and deliberately: it holds one day, and a day is
    bounded by how much a person writes in one. Somebody writing sixty chits in a day would feel it
    before the archive does. The fix would be the archive's (ADR-077), but the rail is drawn behind
    the whole column, so a lazy sliver there is a real piece of work rather than a swap.
46. **The performance numbers are from one handset** (Android 16, 2,000 chits, 40 recordings,
    profile build), and they are a baseline to beat, not a guarantee. Build times, 16.7ms budget:

    | Doing | build p50 | build p90 | over budget |
    |---|---|---|---|
    | Scrolling the archive | 0.5ms | 1.1ms | none, at any depth |
    | Switching tab | 1.0–1.6ms | 2.4ms | none |
    | Switching month, as fast as taps land | 2.2–5.0ms | 11.7ms | 2 frames in 241, worst 17.6ms |
    | Playing and pausing a recording | 1.4ms | 2.6ms | none |
    | Opening and leaving the editor | 1.4ms | 4.5ms | none |

    **Month switching is the heaviest thing in the app** and still under budget; it rebuilds a grid
    and a month of rows, which is work that has to happen. **Memory does not leak**: 400 month
    switches, 24 editor round trips and 15 playbacks each plateau, and `adb shell am send-trim-memory
    <pkg> RUNNING_CRITICAL` returns the heap to where it started — **that command is how a leak is
    told from garbage**, and the answer here was garbage every time. A 188ms raster frame seen once
    was the stress seeder still writing in the background; it does not reproduce cold.
    `CHIT_SEED=stress` and `CHIT_FRAMES=true` are how all of this is re-checked — before believing a
    report of jank, ask which build mode it was in.
49. **Find reads every chit and parses every chit's words, and nobody has measured it** (ADR-083).
    `watchEvery` has no `WHERE`, and `AxisValues` walks every body with `ChitTags.tagsIn` to know who
    and what the chits name. **That walk is per change to the data, not per screen** — the four
    value lists come off one pass. **`chitsOfValue` walks again**, re-parsing every chit to ask
    whether it carries the one tag, so the third screen costs a second pass on every open.
    Item 46's numbers are from the archive and say nothing about this. **Three things to try before
    an index, in order**: the parse is the suspect, not the query; `weather` and `motion` could be
    pushed into SQL and deliberately were not; and only then the `weather` index ADR-077 deleted,
    which is a schema change — a step and a snapshot now (ADR-099), not a reinstall. A tags table is
    the end of that road, and is what would also make a tapped tag (ADR-086) cheap.
50. **The find tab has been seen, and most of it is answered** (ADR-084). The owner read it on a
    CPH2707 and called the layout right — **the right-flush column does not read as a mistake** —
    and the glitch they found there was real and is fixed (ADR-085). Two things are still
    unlooked-at. **The bottom-to-top switch at the frame where it flips**, which lands at a
    different list length on every handset: a list one row over the line jumps the whole column
    from the bottom of the screen to the top, and nobody has written enough tags to cross it. And
    **the quote's two-line ceiling** — `FindLine.longest` is 92 characters, set by arithmetic rather
    than by looking, so a long line on a narrow phone may take three.
51. **find's column is Hanken at 16.5px, sitting directly above a tab bar of Newsreader at
    16.5px.** Two faces at one size a few pixels apart, which §6.2 does not do anywhere else. It
    was chosen because find's words *are* the ambient vocabulary and a chit says `raining` in
    Hanken — but §6.2 also gives **tab labels** to Newsreader, and this column is as much
    navigation as it is vocabulary. Nobody has decided it is wrong; **switching `filterWord` to
    `_serif` is one line** if the two ever read as a mismatch.57. **None of the four changes of 091–094 has been seen on a handset.** Each is a looking question
    and none of them is arithmetic. **The tab now reads `past`** — one word narrower than
    `calendar`, in a three-way row that divides the width evenly, so the label sits differently in
    its share. **find's line moves on arriving at the tab**, which is the one of these that could
    read as *broken* rather than as *different*: switching away and back to compare two screens now
    changes the line, and whether that reads as alive or as restless is the thing to watch.
    **A tag drawn in lower case changes how a name reads** — `@Anant` was somebody's name as they
    write it and is now `anant`, and a person's name folded may read as carelessness rather than as
    a convention. If it does, the fix is to fold the *key* and draw the label as typed, which is
    what ADR-092 rejected for the drift it allows.
58. **The location dialog lands on the first save** (ADR-094), and **the grant is now carried back**
    — the owner saw a granted chit keep an empty stamp until the app was restarted, so the save that
    won the permission re-reads and patches both the chit it wrote and the open one. What is still
    unwatched is the *timing*: the re-read happens while somebody is looking at the thread, so a
    stamp gains a word a second or two after the chit appears, and whether that reads as the app
    catching up or as a glitch is a looking question. The second ask lands on the second save, which
    is a stranger place to meet it than the first; if two dialogs two chits apart read as nagging,
    the honest change is to ask once and let the OS's second chance go unused.
59. **The haptic vocabulary has three steps and has been felt on nothing** (ADR-096). `selected`,
    `committed` and `destroyed` are `selectionClick`, `lightImpact` and `mediumImpact`, and **the
    three are meant to be tellable apart in the hand** — on a phone whose motor is weak, or whose
    owner has system haptics turned down, they may be one buzz with three names. Feel them in order
    before trusting the vocabulary. The pair most likely to collapse is `selected` against
    `committed`, which is the pair Save depends on. **iOS and Android differ here**: `selectionClick`
    is a distinctly lighter tick on iOS than on Android, so the ladder may read as even on one and
    steep on the other.
60. **553 comments were deleted at once** (ADR-095), and what they carried was checked against the
    records one file at a time, not exhaustively. If a future session finds a line whose reason is
    nowhere — a constant that looks arbitrary, an ordering that looks incidental — it may be one the
    strip took. `git show` before the ADR-095 commit is where to look, and the answer belongs in a
    record, not back in the file.
61. **The tab bar arrives a frame or two after launch** (ADR-097), because the answer to *has
    anything been written* is a query and `main()` awaits nothing (ADR-094). Today's thread and the
    strip fill in on the same beat, so it should read as the app arriving rather than as a bar
    popping in — **nobody has watched a cold start for it**. The other moment is the **first save**,
    where the bar appears mid-session and the open chit moves up under the thumb at the same instant
    ADR-096's `committed` haptic fires. It is deliberately not animated (ADR-071 on travel taking
    the eye), and if the jolt reads worse than the travel would, that is the trade to revisit.
62. **Deleting the last chit takes the tabs away** (ADR-097), which is correct and has not been
    seen. It happens from the editor, which covers the tab bar anyway (ADR-062), so the bar is gone
    before the screen returns — the question is whether coming back to a Today with no tabs reads as
    a fresh start or as something broken.
63. **The release key exists and signs, and the refusal it causes is confirmed** (ADR-098). The
    keystore is at `C:\Users\anant\keys\chitta-release.jks`, all three per-ABI APKs carry
    `cc38c02f…` (PACKAGES.md prints the fingerprint), and installing one over the debug-signed build
    on the CPH2707 failed with exactly `INSTALL_FAILED_UPDATE_INCOMPATIBLE: signatures do not
    match` — the attempt changed nothing, the old build still being there afterwards. **So every
    handset carrying a test build must be uninstalled before it can take a signed one, and
    uninstalling takes its chits with it.** Do it while the only chits are test ones. **A signed
    APK runs** — the owner installed one, closing this and item 66 together.
64. **`allowBackup="false"` is a trade, not a free win** (ADR-100). It stops the chits going to
    Google's servers, which is what the README has always promised — and it also stops a new phone
    inheriting them during setup. Until there is an export format, **the only copy of somebody's
    journal is the handset**. If that reads as too sharp a cost, the honest reversal is not to turn
    backup back on but to ship the export, because backup-on would mean the README is wrong.
65. **iOS has not been built, let alone run** — there is no Mac here. The `LaunchScreen.storyboard`
    is still the template's white one (item 58's sibling, ADR-090), `Info.plist`'s two usage strings
    have never been read on a device, and the seeded recordings may be silent there (item 37).
    **Nothing about the iOS half of v1 should be called ready**; what has shipped is Android.
66. **— closed with item 63.** *`--split-per-abi` had not been installed from.* The owner has since
    installed and run a signed per-ABI build.
67. **Nobody has seen the switch sheet, and it is the half no unit test reaches** (ADR-102). The
    permission half is arithmetic and covered; the switch is raised by letting `getCurrentPosition`
    reach Play Services' resolution, which needs Play Services present, the activity attached, and
    a handset to watch. **Three things to look at**: whether the sheet appears at all on the
    CPH2707; whether it arriving *after* the chit is saved reads as the app catching up or as a
    jolt, which is item 58's question again; and whether once a launch is reasonable or nagging,
    since somebody who means *no, not ever* has no way to say so. **On iOS there is no such sheet**
    — `getCurrentPosition` throws, the run is spent and nothing is drawn, which is item 65's
    territory and unverified like the rest of it.
68. **Every recording written before ADR-103 carries a duration longer than its audio.** The row was
    timed from before `_recorder.start()` returned, so it counts the encoder opening — 100–300ms on
    Android — as sound. **Nothing re-reads it**: the pill now measures against the length
    `just_audio` decodes, so the bars and the figure are right while a take plays, and the stored
    number is only what the pill shows at rest. It is wrong by a fraction of a second and there is
    no migration for it, because the file is the truth and the row was only ever a label.
69. **The recorder's timing is not tested, and cannot be as the class stands.** `RecordAudioRecorder`
    builds `plugin.AudioRecorder()` in a field, so `start` and `stop` need a platform and only the
    pure statics are covered. The clock-after-`start` fix is therefore **read, not proven**. Making
    it testable means wrapping the plugin behind an interface of ours — worth doing the next time
    anything in that file changes for another reason, not on its own.
