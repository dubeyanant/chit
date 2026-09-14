# chit

A private journal for things that hit you during the day.

The name is a wordplay. **चित्त** (*chitta*) is Sanskrit for consciousness, mind, the field
where impressions land. A **chit** is also a small slip of paper you scribble something on
and keep. The app is both: a place where passing impressions get written down on small slips.

---

## 0. Start here

**This file is the front door, not the whole house.** It holds what chit is (§1–§2) and what a
chit is (§5), and §10 maps everything else. The behaviour specification, the design system and
the open questions live in their own documents — they are still the design authority, they are
just not all in one 500-line file.

Read these three, in this order. It is about ten minutes and it is the whole context.

| # | Read | For |
|---|---|---|
| 1 | **[`docs/PROGRESS.md`](docs/PROGRESS.md)** | **Where the build stands and what to do next.** The status board, what the last session did, the current milestone's task list, every open item. If you read one thing, read this |
| 2 | **[`CLAUDE.md`](CLAUDE.md)** | How to work here — the standing rule below, the engineering principles, the commit format |
| 3 | **[`docs/BUILD-PLAN.md`](docs/BUILD-PLAN.md)** | What "done" means for the milestone `PROGRESS.md` just named |

Then read what that milestone points at, and open
[`design/chit-app-v5.html`](design/chit-app-v5.html) in a browser — it is the visual target.
**[§10](#10-the-map) is the map: every file in the repository and why it exists.**

> **Status:** in build. M0 is done — the project is configured and the design system is in code
> as four theme extensions, with the contrast floor and the reduced-motion rule enforced as
> tests. **M1, the data spine, is next.**
>
> This line is a courtesy and goes stale. `docs/PROGRESS.md` is the one that is kept true.

### Section numbers are stable, and global

§1 to §10 are numbered once, across this file and the three documents that hold the rest of the
specification. **A section keeps its number wherever it lives**, so a citation like §6.1 or
§3.5 resolves the same way from any file, and the two hundred-odd cross-references in the docs
and the source did not have to be rewritten when the specification was split.

That is why the numbering here has gaps. It is not an omission:

| | Section | Lives in |
|---|---|---|
| §0 | Start here | this file |
| §1 | What chit is | this file |
| §2 | Core concepts | this file |
| **§3** | **Behaviour specification** | [`docs/BEHAVIOUR.md`](docs/BEHAVIOUR.md) |
| **§4** | **Screens** | [`docs/BEHAVIOUR.md`](docs/BEHAVIOUR.md) |
| §5 | Data model | this file |
| **§6** | **Design system** | [`docs/DESIGN-SYSTEM.md`](docs/DESIGN-SYSTEM.md) |
| **§7** | **The prototype** | [`docs/DESIGN-SYSTEM.md`](docs/DESIGN-SYSTEM.md) |
| **§8** | **The three hard questions** | [`docs/OPEN-QUESTIONS.md`](docs/OPEN-QUESTIONS.md) |
| **§9** | **Feature backlog** | [`docs/OPEN-QUESTIONS.md`](docs/OPEN-QUESTIONS.md) |
| §10 | The map | this file |

### The standing rule

**No change is finished until the documents that describe it are true again** — in the *same*
change, never as a follow-up. Contradicting a document is a change to that document.

That is what makes the reading order above work. A session that follows the rule leaves
`PROGRESS.md` describing reality, so the next session starts from it without being told
anything. A session that skips it leaves the next one with a lie and no way to tell which half
to trust.

[`CLAUDE.md`](CLAUDE.md) §0 has the full version — which document to update for which kind of
change, and the checklist to run before calling anything done. If you are Claude Code, that
file is already loaded: read `docs/PROGRESS.md` and start.

---

## 1. What chit is

chit assumes **you write when something hits you**: several times a day, in a few words,
and then you get on with your life.

Everything in the product follows from that:

| Assumption | Consequence in the design |
|---|---|
| People write in bursts, not sessions | A chit is short. The composer is always open on the home screen. |
| A day holds many chits | The home screen is a thread of today. |
| Writing happens mid-thought | Opening the app costs nothing — the page is blank and ready. |
| Speaking is often faster than typing | The composer is one surface: a live field, a microphone beside it. |
| Speech gets names, places and code-switching wrong | Whatever the machine hears lands in the field, where it can be fixed. |
| The moment matters as much as the words | Time, weather and location are captured with every chit. |
| The habit survives on rhythm, not scores | Rhythm is shown as shape and colour; the app keeps no score. |

---

## 2. Core concepts

- **chit** — one entry. Text, a recording, or both. Timestamped and stamped with ambient
  context.
- **the open chit** — a blank chit at the top of the home screen: a field ready to type in,
  with a microphone beside it. It becomes a record when the user saves it.
- **the ambient stamp** — time, weather condition and a location marker, captured
  automatically when a chit is opened.
- **the thread** — a day's chits, in order, hanging off a vertical rail. A day reads as one
  continuous thing.
- **the day arc** — a horizontal line from 5am to midnight showing *when* today's chits landed.


---

## 5. Data model

A chit is text, audio, or both:

| Field | Notes |
|---|---|
| `id` | |
| `createdAt` | drives both the day arc and the day grouping |
| `text` | what the chit says. Typed, transcribed, or transcribed and then corrected. **Null when a recording produced nothing and the user wrote nothing.** |
| `audioPath` | present whenever a recording was kept |
| `textOrigin` | `typed` \| `transcript` \| `transcriptEdited` — where the words came from |
| `weather` | a condition word |
| `location` | stored; surfaced in the UI only as the pin |

`text` and `audioPath` are independently nullable and **at least one of them is always
present** — a chit with neither is not a chit, and is what §3.1 refuses to save.

That leaves four shapes, all ordinary:

| | `text` | `audioPath` |
|---|---|---|
| typed | ● | — |
| recorded and transcribed | ● | ● |
| recorded, transcript corrected | ● | ● |
| recorded, nothing recognised (§3.5) | — | ● |

`textOrigin` is provenance, not behaviour: nothing in the UI reads differently because of it.
It exists so that a future re-transcription (§8.2) can tell whether it would be overwriting the
machine's words or the user's.


---

## 10. The map

Everything in the repository and why it exists. Nothing here should be reachable only by `ls`:
if a file matters, it has a line in this section.

`test/docs/readme_maps_everything_test.dart` enforces that. It fails if a document, a
prototype, or a top-level source directory exists without being named here, and if an ADR
exists without a line in `DECISIONS.md`'s own index. An index nobody maintains is worse than no
index, so this one is maintained by the build.

```
chit/
├── README.md               this file — §0 says where to start, §10 is this map
├── CLAUDE.md               how to work here: the standing rule, the principles, the commits
├── docs/                   §10.1 — nine documents, one question each
├── lib/                    §10.2 — the Flutter source
├── test/                   §10.3 — what is enforced rather than intended
├── design/                 §10.4 — the prototype, and the visual target
├── assets/fonts/           §10.5 — the three faces of §6.2
├── analysis_options.yaml   §10.6 — CLAUDE.md §4.1 in the form the machine can check
├── pubspec.yaml            §10.6 — every dependency, each justified in docs/PACKAGES.md
└── android/  ios/  web/    §10.6 — platform configuration
```

### 10.1 The documents

| File | Answers | Read it |
|---|---|---|
| [`docs/PROGRESS.md`](docs/PROGRESS.md) | **Where the build stands and what is next.** The status board, what the last session did, the current milestone's task list, and every open item | First. Always |
| [`CLAUDE.md`](CLAUDE.md) | How to work here — the standing rule, the engineering principles, the commit format, the commands | Second, before writing anything |
| [`docs/BUILD-PLAN.md`](docs/BUILD-PLAN.md) | The order it gets built in, M0 to M7, and what "done" means for each | Starting a milestone |
| [`docs/BEHAVIOUR.md`](docs/BEHAVIOUR.md) | **§3 and §4** — the behaviour specification and the screens. What the app does and what it looks like doing it | Building any screen |
| [`docs/DESIGN-SYSTEM.md`](docs/DESIGN-SYSTEM.md) | **§6 and §7** — the palette, the three faces, the spacing, the motion, the accessibility floors, and the prototype | Drawing anything |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | How it is put together — the three layers, the folder map, the Riverpod conventions, the data flow behaviour by behaviour | Adding a file and unsure where it goes |
| [`docs/DECISIONS.md`](docs/DECISIONS.md) | The twenty ADRs — every choice, what it was chosen over, what it costs. Indexed at its head | Before reversing something that looks arbitrary |
| [`docs/DATA-MODEL.md`](docs/DATA-MODEL.md) | The schema, the invariants, the queries, and what a migration must preserve. §5 here is the product-level version of the same thing | M1, and any change to a row |
| [`docs/PACKAGES.md`](docs/PACKAGES.md) | Every dependency, why it is there, what it was chosen over, and the platform configuration each implies | Before adding a package. Nothing enters `pubspec.yaml` without a line there |
| [`docs/DESIGN-LOG.md`](docs/DESIGN-LOG.md) | Why the design is what it is — including the arguments that were made and lost | Before changing something in §4 or §6 that looks arbitrary. Most of it is load-bearing |
| [`docs/OPEN-QUESTIONS.md`](docs/OPEN-QUESTIONS.md) | **§8 and §9** — the questions still open, and the feature backlog | Deciding what comes after the current milestone |

**The design authority is this file, `BEHAVIOUR.md` and `DESIGN-SYSTEM.md`** — §1 to §9 between
them. Where any other document disagrees with those three, the disagreement is a bug in that
document, fixed in the same change that found it.

### 10.2 The source

The three layers and the one rule are [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) §1; the
file-by-file map is its §2. Every file listed there exists — the ones a milestone has not
reached hold a doc comment naming the milestone that fills them.

```
lib/
├── main.dart      runApp(ProviderScope(child: ChitApp()))
├── app/           the application root and the router (ADR-011)
├── core/          the design system, the clock, the BuildContext accessors
├── domain/        models and interfaces. Pure Dart; imports neither of the two below
├── data/          the implementations: Drift, files, network, platform plugins
├── features/      one folder per screen — shell, today, composer, calendar, editor
└── shared/        widgets used by more than one feature
```

**`features` never imports `data`.** Widgets watch controllers, controllers depend on
interfaces in `domain`, Riverpod supplies the implementations at the root — ADR-002.

`lib/core/theme/` is §6 turned into four `ThemeExtension`s — `ChitColors`, `ChitType`,
`ChitSpace` and `ChitMotion` — reached through `context.colors`, `.type`, `.space` and
`.motion`, four accessors rather than one so a widget that needs a colour cannot reach motion.

### 10.3 The tests

What is enforced rather than intended. `flutter test`.

| Suite | Guards |
|---|---|
| `test/core/theme/contrast_test.dart` | §6.4's contrast floor: every text token against every surface it sits on, **composited**. Also the negative cases — `--seal` failing as text on a chit is why `--seal-ink` exists, and `--ink-faint` failing on the audio pill's wash is why the pill's duration is set in `--ink-muted`. It locks §6.1's quoted figures to ±0.01 so the prose and the arithmetic cannot drift apart |
| `test/core/theme/chit_type_test.dart` | ADR-015: every style sets `fontVariations`, not `fontWeight` alone. The three faces of §6.2 are the only families used, the चित्त mark is the only thing set in Devanagari, tabular figures are on everything that counts or keeps time, no functional text is under 11.5px |
| `test/core/theme/chit_motion_test.dart` | §6.4's reduced-motion rule: movement collapses, feedback does not. The suite that found ADR-020 |
| `test/core/clock_is_the_only_now_test.dart` | ADR-012: nothing in `lib/` calls `DateTime.now()` except `SystemClock` |
| `test/docs/readme_maps_everything_test.dart` | This section, and `DECISIONS.md`'s ADR index |
| `test/support/contrast.dart` | Not a suite — the WCAG arithmetic, in one place so every check uses the same maths |

The pattern, set in M0b and worth keeping: **a rule that fails silently gets a test that checks
a property, not an example.** `chit_motion_test.dart` asserting "no fade is slower than it was"
is what caught a motion rule that was self-consistent and wrong.

### 10.4 The prototype

| File | |
|---|---|
| [`design/chit-app-v5.html`](design/chit-app-v5.html) | The interactive design prototype and **the visual target**. One self-contained file, no build step — open it in any browser. §7 says what is live in it and what is deliberately not wired |
| [`design/chit-app-v4.html`](design/chit-app-v4.html) | Superseded. It predates §3.2 and §3.4 — Write and Speak as two exclusive buttons, and a locked transcript. History, not a second option |

When in doubt about a pixel, open v5. The type scale, the spacing steps and the motion pace
table were all read from it.

### 10.5 Assets

`assets/fonts/` holds the three faces of §6.2 as **variable** fonts with an `OFL.txt` beside
each: Newsreader (upright and italic), Hanken Grotesk, Noto Serif Devanagari. ADR-015 says why
variable rather than static cuts, and what it costs — weight has to be applied through
`fontVariations`, because `fontWeight` alone is silently ignored.

### 10.6 Configuration

| File | |
|---|---|
| [`analysis_options.yaml`](analysis_options.yaml) | The engineering principles of `CLAUDE.md` §4.1 in the form the machine can check: strict casts, inference and raw types; exhaustive switches and unawaited futures as errors; immutability and documentation rules. `riverpod_lint` runs inside `flutter analyze` through the `plugins:` key — ADR-018, no separate command |
| [`pubspec.yaml`](pubspec.yaml) | Dependencies and the font declarations. Every entry is justified in [`docs/PACKAGES.md`](docs/PACKAGES.md) |
| `android/app/src/main/AndroidManifest.xml` | `RECORD_AUDIO`, both location permissions (ADR-016), `INTERNET`, and the `android.speech.RecognitionService` queries intent `speech_to_text` needs from targetSdk 30 |
| `android/app/build.gradle.kts` | `minSdk 24` — `record_android`'s floor, the highest of any plugin — and the `com.infiniteants.chit` application id |
| `android/gradle.properties` | `kotlin.incremental=false`. Without it every plugin's Kotlin compile fails to close its caches on Windows; `docs/PROGRESS.md` has the detail |
| `ios/Runner/Info.plist` | The microphone, speech-recognition and location usage strings — the only copy in the app the design never sees, so they are written in chit's voice |

Android and iOS only — ADR-019. The desktop scaffolds went in M0a; `web/` is kept because
responsive web is planned after v1, and no layout work is being spent on it yet.

### 10.7 Running it

```bash
flutter pub get
dart run build_runner watch      # leave running while working
flutter analyze                  # must be clean before a commit
flutter test
flutter run                      # an Android device or emulator
```

Targets: Android and iOS. Responsive web comes later — the current design is mobile at 390×844.

On Windows, `flutter pub get` warns unless **Developer Mode** is enabled; plugin builds need
symlink support. `start ms-settings:developers`.
