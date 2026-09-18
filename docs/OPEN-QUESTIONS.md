# Open questions and the backlog

**What is not settled** (§8), **what is not built** (§9), and what a session has to know before it
changes anything near them. The nearest thing to a plan the repository still has.

## 8. The three hard questions

Numbering is stable — an answered question keeps its number, because it is cited.

**8.1 Where a saved chit is edited — settled.** An editor of its own above the tab shell, reached by
holding a chit; leaving with changes asks. BEHAVIOUR.md §4.5, ADR-017, ADR-061 to ADR-064. The
recording is editable there too (ADR-063); the moment is not.

**8.2 Re-transcription — retired.** There is no transcription to re-attempt (ADR-058). Bringing a
speech engine back would open a new question, not reopen this one.

**8.3 Does Today carry enough rhythm? — open.** The timeline is the only rhythm signal on the home
screen. Answerable by living with the app for a week rather than by more design.

## 9. Feature backlog

Ordered by how much each reinforces what chit already is, not by appetite. **2, 6 and 8 are built**
— weather as a search axis in find (§4.6, ADR-083), voice chits as §3.4, and tags written, drawn
and tapped (§3.7, ADR-082, ADR-086). **Their numbers are not reused**, 2 and 8 being cited from
DATA-MODEL.md and from the records.

1. **Extend ambient capture** — coarse place ("home", "office"), what was playing.
3. **Resurfacing** — a chit from a year ago on the home screen.
4. **Adapt the prompt to time-to-first-word.**
5. **The stitch** — one continuous year-long line, one mark per day.
7. **Chit threading** — one chit replying to another. Hold until real usage shows people write in
   chains.

**1 and 3** make the app stickier; **5** makes it distinctive. **2 and 8 are both built** — 2 is
find's weather row, and 8 is §3.7 drawn (ADR-082) and §3.7 tapped (ADR-086). M6's note was right
twice over: the `Text` became a `Text.rich` with no restructuring, and **the arena half of it is
now live code rather than a caution** — open item 52.

**After v1** (signed off 18 September 2026, ADR-073), nothing is scheduled. In order: §8.3 answered
with real usage; the backlog above; **migrations back** (item 38) before the first install anybody
would miss; **an export format**, which is what would pay back ADR-004's accepted cost of no backup;
then responsive web. Deliberately not on the list: **any speech engine, cloud or on-device**
(ADR-005, ADR-058).

## Known and unscheduled

Things a future session needs to know that are not work anybody has planned. **Numbers are stable**
— they are cited from the other documents and from the source, so a closed item keeps its number and
nothing is renumbered. **Closed: 2, 3, 4, 9–15, 17, 19, 20, 24, 25–27, 30, 31, 34, 39, 40, 43, 47, 48, 52;
retired: 32, 33, 35, 36.**

1. **Nobody has looked at the type on a handset beside the original prototype.**
   `ChitType._opticalSizeFor` converts logical pixels to points at 0.75, which is what a browser does
   with `font-optical-sizing: auto`. If Newsreader looks heavier or lighter than intended, that
   constant is the first suspect.
5. **Developer Mode on Windows.** `flutter pub get` warns that plugin builds need symlink support.
   Not blocking — the APK builds.
6. **Font bundle is ~1.8 MB,** of which Noto Serif Devanagari is 758 KB to draw one word.
7. **`public_member_api_docs` is on.** Valuable in `domain`, `data` and `core`; noise on a
   zero-argument widget constructor. If it becomes a tax, a nested `analysis_options.yaml` under
   `lib/features/`, not turning it off everywhere.
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
22. **A refused location permission is a dead end** — the app asks once and never again, and there
    is no settings screen, so a refusal can only be undone through the OS. A refused *microphone*
    names the phone's settings; location says nothing.
23. **The open chit's preview goes stale without bound, and now it is only the weather**
    (ADR-042). ADR-080 took the clock off that line, which was the half a person could tell was
    wrong by looking at it; what is left is a sky word that can be hours old on a phone left open
    all day. **No chit is ever saved with it** — the save re-reads past one minute (ADR-045) — so
    this is a wrong word on the screen and never a wrong row. The smallest honest fix is still a
    refresh when the app returns to the foreground after a long absence.
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
38. **There are no database migrations, and that reverses the day chit holds real data.** ADR-059
    pinned `schemaVersion` at 1 and deleted the harness. **The trigger is the first install that is
    not a development one.** DATA-MODEL.md §6 has the four rules the harness taught; the code is in
    git at `ff78077`. Leaving it until *after* that install is how somebody's chits go.
41. **Two stored names still say `chit`, and that is on purpose** (ADR-074). The package is `chitta`
    — `pubspec.yaml`, `applicationId`, the iOS bundle id — but `driftDatabase(name: 'chit')` and the
    two `chit.firstRun.*` preference keys are not, so that an applicationId reversed later still
    finds the chits somebody wrote. Rename them only once nothing could be carrying data under the
    old id. The `Chit` classes and the repository directory keep the short name for their own
    reasons: an entry *is* a chit.
42. **Nobody has seen the icon on an iPhone.** The Android set was checked in the drawer under a
    round mask (ADR-075); the sixteen iOS sizes were generated by the same run and have never been
    drawn. The one to look at is the smallest — the glyph sits above centre, and at 20px a mark that
    high can read as an accident. Re-exporting it centred is a Figma change, not a code one.
44. **The first-run screen has a copy ceiling, because it does not scroll** (ADR-076). On the 800dp
    handset it was checked on, the two slips and the two answers leave roughly 65dp of slack above
    the first slip; a phone with much less height, or a sentence added to either slip, clips instead
    of scrolling. Cut something before adding something.
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
    which is a schema change and ADR-059's reinstall. A tags table is the end of that road and is
    what would also make backlog 8's tap cheap.
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
    `_serif` is one line** if the two ever read as a mismatch.
53. **First run's three lines were rewritten twice and nobody has measured the result** (ADR-087,
    open item 44). The microphone line went and the tag line arrived, so the *count* is unchanged
    at three — but what the screen costs is **drawn** lines, not written ones, and at roughly 42
    characters to a line in that slip all three of the current ones sit near the wrap. Best guess
    is five drawn lines, the same as before, which would leave item 44's ~65dp of slack intact on
    an 800dp handset. **That is arithmetic, not a look.** Anything added here still has to replace
    something, and a short phone clips rather than scrolls (ADR-076).
