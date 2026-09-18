# Progress

**Where the build is, and what to do next.** This is the handover: a session that has read only
this file and [CLAUDE.md](../CLAUDE.md) should be able to pick up the work.

Updated at the end of every working session, per CLAUDE.md §0 and §0.1 — including sessions
that ended mid-milestone. **This file is not a history.** Git is the history; what belongs here
is the present. On 18 September 2026 everything before M7 was cut from it, from BUILD-PLAN.md
and from TASKS.md, on the owner's instruction: what each milestone built is in git, what it
settled is in DECISIONS.md, and what it taught is in BUILD-PLAN.md's one list of lessons.

**Last updated:** 18 September 2026. **M0 to M6 are done and signed off on a handset. M7 —
motion and the floors — is cut into five groups in [TASKS.md](TASKS.md); A, B and C are built
and committed. D and E are open.** M7 is the last milestone of v1.

---

## Status board

| Milestone | State | Notes |
|---|---|---|
| M0a, M0b, M1 — scaffold, design system, data spine | ✅ done | 14–15 Sep 2026 |
| M2 — Today, text only | ✅ done | 16 Sep 2026 |
| M3 — ambient capture | ✅ done | 17 Sep 2026 |
| M4 — calendar | ✅ done | 17 Sep 2026 |
| M5 — voice | ✅ done | 18 Sep 2026. No transcription (ADR-058), no migrations (ADR-059) |
| M6 — the chit editor | ✅ done | 18 Sep 2026. Its last three handset checks are carried into M7's device pass (ADR-067) |
| **M7 — motion and the floors** | 🔨 in progress | five groups, **A to C done**, D and E open. ADR-068 to ADR-070 |

**506 tests, `flutter analyze` clean, `dart format` clean.** Schema is v1 and there are no
migrations — an install carrying an older shape is reinstalled (ADR-059, open item 38).

**Both APKs build**, release included. The release APK is a 59 MB fat APK across three ABIs, of
which one device's share is about 22 MB; nothing about shipping is decided, so no
`--split-per-abi` and no bundle yet.

---

## Next: M7 group D, the floors

Targets at 44px, focus rings, and the semantics audit. TASKS.md D carries it and D5 and D6 are
the decisions it turns on. **Then group E is the device pass that signs v1 off**, and it has
grown: everything A to C built has been seen only once, half-working, and its checklist says
what to look at.

M7 is mostly a device pass (BUILD-PLAN.md M7), so **write what the handset showed into this
file as each group lands**, not at the end. **Read BUILD-PLAN.md's lessons first** — two of them
were paid for again this session.

### What the last two handset looks cost, and what they taught

**Group A was built and then removed on the owner's call.** The press feedback — a depress on
every control, a wash under it — went out in two steps: the colour first, called artificial,
then the whole effect. There is now no press feedback anywhere (ADR-070). What survives is the
tab bar off Material's `InkWell`, and the two bugs the work flushed out.

**A recording in the thread could not be played at all, and the cause was not the player.** The
chit row's pressed wash was a `DecoratedBox` added on press and taken away again, so the shape
of the tree changed under the finger, Flutter rebuilt the subtree, and the audio pill's gesture
recogniser was disposed on the frame the pointer landed. The hold (ADR-061) made it certain,
because `onLongPressDown` fires on the first pointer event where a tap's own `onTapDown` waits
to see whether it has won. The box is always in the tree now and only its colour changes.

*Two earlier player fixes are in the same area and both are real, so do not undo them:* the
adapter pauses rather than stops before loading the next file (a stop releases the native
player, which cost the first tap after launch its sound), and `just_audio_player_test.dart`
counts platform inits so that difference cannot regress unseen.

**The timeline glitched inside the page's entrance**, and it is the one block the entrance now
draws straight through (`Unstaggered`). It already arrives by scrolling to now (ADR-024), so
inside the stagger it was fading, rising and scrolling at once; it also spared a moving viewport
an `Opacity` layer every frame.

**The lesson, and it is the third time this milestone:** *a wrapper that comes and goes is a
rebuild.* Both `Arrival` and the row's wash are written to it now — the wrapper stays and is
told whether to play. It belongs in BUILD-PLAN.md's list when M7 is signed off.

---

## Open items

Things a future session needs to know but that are not scheduled work. **Numbers are stable** —
they are cited from other documents — so a closed item keeps its number. **Closed: 2, 3, 4, 9,
10, 11, 12, 13, 14, 15, 17, 19, 25, 26, 27, 30, 31, 34, 39; retired: 32, 33, 35, 36.** What
each was and how it closed is in git, at the commit before this file was cut; 14, the caret,
closed as a stated limit (ADR-068).

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
8. **OPEN-QUESTIONS.md §8.3 — does Today carry enough rhythm — is open**, and answerable by
   living with the app for a week rather than by more design.
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
