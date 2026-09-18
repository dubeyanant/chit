# Packages

Every dependency, what it is for, and what it was chosen over. **Nothing goes in `pubspec.yaml`
without a line here.** Versions are those resolved in `pubspec.lock`.

**Runtime.** `flutter_riverpod` + `riverpod_annotation` state and DI (ADR-001) · `drift` +
`drift_flutter` the local database, opened with no async bootstrap (ADR-003) · `go_router` the tab
shell (ADR-011) · `freezed_annotation` immutable models with a private constructor that can assert
its invariant · `record` recording to a temp file, and the microphone permission ask (ADR-052) ·
`just_audio` playback · `geolocator` the fix and the location permission flow, whose **last known**
fix is what the weather call uses so the two signals stay parallel (ADR-025), and whose `Position`
carries `speed`, `speedAccuracy` and `altitude` — **the whole of motion capture** (ADR-037), which
is why chit needs no motion-sensor package and no second permission · `http` one call, to Open-Meteo
· `intl` dates and tabular figures · `path_provider` + `path` · `uuid` client-generated ids
(ADR-004) · `shared_preferences` **two booleans**, whether the first-run screen has been shown and
whether the app has spent its one permission ask (ADR-041) — the only state outside the database,
and the only thing `main()` awaits before the first frame, the router being unable to pick the right
first screen without it.

**Development.** `build_runner` · `riverpod_generator` · `riverpod_lint`, enabled through `plugins:`
rather than `custom_lint` (below) · `drift_dev` · `freezed` · `flutter_lints` ·
`just_audio_platform_interface`, **only for `just_audio_player_test.dart`**, which stands a fake
platform under the real plugin (ADR-067); already transitive, listed so the test may import it ·
`flutter_launcher_icons`, **run by hand and never at build time** — `dart run flutter_launcher_icons`
rewrites the Android mipmaps, the iOS appiconset and the web icons from the two files in
`assets/icon/` and the config block in `pubspec.yaml` (ADR-075); the output is committed, so a fresh
clone builds without running it. **Read the `project.pbxproj` diff after every run** — 0.14.4 writes
`AppIcon` into `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS`, which takes `YES` or
`NO`; the setting it means is `ASSETCATALOG_COMPILER_APPICON_NAME`, already correct beside it.

`json_serializable` is not listed: the only JSON is one Open-Meteo response, decoded by hand in one
file. `drift_flutter` pulls `sqlite3_flutter_libs 0.6.0+eol` transitively; the marker is upstream's,
that package relating to `package:sqlite3` 2.x and being obsolete now 3.x ships the native library
itself. The consequence is good — `NativeDatabase.memory()` opens in `flutter test` on the host with
no setup and no downloaded binary, which is what lets every repository test run against real SQLite.

## Assets

```
assets/fonts/
├── Newsreader/            Newsreader-VF.ttf         opsz 6–72, wght 200–800
│                          Newsreader-Italic-VF.ttf  opsz 6–72, wght 200–800
├── HankenGrotesk/         HankenGrotesk-VF.ttf      wght 100–900
└── NotoSerifDevanagari/   NotoSerifDevanagari-VF.ttf            ← चित्त only

assets/icon/
├── icon.png               1024²  the icon as drawn, opaque, square corners
└── icon_foreground.png    1024²  the glyph alone, transparent — Android's adaptive layer
```

**Neither is bundled into the app.** They are sources for `flutter_launcher_icons`, which is why
they are not under `flutter: assets:`; the icon the phone draws is the generated set under
`android/app/src/main/res/` and `ios/Runner/Assets.xcassets/`.

Bundled rather than fetched (ADR-009) and **variable** rather than static cuts (ADR-015): the design
uses Newsreader at 300–600 and Hanken Grotesk at 400/500/600, and relies on Newsreader's `opsz` axis
to make a 26px date and 16.5px body text both look right. **Consequence for the code: a variable
font renders at weight 400 unless a `TextStyle` sets `fontVariations`. `fontWeight` alone does
nothing**, and `chit_type.dart` is the only file that may set either. All three are SIL Open Font
License with `OFL.txt` beside each; the bundle is ~1.8 MB, of which Noto Serif Devanagari is 758 KB
to draw one word — subset before shipping.

## Considered and not taken

**`isar` / `hive`** — the calendar's per-day counts, the month summary and the weather-search
backlog item are aggregate queries SQL answers in the database and a document store answers in Dart.
**`google_fonts`** — a network fetch on first run, in an app whose premise is that it opens instantly
and works offline. **`firebase_*` / `supabase_flutter`** — out of scope for v1 (ADR-004). **`dio`** —
`http` is enough for one endpoint. **`flutter_hooks`** — Riverpod's notifiers cover the state here,
and mixing two idioms for local widget state makes the codebase harder to read than either alone.
**`permission_handler`** — `record` asks for the microphone and `geolocator` for location, each with
the flow their plugin already handles; a third library would be a second source of truth for two
permissions.

**Any speech engine at all.** `speech_to_text` **was** here and came out with the feature (ADR-058);
a cloud engine was refused before that on privacy grounds and still is. Reopening either is a
product decision, not a package one.

**`flutter_activity_recognition` / `sensors_plus`** — ADR-037 took neither. `sensors_plus` gives raw
accelerometer and gyroscope, and **neither measures speed**: recovering it from acceleration needs a
double integration whose error compounds uselessly within seconds. `flutter_activity_recognition`
wraps the platform classifiers, which do work — at the price of a **second runtime permission** on
both platforms, a Play Services dependency, a stream-only API with no one-shot query, and no flying
class regardless. `geolocator` already returns the speed on a fix chit was taking anyway.

**`custom_lint`** — not a dependency, and **cannot become one**. `riverpod_lint` 3.x is built on
`analysis_server_plugin` and enabled through `plugins:`, and the two cannot coexist:
`riverpod_generator` needs `analyzer >=13` while the newest `custom_lint` is pinned to `analyzer ^8`,
so version solving fails outright with both present — discovered while resolving, not chosen. The
gain is that `flutter analyze` surfaces the Riverpod lints directly, with **no separate lint step**.
It cost one thing: ADR-012's ban on `DateTime.now()` had no host for a lint rule, so it is a test
that walks `lib/` instead.

## Platform configuration this implies

**Android** — `RECORD_AUDIO`, `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` (precise first,
coarse as the fallback — ADR-016), `INTERNET`; `minSdk = 24`, `record_android`'s floor and the
highest of any plugin here. **iOS** — `NSMicrophoneUsageDescription` and
`NSLocationWhenInUseUsageDescription`, written in Chitta's own voice and the only copy in the app the
design never sees; `IPHONEOS_DEPLOYMENT_TARGET` is 15.0, above every plugin's floor. Both location
strings should say what §3.6 says the app does: it records that a place was there, and never shows
which one. The microphone string says the thing that is unusual, true and most likely to earn the
permission — that the recording stays on the phone.
