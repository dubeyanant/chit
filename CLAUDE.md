# Working on chit

Read this first. It is loaded into every Claude Code session automatically.

---

## 0. The standing rule — every change closes the loop

**No change is finished until the documents that describe it are true again.**

This is not a suggestion and it is not a final tidy-up pass. It applies to 
every session. A session that leaves the docs behind has
left the next session with a lie, and the next session has no way to know which half to
trust.

So, as part of the same change — never as a follow-up:

| If the change… | Then update |
|---|---|
| finishes, starts, or alters a milestone | `docs/PROGRESS.md` — always. This one is never optional |
| adds, removes or repins a package | `docs/PACKAGES.md` |
| decides something that could reasonably have gone another way | `docs/DECISIONS.md` — a new ADR, edit a previous ADR if it is changed or superseded, and short (§0.2) |
| changes how the app is put together | `docs/ARCHITECTURE.md` |
| changes the schema, an invariant or a query | `docs/DATA-MODEL.md` |
| changes what the app *does* | `docs/BEHAVIOUR.md` — §3, and §4 if a screen changed |
| changes how it looks — a token, a face, a pace, a floor | `docs/DESIGN-SYSTEM.md` — §6 |
| changes what chit *is*, or the shape of a chit | `README.md` — §1, §2, §5 |
| adds a file, a document or an ADR | `README.md` §10, the map — by hand; §4.2 says why there is no test for it |
| changes why the design is what it is | `docs/DESIGN-LOG.md` |
| changes the order of work or what "done" means | `docs/BUILD-PLAN.md` |
| changes how to work in this repo | this file |
| **orphans a file** — a support file, an asset, a prototype, a fixture | **delete it, in this commit.** §0.1 below |

**Contradicting a document is a change to it.** If the code has to depart from what a doc
says, the doc gets corrected in the same change.

**`docs/PROGRESS.md` is the handover.** It is the single place that answers "where are we and
what is next". Update it at the end of every working session even when nothing else moved —
including when the session ended mid-milestone, in which case say exactly where it stopped.

### 0.1 The second standing rule — nothing unnecessary gets committed

**A file that has stopped earning its place is deleted in the same change that stopped it
earning it.** This is the other half of §0 and it is not a housekeeping pass somebody schedules
later: a repository is read by whoever arrives next, and every file in it is a claim that it is
worth reading. A superseded prototype, a scratch script, an ADR, a support file whose last caller is
gone, a doc nobody has cited in three milestones — each one costs the next session time and
context to rule out, and the cost is paid on every session, forever, by everyone.

**Git is the archive. The working tree is not.** Don't even "keep it just in case." Superseded means deleted, not moved to `old/`, not renamed with a
`_v2`, and not left in place with a comment saying it is dead.

**Before every commit, ask what this change has orphaned**, and delete it in the same commit:

- Code
- The asset, fixture, snapshot or prototype
- Anything written to the repository that was only ever scaffolding for the work itself
- Docs

What this rule does **not** licence: deleting something because it is merely old, unfamiliar or
understood by somebody else. "Not earning its place" means nothing points at it and nothing
would — not "I did not need it today". Two things earn their place by being deliberately kept
and say so where they live: `web/` (ADR-019) and the generated `*.g.dart` and `*.freezed.dart`
files, which are committed so a fresh clone runs without codegen.

If a deletion is a judgement call rather than an orphan, it is a decision — **say what was
deleted and why in the commit body**, which is where §5 says the reasoning goes.

### 0.2 An ADR is one paragraph

An ADR is **five to ten lines, shorter where possible, in a single paragraph** — no headed
Decision / Over / Why / Costs sections. State what was decided, what it was chosen over, the
reason or two that actually mattered, and a cost only when a reader must not forget it. On
17 September 2026 this went further and, once, went backward in time: ADR-001 through ADR-050
were rewritten to this form in the same change, the one exception to §0.3's going-forward-only
rule, because the old five-section essay had become the largest single cost to a working
session's context. Nothing any record *decided* changed — only the argument's texture did, and
git holds the fuller version at the commit before.

- **A change or a supersession still edits the ADR it affects, in place** — rewrite the
  paragraph to the current truth and add a clause saying what it used to say. Git carries the
  before; the file only has to carry the after. A wholly new decision still gets a new record,
  indexed at the head of the file the same way as ever.
- **One ADR can hold several related calls from the same session** — decide by whether a future
  citation would ever want one without the others.

### 0.3 Write it short

Every word in a doc or a comment is a word a future session pays to read before it can act.
State the fact and the reason it matters, once, and stop — no second example making the same
point, no aside that isn't load-bearing. Shorter is better whenever it loses nothing a reader
needs; a paragraph earns its length, it is not owed one. Applies wherever prose appears — every
file under `docs/`, `README.md`, this file, and every comment in `lib/` and `test/` — and, like
§0.2, to what gets written from here. Existing prose is not rewritten to meet it on its own —
ADRs are the one exception, §0.2 — since §0.1 already said rewriting settled text for its own
sake is not the job.

### The checklist to run before saying a piece of work is done

1. `flutter analyze` is clean.
2. `flutter test` passes.
3. Every table above whose left column matches was acted on.
4. `docs/PROGRESS.md` reflects reality — the milestone state, what was just finished, what is
   next, and any new open question.
5. **§0.1 was run: what this change orphaned is deleted, in this commit.**
6. The change, its doc updates and its deletions are all in the same commit.

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
| `docs/TASKS.md` | **the current milestone, cut into buildable groups** — read it before writing code. One milestone at a time, replaced when the next starts |
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
| `design/chit-app-v6.html` | the interactive prototype — the visual target. Open in a browser |

v6 is the only prototype.

**Section numbers are global and stable.** §1 to §10 are numbered once across `README.md`,
`BEHAVIOUR.md`, `DESIGN-SYSTEM.md` and `OPEN-QUESTIONS.md`; a section keeps its number wherever
it lives, so §6.1 means the same thing cited from anywhere. `README.md` §0 has the table of
which file owns which number. Never renumber — roughly two hundred citations in the docs and
the source depend on them.

## 3. Starting a session

1. Read `docs/PROGRESS.md`. It names the current milestone and the next task.
2. Read the milestone's section in `docs/BUILD-PLAN.md` for what "done" means.
3. Read `docs/TASKS.md` for that milestone cut into groups, and the decisions it turns on.
4. Read the parts of `README.md` that section points at.
5. Do the work. Close the loop per §0.

**`README.md` §0 points here instead of restating this**, for anyone who arrives at the README
first — a human, or an agent that does not load this file automatically. If the reading order
changes here, check that README §0's pointer still lands in the right place.

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
- **Liskov.** A fake used in a test must be honest. `FakeAudioRecorder` that "refuses" must
  refuse the way the real one does — a `false`, never an exception — and `FakeAudioPlayer` must
  replay its current state to a new listener because the real one does. A test only means
  something if the substitute cannot lie, and both times a fake lied here it cost a handset pass
  (ADR-057, and the pill nobody could pause).
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
- **Every gap and padding comes off the 4px scale** — `s1`…`s8`, no one-off spacings, even when
  the prototype's CSS says otherwise (DESIGN-SYSTEM.md §6.3). A *dimension* may sit off the
  scale when it is a property of one component and it is named in `ChitSpace`; a *gap* may not,
  because a gap is a relationship and the scale exists to keep relationships consistent.
- **Fonts are variable fonts** (see ADR-015). Weight and optical size are applied through
  `TextStyle.fontVariations`, *not* `fontWeight` alone — a variable font declared once renders
  at 400 whatever `fontWeight` says. Every style in `chit_type.dart` sets both: `fontWeight`
  for fallback and semantics, `fontVariations` for what is actually drawn. This is exactly why
  the rule above exists.
- **Riverpod is generated.** `@riverpod`, `part 'x.g.dart'`, `dart run build_runner watch`.
- **go_router and Riverpod take every responsibility they can.** go_router owns all navigation
  — the shell, the branches, the paths, the names, every stack — and `ChitRoute` is the one list
  of destinations that the tab bar is built from. Riverpod owns everything that outlives a
  build, the router included: a `GoRouter` in a `StatefulWidget` is state in the one place that
  does not survive a rebuild. Before hand-rolling near either of them, check whether the package
  has the seam already; `BranchFade` is written into go_router's `navigatorContainerBuilder`
  rather than around it. The single deliberate exception is ADR-011's recording sheet, which is
  a modal sheet and not a route. See `docs/ARCHITECTURE.md` §3.
- **No widget tests. Ever.** (ADR-031.) Nothing under `test/` may call
  `testWidgets`, `pumpWidget` or `WidgetTester`, and no test may build a widget in order to look
  at it. **A claim that can only be checked by pumping a screen is checked on a device instead**
  — build it, look at it, and write what you saw into `docs/PROGRESS.md`. There is a test that
  fails if a `testWidgets` reappears, so this is enforced rather than remembered.
- **What is tested instead**, and where the effort goes now: pure functions, models and their
  invariants, the repository and the DAO against `NativeDatabase.memory()`, the migration
  against the committed snapshots, controllers driven through a bare `ProviderContainer`, and
  the design-system floors computed arithmetically. **Pull the logic out of the widget until it
  can be tested that way** — a controller that can only be exercised through a screen is a
  controller with too much in it. That is the rule doing its real work: it is a constraint on
  where behaviour lives, not just on what the test folder contains.
- **Tests override at the root**, with hand-written fakes and no mocking framework. A fake must
  refuse whatever the real one refuses; that is the Liskov rule above, and it is the only thing
  keeping a fake and the real implementation honest.
- **No test cases for documents.** Nothing checks that README §10 lists every file or that
  DECISIONS.md's ADR index is complete — that was `readme_maps_everything_test.dart`, deleted
  17 September 2026 for the same reason §0.3 exists: it was more to read than the thing it
  guarded was worth. Keep the map and the index true by hand, at the point in §0 that says to.
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

To look at a calendar or a timeline with something in it, seed a build and clear it afterwards
— `docs/DATA-MODEL.md` §7. The flag works in any build mode, both are idempotent, and neither
touches a chit a person wrote. The console is the only place it reports:

```bash
flutter run --dart-define=CHIT_SEED=seed
flutter run --dart-define=CHIT_SEED=clear
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
