# Build plan

The order the app gets built in, and what "done" means at each step. Each milestone ends with
something runnable; none of them is a refactor of the one before.

The principle behind the ordering: **the data spine before any screen, the field before the
microphone, and real content before polish.** Voice is the most involved feature in the app and
the one most likely to distort everything around it if it arrives first.

**Current state is in [PROGRESS.md](PROGRESS.md), not here.** This file says what the order is
and what "done" means; that file says where we actually are. It is the one to read first.

*On 18 September 2026 the sections for M0 to M6 were cut to the table below, on the owner's
instruction. What each built is in git and ARCHITECTURE.md; what each settled is in
DECISIONS.md; what each taught is the list after the table.*

---

## M0 to M6 — done

| Milestone | Signed off | Records |
|---|---|---|
| M0a, M0b — scaffold, the design system in code | 14 Sep 2026 | ADR-001 to ADR-020 |
| M1 — the data spine | 15 Sep 2026 | ADR-021 (superseded by ADR-040), ADR-022 |
| M2 — Today, text only | 16 Sep 2026 | ADR-023 to ADR-036 |
| M3 — ambient capture | 17 Sep 2026, on a handset | ADR-037 to ADR-045 |
| M4 — calendar | 17 Sep 2026, on a handset, fourth look | ADR-046 to ADR-050 |
| M5 — voice | 18 Sep 2026, on a handset, third look | ADR-052 to ADR-059. Transcription removed, migrations removed |
| M6 — the chit editor | 18 Sep 2026, on a handset, third look | ADR-017, ADR-060 to ADR-067. Audio became editable, a chit deletable |

## What they taught

Read before writing a fake, and before fixing anything a device turns up.

- **A rule that fails silently gets a test that checks a property, not an example.** "No fade
  is slower than it was" found ADR-020; a table of durations would not have.
- **An invariant worth having is held in more than one place, each tested where it lives.** The
  one-of rule of README §5 is an assert, a check constraint and a repository refusal.
- **A feature can be built correctly and still be the wrong feature.** Transcription passed
  every test it had and recognised nothing on a real microphone; ADR-005 had written that cost
  down two milestones earlier. A stated cost is a prediction — re-read it before paying it.
- **A fake that behaves better than the real thing turns a test into a claim about nothing.**
  A listener added "for symmetry" gave a controller a lifetime the app does not have (ADR-057);
  a fake player that carried only changes hid a pill nobody could pause. CLAUDE.md §4.1's Liskov
  rule names both.
- **And the reverse: a fake can be more honest than what it stands in for.** `FakeAudioPlayer`
  took a second pill over a first one correctly and `JustAudioPlayer` did not. The net was a
  fake *under* the plugin so the plugin's own logic runs in the suite
  (`just_audio_player_test.dart`), not a better fake above it.
- **Removing a feature removed four open risks.** The cheapest way to answer a hard question is
  sometimes to stop asking it (ADR-058).
- **A seeded fixture has to be as real as what it stands in for.** Thirty-eight bytes of ASCII
  where a recording should be was indistinguishable from playback being broken.
- **"It's broken" on a device is first a layout question.** Save shrank to its label under an
  `AnimatedSwitcher` and read as dead. Look at the widget's constraints before its callback.
- **An affordance on a scrolling surface is decided by a thumb.** The tap ADR-061 chose at a
  desk fired on a glancing touch; a day of use turned it into a hold.
- **Sign-off is a decision about what to carry, not an empty checklist.** M6 moved three boxes
  into M7's pass with the owner's say-so, and TASKS.md says which.

---

## M7 — Motion and the floors

Polish, done deliberately and once. Last, so that every surface it touches already exists.

- The staggered entrance: fade plus a 6px rise, 55–60ms apart, capped, playing on first build
  and then shedding itself. A tab regaining visibility costs a 200ms fade and nothing more.
- The two authored arrivals: a saved chit falls *down* into the thread; a kept recording rises
  *up* into the open chit — the pill first, then its words landing in the field.
- Press feedback everywhere — 90ms, 0.985 depress, 0.99 on the pill. On a phone it is the only
  acknowledgement a finger gets.
- The reduced-motion pass: travel and ambient loops stop, fades and colour survive.
- Touch targets ≥44px with no exceptions — including the microphone's, which does not shrink
  when the field has text in it; focus rings; a semantics audit.

**Done when** the whole app is walked through once with reduced motion on and once with a
screen reader, and DESIGN-SYSTEM.md §6.4 holds as far as it can be held.

**This milestone is mostly a device pass, and ADR-031 is why.** The floors split in two. The
ones that are arithmetic over tokens — contrast, type, the reduced-motion re-timing — are tests,
and always were. The ones that are spatial or perceptual — targets, semantics, whether the
stagger reads as one movement — are a person with a handset, because there are no widget tests
to cover them and goldens are not coming back. Write what you saw into PROGRESS.md as you go: a
floors pass nobody recorded is a floors pass nobody can trust the next time round.

`docs/TASKS.md` carries the cut, in five groups, and the decisions it turns on. **M7 is the last
milestone of v1.**

---

## After v1

In the order OPEN-QUESTIONS.md's own §8 suggests, not in the order of appetite.

1. **OPEN-QUESTIONS.md §8.3 — whether Today carries enough rhythm.** Worth answering with real
   usage rather than more design.
2. Backlog items 1 and 3 (richer ambient capture, resurfacing) make the app stickier; 2 and 5
   (weather as a search axis, the stitch) make it distinctive. Item 8, `@person` and
   `#hashtag`, is wanted and M6 left room for it.
3. **Migrations back** (PROGRESS.md item 38) before the first install anybody would miss.
4. **An export / backup format.** Wanted eventually and not on the v1 path — ADR-004 accepted
   "no backup beyond the OS's own" as a cost of being local-only, and this is what would pay
   it back.
5. Responsive web.

Deliberately not on this list: **any speech engine, cloud or on-device.** ADR-058 removed
transcription after it recognised nothing on a handset, and ADR-005 rules a cloud one out until
there is an answer to what happens to the audio. Bringing either back is a product decision, not
a scheduling question.

---

## How to use this

One milestone at a time, and each one ends in a state that can be shown to someone. If a
milestone starts needing a piece from a later one, that is worth noticing — it usually means
the ordering was wrong somewhere and it is cheaper to say so than to reach forward.

Every milestone ends by updating [PROGRESS.md](PROGRESS.md), and by correcting whatever else
the work made untrue. That is the standing rule in [CLAUDE.md](../CLAUDE.md) §0, and it is not
optional: this file is only useful to the next session if it is still true.
