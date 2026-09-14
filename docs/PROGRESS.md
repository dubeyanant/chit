# Progress

**Where the build is, and what to do next.** This is the handover document: a session that
has read only this file and `CLAUDE.md` should be able to pick up the work.

Updated at the end of every working session, per the standing rule in
[CLAUDE.md](../CLAUDE.md) §0 — including sessions that ended mid-milestone.

**Last updated:** 14 September 2026, end of M0a — verified on a handset, package name set.

---

## Status board

| Milestone | State | Notes |
|---|---|---|
| **M0a** — project stops being a scaffold | ✅ done | 14 Sep 2026 |
| **M0b** — the design system in code | ⬜ next | |
| M1 — the data spine | ⬜ | |
| M2 — Today, text only | ⬜ | |
| M3 — ambient capture | ⬜ | |
| M4 — calendar | ⬜ | |
| M5 — voice | ⬜ | |
| M6 — the chit editor | ⬜ | new; README §8.1 was settled 14 Sep 2026 (ADR-017) |
| M7 — motion and the floors | ⬜ | was M6 |

---

## What M0a actually did

- **Dependencies.** `pubspec.yaml` now carries every package in [PACKAGES.md](PACKAGES.md).
  All resolve at the pinned versions. `custom_lint` was dropped — see ADR-018.
- **The scaffold is gone.** `lib/main.dart` is `runApp(ProviderScope(child: ChitApp()))`;
  `lib/app/chit_app.dart` is a bare `--paper` surface that M0b replaces. The counter test
  was deleted.
- **Platforms.** `windows/`, `linux/` and `macos/` deleted; `.metadata` trimmed to root,
  android, ios, web. `web/` is kept — README §10 plans responsive web after v1 (ADR-019).
- **Fonts.** The three families of README §6.2 are in `assets/fonts/` as **variable** fonts
  with their OFL licences, and declared in `pubspec.yaml`. See ADR-015 — this changed what
  PACKAGES.md said, because the prototype uses weights PACKAGES.md had not listed.
- **Android.** `minSdk` 24 (`record_android`'s floor, the highest of any plugin).
  `RECORD_AUDIO`, `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `INTERNET`, plus the
  `android.speech.RecognitionService` queries intent that `speech_to_text` needs from
  targetSdk 30.
- **iOS.** Microphone, speech-recognition and when-in-use location strings in `Info.plist`,
  written in chit's voice. Deployment target was already 15.0, above every plugin's floor —
  unchanged.
- **Package name.** `com.example.chit` → **`com.infiniteants.chit`**, everywhere: the Android
  `namespace` and `applicationId`, the Kotlin package declaration and the directory holding
  `MainActivity.kt`, and all six `PRODUCT_BUNDLE_IDENTIFIER` entries in the Xcode project
  (`RunnerTests` included). Done during M0a rather than left as debt, because it is the app's
  identity and every day it stays wrong is a day something else is built on top of it.
- **Gradle.** `kotlin.incremental=false` added to `android/gradle.properties`. Every plugin's
  `compileDebugKotlin` task failed with *"Could not close incremental caches in
  …\caches-jvm\jvm\kotlin"* — a Windows file-locking problem, reproducible across a
  `flutter clean`. Turning incremental Kotlin compilation off fixes it and costs rebuild time
  and nothing else. Revisit if the build ever moves off Windows.
- **Docs.** `CLAUDE.md` created (the standing rule); this file created; ADR-015 to ADR-019
  added; README, ARCHITECTURE, DATA-MODEL, DESIGN-LOG, PACKAGES and BUILD-PLAN all updated to
  match.

**Verified:** `flutter pub get`, `flutter analyze` (clean), `dart run build_runner build`
(clean), `flutter build apk --debug`, and **the debug build installed and launched on a real
Android handset over wireless debugging.** It shows an empty `--paper` screen, which is all
`ChitApp` draws until M0b step 10. Every M0a criterion is met.

Worth writing down because it will be asked again: **an empty near-black screen is the correct
output of M0a.** `--paper` is `#191714` and reads as black on a phone. A crash would show a red
error screen instead. The wordmark is the first thing that makes the screen self-evidently
alive, and it lands at the end of M0b.

---

## Next: M0b — the design system in code

Full statement of done in [BUILD-PLAN.md](BUILD-PLAN.md) M0. In order:

1. The folder skeleton of [ARCHITECTURE.md](ARCHITECTURE.md) §2, empty files in place.
2. `core/theme/chit_colors.dart` — the eleven README §6.1 tokens as a `ThemeExtension`.
3. `core/theme/chit_type.dart` — the three faces and the scale. **Every style sets
   `fontVariations`**, not `fontWeight` alone (ADR-015). Tabular figures on anything that
   counts or keeps time.
4. `core/theme/chit_space.dart` — the 4px scale, 2px radius (14px for the recording sheet's
   top corners), the 26px gutter.
5. `core/theme/chit_motion.dart` — 220ms `cubic-bezier(.2,0,0,1)`, the README §6.3 pace
   table, and `travel()` vs `fade()` so `prefers-reduced-motion` is one decision made once.
6. `core/theme/chit_theme.dart` assembling `ThemeData`; `core/extensions.dart` for the
   `context.colors` / `context.type` sugar.
7. `core/clock.dart` (ADR-012) and the lint that fails a raw `DateTime.now()`.
8. `analysis_options.yaml` tightened; `riverpod_lint` enabled through the `plugins:` key
   (ADR-018), and `flutter analyze` clean with it on.
9. **The contrast test** — every token pair from README §6.4, composited, ≥4.5:1, as a real
   test in `test/`.
10. First real paint: empty `--paper` screen, "chit" set in Newsreader, चित्त in Noto Serif
    Devanagari.

---

## Open items

Things a future session needs to know but that are not yet scheduled work.

1. **Developer Mode on Windows.** `flutter pub get` warns that plugin builds need symlink
   support. The debug APK built anyway, so it is not currently blocking — but if a build fails
   on Windows in a way the Kotlin fix above does not explain, this is the next thing to check:
   `start ms-settings:developers`.
2. **`speech_to_text` applies the Kotlin Gradle Plugin,** and the build warns that *"future
   versions of Flutter will fail to build if your app uses plugins that apply KGP."* Harmless
   today on Flutter 3.47.4. It becomes real at some future SDK bump, and the answer will be a
   `speech_to_text` release that has migrated to Built-in Kotlin — worth checking before any
   Flutter upgrade, since ADR-005 makes that package hard to swap.
3. **`sqlite3_flutter_libs` resolves to `0.6.0+eol`,** pulled in by `drift_flutter 0.3.1`.
   The `+eol` marker is upstream's. It works; check for a successor when M1 starts.
4. **Font bundle is ~1.8 MB,** of which Noto Serif Devanagari is 758 KB for the single
   चित्त mark. PACKAGES.md already suggests subsetting before shipping; this is the file
   that makes it worth doing.
5. **README §8.2 (re-transcription) and §8.3 (does Today carry enough rhythm) are still
   open.** Neither blocks anything before M7.
