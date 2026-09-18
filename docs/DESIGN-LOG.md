# Design log

The constraints the design rests on that are stated nowhere else. Read this before changing
something that looks arbitrary. The tokens and floors themselves are DESIGN-SYSTEM.md §6.

**The register.** Kenya Hara and MUJI: a ground, ink, hairlines, one accent. Structure comes from
1px rules and spacing rather than cards and shadows, because a journal should feel like paper. It is
dark because journalling happens at night more often than not.

**The name does design work.** A chit is **small**, so entries are short and the composer never
pretends to be a page; chits **accumulate**, so the day is a stack and the open chit rests on a
visible pad; chits are **torn off**, hence the perforated edge; and चित्त is the **field where
impressions land**, hence ambient capture — the moment is part of the record, not just the words.

**The perforation is holes, not a line.** The dots are the colour of the surface *beneath* the slip,
so the edge reads as punched through paper. In a hairline tone they would be *lighter* than the
slip, which is a dotted border — a different object, saying nothing about tearing. The test that
asserted this went with the widget suite (ADR-031) and nothing replaced it, so read this before
touching `perforated_edge.dart`.

**Draw what varies.** Location is captured and never drawn, because a mark on every chit
distinguishes nothing; motion is drawn everywhere, because almost no chit has one; `stationary`
draws nothing, for the same reason. The rule was never "ambient marks belong here".

**The home screen is about today.** The strip covers three days because yesterday and the day before
are *context for where now sits* — no thread, no count, nothing to tap. Three days is the smallest
window in which "yesterday was quiet and today is not" is visible at a glance, and the largest that
still reads as one glance.

**The calendar is a shape, not a grid of numbers to read one at a time.** Density is how much ink
went down that day, which is why the steps are ink rather than accent. It stops at today because
tiles for days that have not happened read as days with nothing written in them.

**A surface token is never a local change.** Lifting `--slip` four points moved every ratio measured
against a chit at once, and `--ink-faint` sits on two surfaces and must clear 4.5:1 on both.
**Translucent surfaces are their own surface** — a 3.5% wash is enough to fail a pair.

**"Used sparingly" is advice nobody can fail.** v5 obeyed it item by item and ended with an orange
thread and an orange calendar: every use defensible, the sum not. The rule that can actually be
broken is **the seal marks what is live, and a record is ink** (ADR-022). The test of a new element
is not "is this important enough for the accent" — everything is — but "is this happening now".

**Icons are normalised by effective stroke, not by the number in the markup** —
`stroke-width × (rendered size ÷ viewBox size)`, held at about 1.22px across the set. Two icons in
different viewBoxes with identical `stroke-width` stop looking equal for reasons nobody can name by
reading the code. Motion marks are **strokes rather than silhouettes**: at 12px an outlined plane's
wings close into a blob.

**An affordance that does nothing is worse than a missing one.** It costs a tap to discover, teaches
that taps here are ignored, and on a keyboard or screen reader is a stop that leads nowhere.

**Press feedback was built and removed three times** (ADR-069 to ADR-071); a control's answer is now
the thing it does. If it comes back, it comes back as one widget.

**Reduced motion is quieter, not silent.** Collapsing every duration to zero does not distinguish
movement from feedback, and deleting the fades along with the travel leaves a user with vestibular
sensitivity worse off than everyone else, not merely calmer.

**Placeholder copy shapes how a design reads.** Sample chits are four words and mundane — *"Train 20
late."* Literary ones make the screen read as a demonstration rather than a tool.

**Asking for a permission is a design problem.** The platform raises a dialog; what it will not do
is say why, in your voice, before it appears. Asking in context at the first chit open — which most
guidance recommends — puts a system dialog on exactly the path that is supposed to be free. So the
ask is its own screen built from the app's own furniture, and **"Not now" raises nothing at all**,
since a quiet option that still summons a prompt is a dark pattern wearing a polite label. The cost
is written down rather than argued away: a refusal is a dead end, there being no settings screen.

**The recording is the record.** Transcription was built and removed inside one milestone (ADR-058).
**A cloud engine is ruled out until someone can say what happens to the audio** — a privacy
decision, not a technical one.
