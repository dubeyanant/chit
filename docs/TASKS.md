# Tasks — the current milestone, broken down

**M5 — Voice.** What [BUILD-PLAN.md](BUILD-PLAN.md) M5 says is *done*, cut into groups that
can each be built, tested and committed on their own.

This file holds **one milestone at a time** and is replaced wholesale when the next one starts.
It is the working list; [PROGRESS.md](PROGRESS.md) is the handover.

**Cut on 17 September 2026** in seven groups, and **rewritten on 18 September** when
transcription was removed (ADR-058). Groups B and C were half about a recogniser, D and F about
a transcript and its failure note; the record of what they built is in git and in the ADRs. What
is left below is the milestone as it actually stands.

**Deliberately not in M5:** opening a past chit and its pill in the editor (M6), the pill's rise
into the open chit and every other authored motion (M7), and a settings screen from which a
refused microphone could be reconsidered (open item 22).

---

## The decisions it turns on

| | Decision | Where |
|---|---|---|
| **D1** | ~~Two plugins, one microphone.~~ **Moot** — there is one plugin. Whether Android would let `record` capture beside the recognition service was the milestone's biggest open risk, and removing transcription removed the question | ADR-058, item 32 |
| **D2** | **Permission is asked at the first tap, never at first run.** A refusal does not open the sheet; the microphone explains once and stays available | BEHAVIOUR.md §3.2, ARCHITECTURE.md §6 |
| **D3** | **A take's length is the clock's, start to stop, and never read from the file.** The file is not opened until playback | ADR-052 |
| **D4** | **The recorder reports a level from 0 to 1, not decibels.** The waveform draws a number; the scale it came off is the data layer's | ADR-052 |
| **D5** | ~~Three failures, one branch.~~ **Moot with the recogniser** | ADR-058 |
| **D6** | ~~The pending transcript lives in the sheet's controller.~~ **Moot** — the sheet holds elapsed time and levels, and Stop & keep never touches the field | ADR-058 |
| **D7** | **The record dot is `ChitMotion.loop`'s only caller.** Its period is 1.2s and belongs to the dot; under reduced motion it draws at rest. **The waveform is not a loop** — it is levels | ADR-027, ADR-054, DESIGN-SYSTEM.md §6.3 |
| **D8** | **A take is not scoped to the sheet.** It begins on the tap, before the sheet exists, and finishes after it has gone — so the controller is `keepAlive` | ADR-057 |

---

## A. Capture — the recorder over `record` ✅

*A press on the microphone produces a file.*

- [x] `domain/services/audio_recorder.dart` — the `AudioRecorder` interface: `requestPermission`,
      `start`, `levels`, `stop`, `cancel`; `Recording`, a temp path and a length that cannot be
      set apart. Never throws.
- [x] `data/audio/record_audio_recorder.dart` — mono AAC in an `.m4a`. Duration by the clock
      (D3); levels normalised (D4).
- [x] `main.dart` supplies it; `test/data/record_audio_recorder_test.dart` covers the arithmetic.

## B. Recognition — **removed** ✅

*Built, shipped to a handset, recognised nothing, and deleted — ADR-058.*

`speech_to_text`, `SpeechRecognizer`, `OnDeviceSpeechRecognizer`, their tests and fake, the
Android `<queries>` intent and the iOS speech permission are all gone. Git holds them.

## C. The composer's voice flow ✅

- [x] `features/composer/application/recording_controller.dart` — elapsed time off the clock and
      the last twenty levels (ADR-054). `start()` asks permission then records; `stopAndKeep()`
      hands the take to `ComposerController`; `cancel()` throws it away. **`keepAlive`** (D8).
- [x] `ComposerController.keepRecording(Recording?)` — attaches the take and **leaves the field
      alone**. A take that wrote nothing closes the sheet and changes nothing.
- [x] `discard` deletes the temp file through `ChitRepository.discardTemp` — `features` cannot
      reach `AudioStore` (ADR-054).
- [x] `microphoneRefused` — set when permission is withheld (D2); cleared by Discard.
- [x] `test/support/fake_audio_recorder.dart`, and the tests in
      `recording_controller_test.dart` and `composer_controller_test.dart`.

## D. The recording sheet ✅

- [x] `features/composer/presentation/recording_sheet.dart` — a modal, not a route (ADR-011).
      The perforated top edge, corners at `ChitSpace.sheetRadius`, elapsed time in tabular
      figures, `LISTENING` in the one uppercase, and **two** controls: Discard and Stop & keep
      (ADR-055). A `--scrim` token came with it.
- [x] The record dot in `--seal` (ADR-022), breathing on `ChitMotion.loop` at 1.2s (D7) —
      closes open item 17.
- [x] The live waveform, **drawn from real levels** and at v6's fixed heights under reduced
      motion (ADR-054).
- [x] The microphone's tap: `requestPermission` then `start`; a `false` from either leaves the
      sheet closed and sets `microphoneRefused`.
- [x] Dismissing by drag, scrim, back **or Discard** is `cancel` — one path (ADR-055).
- [x] The microphone retires once a take is kept.

## E. The audio pill and playback ✅

- [x] `shared/widgets/audio_pill.dart` — ink at rest, 3.5% wash, duration in `--ink-muted`; the
      seal only while playing (ADR-022).
- [x] `domain/services/audio_player.dart` and `data/audio/just_audio_player.dart` — one player
      so two pills never sound at once. **The stream replays its current state to every new
      listener**, and `stopIf` lets the composer silence a take whose file is about to move.
- [x] The pill on a chit in the thread and in the archive, and on the open chit once a take is
      kept.
- [x] `test/features/composer/audio_pill_test.dart` and `live_wave_test.dart`.

## F. The refused microphone ✅

- [x] The line *"The microphone isn't allowed. You can turn it on in your phone's settings."*
      under the action row, said once and naming the OS (ADR-056).
- [x] *The §3.5 failure note was built here and removed with transcription.*

## G. Handset pass and sign-off ✅

*What no test can settle. Three passes; four bugs found and fixed.*

- [x] A chit recorded on a handset, and played back.
- [x] A seeded recording played from the calendar.
- [x] **A recording that survives a restart** — saved, app killed, reopened, played.
- [x] A typed chit recorded into, keeping both.
- [x] A refused microphone: the sheet stays closed, the line shows, the microphone stays.
- [x] **The wave answers a voice** — item 34 closed. The -60 dBFS floor was arithmetic nobody
      had measured against a real microphone, and it reads as loudness.
- [x] Reduced motion on: the dot at rest, the wave at v6's fixed heights.
- [x] **Signed off 18 September 2026.** BUILD-PLAN.md M5 carries what it taught.

Not done here, and neither blocks M5:

- Item 18 against a real `Position` — an M3 question riding along on a walk that has not
  happened. It is about motion, not voice.
- Item 37 on iOS, if there is ever an iOS build: the seeded tone is a WAV in an `.m4a`.

**This file is replaced when M6 starts** (CLAUDE.md §2). Until then it is the record of a
finished milestone.
