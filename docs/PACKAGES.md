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
(ADR-004). **Nothing is stored outside the database** — `shared_preferences` held the first-run flags
until ADR-094 deleted the screen that needed them, and `main()` now awaits nothing before the first
frame.

**Development.** `build_runner` · `riverpod_generator` · `riverpod_lint`, enabled through `plugins:`
rather than `custom_lint` (below) · `drift_dev` · `freezed` · `flutter_lints` ·
`just_audio_platform_interface`, **only for `just_audio_player_test.dart`**, which stands a fake
platform under the real plugin (ADR-067); already transitive, listed so the test may import it ·
`flutter_launcher_icons`, **run by hand and never at build time** — `dart run flutter_launcher_icons`
rewrites the Android mipmaps, the iOS appiconset and the web icons from the two files in
`assets/icon/` and the config block in `pubspec.yaml` (ADR-075); the output is committed, so a fresh
clone builds without running it. **Read the `project.pbxproj` diff after every run** — 0.14.4 writes
`AppIcon` into `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS`, which takes `YES` or
`NO`; the setting it means is `ASSETCATALOG_COMPILER_APPICON_NAME`, already correct beside it. **It
does not touch the splash** — `drawable/ic_splash_glyph.xml` is written by hand from the same export
(ADR-090), so a redrawn glyph needs the rerun *and* that file.

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

assets/geo/
└── outline.bin            1.1 MB  the outlines behind find's first screen — ADR-089
```

**`outline.bin` is generated, and committed like the codegen is.** It is Natural Earth 10m —
urban areas, coastline, lakes and river centrelines — simplified, quantised to milli-degrees and cut
into a 2° grid by [`tool/pack_outlines.mjs`](../tool/pack_outlines.mjs), which documents the
`mapshaper` invocation that feeds it. **Natural Earth is public domain**, which is why nothing is
credited on screen and why it was taken over OSM, whose ODbL would put a permanent line on a surface
that has no room for one. The script needs Node and a download; the committed binary is what stops a
fresh clone needing either. `lib/data/geo/outline_atlas.dart` documents the byte format and is the
only thing that reads it.

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

**`isar` / `hive`** — past's per-day counts, the month summary and the weather-search
backlog item are aggregate queries SQL answers in the database and a document store answers in Dart.
**`google_fonts`** — a network fetch on first run, in an app whose premise is that it opens instantly
and works offline. **`firebase_*` / `supabase_flutter`** — out of scope for v1 (ADR-004). **`dio`** —
`http` is enough for one endpoint. **`flutter_hooks`** — Riverpod's notifiers cover the state here,
and mixing two idioms for local widget state makes the codebase harder to read than either alone.
**`permission_handler`** — `record` asks for the microphone and `geolocator` for location, each with
the flow their plugin already handles; a third library would be a second source of truth for two
permissions.

## Platform configuration this implies

**Android** — `RECORD_AUDIO`, `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` (precise first,
coarse as the fallback — ADR-016), `INTERNET`; `minSdk = 24`, `record_android`'s floor and the
highest of any plugin here. **iOS** — `NSMicrophoneUsageDescription` and
`NSLocationWhenInUseUsageDescription`, written in Chitta's own voice and the only copy in the app the
design never sees; `IPHONEOS_DEPLOYMENT_TARGET` is 15.0, above every plugin's floor. Both location
strings should say what §3.6 says the app does: it records that a place was there, and never shows
which one. The microphone string says the thing that is unusual, true and most likely to earn the
permission — that the recording stays on the phone.

## Shipping a release

**The keystore is the owner's and is never committed** (ADR-098). Without `android/key.properties` a
release build still runs — signed with the **debug** key, and it says so on every build. Such an APK
installs and can then never be updated, the signature not matching any properly signed build, so the
line is worth reading.

```bash
keytool -genkeypair -v -keystore ~/chitta-release.jks -storetype PKCS12 \
  -keyalg RSA -keysize 2048 -validity 10000 -alias chitta
```

Then `android/key.properties`, which `android/.gitignore` already covers:

```properties
storePassword=…
keyPassword=…
keyAlias=chitta
storeFile=C:/absolute/path/to/chitta-release.jks
```

**Back up four things, somewhere that is not this machine**: the `.jks` file, the store password,
the key password and the alias. `key.properties` is not one of them — it is a pointer, rewritten in
a minute from the other four, and it holds secrets so it stays out of git.

**What losing them costs depends on how the app was delivered**, and the two answers are not alike:

| | Who signs what users install | If the key is lost |
|---|---|---|
| **A download** (GitHub, sideload) | this keystore, directly | **nothing can ever update it.** A new key is a new app — it installs beside the old one and opens empty (ADR-074) |
| **Play** | Google, with the *app signing key* it holds; this keystore is only the **upload key** that proves the upload is yours | **recoverable** — Google registers a new upload key on request. The app signing key is Google's copy and cannot be lost |

**Play App Signing is not optional** for an app first published now, so the keystore there is an
upload key whatever else it is.

**The trap is shipping both ways.** An APK downloaded from GitHub is signed by *this* key; an APK
from Play is signed by whatever key Play holds. If Play generates its own, the two signatures differ
and **nobody who installed from a download can update from Play** — Android refuses, and the way
through is uninstall-and-lose-the-chits. To keep one lineage, **upload this keystore as the app
signing key when enrolling** rather than letting Play generate one. That choice is made once, at
enrolment, and is not revisitable afterwards.

**`versionCode` has to rise for every Play upload.** It comes from the `+n` in `pubspec.yaml`'s
`version:` — `1.0.0+1` is versionCode 1 — and Play rejects a build that reuses one.

```bash
flutter build apk --release --split-per-abi   # three APKs, ~20 MB each
flutter build appbundle --release             # for Play, which re-signs and splits per device
```

**`--split-per-abi` is what a direct download wants**: the universal APK carries arm64, armeabi-v7a
and x86_64 at once and is three times the size for no gain on a phone. **Verify what was signed
before it goes anywhere**: `apksigner verify --print-certs <apk>` prints the certificate, and a
debug-signed build says `CN=Android Debug`.
