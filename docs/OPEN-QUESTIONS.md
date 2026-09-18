# Open questions and the backlog

**What is not settled** (§8) **and what is not built** (§9).

§8 holds three questions the design deliberately left open; one has since been answered and
keeps its number so the citations to it still resolve. §9 is the feature backlog, ordered by
how much each reinforces what chit already is — not by appetite.

Neither section is a plan. [BUILD-PLAN.md](BUILD-PLAN.md) is the plan, and its *After v1*
list is what actually draws on both of these. Section numbers are stable across the split:
§8.1 is §8.1 wherever it is cited from, and it lives here. [README §10](../README.md#10-the-map)
maps every section to its file.

---

## 8. The three hard questions

Two are still open. The numbering is stable — §8.1, §8.2 and §8.3 are referred to across the
docs — so a question that gets answered keeps its number.

### 8.1 Where a saved chit is edited — **settled, 14 September 2026**

A saved chit opens in **an editor of its own**, not inline in the thread. The thread is a
reading surface, and Today already carries a live writing surface at the top of it; a second,
differently-behaved editable field in the rows below would make it ambiguous which one a tap
is about to put the cursor in.

**Leaving with unsaved changes asks.** The prompt offers to keep the edit or to discard it.
Quitting outright — answering *discard*, or the app being killed — cancels the edit and
returns to Today, and nothing is written.

The prompt exists because editing a saved chit is not like writing a new one. Discarding an
open chit throws away something that was never a record, and gets no confirmation (§3.1).
Discarding an edit throws away a change to something that is, and gets one.

A chit's **audio is never editable and never removable**, here or anywhere. Editing changes
what the chit says, never what was said.

The affordance in the thread arrives with the editor, in the same change — until then a chit
in the thread is still not tappable, because a pointer that leads nowhere is worse than none.

### 8.2 Re-transcription — retired

*Should a recording that produced nothing be re-transcribable later?* There is nothing to
re-attempt: transcription was removed in M5 (ADR-058) after recognising nothing on a handset,
and `textOrigin`, which existed so a second attempt could refuse to overwrite the user's own
words, went with it. **The number is not reused** — it is cited from other documents and from
git history.

Bringing transcription back is a product decision that would open a new question with a new
number, not this one again.

### 8.3 Does Today carry enough rhythm? — open

The timeline is the only rhythm signal on the home screen. It fills in as chits are saved,
which is the cheapest version of an answer; whether it is enough is still open.

---

## 9. Feature backlog

Ordered by how much each reinforces what chit already is.

| # | Feature | Why it fits |
|---|---|---|
| 1 | Extend ambient capture — coarse place ("home", "office", "in transit"), what was playing | Costs the user nothing; recovers a memory faster than the text does |
| 2 | **Weather as a search axis** — "show me everything I wrote when it was raining" | Possible *because* of the ambient-stamp decision. A genuinely novel way in |
| 3 | Resurfacing — a chit from a year ago on the home screen | Brings people back with their own words |
| 4 | Adapt the prompt to time-to-first-word | Stays out of the way of fluent writers, helps blocked ones |
| 5 | The stitch — one continuous year-long line, one mark per day | Shows a year's rhythm in a single gesture |
| 6 | Voice chits (**in the design**, §3.4) | Matches the "whenever something hits them" trigger. On-device only for now; a cloud engine would be more accurate and is a decision for later |
| 7 | Chit threading — one chit replying to another | Lets a preoccupation reveal itself over weeks |

Suggested order: **1 and 3** make the app stickier; **2 and 5** make it distinctive.
Hold **7** until real usage shows people write in chains.

