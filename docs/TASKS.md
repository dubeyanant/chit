# Tasks — the current milestone, broken down

**M6 — The chit editor.** What [BUILD-PLAN.md](BUILD-PLAN.md) M6 says is *done*, cut into groups
that can each be built, tested and committed on their own.

This file holds **one milestone at a time** and is replaced wholesale when the next one starts.
It is the working list; [PROGRESS.md](PROGRESS.md) is the handover.

**Cut on 18 September 2026**, and the cut is wider than BUILD-PLAN.md M6 as written. Three
things the owner asked for that the plan did not have: **a chit's recording can be removed and
replaced**, which reverses ADR-014's second half; **a chit can be deleted**, which closes open
item 9; and **Today's Discard goes**, replaced by a `Remove` on the audio pill. The first group
below is that last one, on Today, before the editor exists at all.

**Deliberately not in M6:** `@person` and `#hashtag` — the owner wants them and they are
OPEN-QUESTIONS.md §9 item 8, not this milestone. What M6 owes them is only that it does not box
them in; D12 says how. Also not here: authored motion on the editor's entry and exit (M7), and a
settings screen (open item 22).

---

## The decisions it turns on

| | Decision | Where |
|---|---|---|
| **D1** | **Today's Discard goes entirely, and the audio pill gains `Remove`.** Text is cleared by select-all-delete; a kept take is dropped from the pill. Discard's one remaining job was the take, and the pill is where the take is | ADR-060, group A |
| **D2** | **Tapping a chit row opens the editor**, and the thread offers nothing else — no long-press, no swipe. The whole row is the target, on Today and in the archive, in one change | ADR-017, ADR-062 |
| **D3** | **The editor covers the tab shell.** A route above it, not inside a branch: one task with one way out, so a tab change cannot strand a half-typed edit | ADR-011, ADR-062 |
| **D4** | **The stamp cannot move.** `createdAt`, `localDay`, `weather`, `lat`, `lon` and `motion` are not parameters of anything the editor can call. `updatedAt` moves on any edit, text or audio | ADR-014 |
| **D5** | **A chit's recording can be removed and replaced** — reverses ADR-014's second half, which said audio was neither editable nor removable anywhere. The pill's `Remove` is one control on both screens | ADR-061 |
| **D6** | **Removing a recording in the editor is staged until Save**, and it cannot be otherwise: a row with neither words nor audio is one the check constraint refuses. It is also what makes Cancel honest | README §5, DATA-MODEL.md §2 |
| **D7** | **Save appears only once something has changed**, and is withheld when the chit holds nothing — a removal that empties the chit leaves Cancel and Delete alone. Today's rule, on Today's own terms: a control arrives when there is something for it to do, and a retired one leaves rather than greys out | BEHAVIOUR.md §4.1 |
| **D8** | **Three acts, three words.** *Discard* is gone; *Cancel* abandons an edit; *Delete this chit* destroys a record, named in full so it cannot be misread | ADR-063, CLAUDE.md §4.1 |
| **D9** | **The prompt is a slip-style sheet, and it is the app's first confirmation.** No `showDialog` and no `SnackBar` exist anywhere yet, so whatever this is becomes the idiom every later prompt inherits | ADR-011, ADR-063 |
| **D10** | **Delete confirms and there is no undo.** There is no trash and no backend, so an undo would be a whole feature pretending to be a nicety | ADR-063 |
| **D11** | **The controller decides; the widget draws.** Whether to prompt, whether Save shows, whether the chit is still legal — all controller state, because ADR-031 means none of it can be tested through a screen | ADR-031 |
| **D12** | **Nothing here boxes in `@person` and `#hashtag`.** A row that is a button can still carry tappable spans — a `TapGestureRecognizer` on a `TextSpan` wins the gesture arena against an ancestor — so `ChitRow`'s `Text` becomes a `Text.rich` later without restructuring. Nothing goes in the schema now | OPEN-QUESTIONS.md §9 |

---

## A. Today's Discard goes; the pill gains `Remove` ✅

*Before the editor exists. It is a change to the composer, and it is what makes the pill's
`Remove` one control rather than two that look alike.*

- [x] `ComposerController.discard()` deleted. `removeTake()` in its place: stops the player,
      deletes the temp file through `discardTemp`, clears the take, and re-arms the five seconds
      if the chit is now empty.
- [x] `microphoneRefused` was cleared by Discard and now has no clearer. It clears on `save()`
      — `_openChit()` already returns a fresh state — and on the next `recordingStarted()`.
- [x] `AudioPill` gains an optional `onRemove`. Absent on a chit in the thread and in the
      archive, present on the open chit and in the editor. `QuietButton`'s weight.
- [x] `_CommitControls` becomes Save alone; `_ActionRow` is the microphone and Save.
- [x] Tests: `composer_controller_test.dart` for `removeTake` — the take goes, the file is
      deleted, the microphone comes back, the prompt re-arms on an emptied chit, and the chit's
      text is untouched.
- [x] Docs: BEHAVIOUR.md §3.1, §3.2, §3.4 and §4.1's sketch; DESIGN-SYSTEM.md §6.3 where the
      pace table names Discard; ARCHITECTURE.md §4; **ADR-060**; README.md §10 if a file moves;
      PROGRESS.md.

## B. The affordance and the route ✅

*The editor as a place you can get to and read. No editing yet.*

- [x] `ChitRow` becomes a button: pointer, focus stop, button semantics, and the tap. On Today
      **and** in the archive, in this change — one widget, so both screens gain it together.
      This is what M2 and M4 have been holding back.
- [x] The comment D12 asks for, at the `Text` that becomes a `Text.rich`.
- [x] `ChitRoute` gains the editor: a route **above** the shell (D3), taking a chit id.
- [x] `editor_screen.dart` — back arrow and the chit's day in Today's one-line treatment, then
      the slip: the saved stamp, the text, the pill. Read-only.
- [x] `editor_controller.dart` — loads the chit through `ChitRepository.byId`, which has existed
      since M1 for this. A missing id lands back where it came from rather than drawing nothing.
- [x] Tests: the controller through a bare `ProviderContainer` — loads, and the missing-id case.
- [x] `shared/day_label.dart` — *Today* / *Yesterday* / *Friday 11 September* moved off
      `ArchiveDay` so the editor's header and the archive's headings are one function.
- [x] `ChitColors.rowPressedWash`, and the stamp lifting to `--ink-muted` under it. **The
      contrast test decided this rather than checking it**: `--ink-faint` measures 4.42:1 on the
      wash and fails §6.4's floor (ADR-061).

## C. Editing the text

- [ ] `EditorController` gains the field and **dirty tracking**: dirty is *differs from what was
      loaded*, not *was typed in*, so typing a character and deleting it again is not a change.
- [ ] `ChitRepository.updateText` becomes **`update`**, one transactional write taking the text
      and a sealed `AudioEdit` — `Keep` (the default), `Remove`, `Replace`. Its guarantee was
      that an edit could not touch audio, and D5 has taken that away; what replaces it is one
      write, exhaustively switched, with the invariant asserted in one place. `updatedAt` moves;
      nothing else does (D4).
- [ ] Save, in `PrimaryButton`'s weight, appearing only once dirty (D7).
- [ ] Tests: the controller's dirty rule; `chit_repository_test.dart` for `update` against
      `NativeDatabase.memory()` — the text changes, `updatedAt` moves, `createdAt`, `localDay`
      and the three ambient fields do not, and a blank text is refused.

## D. The prompt sheet

- [ ] `shared/widgets/prompt_sheet.dart` — the app's first confirmation (D9). Rises like the
      recording sheet: perforated top edge, `ChitSpace.sheetRadius`, the existing `--scrim`. A
      question, and two answers in the two button weights. **It decides nothing** (D11).
- [ ] *Keep this edit?* → Keep · Discard, raised by Cancel, the back arrow and the system back
      gesture alike. With nothing changed, all three just leave.
- [ ] `Cancel` beside Save, arriving with it (D7, D8).
- [ ] Tests: the controller's `shouldPromptOnLeave`, and that answering *discard* leaves the row
      exactly as it was.

## E. The voice in the editor

- [ ] `Remove` on the editor's pill — **staged** (D6). The row is not written until Save, and
      Cancel takes it back.
- [ ] The microphone returns to the editor's action row whenever the chit holds no recording,
      reusing the recording sheet unchanged. A new take is staged the same way.
- [ ] Save withheld when a removal leaves the chit holding nothing; Cancel and *Delete this
      chit* are what is left (D7).
- [ ] `AudioEdit.Remove` and `.Replace` wired through `update`: the row stops pointing at the
      old file and ADR-008's existing sweep collects it, so `AudioStore` stays the single owner
      of a recording's lifetime.
- [ ] A playing recording is stopped before its file stops being the row's — `stopIf`, as
      `save()` already does.
- [ ] Tests: the controller's legality rule; the repository's remove and replace paths; that a
      chit with no text and no take cannot be written.

## F. Delete this chit

- [ ] `ChitRepository.delete(id)` — the row and the file together (open item 9).
- [ ] *Delete this chit* below the slip, in `QuietButton`'s weight and apart from the action
      row: distance from Save is the first defence, and the prompt is the second.
- [ ] *Delete this chit?*, and *"The recording goes with it."* on a chit that has one →
      Delete · Keep it. No undo (D10).
- [ ] Deleting lands back where the editor was opened from.
- [ ] Tests: the row goes, the file goes, the thread and the calendar re-emit without it.

## G. Handset pass and sign-off

*What no test can settle. Seed first — `flutter run --dart-define=CHIT_SEED=seed`, `=clear`
after. There is no migration now (ADR-059), but M6 changes no schema, so nobody has to
uninstall.*

- [ ] A chit opened from Today, corrected, saved — and it has not moved in the thread, on the
      strip, or on the calendar.
- [ ] The same from the archive, landing back in the archive with its filter intact.
- [ ] Leaving with changes: the prompt, both answers, and the back gesture as well as Cancel.
- [ ] A recording removed on the **open chit** — the microphone comes back, the take is gone.
- [ ] A recording removed in the **editor** and cancelled: it is still there and still plays.
- [ ] A recording replaced, saved, and played back.
- [ ] A recording-only chit: remove the take, and Save is not offered.
- [ ] A chit deleted, recording and all.
- [ ] Reduced motion on: the prompt sheet arrives without a rise.
- [ ] Read BUILD-PLAN.md M5's four lessons before writing a fake. Two of M5's four handset bugs
      were a fake or its harness behaving better than the real thing.

**This file is replaced when M7 starts** (CLAUDE.md §2).
