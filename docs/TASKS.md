# Tasks — the current milestone, broken down

**M5 — Voice.** What [BUILD-PLAN.md](BUILD-PLAN.md) M5 says is *done*, cut into groups that
can each be built, tested and committed on their own.

This file holds **one milestone at a time** and is replaced wholesale when the next one starts.
It is the working list; [PROGRESS.md](PROGRESS.md) is the handover.

**Cut on 17 September 2026**, the day M4 was signed off. The order is deliberate: the two
platform seams come first (A, B), the milestone's logic is pulled out of the widget and tested
bare (C) before anything is drawn (D, E, F), and the last group takes a build to a handset with
the one thing no test can settle — whether two plugins can share one microphone (D1).

Much of the ground is laid. The three packages have been pinned since M0a, `ComposerState` has
carried `audioTempPath`, `audioDuration`, `isRecording` and `sttFailed` since M2, `Chit`
enforces the audio invariants, `AudioStore` moves a temp file into place on Save, and the
microphone has sat inert on the composer since M2. M5 is what happens when it is pressed.

**Deliberately not in M5:** opening a past chit and its pill in the editor (M6), the pill's
rise into the open chit and every other authored motion (M7), re-transcription (§8.2), and a
settings screen from which a refused microphone could be reconsidered.

---

## The decisions it turns on

| | Decision | Where |
|---|---|---|
| **D1** | **Two plugins, one microphone.** `record` writes the file and `speech_to_text` listens, at the same time, because the recogniser takes no file and no stream. Whether Android lets a second capture run beside the recognition service is a fact about the platform, not the code — **it is the first thing group G checks, before anything else about voice is believed** | open item 32 |
| **D2** | **Permission is asked at the first tap, never at first run.** A refusal does not open the sheet; the microphone explains once and stays available | BEHAVIOUR.md §4.4, ARCHITECTURE.md §6 |
| **D3** | **A take's length is the clock's, start to stop, and never read from the file.** The file is not opened until playback | ADR-052 |
| **D4** | **The recorder reports a level from 0 to 1, not decibels.** The waveform draws a number; the scale it came off is the data layer's | ADR-052 |
| **D5** | **Three failures, one branch** — and since group B, *every* failure. Heard nothing, on-device refused, no model, anything else the platform reports: all `sttFailed`, all keep the audio | ADR-005, ADR-053, ARCHITECTURE.md §4.4 |
| **D6** | **The pending transcript lives in the sheet's controller, not in `text`.** The field is written once, at Stop & keep, and never by the recogniser again | ARCHITECTURE.md §4.4, BEHAVIOUR.md §3.4.1 |
| **D7** | **The record dot and the waveform are `ChitMotion.loop`'s first callers.** The dot's period is 1.2s and belongs to the dot; under reduced motion both draw at rest | ADR-027, DESIGN-SYSTEM.md §6.3 |

---

## A. Capture — the recorder over `record` ✅

*A press on the microphone can produce a file. Nothing on screen yet.*

- [x] `domain/services/audio_recorder.dart` — the `AudioRecorder` interface: `requestPermission`,
      `start`, `levels`, `stop`, `cancel`; `Recording`, a temp path and a length that cannot be
      set apart; `audioRecorderProvider`, unimplemented in `domain` and overridden at the root.
- [x] `data/audio/record_audio_recorder.dart` — over `record`. Mono AAC in an `.m4a`, the
      extension `AudioStore` keeps. Never throws: a refusal, a plugin failure and an empty take
      are `false` or `null`. Duration by the clock (D3); levels normalised (D4).
- [x] `main.dart` supplies it beside the location service.
- [x] `test/data/record_audio_recorder_test.dart` — the level arithmetic and the take's path.

## B. Recognition — the recogniser over `speech_to_text` ✅

*Speech becomes words on the device. Nothing sent anywhere.*

- [x] `domain/services/speech_recognizer.dart` — the `SpeechRecognizer` interface: `start`
      returning a stream of partials, each carrying the committed words and the word still
      pending (the lighter-ink word of §3.4), and `stop`. A result that never arrives is the
      §3.5 branch, not an error.
- [x] `data/speech/on_device_speech_recognizer.dart` — `SpeechListenOptions(onDevice: true)` at
      the one call site (ADR-005). Initialised once, lazily. An `initialize` that returns
      `false` and **every** error end the stream with nothing — D5. *The four error codes this
      list named are not in the code: Android marks every error permanent and stops listening
      as it reports one, so the table would have described one platform's vocabulary and
      changed nothing. ADR-053.*
- [x] `main.dart` supplies it.
- [x] `test/data/on_device_speech_recognizer_test.dart` — the partial split, and nothing that
      needs the plugin. There is no error table left to walk.

## C. The composer's voice flow — the logic, bare

*Every rule in §3.4 and §3.5 has a passing test before a widget exists — ADR-031 doing its
work.*

- [ ] `features/composer/application/recording_controller.dart` — the sheet's state: elapsed
      time off the clock, the levels, the pending transcript (D6), and whether recognition has
      given up. `start()` asks permission then starts both services; `stopAndKeep()` stops both
      and hands `ComposerController` a `Recording` and a transcript or nothing; `cancel()`.
- [ ] `ComposerController.keepRecording(Recording, String? transcript)` — appends the transcript
      to the field with a space where the field already has words, sets `textOrigin` to
      `transcript` on an empty field and `transcriptEdited` on one that had text; an empty or
      absent transcript sets `sttFailed` and leaves the field alone; `audioTempPath` and
      `audioDuration` are set together. The prompt is cancelled either way — the note occupies
      its space (BEHAVIOUR.md §3.5).
- [ ] The one-way slide: `edit` on `transcript` moves it to `transcriptEdited`; emptying the
      field clears the origin as it does now; typing again after that is `typed`.
- [ ] `discard` deletes the temp file through the recorder's store. `sttFailed` clears with it.
- [ ] `microphoneRefused` — set once when permission is refused, so the composer can say so
      beside the microphone (D2); cleared by Discard.
- [ ] `test/support/fake_audio_recorder.dart` and `fake_speech_recognizer.dart` — hand-written,
      and each refuses what the real one refuses: no permission, a take that wrote nothing, a
      recogniser with no model. Their honesty is what makes the §3.5 tests mean anything.
- [ ] `test/features/composer/recording_controller_test.dart`, and the voice cases added to
      `composer_controller_test.dart`: transcript into an empty field, transcript after typed
      text, the slide on the first keystroke, all three failures landing on `sttFailed` with the
      audio kept, a chit saved with audio and no text reloading with its pill, Discard removing
      the temp file.

## D. The recording sheet

*The recording experience, drawn. v6 is the reference.*

- [ ] `features/composer/presentation/recording_sheet.dart` — a modal sheet, not a route
      (ADR-011), raised by the microphone. The perforated top edge (`PerforatedEdge`), corners
      at `ChitSpace.sheetRadius`, elapsed time in tabular figures, `LISTENING` in the one
      uppercase (DESIGN-SYSTEM.md §6.2), the transcript with the pending word in lighter ink,
      and one control: **Stop & keep**, at Save's weight.
- [ ] The record dot in `--seal` (ADR-022), breathing on `ChitMotion.loop` at its own 1.2s (D7).
- [ ] The live waveform off `levels`, also on `loop`; at rest under reduced motion.
- [ ] The microphone's tap: `requestPermission` then `start`; a `false` from either leaves the
      sheet closed and sets `microphoneRefused`.
- [ ] Dismissing the sheet by drag or back is `cancel` — nothing kept, nothing written.

## E. The audio pill and playback

*Open item 31 closes: a recording with no words reads as a recording.*

- [ ] `shared/widgets/audio_pill.dart` — ink at rest, 3.5% wash, duration in `--ink-muted`
      (§6.4's floor); the seal only while playing (ADR-022); the 0.99 press depress.
- [ ] `domain/services/audio_player.dart` and `data/audio/just_audio_player.dart` — one player
      provider so two pills never play at once; play, pause, the position for the playhead.
- [ ] The pill on a chit in the thread and in the archive, and on the open chit once a take is
      kept. A pill whose file has vanished is absent, not broken (ARCHITECTURE.md §6).
- [ ] A test for the player's state around play, pause and end, through a fake.

## F. The settled microphone and the failure note

*Every state of the composer is drawn, and nothing on it is a control that does nothing.*

- [ ] The microphone leaves the action row once a take is kept (BEHAVIOUR.md §4.1) — the pill
      is where the recording now is.
- [ ] The note *"Speech wasn't recognised. Your recording is kept."* beside the body when
      `sttFailed`, in the prompt's place and never in the field.
- [ ] The line beside the microphone when `microphoneRefused`, once (D2).

## G. Handset pass and sign-off

*What no test can settle.*

- [ ] **D1 first.** Record while recognising on Android and play the take back. If the file is
      silence, stop and write the finding into PROGRESS.md before touching anything else: the
      fallback is a decision, not a fix.
- [ ] Item 18 against a real `Position`, since a walk is being taken anyway.
- [ ] A typed chit recorded into, keeping both. A recording corrected before Save. A saved
      recording replaying after a restart.
- [ ] **The failure path on a phone with no on-device language model** — BUILD-PLAN.md M5 names
      it the case most likely to reach a real user in India first. Then the other two routes.
- [ ] A refused microphone: the sheet stays closed, the line shows once, the microphone stays.
- [ ] Reduced motion on: the dot and the waveform at rest.
- [ ] Seed, look at the 23:55 row of 15 September with its pill, clear.
- [ ] Sign off in PROGRESS.md and BUILD-PLAN.md; close items 17 and 31; replace this file when
      M6 starts.
