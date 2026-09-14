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
| changes what the app *does* or how it looks | `README.md` — it is the design authority |
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
4. `docs/PROGRESS.md` reflects reality — the milestone state, what was just finished, what is
   next, and any new open question.
5. The change and its doc updates are in the same commit.

---

## 1. What this project is

A private journal for short entries — "chits" — written or spoken several times a day.
Flutter, Android and iOS only. Offline-first, no backend, nothing leaves the device.

**`README.md` is the design authority.** It holds the product model, the behaviour spec and
the design system. Where any other document disagrees with it, the README wins — and the
disagreement is a bug in the other document, to be fixed rather than worked around.

## 2. The documents, and what each is for

| File | Answers |
|---|---|
| `README.md` | what the app is, how it behaves, what it looks like |
| `docs/PROGRESS.md` | **where we are right now, and what to do next** — start here |
| `docs/BUILD-PLAN.md` | the order it gets built in and what "done" means per milestone |
| `docs/ARCHITECTURE.md` | how it is put together — layers, folders, providers, data flow |
| `docs/DECISIONS.md` | the ADRs — why each choice was made and what it was chosen over |
| `docs/DATA-MODEL.md` | schema, invariants, queries |
| `docs/PACKAGES.md` | every dependency and why it is there |
| `docs/DESIGN-LOG.md` | why the design is what it is |
| `design/chit-app-v5.html` | the interactive prototype — the visual target. Open in a browser |

`design/chit-app-v4.html` is superseded and is history, not a second option.

## 3. Starting a session

1. Read `docs/PROGRESS.md`. It names the current milestone and the next task.
2. Read the milestone's section in `docs/BUILD-PLAN.md` for what "done" means.
3. Read the parts of `README.md` that section points at.
4. Do the work. Close the loop per §0.

## 4. House rules for the code

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

## 5. Commands

```bash
flutter pub get
dart run build_runner watch      # while working
flutter analyze
flutter test
flutter run                      # Android device or emulator
```

Windows note: `flutter pub get` warns unless **Developer Mode** is enabled — plugin builds
need symlink support. `start ms-settings:developers`.
