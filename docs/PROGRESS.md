# Progress

**Where the build is, and what to do next.** This is the handover: a session that has read only
this file and [CLAUDE.md](../CLAUDE.md) should be able to pick up the work.

Updated at the end of every working session, per the standing rule in CLAUDE.md §0 — including
sessions that ended mid-milestone.

**Last updated:** 16 September 2026, after M2 group G and after the cleanup pass that removed
the widget tests (ADR-031) and cut this file from 930 lines to what you are reading.

**This file is not a history.** Git is the history, and [TASKS.md](TASKS.md)'s ✅ marks are the
ledger of what is done. What belongs here is the present: where the build is, what the next
session picks up, what has been seen on a device, and what is known-wrong and unscheduled. A
session that finishes a group **replaces** the *Next* section rather than appending to a log.

---

## Status board

| Milestone | State | Notes |
|---|---|---|
| **M0a** — project stops being a scaffold | ✅ done | 14 Sep 2026 |
| **M0b** — the design system in code | ✅ done | 14 Sep 2026 |
| **M1** — the data spine | ✅ done | 15 Sep 2026. ADR-021 |
| **M2** — Today, text only | 🔶 in progress | groups A–G of [TASKS.md](TASKS.md) done; **H is next**. ADR-023 to ADR-031 |
| M3 — ambient capture | ⬜ | |
| M4 — calendar | ⬜ | |
| M5 — voice | ⬜ | |
| M6 — the chit editor | ⬜ | OPEN-QUESTIONS.md §8.1 settled 14 Sep 2026 (ADR-017) |
| M7 — motion and the floors | ⬜ | |

**171 tests, `flutter analyze` clean, debug APK builds.** The count was 251 until ADR-031 took
the widget tests out; seven of them came straight back as `widget_constants_test.dart`, because
those claims never needed a widget in the first place. That is the pattern to reach for before
accepting a loss — but most of what went could not be recovered that way, which makes *The
device is the other half of the suite* below load-bearing rather than a nicety.

---

## What is on a handset today

The masthead on `--paper`, a two-tab bar, and **the open chit** — a slip with its tear edge and
the pad behind it, its stamp reading `3:42 pm   raining   ⌖` spaced and never separated, a blank
page to write on, and a microphone leading the action row. **Nothing moves until you touch it**
(ADR-028): no caret is drawn, and the one that arrives on the first tap is the platform's. Leave
it five seconds and a prompt fades in — *"Rain. What's it like out?"* in the afternoon, *"Still
up. What's keeping you?"* at one in the morning, chosen from the stamp (ADR-029). Typing brings
**Discard** and **Save chit**, and both work: Save writes the row, the chit drops into the thread
under *earlier* with its count beside it, and a new blank chit opens stamped at that moment.
Above the slip is the date — *Wednesday 16 September* — and below the thread the चित्त mark
closes the day. An empty day reads *"Nothing written yet today."* with no rail and no count.
Tapping *calendar* cross-fades to a placeholder line that M4 deletes.

**The timeline is the only thing still missing from §4.1**, and it is group H.

*The weather word and the pin are fixed fakes until M3 and will always read `raining` at the
Royal Observatory — that is `FixedWeatherService` and `FixedLocationService` doing their job,
not a bug.*

**Actually confirmed on a device:** the palette on 15 September — dark warm brown, "chit चित्त"
in the gutter, `--paper` `#191714` behaving exactly as §6.1 sets it — and after group E the
slip, the field, the stamp and Discard. **Save, the thread and the tab bar have not been looked
at on a handset yet.** Nor has the type been compared against the prototype side by side, which
is open item 1.

---

## The device is the other half of the suite

ADR-031 removed the widget tests, so what was only ever visible on a screen is now only checked
by someone looking at one. **This list is the mitigation, and it is a weaker one than a test
was** — it works only if it is actually run. Run it at the end of any group that touches a
surface, and write what you saw into the section above.

| Check | Why it is here |
|---|---|
| The keyboard does **not** come up on launch | ADR-023. Had a test; has none now |
| A chit left open across a minute boundary saves at the time it was **opened** | ADR-021. The stamp is held, and a stale one looks exactly like a fresh one |
| Discard, then read the stamp — it is the **new** time | ADR-026, same failure mode, opposite direction |
| The tear edge is holes in the pad, not a dotted border | DESIGN-LOG.md calls this load-bearing, and it is two characters of paint code from being wrong |
| Switching tabs and back does not reset the field | ADR-011 — a fade, not a rebuild |
| The microphone is still reachable and still an equal on a half-written chit | DESIGN-LOG.md's standing warning about it drifting into a toolbar of small grey icons |
| Every target ≥44px, and the reduced-motion setting actually quiets things | §6.4. M2 group I is this row done properly |

---

## Next: M2 group H — the timeline

The largest piece left, reshaped by ADR-024: a full day, three days of span, proportional,
scrolling, resting at now. [TASKS.md](TASKS.md) H has the list. Five things it inherits:

- **`ChitRepository.watchDayRange` does not exist yet** — the thread reads one day and the
  timeline reads three, so H adds the query and the DAO method under it (DATA-MODEL.md §4).
  This is the part of H that is properly testable, and it is where the testing effort goes.
- **The position function is pure** — an instant to a position within the three-day window — so
  it is tested directly, at both bounds and across a midnight. Keep it out of the widget; under
  ADR-031 that is the difference between a claim that is checked and one that is merely looked
  at.
- **Read `todayProvider`, not the clock.** A screen that reads the clock twice is a screen that
  can show two days: the date line and the thread each called `clock.now()` at first, and a
  millisecond apart at midnight is a date above a thread that does not belong to it.
- **The pulse at `now` is `ChitMotion.loop`'s first caller** (ADR-027), at the prototype's 5.2s.
  It stops *drawn* under reduced motion, not hidden.
- **v6 draws the old day arc**, not this. DESIGN-SYSTEM.md §7 flags it: the prototype is behind
  the specification here, so BEHAVIOUR.md §4.1 is what to build from.

---

## Open items

Things a future session needs to know but that are not scheduled work. **Numbers are stable** —
they are cited from TASKS.md and DESIGN-SYSTEM.md — so a closed item keeps its number and
shrinks to a line rather than being deleted.

1. **Nobody has looked at the type on a handset.** `ChitType._opticalSizeFor` converts logical
   pixels to points at 0.75, which is what the CSS spec says a browser does with
   `font-optical-sizing: auto`. If Newsreader looks heavier or lighter than
   `design/chit-app-v6.html` at the same size, that constant is the first suspect. Worth
   settling in M2, now that there is real text and a thread of it to compare.
2. ~~Two colours with no token.~~ **Closed 15 Sep 2026 by v6** (ADR-022), which removed both
   rather than naming either.
3. ~~`sqlite3_flutter_libs` resolves to `0.6.0+eol`.~~ **Closed 15 Sep 2026.** The package is
   empty; `package:sqlite3` 3.x ships the native library itself. PACKAGES.md has the detail.
4. **`speech_to_text` applies the Kotlin Gradle Plugin,** and the build warns that future
   Flutter versions will fail on plugins that do. Harmless on 3.47.4. Check before any Flutter
   upgrade, since ADR-005 makes that package hard to swap.
5. **Developer Mode on Windows.** `flutter pub get` warns that plugin builds need symlink
   support. Not blocking — the APK builds. If a build fails in a way `kotlin.incremental=false`
   does not explain, check this: `start ms-settings:developers`.
6. **Font bundle is ~1.8 MB,** of which Noto Serif Devanagari is 758 KB to draw one word.
   PACKAGES.md suggests subsetting before shipping; this is the file that makes it worth doing.
7. **`public_member_api_docs` is on.** Valuable in `domain`, `data` and `core`; noise on a
   zero-argument widget constructor. If it becomes a real tax the answer is a nested
   `analysis_options.yaml` under `lib/features/`, not turning it off everywhere — and either way
   it is a change that gets recorded.
8. **OPEN-QUESTIONS.md §8.2 (re-transcription) and §8.3 (does Today carry enough rhythm) are
   still open.** Neither blocks anything before M7.
9. **Nothing deletes a chit yet,** so the orphan sweep has little to collect. `ChitRepository`
   has no `delete`, because no screen offers one and BEHAVIOUR.md does not describe one. The
   sweep still earns its place: a save that moves the file and then fails to write the row
   leaves exactly the orphan it collects. When a delete arrives it goes in the repository,
   removes the row and the file together, and gets its own test.
10. **The debug seeder of DATA-MODEL.md §7 does not exist.** Worth writing the moment the
    calendar has something to shade — M4. A seeded day must cover all four shapes of §2,
    especially the recording with `NULL` text.
11. ~~Re-point `lib/core/theme/` at v6.~~ **Closed 15 Sep 2026.** The four extensions, their
    tests and `lib/`'s vocabulary all describe v6 now.
12. ### ⬜ **Today's ring fails its contrast floor on a busy day.** Wants a design answer.

    Today is ringed in `--seal` on the calendar; the tile under it is an ink wash whose strength
    depends on how much was written that day. As a non-text UI component the ring needs 3:1, and
    it gets:

    | Tile | Ratio | |
    |---|---|---|
    | empty | 4.56:1 | passes |
    | one chit | 3.97:1 | passes |
    | two | 3.36:1 | passes |
    | three | **2.61:1** | fails |
    | four or more | **1.88:1** | fails |

    Three chits is an ordinary day in an app whose premise is several a day, so this is not a
    corner case — on a busy today the one mark a person is looking for is the hardest to see.
    Do not fix it by nudging a token: the ring and the fill are the same lightness family by
    design now (ADR-022). It probably wants a different *shape* for today — a ring drawn outside
    the tile, a gap between ring and fill, or a mark rather than a border. It is M4's problem,
    and M4 should not invent the answer under time pressure.

    The figures are asserted in `test/core/theme/contrast_test.dart`, **including the two that
    fail**. Fixing this breaks that test, which is deliberate: whoever fixes it is told to come
    back and rewrite the record rather than leaving a stale one behind.
13. ~~`--hair-soft` has collapsed on a chit.~~ **Closed 15 Sep 2026** by M2 decision A4. The
    token was not nudged — it divides on the ground, where it measures 1.13:1 and is fine, and
    the one place that put it on a chit takes `ChitColors.discardPressedWash` instead. It turned
    up a second thing worth keeping: **`--ink-faint` fails on any wash at all** (4.12:1 at 4%,
    and the wash is 6%), so Discard's label lifts to `--ink` while the control is held. A
    pressed state is a surface that text sits on, and §6.4 makes no exception for surfaces that
    are brief.
14. **The framework's caret still blinks under reduced motion,** and it belongs to M7's floors
    pass. §6.4 lists the caret blink among the ambient loops that stop outright, and since
    ADR-028 the only caret in the app is Flutter's. There is no public way to steady it:
    `TickerMode(enabled: false)` sets the cursor's opacity to **zero**, so it vanishes rather
    than resting, which removes the thing the rule exists to protect; and
    `EditableText.debugDeterministicCursor` is a `debug`-prefixed global documented as being for
    tests. Some perspective before anyone spends a day on it: a stock Android keyboard blinks
    whatever the animation setting says, so this matches every other text field on the device
    rather than standing out. The two honest ways forward are a framework issue, or accepting it
    and writing it into §6.4 as a stated limit rather than a silent one.
