# Chitta

A private journal for things that hit you during the day.

**चित्त** (*chitta*) is Sanskrit for consciousness, mind, the field where impressions land; a
**chit** is a small slip of paper you scribble on and keep. **The app signs itself चित्त on screen
and Chitta wherever the phone says it** — the drawer, the switcher, the stores — and **one entry is
a chit**. The Dart package and both bundle ids are `chitta` (ADR-074); the repository directory,
these documents and the `Chit` classes keep the short name.

## 0. Start here

This file holds what chit is (§1–§2), what a chit is (§5), and the map (§10). Read
[`CLAUDE.md`](CLAUDE.md) first for how to work here, then
[`docs/OPEN-QUESTIONS.md`](docs/OPEN-QUESTIONS.md) — what is open, what comes after v1, and the
numbered items a session must know. **v1 is finished** (ADR-073), so there is no next task waiting.

> **Status: v1 is done.** A chit can be typed or spoken, carries the time, the weather and what the
> phone was doing, and is read back on Today, on a scrolling timeline and in past, a grid of the
> months written. **Voice is recording and playback: there is no transcription** (ADR-058). A saved
> chit is opened by holding it, and its words, its recording and the chit itself can be changed or
> destroyed. **There are no database migrations** (ADR-059) — see OPEN-QUESTIONS.md item 38 before
> installing it anywhere the chits would be missed.

**Section numbers are global and stable.** §1 to §10 are numbered once across four files, and a
section keeps its number wherever it lives, so §6.1 resolves the same way from anywhere. Roughly two
hundred citations depend on it. **Never renumber.**

| | Section | Lives in |
|---|---|---|
| §0 §1 §2 §5 §10 | Start here · What Chitta is · Core concepts · Data model · The map | this file |
| **§3 §4** | **Behaviour specification · Screens** | [`docs/BEHAVIOUR.md`](docs/BEHAVIOUR.md) |
| **§6 §7** | **Design system · The prototype (retired)** | [`docs/DESIGN-SYSTEM.md`](docs/DESIGN-SYSTEM.md) |
| **§8 §9** | **The three hard questions · Feature backlog** | [`docs/OPEN-QUESTIONS.md`](docs/OPEN-QUESTIONS.md) |

**The design authority is this file, `BEHAVIOUR.md` and `DESIGN-SYSTEM.md`.** Where another document
disagrees, that document is wrong and is fixed in the change that found it. Both standing rules —
every change closes the loop on the docs it made untrue, and nothing that has stopped earning its
place gets committed — live in [`CLAUDE.md`](CLAUDE.md) §0.

## 1. What Chitta is

Chitta assumes **you write when something hits you**: several times a day, in a few words, and then
you get on with your life. Everything follows from that:

| Assumption | Consequence |
|---|---|
| People write in bursts, not sessions | A chit is short. The composer is always open on the home screen |
| A day holds many chits | The home screen is a thread of today |
| Writing happens mid-thought | Opening the app costs nothing — the page is blank and ready, on a fresh install as on any other. **Nothing is asked for until there is something to ask about**: the place, once, after the first chit is saved (ADR-094) |
| Speaking is often faster than typing | One surface: a live field, a microphone beside it. A chit holds words, a recording, or both |
| The moment matters as much as the words | Time, weather, motion and location are recorded with every chit |
| The habit survives on rhythm, not scores | Rhythm is shape and colour; the app keeps no score |

## 2. Core concepts

- **chit** — one entry. Text, a recording, or both. Timestamped and stamped with ambient context.
- **the open chit** — a blank chit at the top of the home screen, which becomes a record when saved.
- **the ambient stamp** — the time and one ambient fact, carried by every chit. The time is read
  when the chit is **saved** (ADR-040); the weather, the motion and the fix are read at launch and
  at each save, never in between (ADR-042). The stamp on the open chit is a preview.
- **the thread** — a day's chits hanging off a vertical rail, so a day reads as one continuous thing.
- **the timeline** — a horizontal line under the date showing *when* chits landed, each mark where
  its time actually falls. Today and the two days before it; it scrolls and rests at now (ADR-024).

## 5. Data model

| Field | Notes |
|---|---|
| `id`, `createdAt` | `createdAt` drives both the timeline and the day grouping |
| `text` | what the chit says, typed. **Null on a chit that is only a recording** |
| `audioPath` | present whenever a recording was kept |
| `weather` | a condition word |
| `location` | stored; **not surfaced in the UI** (ADR-066) |
| `motion` | `stationary`, `walking`, `traveling`, `flying`, read off the same fix as `location` (ADR-037). Drawn as a word beside the time, and `stationary` is not drawn at all (ADR-078) |

`text` and `audioPath` are independently nullable and **at least one is always present** — a chit
with neither is not a chit, and is what §3.1 refuses to save. That leaves three shapes, all
ordinary: words alone, words and a recording, a recording alone. **A chit does not record where its
words came from**; every chit's words are typed (ADR-058).

## 10. The map

Every file and why it exists, kept true by hand rather than by a test (CLAUDE.md §4.2).

**Documents.** [`CLAUDE.md`](CLAUDE.md) how to work here (**read first**) ·
[`docs/OPEN-QUESTIONS.md`](docs/OPEN-QUESTIONS.md) §8–§9, what is open and what comes after v1
(**read second**) · [`docs/BEHAVIOUR.md`](docs/BEHAVIOUR.md) §3–§4 ·
[`docs/DESIGN-SYSTEM.md`](docs/DESIGN-SYSTEM.md) §6–§7 ·
[`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) layers, folders, providers, data flow, testing ·
[`docs/DECISIONS.md`](docs/DECISIONS.md) every decision that would be expensive to reverse ·
[`docs/DATA-MODEL.md`](docs/DATA-MODEL.md) schema, invariants, queries, the seeder ·
[`docs/PACKAGES.md`](docs/PACKAGES.md) every dependency and the platform config it implies —
nothing enters `pubspec.yaml` without a line there ·
[`docs/DESIGN-LOG.md`](docs/DESIGN-LOG.md) the constraints the design rests on.

**Source.** The layer rule and the file-by-file map are ARCHITECTURE.md §1.

```
lib/
├── main.dart   runApp(ProviderScope(child: ChitApp()))
├── app/        the application root and the router (ADR-011)
├── core/       the design system, the clock, the haptic vocabulary, the BuildContext accessors
├── domain/     models and interfaces. Pure Dart; imports neither of the two below
├── data/       the implementations: Drift, files, network, platform plugins
├── features/   one per screen — shell, today, composer, past, find, editor
└── shared/     widgets used by more than one feature

tool/           pack_outlines.mjs — builds assets/geo/outline.bin, run by hand (ADR-089)
```

`lib/core/theme/` is §6 as four `ThemeExtension`s, reached through `context.colors`, `.type`,
`.space` and `.motion` — four accessors rather than one, so a widget that needs a colour cannot
reach motion. `lib/domain/tags/` reads `@person` and `#topic` out of a chit's words (ADR-082) —
pure, so the widget that draws them holds no grammar, and `lib/domain/find/` says which axis a tag
is found on. `lib/domain/find_line.dart` holds the two books find opens with — the house lines and
the hints (ADR-086) — and turns a visit count into one of them (ADR-093).
`lib/domain/services/place_permission.dart` is the whole of asking for location: it is called by the
save and by nothing else, and draws nothing (ADR-094).
`lib/core/haptics.dart` is the three steps of §6's haptic vocabulary and the only place
`HapticFeedback` is called (ADR-096). `lib/shared/widgets/` is the chit vocabulary:
the slip and its tear edge, the chit's own body text, the stamp
row and its motion marks, the rail and the thread over it, a day's heading and its group, the
wordmark, the heading row the tabs hang their title in, the two button weights, the microphone, the
pill, the prompt sheet, `Arrival`, `StaggeredEntrance` and `FocusRing`.

**Tests.** `flutter test`. **There are no widget tests, and there will not be** (ADR-031) — what can
only be seen on a screen is seen on a handset and written into the commit. Suites sit beside what
they guard, mirroring `lib/`, plus `test/support/` for the fakes and the WCAG arithmetic and
`test/docs/` for the two source rules enforcing themselves — no widget tests (ADR-031) and no
comments (ADR-095). What is covered is ARCHITECTURE.md §4.
Three patterns worth keeping: **a rule that fails silently gets a test that checks a property, not
an example** (asserting "no fade is slower than it was" caught a motion rule that was
self-consistent and wrong); **an invariant worth having is worth holding in more than one place**,
each tested where it lives; and **a fake must refuse whatever the real one refuses** — where the
fault was *under* the fake, the test stands a fake platform under the real plugin (ADR-067).

**Assets and configuration.** `assets/fonts/` holds the three faces of §6.2 as **variable** fonts
with an `OFL.txt` beside each (ADR-015 — weight must go through `fontVariations`, `fontWeight` alone
being silently ignored). `assets/icon/` holds the two icon exports the launcher set is generated
from by hand — not bundled into the app, and PACKAGES.md says which command; the splash glyph beside
it in `android/app/src/main/res/drawable/` is a vector and is **not** generated, so a redrawn icon is
three files (ADR-090). [`analysis_options.yaml`](analysis_options.yaml) is CLAUDE.md §4.1 in the
form the machine can check, with `riverpod_lint` running inside `flutter analyze` through the
`plugins:` key. `android/` carries `RECORD_AUDIO`, both location permissions and `INTERNET`,
`minSdk 24` (`record_android`'s floor, the highest of any plugin), a `values-v31` launch theme for
the system splash, and `kotlin.incremental=false`, without which every plugin's Kotlin compile fails
to close its caches on Windows.
`ios/Runner/Info.plist` holds the microphone and location usage strings — the only copy in the app
the design never sees. Android and iOS only (ADR-019); `web/` is kept because responsive web is
planned after v1.

**Running it.**

```bash
flutter pub get
dart run build_runner watch                 # leave running while working
flutter analyze                             # must be clean before a commit
flutter test
flutter run                                 # an Android device or emulator
flutter run --dart-define=CHIT_SEED=seed    # three months of chits — DATA-MODEL.md §6
flutter run --dart-define=CHIT_SEED=stress  # 2,000 of them, for measuring
flutter run --dart-define=CHIT_SEED=clear   # and the same build with them taken off again
flutter run --profile --dart-define=CHIT_FRAMES=true   # frame times to the log
```

The design is mobile at 390×844. On Windows, `flutter pub get` warns unless **Developer Mode** is
enabled — plugin builds need symlink support. `start ms-settings:developers`.
