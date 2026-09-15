# Working on chit

Read this first. It is loaded into every Claude Code session automatically.

---

## 0. The standing rule — every change closes the loop

**No change is finished until the documents that describe it are true again.**

This is not a suggestion and it is not a final tidy-up pass. It applies to every commit,
every session, and every change however small. A session that leaves the docs behind has
left the next session with a lie, and the next session has no way to know which half to
trust.

So, as part of the same change — never as a follow-up:

| If the change… | Then update |
|---|---|
| finishes, starts, or alters a milestone | `docs/PROGRESS.md` — always. This one is never optional |
| adds, removes or repins a package | `docs/PACKAGES.md` |
| decides something that could reasonably have gone another way | `docs/DECISIONS.md` — a new ADR, never an edit to a settled one |
| changes how the app is put together | `docs/ARCHITECTURE.md` |
| changes the schema, an invariant or a query | `docs/DATA-MODEL.md` |
| changes what the app *does* | `docs/BEHAVIOUR.md` — §3, and §4 if a screen changed |
| changes how it looks — a token, a face, a pace, a floor | `docs/DESIGN-SYSTEM.md` — §6 |
| changes what chit *is*, or the shape of a chit | `README.md` — §1, §2, §5 |
| adds a file, a document or an ADR | `README.md` §10, the map. There is a test for it |
| changes why the design is what it is | `docs/DESIGN-LOG.md` |
| changes the order of work or what "done" means | `docs/BUILD-PLAN.md` |
| changes how to work in this repo | this file |

**Contradicting a document is a change to it.** If the code has to depart from what a doc
says, the doc gets corrected in the same change, with a line saying what it used to say and
why it moved. Silently diverging is the one thing that is never acceptable.

**`docs/PROGRESS.md` is the handover.** It is the single place that answers "where are we and
what is next". Update it at the end of every working session even when nothing else moved —
including when the session ended mid-milestone, in which case say exactly where it stopped.

### The checklist to run before saying a piece of work is done

1. `flutter analyze` is clean.
2. `flutter test` passes.
3. Every table above whose left column matches was acted on.
4. **If a number, a name or a path changed, `grep` for the old one.** A figure corrected only
   where the test pointed is a figure still wrong in three other files — that has happened
   here once already, with `--seal`'s contrast ratio. The rule is only as good as the search.
5. `docs/PROGRESS.md` reflects reality — the milestone state, what was just finished, what is
   next, and any new open question.
6. The change and its doc updates are in the same commit.

---

## 1. What this project is

A private journal for short entries — "chits" — written or spoken several times a day.
Flutter, Android and iOS only. Offline-first, no backend, nothing leaves the device.

**The design authority is three files:** `README.md` (the product model, §1–§2, and the data
model, §5), `docs/BEHAVIOUR.md` (§3–§4) and `docs/DESIGN-SYSTEM.md` (§6–§7). Where any other
document disagrees with those three, they win — and the disagreement is a bug in the other
document, to be fixed rather than worked around.

## 2. The documents, and what each is for

| File | Answers |
|---|---|
| `docs/PROGRESS.md` | **where we are right now, and what to do next** — start here |
| `README.md` | what chit is (§1–§2), what a chit is (§5), and **§10 maps every file in the repository** |
| `docs/BEHAVIOUR.md` | **§3–§4** — the behaviour specification and the screens |
| `docs/DESIGN-SYSTEM.md` | **§6–§7** — palette, type, spacing, motion, the accessibility floors, the prototype |
| `docs/BUILD-PLAN.md` | the order it gets built in and what "done" means per milestone |
| `docs/ARCHITECTURE.md` | how it is put together — layers, folders, providers, data flow |
| `docs/DECISIONS.md` | the ADRs — why each choice was made and what it was chosen over. Indexed at its head |
| `docs/DATA-MODEL.md` | schema, invariants, queries |
| `docs/PACKAGES.md` | every dependency and why it is there |
| `docs/DESIGN-LOG.md` | why the design is what it is |
| `docs/OPEN-QUESTIONS.md` | **§8–§9** — what is not settled, and the feature backlog |
| `design/chit-app-v5.html` | the interactive prototype — the visual target. Open in a browser |

`design/chit-app-v4.html` is superseded and is history, not a second option.

**Section numbers are global and stable.** §1 to §10 are numbered once across `README.md`,
`BEHAVIOUR.md`, `DESIGN-SYSTEM.md` and `OPEN-QUESTIONS.md`; a section keeps its number wherever
it lives, so §6.1 means the same thing cited from anywhere. `README.md` §0 has the table of
which file owns which number. Never renumber — roughly two hundred citations in the docs and
the source depend on them.

## 3. Starting a session

1. Read `docs/PROGRESS.md`. It names the current milestone and the next task.
2. Read the milestone's section in `docs/BUILD-PLAN.md` for what "done" means.
3. Read the parts of `README.md` that section points at.
4. Do the work. Close the loop per §0.

**`README.md` §0 says the same thing**, for anyone who arrives at the README first — a human,
or an agent that does not load this file automatically. The two are deliberately redundant, so
changing the reading order means changing both.

## 4. How the code is written

### 4.1 The engineering principles, and what each one means *here*

These are not decoration. Each line below says what the principle actually forbids in this
codebase, because a principle nobody can fail is a principle nobody is following.

**SOLID.**

- **Single responsibility.** A class has one reason to change. The four theme extensions are
  four classes rather than one `ChitTheme` bag precisely because colour, type, spacing and
  motion change for different reasons. A controller that both formats a date and writes a row
  is two classes.
- **Open/closed.** Extend by adding a type, not by adding a branch to a `switch` that already
  exists. A new `WeatherCondition` should light up as a missing case at compile time — so
  switches over sealed types and enums are **exhaustive, with no `default:`**. A `default:` is
  how a new variant ships silently wrong.
- **Liskov.** A fake used in a test must be honest. `FakeSpeechRecognizer` that "fails" must
  fail the way the real one does — the §3.5 path is only tested if the substitute cannot lie.
- **Interface segregation.** `context.colors`, `context.type`, `context.space` and
  `context.motion` are four accessors, not one `context.theme` returning everything. A widget
  that needs a colour should not be able to reach motion.
- **Dependency inversion.** `features` depends on interfaces in `domain`; `data` supplies the
  implementations; Riverpod wires them at the root. This is the layer rule below, and it is the
  same principle.

**And the rest, in the same spirit.**

- **Composition over inheritance.** Widgets compose. `extends` a concrete class of ours is
  almost always the wrong answer; a `Widget` field or a builder callback is the right one.
- **Immutability by default.** `final class`, `const` constructors, `final` fields. Models are
  `freezed`. If a thing can be `const`, it is.
- **Make illegal states unrepresentable.** The `Chit` invariant (text or audio, never neither)
  is enforced by a private constructor with an assert *and* a database check constraint, not by
  a comment and good intentions. Prefer a type that cannot be wrong to a validation that runs.
- **YAGNI, and it outranks the rest.** Do not add an abstraction for a second implementation
  that does not exist. The interfaces in `domain` earn their place because tests are the second
  implementation. Nothing else gets an interface on speculation.
- **DRY, but only for knowledge.** Two lines that look alike but change for different reasons
  are not duplication. Extract a rule, never a coincidence.
- **Fail loudly in development, degrade quietly in production.** `assert` for what must never
  happen; a null and an undrawn element for a signal that did not arrive (ADR-007).
- **Name things as the README names them.** A chit is a `Chit`. The blank one at the top of
  Today is the *open chit*, not a draft, not an entry, not a note. The vocabulary in the README
  is the vocabulary in the code, and a synonym is a bug in the making.

### 4.2 The specific rules

- **The layer rule.** `features` never imports `data`. Widgets watch controllers; controllers
  depend on interfaces in `domain`; Riverpod supplies implementations at the root.
  See `docs/ARCHITECTURE.md` §1.
- **Never call `DateTime.now()`.** Inject `Clock` (ADR-012). There is a lint for it.
- **Never write a bare `TextStyle`, colour, duration or padding.** They come from the four
  theme extensions in `lib/core/theme/`. A literal in a widget is a design-system leak.
- **Fonts are variable fonts** (see ADR-015). Weight and optical size are applied through
  `TextStyle.fontVariations`, *not* `fontWeight` alone — a variable font declared once renders
  at 400 whatever `fontWeight` says. Every style in `chit_type.dart` sets both: `fontWeight`
  for fallback and semantics, `fontVariations` for what is actually drawn. This is exactly why
  the rule above exists.
- **Riverpod is generated.** `@riverpod`, `part 'x.g.dart'`, `dart run build_runner watch`.
- **Tests override at the root** with an in-memory Drift database and hand-written fakes.
  No mocking framework.
- The prototype is the visual reference. When in doubt about a pixel, open it.

## 5. Commits

**[Conventional Commits](https://www.conventionalcommits.org).** `type(scope): subject`, the
subject in the imperative mood and lowercase, no trailing full stop.

| Type | Used here for |
|---|---|
| `feat` | behaviour a user of the app can see |
| `fix` | a defect in behaviour that already shipped |
| `refactor` | changes shape, not behaviour |
| `perf` | faster, same behaviour |
| `test` | tests only |
| `docs` | documentation only — including a docs-only milestone update |
| `build` | dependencies, Gradle, Xcode, fonts, platform config, codegen setup |
| `chore` | anything that fits nowhere above. Rare; prefer a real type |
| `style` | formatting only. Rarer still — `dart format` runs before every commit |

Scope is the milestone (`m0b`) or the area (`theme`, `composer`, `calendar`, `db`). Omit it
when the change is genuinely global.

**The body says why, not what** — the diff already says what. Mention the ADR when the change
turns on one, and record what was verified.

**The docs go in the same commit as the code that made them untrue** (§0). A commit whose body
says "docs to follow" is a commit that should not have been made.

History before `a367e0a` was rewritten once, on 14 September 2026, to bring the first four
commits to this format. The originals are tagged `pre-conventional-commits`.

## 6. Commands

```bash
flutter pub get
dart run build_runner watch      # while working
flutter analyze
flutter test
flutter run                      # Android device or emulator
```

When `AppDatabase.schemaVersion` changes, and only then:

```bash
dart run drift_dev schema dump lib/data/db/app_database.dart drift_schemas/
dart run drift_dev schema generate drift_schemas/ test/data/db/generated/
```

The first commits the shape that shipped, the second writes what
`test/data/db/migration_test.dart` reads. A version with no snapshot fails that test, because a
migration with nothing to migrate *from* is not a migration — `docs/DATA-MODEL.md` §6.

Windows note: `flutter pub get` warns unless **Developer Mode** is enabled — plugin builds
need symlink support. `start ms-settings:developers`.
