# Working on Chitta

Read this first. It is loaded into every Claude Code session automatically.

## 0. The standing rule — every change closes the loop

**No change is finished until the documents that describe it are true again.** Not a final tidy-up
pass: a session that leaves the docs behind leaves the next one with a lie, and no way to know which
half to trust. So, as part of the same change:

| If the change… | Then update |
|---|---|
| adds, removes or repins a package | `docs/PACKAGES.md` |
| decides something that could reasonably have gone another way | `docs/DECISIONS.md` — a new record, or edit the one it changes (§0.2) |
| changes how the app is put together | `docs/ARCHITECTURE.md` |
| changes the schema, an invariant or a query | `docs/DATA-MODEL.md` |
| changes what the app *does* | `docs/BEHAVIOUR.md` — §3, and §4 if a screen changed |
| changes how it looks — a token, a face, a pace, a floor | `docs/DESIGN-SYSTEM.md` §6 |
| changes what chit *is*, or the shape of a chit | `README.md` §1, §2, §5 |
| adds a file, a document or a decision | `README.md` §10, the map — by hand; §4.2 says why there is no test for it |
| breaks a constraint the design rests on | `docs/DESIGN-LOG.md` |
| settles, opens or closes something nobody has scheduled | `docs/OPEN-QUESTIONS.md` — its numbered items, which never get renumbered |
| changes how to work in this repo | this file |
| **orphans a file** | **delete it, in this commit** — §0.1 |

**Contradicting a document is a change to it.** If the code has to depart from what a doc says, the
doc gets corrected in the same change.

**There is no handover document, and that is deliberate.** What a session learns that a later one
must know goes in `docs/OPEN-QUESTIONS.md`, whose numbered items are stable and cited from the
source; what a session did goes in the commit body. Git is the history; the working tree is not.

### 0.1 Nothing unnecessary gets committed

**A file that has stopped earning its place is deleted in the same change that stopped it earning
it.** Every file is a claim that it is worth reading, and a superseded prototype or a support file
whose last caller is gone costs the next session time and context to rule out, on every session,
forever. **Git is the archive; the working tree is not** — superseded means deleted, not moved to
`old/`, not renamed `_v2`, not left with a comment saying it is dead.

This does **not** licence deleting something merely old or unfamiliar: "not earning its place" means
nothing points at it and nothing would, not "I did not need it today". Two things are deliberately
kept and say so where they live — `web/` (ADR-019), and the generated `*.g.dart` and
`*.freezed.dart` files, committed so a fresh clone runs without codegen. If a deletion is a
judgement call rather than an orphan, **say what was deleted and why in the commit body**.

### 0.2 A decision record is one row

`docs/DECISIONS.md` is a table, one row per decision: the number, what was decided, and then the
reason that actually mattered plus a cost only where a reader must not forget it. What it was chosen
over goes in that third column only when the alternative *is* the argument. **A change or a
supersession edits the row in place**, rewriting it to the current truth with a clause saying what it
used to say; git carries the before. One row can hold several related calls from the same session.
**Numbers are never reused**, roughly two hundred citations pointing into that file.

**A row is one or two lines, and so is every entry in the design documents.** Not one long line with
the same words packed tighter — **fewer words**. Records 001 to 073 are the length to write at; the
ones after them grew into essays, were cut back, and are what the rule exists to prevent. Say what
was decided and the one reason it turned on. The argument you had on the way there is not the
decision, the alternatives you rejected are not the decision, and neither belongs in the row: if a
fact is load-bearing somewhere else, it belongs in the document that owns it, and if it is load-
bearing nowhere, it goes.

### 0.3 Write it short

Every word in a doc or a comment is a word a future session pays to read before it can act. State
the fact and the reason it matters, once, and stop — no second example making the same point, no
aside that isn't load-bearing, and nothing restated in two documents. **Git holds the history, so a
document carries the current truth and not the story of how it got there**; keep a historical note
only where it stops a future session repeating a mistake.

### Before saying a piece of work is done

1. `flutter analyze` is clean, and `flutter test` passes.
2. Every table row in §0 whose left column matches was acted on.
3. Anything a later session must know that is not in the code went into `docs/OPEN-QUESTIONS.md`,
   and what was done is in the commit body.
4. **§0.1 was run: what this change orphaned is deleted, in this commit.**
5. The change, its doc updates and its deletions are all in the same commit.

## 1. What this project is

A private journal for short entries — "chits" — written or spoken several times a day. Flutter,
Android and iOS only. Offline-first, no backend, nothing leaves the device.

**The design authority is three files:** `README.md` (§1–§2, §5), `docs/BEHAVIOUR.md` (§3–§4) and
`docs/DESIGN-SYSTEM.md` (§6–§7). Where any other document disagrees they win, and the disagreement
is a bug in the other document. **Section numbers are global and stable** — §1 to §10 are numbered
once across those files and `OPEN-QUESTIONS.md` (§8–§9), and a section keeps its number wherever it
lives. `README.md` §0 has the table. Never renumber.

## 2. The documents

`README.md` §10 lists every document and what each answers — read that rather than a second copy of
the list here.

## 3. Starting a session

**v1 is finished and nothing is part-built** (ADR-073), so there is no next task waiting. A session
starts from whatever is being asked for: `README.md` §0 and §10, then `docs/OPEN-QUESTIONS.md`, then
whichever of §3–§4 (behaviour), §6 (design) or `ARCHITECTURE.md` the work touches and the records it
cites. Then do the work, and close the loop per §0.

## 4. How the code is written

### 4.1 The engineering principles, and what each one forbids *here*

**SOLID.** A class has one reason to change — the four theme extensions are four classes rather than
one bag because colour, type, spacing and motion change for different reasons, and a controller that
both formats a date and writes a row is two classes. Extend by adding a type, not a branch to an
existing `switch`: switches over sealed types and enums are **exhaustive, with no `default:`**,
which is how a new variant would ship silently wrong. **A fake must be honest** — it refuses the way
the real one refuses, and both times one lied here it cost a handset pass (ADR-057, ADR-067).
`context.colors`, `.type`, `.space` and `.motion` are four accessors rather than one returning
everything, so a widget that needs a colour cannot reach motion. And `features` depends on interfaces
in `domain` while `data` supplies the implementations, wired by Riverpod at the root.

**And the rest.** Composition over inheritance — `extends` on a concrete class of ours is almost
always wrong. **Immutability by default**: `final class`, `const` constructors, `freezed` models; if
a thing can be `const`, it is. **Make illegal states unrepresentable** — the `Chit` invariant is a
private constructor with an assert *and* a database check constraint, not a comment and good
intentions. **YAGNI outranks the rest**: no abstraction for a second implementation that does not
exist, the interfaces in `domain` earning their place because tests are the second implementation.
**DRY, but only for knowledge** — two lines that look alike but change for different reasons are not
duplication; extract a rule, never a coincidence. **Fail loudly in development, degrade quietly in
production**: `assert` for what must never happen, a null and an undrawn element for a signal that
did not arrive (ADR-007). **Name things as the README names them** — the app is **चित्त** on screen
and **Chitta** to the phone, one entry is a **chit**, a `Chit`, and the blank one at the top of Today
is the *open chit*, not a draft or a note; a synonym is a bug in the making. The Dart package and
both bundle ids are `chitta`; the `Chit` classes, the Drift file and the repo directory stay
`chit` (ADR-074).

### 4.2 The specific rules

- **The layer rule.** `features` never imports `data` (`docs/ARCHITECTURE.md` §1).
- **Never call `DateTime.now()`.** Inject `Clock` (ADR-012). There is a test for it.
- **Never write a bare `TextStyle`, colour, duration, padding or `HapticFeedback` call** — the first
  four come from the four theme extensions in `lib/core/theme/`, and the haptic from `ChitHaptics`
  (ADR-096). A literal in a widget is a design-system leak.
- **Every gap and padding comes off the 4px scale** — `s1`…`s8`, no one-off spacings. A *dimension*
  may sit off the scale when it is a property of one component and named where it is drawn; a *gap*
  may not, because a gap is a relationship and the scale exists to keep relationships consistent.
- **Fonts are variable fonts** (ADR-015): weight goes through `TextStyle.fontVariations`, *not*
  `fontWeight` alone, which a variable font silently ignores. Every style in `chit_type.dart` sets
  both.
- **Riverpod is generated.** `@riverpod`, `part 'x.g.dart'`, `dart run build_runner watch`.
- **go_router and Riverpod take every responsibility they can.** go_router owns all navigation, and
  Riverpod owns everything that outlives a build, the router included; before hand-rolling near
  either, check whether the package has the seam already. The two deliberate exceptions are modal
  sheets and not routes: ADR-011's recording sheet and ADR-064's prompt sheet.
- **No comments. Ever.** (ADR-095.) Nothing under `lib/` or `test/` carries a comment — not a `///`
  doc comment, not a `//` aside, not a `/* */` block. **The code says what it does and the documents
  say why**, and a comment is a third place for the reason to live, out of reach of every rule in §0
  that keeps the other two true. When a line needs explaining, either the name is wrong and you
  rename it, or the reason is a decision and it belongs in `docs/DECISIONS.md` with the citation
  going the other way — the record names the file. The generated `*.g.dart` and `*.freezed.dart`
  are exempt: they are not written here. A test fails if a comment reappears.
- **No widget tests. Ever.** (ADR-031.) Nothing under `test/` may call `testWidgets`, `pumpWidget`
  or `WidgetTester`, and no test may build a widget in order to look at it. **A claim that can only
  be checked by pumping a screen is checked on a device instead** — build it, look at it, and write
  what you saw into the commit body, and into `docs/OPEN-QUESTIONS.md` if a later session has to
  know it. A test fails if `testWidgets` reappears.
- **What is tested instead**: pure functions, models and their invariants, the repository and DAO
  against `NativeDatabase.memory()`, controllers through a bare `ProviderContainer`, and the
  design-system floors computed arithmetically. **Pull the logic out of the widget until it can be
  tested that way** — the rule constrains where behaviour lives, not just what `test/` contains.
- **Tests override at the root**, with hand-written fakes and no mocking framework.
- **No test cases for documents.** Keep README §10's map true by hand.

## 5. Commits

[Conventional Commits](https://www.conventionalcommits.org): `type(scope): subject`, the subject
imperative and lowercase, no trailing full stop. `feat` behaviour a user can see · `fix` a defect in
behaviour that already shipped · `refactor` shape, not behaviour · `perf` faster, same behaviour ·
`test` tests only · `docs` documentation only · `build` dependencies, Gradle, Xcode, fonts, platform
config, codegen · `chore` anything that fits nowhere above (rare) · `style` formatting only (rarer —
`dart format` runs first). Scope is the area (`theme`, `composer`, `past`, `db`), omitted when
the change is global.

**The body says why, not what** — the diff already says what. Mention the decision record when the
change turns on one, and record what was verified. **The docs go in the same commit as the code that
made them untrue** (§0); a commit whose body says "docs to follow" should not have been made.

## 6. Commands

```bash
flutter pub get
dart run build_runner watch      # while working
flutter analyze
flutter test
flutter run                      # Android device or emulator
flutter run --dart-define=CHIT_SEED=seed    # three months of chits — docs/DATA-MODEL.md §6
flutter run --dart-define=CHIT_SEED=stress  # 2,000 of them, for measuring
flutter run --dart-define=CHIT_SEED=clear   # and the same build with them taken off again
flutter run --profile --dart-define=CHIT_FRAMES=true   # frame times to the log
```

Both seed flags work in any build mode, are idempotent, and never touch a chit a person wrote; the
console is the only place they report.

**`flutter install` does not build** — it pushes whatever APK is already under
`build/app/outputs/flutter-apk/`, which may be hours old and from a different `--dart-define`. It
reports success either way, so a verification pass run on it can be a pass on code that was never
compiled. **To look at a change on a handset, `flutter build apk --release` first**, then
`adb install -r`, and check the APK's timestamp if there is any doubt.

**Do not drive the phone with `adb input`.** The handset is somebody's, the taps land in whatever
app is in front, and a screenshot pass can end up typing into it. Capture with
`adb exec-out screencap -p` and ask for the gestures.

**There are no migrations** (ADR-059). `schemaVersion` stays 1, changing a table changes the schema,
and an install carrying the old shape is **reinstalled**. That holds only while Chitta has no data
anybody would miss; `docs/DATA-MODEL.md` §5 says what comes back when it does.

Windows: `flutter pub get` warns unless **Developer Mode** is enabled — plugin builds need symlink
support. `start ms-settings:developers`.
