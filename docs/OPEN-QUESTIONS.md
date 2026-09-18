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

Ordered by how much each reinforces what chit already is, not by appetite.

1. **Extend ambient capture** — coarse place ("home", "office"), what was playing.
2. **Weather as a search axis** — "everything I wrote when it was raining". Possible *because* of
   the ambient stamp, and a genuinely novel way in.
3. **Resurfacing** — a chit from a year ago on the home screen.
4. **Adapt the prompt to time-to-first-word.**
5. **The stitch** — one continuous year-long line, one mark per day.
6. **Voice chits** — in the design already, §3.4.
7. **Chit threading** — one chit replying to another. Hold until real usage shows people write in
   chains.
8. **`@person` and `#hashtag`** — tappable in a chit's words, opening every chit carrying it. The
   same shape as 2, off a signal the user chose rather than one the weather gave.

**1 and 3** make the app stickier; **2 and 5** make it distinctive. **8 is wanted and unscheduled**
— nothing about it is decided, and all M6 owed it was not boxing it in: a `TapGestureRecognizer` on
a `TextSpan` wins the gesture arena against an ancestor's hold, so the chit row stays a button and
its `Text` becomes a `Text.rich` later without restructuring.

**After v1** (signed off 18 September 2026, ADR-073), nothing is scheduled. In order: §8.3 answered
with real usage; the backlog above; **migrations back** (item 38) before the first install anybody
would miss; **an export format**, which is what would pay back ADR-004's accepted cost of no backup;
then responsive web. Deliberately not on the list: **any speech engine, cloud or on-device**
(ADR-005, ADR-058).

## Known and unscheduled

Things a future session needs to know that are not work anybody has planned. **Numbers are stable**
— they are cited from the other documents and from the source, so a closed item keeps its number and
nothing is renumbered. **Closed: 2, 3, 4, 9–15, 17, 19, 25–27, 30, 31, 34, 39; retired: 32, 33, 35,
36.**

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
20. **`flying` will almost never fire, and that is expected** — most devices disable GPS in airplane
    mode, so there is no fix and no speed. A barometer is the honest route if it ever matters.
21. **The motion thresholds now have a source, not a measurement.** 0.7, 3.0, 55 m/s and the 2000 m
    ceiling sit inside what the trajectory-classification literature uses — walking is usually cut at
    a 95th-percentile 3.0 m/s, and air travel at 40–80 m/s — but nobody has walked, ridden or flown
    with this app and checked. The boundary most likely to read wrong is still `walking` against
    `traveling` at 3.0 m/s, where a runner is filed as walking on purpose.
22. **A refused location permission is a dead end** — the app asks once and never again, and there
    is no settings screen, so a refusal can only be undone through the OS. A refused *microphone*
    names the phone's settings; location says nothing.
23. **The open chit's preview goes stale without bound** (ADR-042). The smallest honest fix is a
    refresh when the app returns to the foreground after a long absence.
24. **The stamp's time does not tick** — it shows when the chit was opened, while the row carries
    when it was saved (ADR-040). A self-updating clock is an ambient loop and was refused (ADR-027);
    the untried middle option is re-reading the preview on the first keystroke.
28. **Answered by measuring instead of classifying** (ADR-078). Partly cloudy is no longer a code
    question: `cloud_cover >= 60%` is overcast and below it is clear, and code 2 only decides when
    the quantity is missing. **60 is a judgement, not a measurement** — the okta scale calls 50–84%
    "mostly cloudy", and this puts the boundary inside that band. Move it if a grey day reads clear.
29. **A chit can be written from a reading up to five minutes old** (ADR-045), which lands hardest on
    motion: a chit written on a train five minutes after launch says `stationary`. Untested against a
    real journey; the honest fix is a shorter window for motion alone.
37. **The seeded recordings are WAVs wearing an `.m4a` extension, and iOS may refuse them** — Android
    sniffs the content and plays it, while AVFoundation may pick its parser from the extension,
    making every seeded pill silent on an iPhone for a reason unrelated to the player.
38. **There are no database migrations, and that reverses the day chit holds real data.** ADR-059
    pinned `schemaVersion` at 1 and deleted the harness. **The trigger is the first install that is
    not a development one.** DATA-MODEL.md §6 has the four rules the harness taught; the code is in
    git at `ff78077`. Leaving it until *after* that install is how somebody's chits go.
40. **The press pace draws nothing.** `ChitPace.press` is in §6.3's table with no caller since
    ADR-070, kept because ADR-020's rule is argued from it and because web hover will want it.
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
43. **A new `applicationId` is a new app.** `com.infiniteants.chit` installs alongside
    `com.infiniteants.chitta` rather than upgrading to it, so a handset that had the old build keeps
    it, chits and all, and the new one opens empty. There is no export (ADR-004) and no migration
    path between the two — the old app is the only copy.
44. **The first-run screen has a copy ceiling, because it does not scroll** (ADR-076). On the 800dp
    handset it was checked on, the two slips and the two answers leave roughly 65dp of slack above
    the first slip; a phone with much less height, or a sentence added to either slip, clips instead
    of scrolling. Cut something before adding something.
45. **Today's thread is still built eagerly**, and deliberately: it holds one day, and a day is
    bounded by how much a person writes in one. Somebody writing sixty chits in a day would feel it
    before the archive does. The fix would be the archive's (ADR-077), but the rail is drawn behind
    the whole column, so a lazy sliver there is a real piece of work rather than a swap.
46. **The performance numbers are from one handset** (Android 16, 2,000 chits, 40 recordings,
    profile build): archive scroll build p50 0.5ms, p90 1.1ms, nothing over the 16.7ms budget, flat
    at any depth. `CHIT_SEED=stress` and `CHIT_FRAMES=true` are how that is re-checked — before
    believing a report of jank, ask which build mode it was in.
