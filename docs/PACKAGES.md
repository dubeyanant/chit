# Packages

Every dependency, what it is for, and what it was chosen over. Nothing goes in `pubspec.yaml`
without a line here.

Versions marked ✓ were checked on pub.dev on **14 September 2026**. The rest are left for
`flutter pub add` to resolve — pin them here once it does.

---

## Runtime

| Package | Version | For |
|---|---|---|
| `flutter_riverpod` | ✓ `^3.4.3` | state and dependency injection (ADR-001) |
| `riverpod_annotation` | matches riverpod | the `@riverpod` annotation |
| `drift` | ✓ `^2.35.0` | local database (ADR-003) |
| `drift_flutter` | ✓ `^0.3.1` | opens the database with no async bootstrap; pulls `sqlite3_flutter_libs` |
| `go_router` | ✓ `^18.0.1` | the tab shell and routing (ADR-011) |
| `freezed_annotation` | matches freezed | immutable models: value equality, `copyWith`, and a private constructor that can assert its invariant |
| `record` | ✓ `^7.1.1` | recording to a temp file |
| `just_audio` | ✓ `^0.10.6` | playback behind the audio pill |
| `speech_to_text` | ✓ `^7.4.0` | on-device transcription (ADR-005) |
| `geolocator` | ✓ `^14.0.3` | a coarse fix for the pin; also owns the location permission flow |
| `http` | resolve | one call, to Open-Meteo |
| `intl` | resolve | dates and the tabular-figure formats of README §6.2 |
| `path_provider` | resolve | the app documents directory for the audio store |
| `path` | resolve | joining those paths without string concatenation |
| `uuid` | resolve | client-generated ids (ADR-004) |

## Development

| Package | Version | For |
|---|---|---|
| `build_runner` | resolve | runs all codegen |
| `riverpod_generator` | ✓ `^4.0.9` | generates the providers |
| `riverpod_lint` | matches riverpod | catches the misuse codegen cannot |
| `custom_lint` | resolve | the host `riverpod_lint` plugs into |
| `drift_dev` | matches drift | generates the DAOs and the schema |
| `freezed` | ✓ `^4.0.1` | generates the models |
| `flutter_lints` | already present `^6.0.0` | base lint set |

`json_serializable` is not listed. The only JSON in the app is one Open-Meteo response, decoded
by hand in one file; a codegen dependency for that is not worth the build time. Add it if a
second endpoint appears.

### On `speech_to_text` and offline recognition

ADR-005 requires that nothing leaves the device. The package supports this through
`SpeechListenOptions(onDevice: true)` — its own documentation is unambiguous: *"if true the
listen attempts to recognize locally with speech never leaving the device. If it cannot do this
the listen attempt will fail."*

Failing is the behaviour we want; silently falling back to a server is not. So:

- Pass `onDevice: true` on **every** listen call, with no fallback path that omits it. There
  should be exactly one call site.
- A failed listen is not a special case — it resolves to README §3.5 along with "heard nothing"
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

The three faces of README §6.2 ship as files, not through `google_fonts` (ADR-009). Only the
weights actually used:

```
assets/fonts/
├── Newsreader/            regular, italic, medium
├── HankenGrotesk/         regular, medium
└── NotoSerifDevanagari/   regular        ← the चित्त mark only
```

All three are SIL Open Font License. Subset before shipping if the bundle matters.

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

**`flutter_hooks`** — Riverpod's notifiers cover the state in this app, and mixing two idioms
for local widget state makes the codebase harder to read than either alone.

**`shared_preferences`** — nothing to store yet. The settings screen in README §4.1's sketch
has no defined contents; when it gets some, this is the likely answer.

---

## Platform configuration this implies

Worth doing in one pass rather than discovering one plugin at a time.

**Android** (`android/app/src/main/AndroidManifest.xml`)
`RECORD_AUDIO`, `ACCESS_COARSE_LOCATION`, `INTERNET`. `minSdk` rises to whatever `record` and
`speech_to_text` require — check both before setting it.

**iOS** (`ios/Runner/Info.plist`)
`NSMicrophoneUsageDescription`, `NSSpeechRecognitionUsageDescription`,
`NSLocationWhenInUseUsageDescription`. Write the strings in chit's own voice; they are the only
copy in the app the design never sees.

Both location strings should say what the README says the app does with it: it records that a
place was there, and never shows which one. The speech string can say something no other app's
can — that recognition happens on the phone and the recording is not sent anywhere. It is true,
it is unusual, and it is the sentence most likely to earn the permission.
