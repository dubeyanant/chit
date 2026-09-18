# Packages

Every dependency, what it is for, and what it was chosen over. Nothing goes in `pubspec.yaml`
without a line here.

Every version below is the one actually resolved in `pubspec.lock` on **14 September 2026**,
verified by `flutter pub get`. A ✓ marks a version that was also checked on pub.dev before
resolution, so the two can be compared.

---

## Runtime

| Package | Version | For |
|---|---|---|
| `flutter_riverpod` | ✓ `^3.4.3` | state and dependency injection (ADR-001) |
| `riverpod_annotation` | `^4.0.0` → 4.0.7 | the `@riverpod` annotation |
| `drift` | ✓ `^2.35.0` | local database (ADR-003) |
| `drift_flutter` | ✓ `^0.3.1` | opens the database with no async bootstrap; pulls `sqlite3_flutter_libs`, which is now inert — see below |
| `go_router` | ✓ `^18.0.1` | the tab shell and routing (ADR-011) |
| `freezed_annotation` | `^3.1.0` | immutable models: value equality, `copyWith`, and a private constructor that can assert its invariant |
| `record` | ✓ `^7.1.1` | recording to a temp file — mono AAC in an `.m4a`, behind `RecordAudioRecorder` (ADR-052). It also owns the microphone permission ask |
| `just_audio` | ✓ `^0.10.6` | playback behind the audio pill |
| `geolocator` | `^14.0.3` | the fix behind the pin — precise, falling back to coarse (ADR-016); also owns the location permission flow, and its **last known** fix is what the weather call uses so the two signals stay parallel (ADR-025). **Its `Position` also carries `speed`, `speedAccuracy` and `altitude`, which is the whole of motion capture** (ADR-037) — the reason chit needs no motion-sensor package and no second permission |
| `http` | `^1.2.2` | one call, to Open-Meteo |
| `intl` | `^0.20.2` | dates and the tabular-figure formats of DESIGN-SYSTEM.md §6.2 |
| `path_provider` | `^2.1.5` | the app documents directory for the audio store |
| `path` | `^1.9.1` | joining those paths without string concatenation |
| `uuid` | `^4.5.1` | client-generated ids (ADR-004) |
| `shared_preferences` | `^2.3.3` | **two booleans.** Whether the first-run screen has been shown, and whether the app has spent its one permission ask (ADR-041). The only state chit keeps outside the database, and the only thing `main()` awaits before the first frame — the router cannot pick the right first screen without it |

## Development

| Package | Version | For |
|---|---|---|
| `build_runner` | `^2.4.13` | runs all codegen |
| `riverpod_generator` | ✓ `^4.0.9` | generates the providers |
| `riverpod_lint` | `^3.0.0` → 3.1.9 | catches the misuse codegen cannot. Enabled through `plugins:` in `analysis_options.yaml`, not through `custom_lint` — see *Considered and not taken* below, which says why there is no separate lint command |
| `drift_dev` | `^2.35.0` | generates the DAOs and the schema |
| `freezed` | ✓ `^4.0.1` | generates the models |
| `flutter_lints` | already present `^6.0.0` | base lint set |

`json_serializable` is not listed. The only JSON in the app is one Open-Meteo response, decoded
by hand in one file; a codegen dependency for that is not worth the build time. Add it if a
second endpoint appears.

### On `sqlite3_flutter_libs` and its `+eol` marker

`drift_flutter` pulls `sqlite3_flutter_libs 0.6.0+eol` transitively, and the marker is upstream's
rather than a warning about our version constraint. Checked at the top of M1, which is when it
started mattering: **0.6.0+eol is the latest release, and the package is now empty.** Its own
page says so — *"This package relates to version 2.x of `package:sqlite3`, and is obsolete after
upgrading."* Version 3.x of `package:sqlite3` ships the native library itself, our tree already
resolves it at 3.5.2, and the shim will fall away whenever `drift_flutter` drops it from its own
dependencies.

The practical consequence is a good one: `NativeDatabase.memory()` opens in `flutter test` on
the host with no setup and no downloaded binary, which is what lets every repository test run
against a real SQLite.

---

## Assets

The three faces of DESIGN-SYSTEM.md §6.2 ship as files, not through `google_fonts` (ADR-009), and as
**variable** fonts rather than static cuts (ADR-015):

```
assets/fonts/
├── Newsreader/            Newsreader-VF.ttf         opsz 6–72,  wght 200–800
│                          Newsreader-Italic-VF.ttf  opsz 6–72,  wght 200–800
├── HankenGrotesk/         HankenGrotesk-VF.ttf      wght 100–900
└── NotoSerifDevanagari/   NotoSerifDevanagari-VF.ttf              ← the चित्त mark only
```

This corrects what this file used to say — *"only the weights actually used: regular, italic,
medium"*. The prototype loads Newsreader at **300–600** (the date is 300) and Hanken
Grotesk at **400/500/600**, so that list would have shipped the design at the wrong weights.
Variable fonts also carry Newsreader's `opsz` axis, which is what makes a 26px date and 16.5px
body text both look right; ADR-015 has the full argument. *The date was 38px in v5 and is 26px
in v6 (DESIGN-SYSTEM.md §6.2) — a narrower optical range, and the axis still earns its place.*

**Consequence for the code:** a variable font renders at weight 400 unless a `TextStyle` sets
`fontVariations`. `fontWeight` alone does nothing. `chit_type.dart` is the only file that may
set either.

All three are SIL Open Font License, downloaded from `google/fonts`, with `OFL.txt` beside each.
The bundle is ~1.8 MB, of which Noto Serif Devanagari is 758 KB to draw one word — subset it
before shipping.

---

## Considered and not taken

**`isar` / `hive`** — quicker to stand up, but the calendar's per-day counts, the month
summary and the weather-search backlog item are all aggregate queries that SQL answers in the
database and a document store answers in Dart. See ADR-003.

**`google_fonts`** — a network fetch on first run, in an app whose whole premise is that it
opens instantly and works offline. See ADR-009.

**`firebase_*` / `supabase_flutter`** — out of scope for v1. See ADR-004.

**`dio`** — `http` is enough for one endpoint, and ADR-005 removed the second one. Revisit only
if the app grows a backend.

**Any speech engine at all**, cloud or on-device. `speech_to_text` **was** here and came out with
the feature (ADR-058): on-device recognition produced nothing on the first handset it ran on,
which is the cost ADR-005 had already stated. A cloud engine (`google_speech`, or Google Cloud
STT behind a proxy) was refused before that on privacy grounds and still is — reopening either
is a product decision, not a package one.

**`flutter_activity_recognition` / `sensors_plus`** — the two ways to read motion from the
sensors rather than from the fix, and **ADR-037 took neither**. `sensors_plus` gives raw
accelerometer and gyroscope, and neither of those measures speed: recovering it from
acceleration needs a double integration whose error compounds uselessly within seconds, and a
gyroscope only measures rotation. `flutter_activity_recognition` wraps the platform classifiers,
which do work — at the price of a **second runtime permission** on both platforms
(`ACTIVITY_RECOGNITION`, Motion & Fitness) against README §1's *opening the app costs nothing*,
a Google Play Services dependency, a stream-only API with no one-shot query, and no flying class
regardless. `geolocator` already returns the speed on a fix chit was taking anyway.

**`permission_handler`** — `record` asks for the microphone and `geolocator` asks for location,
each with the platform flow their plugin already handles. A third permission library would be
a second source of truth for two permissions. Add it only if a permission appears that neither
plugin owns.

**`custom_lint`** — not a dependency, and cannot become one. *This was ADR-018 until
16 September 2026, when it was folded in here: it is a fact about how two packages resolve, not
a decision about how the app is built, and this file is where dependency facts belong.*

This file used to list `custom_lint` as the host `riverpod_lint` plugs into. It no longer is.
`riverpod_lint` 3.x is built on `analysis_server_plugin` and is enabled through the `plugins:`
key in `analysis_options.yaml`. The two also cannot coexist: `riverpod_generator` 4.0.9 needs
`analyzer >=13` and the newest `custom_lint` is pinned to `analyzer ^8`, so version solving
fails outright with both present — this was discovered while resolving, not chosen.

The practical gain is that `dart analyze` and `flutter analyze` surface the Riverpod lints
directly, with **no separate `dart run custom_lint` step** and nothing extra for CI to run.

It cost one thing, and the cost has since been paid: the ban on `DateTime.now()` (ADR-012) was
going to be a `custom_lint` rule, and with no host for one it had to become either an analyzer
exclusion or a test that reads the source. M0b chose the test —
`test/core/clock_is_the_only_now_test.dart`, which walks `lib/` and fails on any call outside
`SystemClock`.

**`flutter_hooks`** — Riverpod's notifiers cover the state in this app, and mixing two idioms
for local widget state makes the codebase harder to read than either alone.

---

## Platform configuration this implies

Done in one pass in M0a rather than discovered one plugin at a time. What is in the tree now:

**Android** (`android/app/src/main/AndroidManifest.xml`)
`RECORD_AUDIO`, `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` (precise first, coarse as the
fallback — ADR-016), `INTERNET`. *A `<queries>` entry for `android.speech.RecognitionService`
was here too, and went with ADR-058.*

`minSdk = 24`, in `android/app/build.gradle.kts`. That is `record_android`'s floor and the
highest of any plugin here — `path_provider` asks 21, `just_audio` 16.

**iOS** (`ios/Runner/Info.plist`)
`NSMicrophoneUsageDescription` and `NSLocationWhenInUseUsageDescription`, written in chit's own
voice; they are the only copy in the app the design never sees.
*`NSSpeechRecognitionUsageDescription` went with ADR-058 — one fewer permission to explain.*
`IPHONEOS_DEPLOYMENT_TARGET` is 15.0 from the scaffold, above every plugin's floor
(`just_audio` 12.0, `geolocator_apple` 11.0), so it was left alone.

Both location strings should say what BEHAVIOUR.md §3.6 says the app does with it: it records
that a place was there, and never shows which one. The microphone string says the thing that is
unusual and true and most likely to earn the permission — that the recording stays on the phone
and is not sent anywhere.
