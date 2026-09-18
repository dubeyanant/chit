# Open questions and the backlog

**What is not settled** (§8) **and what is not built** (§9).

§8 holds three questions the design deliberately left open; one has since been answered and
keeps its number so the citations to it still resolve. §9 is the feature backlog, ordered by
how much each reinforces what chit already is — not by appetite.

Two sections that are not a plan, and — since v1 was signed off and the planning documents went
with it — two that are as close as the repository now comes to one: what to do after v1, and
what a session has to know before it does anything. Section numbers are stable across the split:
§8.1 is §8.1 wherever it is cited from, and it lives here. [README §10](../README.md#10-the-map)
maps every section to its file.

---

## 8. The three hard questions

Two are still open. The numbering is stable — §8.1, §8.2 and §8.3 are referred to across the
docs — so a question that gets answered keeps its number.

### 8.1 Where a saved chit is edited — **settled**

An editor of its own, above the tab shell, reached by holding a chit; leaving with changes
asks. Built as M6 — BEHAVIOUR.md §4.5, ADR-017, ADR-061 to ADR-064. The recording is editable
there too (ADR-063); the moment is not.

### 8.2 Re-transcription — retired

There is no transcription to re-attempt (ADR-058). The number is kept because it is cited;
bringing a speech engine back is a product decision that would open a new question.

### 8.3 Does Today carry enough rhythm? — open

The timeline is the only rhythm signal on the home screen. It fills in as chits are saved,
which is the cheapest version of an answer; whether it is enough is still open.

---

## 9. Feature backlog

Ordered by how much each reinforces what chit already is.

| # | Feature | Why it fits |
|---|---|---|
| 1 | Extend ambient capture — coarse place ("home", "office", "in transit"), what was playing | Costs the user nothing; recovers a memory faster than the text does |
| 2 | **Weather as a search axis** — "show me everything I wrote when it was raining" | Possible *because* of the ambient-stamp decision. A genuinely novel way in |
| 3 | Resurfacing — a chit from a year ago on the home screen | Brings people back with their own words |
| 4 | Adapt the prompt to time-to-first-word | Stays out of the way of fluent writers, helps blocked ones |
| 5 | The stitch — one continuous year-long line, one mark per day | Shows a year's rhythm in a single gesture |
| 6 | Voice chits (**in the design**, §3.4) | Matches the "whenever something hits them" trigger. On-device only for now; a cloud engine would be more accurate and is a decision for later |
| 7 | Chit threading — one chit replying to another | Lets a preoccupation reveal itself over weeks |
| 8 | **`@person` and `#hashtag`** — a name or a tag in a chit's words is tappable, and opens a screen of every chit carrying it | A second way in that costs nothing to write: the axis is already in the text. The same shape as 2, off a signal the user chose rather than one the weather gave |

Suggested order: **1 and 3** make the app stickier; **2 and 5** make it distinctive.
Hold **7** until real usage shows people write in chains.

**8 is wanted and unscheduled.** Nothing is decided — not whether mentions are derived from the
text on read or indexed in a table, not what a name means when two people share one, not how
one is typed. What M6 owes it is only that it is not boxed in, and the one place it could have
been is the chit row becoming a button: a `TapGestureRecognizer` on a `TextSpan` wins the
gesture arena against an ancestor's hold, so the row stays a button and its `Text` becomes a
`Text.rich` later without restructuring. Nothing goes in the schema on speculation (CLAUDE.md
§4.1, YAGNI).

---

## What comes after v1

v1 was signed off on 18 September 2026 (ADR-073). Nothing below is scheduled; this is the list
of candidates, in the order §8 suggests rather than the order of appetite. *It lived in
`BUILD-PLAN.md` until that file was deleted with the rest of the planning documents, v1 being
finished and there being no plan left to hold.*

1. **§8.3 — whether Today carries enough rhythm.** Worth answering with real usage rather than
   more design.
2. Backlog items 1 and 3 (richer ambient capture, resurfacing) make the app stickier; 2 and 5
   (weather as a search axis, the stitch) make it distinctive. Item 8, `@person` and
   `#hashtag`, is wanted and M6 left room for it.
3. **Migrations back** (item 38 below) before the first install anybody would miss.
4. **An export / backup format.** Wanted eventually and not on the v1 path — ADR-004 accepted
   "no backup beyond the OS's own" as a cost of being local-only, and this is what would pay
   it back.
5. Responsive web.

Deliberately not on this list: **any speech engine, cloud or on-device.** ADR-058 removed
transcription after it recognised nothing on a handset, and ADR-005 rules a cloud one out until
there is an answer to what happens to the audio. Bringing either back is a product decision, not
a scheduling question.

---

## Known and unscheduled

Things a future session needs to know but that are not work anybody has planned. **Numbers are
stable** — they are cited from the other documents and from the source — so a closed item keeps
its number and nothing is renumbered. *These were `PROGRESS.md`'s open items and moved here when
that file was deleted; the ones already closed are listed rather than kept, and what each was is
in git.*

**Closed: 2, 3, 4, 9, 10, 11, 12, 13, 14, 15, 17, 19, 25, 26, 27, 30, 31, 34, 39; retired: 32,
33, 35, 36.**

1. **Nobody has looked at the type on a handset beside the prototype.** `ChitType._opticalSizeFor`
   converts logical pixels to points at 0.75, which is what a browser does with
   `font-optical-sizing: auto`. If Newsreader looks heavier or lighter than
   `design/chit-app-v6.html` at the same size, that constant is the first suspect.
5. **Developer Mode on Windows.** `flutter pub get` warns that plugin builds need symlink
   support. Not blocking — the APK builds.
6. **Font bundle is ~1.8 MB,** of which Noto Serif Devanagari is 758 KB to draw one word.
   PACKAGES.md suggests subsetting before shipping.
7. **`public_member_api_docs` is on.** Valuable in `domain`, `data` and `core`; noise on a
   zero-argument widget constructor. If it becomes a real tax, a nested `analysis_options.yaml`
   under `lib/features/`, not turning it off everywhere.
8. **§8.3 — does Today carry enough rhythm — is open**, and answerable by living with the app
   for a week rather than by more design.
16. **The strip's back-stop has not been looked at** in the one case that remains: the oldest
    day has one chit and the rest is empty, so the strip is a bare line with one mark. Honest,
    and unseen.
18. **`Position.speedAccuracy` may mean *unknown* when it says `0.0`, and the ladder bets that
    it does.** The single most likely thing to be wrong about motion, and nothing in the suite
    can settle it. `MotionLadder` reads zero as absent, so if a platform means `0.0` literally,
    motion is stuck at `stationary` and looks like a feature that does not work. Check against a
    real `Position` before concluding anything else is broken.
20. **`flying` will almost never fire, and that is expected.** Most devices disable GPS in
    airplane mode, so there is no fix and no speed. Do not spend a day on it (ADR-037). A
    barometer is the honest route if it ever matters.
21. **Nothing tunes the motion thresholds.** 0.7, 3.0 and 55 m/s and the 2000 m ceiling are
    arithmetic, not measurements — nobody has walked, driven or flown with this build. The
    boundary most likely to read wrong is `walking` against `traveling` at 3.0 m/s.
22. **A refused location permission is a dead end.** The app asks once, on the first-run
    screen, and never again (ADR-016, ADR-041); there is no settings screen, so a refusal can
    only be undone through the OS. A refused *microphone* names the phone's settings (ADR-056);
    location says nothing. Lands on BEHAVIOUR.md §4.1's settings sketch.
23. **The open chit's preview goes stale without bound.** ADR-042 captures at launch and at a
    stale save, so a phone left open all day draws the launch weather until something is
    written. The smallest honest fix is a refresh when the app returns to the foreground after a
    long absence.
24. **The stamp's time does not tick.** It shows when the chit was opened; the row carries when
    it was saved (ADR-040). A self-updating clock is an ambient loop and was refused (ADR-027).
    Untried middle option: re-read the preview on the first keystroke.
28. **`clear night` is drawn for Open-Meteo's *partly cloudy*.** WMO code 2 sits with 0 and 1
    under §3.6's *clear or nearly clear*. Defensible, and the loosest call in `WmoMapping`; if
    chits read `clear night` on nights that were not, moving code 2 to `overcast` is one line.
29. **A chit can be written from a reading up to five minutes old** (ADR-045), which lands
    hardest on motion: a chit written on a train five minutes after launch says `stationary`.
    Untested against a real journey. The honest fix is a shorter window for motion alone.
37. **The seeded recordings are WAVs wearing an `.m4a` extension, and iOS may refuse them.**
    Android sniffs the content and plays it; AVFoundation may pick its parser from the extension
    and fail, making every seeded pill silent on an iPhone for a reason unrelated to the player.
    If it matters, a small committed `.m4a` asset the seeder copies.
38. **There are no database migrations, and that reverses the day chit holds real data.**
    ADR-059 pinned `schemaVersion` at 1 and deleted the harness; `onUpgrade` throws a message
    saying to reinstall. **The trigger to undo it is the first install that is not a
    development one** — somebody else's phone, or the owner's once they keep chits they would
    miss. DATA-MODEL.md §6 has the four rules the deleted harness taught; the code is in git at
    `ff78077`. Leaving it until *after* that install is how somebody's chits go.
40. **The press pace draws nothing.** `ChitPace.press` is in §6.3's table with no caller in
    `lib/` since ADR-070. It is kept because ADR-020's rule — no fade is slower than it was — is
    argued from it, and because web hover (ADR-019) will want it. If press feedback never comes
    back, it goes when web is decided.
