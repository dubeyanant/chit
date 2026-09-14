# Progress

**Where the build is, and what to do next.** This is the handover document: a session that
has read only this file and `CLAUDE.md` should be able to pick up the work.

Updated at the end of every working session, per the standing rule in
[CLAUDE.md](../CLAUDE.md) §0 — including sessions that ended mid-milestone.

**Last updated:** 14 September 2026, end of M0b.

---

## Status board

| Milestone | State | Notes |
|---|---|---|
| **M0a** — project stops being a scaffold | ✅ done | 14 Sep 2026 |
| **M0b** — the design system in code | ✅ done | 14 Sep 2026 |
| **M1** — the data spine | ⬜ next | |
| M2 — Today, text only | ⬜ | |
| M3 — ambient capture | ⬜ | |
| M4 — calendar | ⬜ | |
| M5 — voice | ⬜ | |
| M6 — the chit editor | ⬜ | README §8.1 settled 14 Sep 2026 (ADR-017) |
| M7 — motion and the floors | ⬜ | |

**43 tests, `flutter analyze` clean, debug APK builds.**

---

## What M0a did

- **Dependencies.** `pubspec.yaml` carries every package in [PACKAGES.md](PACKAGES.md), all
  resolving at their pinned versions. `custom_lint` was dropped — ADR-018.
- **The scaffold is gone.** `lib/main.dart` is `runApp(ProviderScope(child: ChitApp()))`.
- **Platforms.** `windows/`, `linux/` and `macos/` deleted; `.metadata` trimmed. `web/` kept
  — ADR-019.
- **Fonts.** The three families of README §6.2 in `assets/fonts/` as **variable** fonts with
  their OFL licences — ADR-015, which corrected what PACKAGES.md used to say.
- **Android.** `minSdk` 24 (`record_android`'s floor). `RECORD_AUDIO`, `ACCESS_FINE_LOCATION`,
  `ACCESS_COARSE_LOCATION`, `INTERNET`, and the `android.speech.RecognitionService` queries
  intent `speech_to_text` needs from targetSdk 30.
- **iOS.** The three usage strings in `Info.plist`, in chit's voice. Deployment target 15.0,
  already above every plugin's floor.
- **Package name.** `com.infiniteants.chit` in all five places it lives.
- **Gradle.** `kotlin.incremental=false` — every plugin's `compileDebugKotlin` failed with
  *"Could not close incremental caches"* on this Windows setup, reproducibly. Costs rebuild
  time and nothing else.

---

## What M0b did

- **The skeleton.** Every file in [ARCHITECTURE.md](ARCHITECTURE.md) §2 exists. The ones a
  milestone has not reached hold a doc comment naming that milestone and nothing else.
- **The four theme extensions** in `lib/core/theme/`:
  - `ChitColors` — the ten tokens of README §6.1, plus `sealWash` for flattening the audio
    pill's translucent surface so it can actually be checked.
  - `ChitType` — twenty-five styles, the whole scale. Every one sets `fontVariations`.
  - `ChitSpace` — the 4px scale under the prototype's own `s1`…`s8` names, so porting a rule
    out of the CSS is a rename rather than a translation.
  - `ChitMotion` — the pace table as a `ChitPace` enum with `travel()` and `fade()`.
- **`context.colors` / `.type` / `.space` / `.motion`** in `lib/core/extensions.dart`. Four
  accessors, not one, so a widget that needs a colour cannot reach motion. `.motion` resolves
  the reduced-motion flag from `MediaQuery`, which is what makes README §6.4 one decision.
- **`Clock`** in `lib/core/clock.dart` with `clockProvider`, and a test that fails if anything
  else in `lib/` calls `DateTime.now()`.
- **`analysis_options.yaml`** tightened: strict casts, inference and raw types; exhaustive
  switches and unawaited futures as errors; immutability and documentation rules;
  `riverpod_lint` through `plugins:`.
- **The masthead.** "chit चित्त" on `--paper`, baseline-aligned, in the page gutter.
- **Three test suites**, 43 tests: the contrast floor of README §6.4 composited, the
  `fontVariations` rule of ADR-015, and the reduced-motion rule of §6.4.

### Two things M0b changed elsewhere

1. **README §6.1's contrast figures were slightly wrong** and are now measured. `--ink-muted`
   is 6.49:1 on the ground (was quoted as 6.4), `--ink-faint` 5.08:1 (was 5.0), and `--seal`
   is 4.23:1 on a chit (was 4.24). The test asserts the corrected values to ±0.01, so the
   prose and the arithmetic cannot drift apart again.
2. **ADR-020.** Under reduced motion the old rule stretched press feedback from 90ms to 140ms
   — slower, for the users who asked for less animation. The re-timing is now a ceiling, not
   an assignment. Found by a test asserting a *property* ("no fade is slower than it was")
   rather than a value; worth copying when M7 writes the remaining floors.

**Verified:** `flutter analyze` clean, `flutter test` 43 passing, `dart format` clean,
`dart run build_runner build` clean, `flutter build apk --debug`.

**Not verified:** how the type actually renders on a handset. The masthead is on screen but
nobody has looked at Newsreader and Noto Serif Devanagari at real size on a real display. Do
that before M2 starts drawing with the scale — see open item 1.

---

## Next: M1 — the data spine

No UI. Full statement of done in [BUILD-PLAN.md](BUILD-PLAN.md) M1; the schema and its
invariants are in [DATA-MODEL.md](DATA-MODEL.md). In order:

1. `domain/models/` — `Chit` (freezed, private constructor, the one-of assert),
   `AmbientStamp`, `WeatherCondition`, `TextOrigin`, `DaySummary`.
2. `data/db/tables/chits_table.dart` — the columns, the check constraints, the indexes.
3. `data/db/app_database.dart` — the Drift database, and the migration harness with the v1
   schema snapshot taken *before* there is anything to migrate.
4. `data/db/daos/chit_dao.dart` — the queries.
5. `domain/repositories/chit_repository.dart` — the interface. Both `save()` and
   `updateText()` (ADR-014); the update path exists from the start.
6. `data/repositories/chit_repository_impl.dart`.
7. `data/audio/audio_store.dart` — temp → permanent, delete, the orphan sweep. No recorder
   yet; tests write dummy files.
8. Repository tests against an in-memory database: every illegal row shape rejected, all four
   legal ones round-tripping, `localDay` correct across a midnight and across a timezone
   change (the `Clock` from M0b is what makes this testable), audio moved on save and deleted
   on discard, and `updateText` provably touching nothing but `text`, `textOrigin` and
   `updatedAt`.

Check open item 3 before starting — `sqlite3_flutter_libs` resolves to an `+eol` release.

---

## Open items

Things a future session needs to know but that are not yet scheduled work.

1. **Nobody has looked at the type on a handset.** The masthead renders, but the optical-size
   mapping is a judgement call that has never been checked against the prototype side by side:
   `ChitType._opticalSizeFor` converts logical pixels to points at 0.75, which is what the CSS
   spec says a browser does with `font-optical-sizing: auto`. If Newsreader looks heavier or
   lighter than `design/chit-app-v5.html` at the same size, that constant is the first suspect.
   Worth settling in M2, when there is real text to compare.
2. **README §6.1 has no token for two colours the design uses.** The calendar's near-white
   numeral on a strong fill (`#FFF6EE`, README §4.2) and the label on a filled Save button
   (`#1A1310` in the prototype). Neither is in the §6.1 table. M2 hits the second and M4 the
   first; whichever gets there first should add the token to README §6.1 and to the contrast
   test rather than inlining a hex.
3. **`sqlite3_flutter_libs` resolves to `0.6.0+eol`,** pulled in by `drift_flutter 0.3.1`. The
   marker is upstream's. Check for a successor at the top of M1, since that is when it starts
   mattering.
4. **`speech_to_text` applies the Kotlin Gradle Plugin,** and the build warns that future
   Flutter versions will fail on plugins that do. Harmless on 3.47.4. Check before any Flutter
   upgrade, since ADR-005 makes that package hard to swap.
5. **Developer Mode on Windows.** `flutter pub get` warns that plugin builds need symlink
   support. Not currently blocking — the APK builds. If a build fails in a way
   `kotlin.incremental=false` does not explain, check this: `start ms-settings:developers`.
6. **Font bundle is ~1.8 MB,** of which Noto Serif Devanagari is 758 KB to draw one word.
   PACKAGES.md suggests subsetting before shipping; this is the file that makes it worth doing.
7. **`public_member_api_docs` is on.** It is valuable in `domain`, `data` and `core`, and it
   is noise on a zero-argument widget constructor. If M2 finds it a real tax, the answer is a
   nested `analysis_options.yaml` under `lib/features/` rather than turning it off everywhere
   — and either way it is a change that gets recorded.
8. **README §8.2 (re-transcription) and §8.3 (does Today carry enough rhythm) are still open.**
   Neither blocks anything before M7.
