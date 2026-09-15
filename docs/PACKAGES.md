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
| `record` | ✓ `^7.1.1` | recording to a temp file |
| `just_audio` | ✓ `^0.10.6` | playback behind the audio pill |
| `speech_to_text` | ✓ `^7.4.0` | on-device transcription (ADR-005) |
| `geolocator` | `^14.0.3` | the fix behind the pin — precise, falling back to coarse (ADR-016); also owns the location permission flow, and its **last known** fix is what the weather call uses so the two signals stay parallel (ADR-025) |
| `http` | `^1.2.2` | one call, to Open-Meteo |
| `intl` | `^0.20.2` | dates and the tabular-figure formats of DESIGN-SYSTEM.md §6.2 |
| `path_provider` | `^2.1.5` | the app documents directory for the audio store |
| `path` | `^1.9.1` | joining those paths without string concatenation |
| `uuid` | `^4.5.1` | client-generated ids (ADR-004) |

## Development

| Package | Version | For |
|---|---|---|
| `build_runner` | `^2.4.13` | runs all codegen |
| `riverpod_generator` | ✓ `^4.0.9` | generates the providers |
| `riverpod_lint` | `^3.0.0` → 3.1.9 | catches the misuse codegen cannot. Enabled through `plugins:` in `analysis_options.yaml`, not through `custom_lint` — ADR-018 |
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

### On `speech_to_text` and offline recognition

ADR-005 requires that nothing leaves the device. The package supports this through
`SpeechListenOptions(onDevice: true)` — its own documentation is unambiguous: *"if true the
listen attempts to recognize locally with speech never leaving the device. If it cannot do this
the listen attempt will fail."*

Failing is the behaviour we want; silently falling back to a server is not. So:

- Pass `onDevice: true` on **every** listen call, with no fallback path that omits it. There
  should be exactly one call site.
- A failed listen is not a special case — it resolves to BEHAVIOUR.md §3.5 along with "heard nothing"
  and "no model installed" (ARCHITECTURE §4.4).
- Check `initialize()` and the available locales at startup, but do not gate the microphone on
  the result. The user should be able to record whatever the engine can do; the audio is kept
  either way.

Under the hood this is Android's on-device `SpeechRecognizer` and iOS's `SFSpeechRecognizer`
with `requiresOnDeviceRecognition`. On Android the model is the one the system dictation uses,
which means it may need to be downloaded through the OS's own language settings first — worth
verifying on a low-end handset early, because it is the case most likely to surprise a user in
India and the one hardest to reproduce on a developer's phone.

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

**A cloud speech engine** (`google_speech`, or Google Cloud STT behind a proxy) — ADR-005.
Reopening it is a privacy decision, not a package decision.

**`permission_handler`** — `record` asks for the microphone and `geolocator` asks for location,
each with the platform flow their plugin already handles. A third permission library would be
a second source of truth for two permissions. Add it only if a permission appears that neither
plugin owns.

**`custom_lint`** — this file used to list it as the host `riverpod_lint` plugs into. It no
longer is: `riverpod_lint` 3.x is built on `analysis_server_plugin` and is enabled through the
`plugins:` key in `analysis_options.yaml`. The two also cannot coexist — `riverpod_generator`
needs `analyzer >=13` and the newest `custom_lint` is pinned to `analyzer ^8`, so version
solving fails outright. See ADR-018.

**`flutter_hooks`** — Riverpod's notifiers cover the state in this app, and mixing two idioms
for local widget state makes the codebase harder to read than either alone.

**`shared_preferences`** — nothing to store yet. The settings screen in BEHAVIOUR.md §4.1's sketch
has no defined contents; when it gets some, this is the likely answer.

---

## Platform configuration this implies

Done in one pass in M0a rather than discovered one plugin at a time. What is in the tree now:

**Android** (`android/app/src/main/AndroidManifest.xml`)
`RECORD_AUDIO`, `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` (precise first, coarse as the
fallback — ADR-016), `INTERNET`. Plus a `<queries>` entry for `android.speech.RecognitionService`,
without which `speech_to_text` cannot see the recognition service at all from targetSdk 30.

`minSdk = 24`, in `android/app/build.gradle.kts`. That is `record_android`'s floor and the
highest of any plugin here — `speech_to_text` asks 21, `path_provider` 21, `just_audio` 16.

**iOS** (`ios/Runner/Info.plist`)
`NSMicrophoneUsageDescription`, `NSSpeechRecognitionUsageDescription`,
`NSLocationWhenInUseUsageDescription`, written in chit's own voice; they are the only copy in
the app the design never sees. `IPHONEOS_DEPLOYMENT_TARGET` is 15.0 from the scaffold, above
every plugin's floor (`speech_to_text` 13.0, `just_audio` 12.0, `geolocator_apple` 11.0), so it
was left alone.

Both location strings should say what BEHAVIOUR.md §3.6 says the app does with it: it records that a
place was there, and never shows which one. The speech string can say something no other app's
can — that recognition happens on the phone and the recording is not sent anywhere. It is true,
it is unusual, and it is the sentence most likely to earn the permission.
