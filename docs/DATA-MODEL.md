# Data model

README §5 as the schema, the invariants and the queries. Storage decisions are ADR-003, ADR-006,
ADR-008.

## 1. The one table

```dart
@DataClassName('ChitRow')
class Chits extends Table {
  TextColumn get id        => text()();                   // uuid v4, client-generated
  IntColumn  get createdAt => integer()();                // UTC milliseconds
  IntColumn  get localDay  => integer()();                // yyyymmdd, device-local
  TextColumn get body      => text().nullable()();        // README §5 calls it `text`
  TextColumn get audioPath => text().nullable()();        // relative to app documents
  IntColumn  get audioMs   => integer().nullable()();
  TextColumn get weather   => textEnum<WeatherCondition>().nullable()();
  RealColumn get lat       => real().nullable()();
  RealColumn get lon       => real().nullable()();
  TextColumn get motion    => textEnum<MotionState>().nullable()();
  IntColumn  get updatedAt => integer()();

  @override Set<Column> get primaryKey => {id};
}
```

**One index: `(localDay, createdAt)`** — the order every query here reads in, so the archive's
`WHERE local_day BETWEEN ? AND ? ORDER BY local_day DESC, created_at DESC` is a walk of one month
rather than a sort of the whole table,
and `localDay` alone is still served as the leftmost column (ADR-077). *Three separate indexes until
then*, of which the one on `weather` served a backlog item and nothing that existed — an index on
speculation is what YAGNI forbids, and the same argument always ruled out `motion`. **That backlog
item is now find** (ADR-083) and **the index is still not back**: find reads every row and narrows
in Dart, because its tags are in the body text and no index reaches them. Open item 49 says what to
try, and in what order, if that ever measures slow.

**Two names are forced.** `text` is Drift's own column builder, so a getter called `text` is a
compile error in a `Table`; the column is `body`. Drift's row class would have been `Chit` and
collided with the domain model, so it is `ChitRow` — a row is not a chit, and the repository is
where one becomes the other. **The rename stops at the data layer**: README §5, the domain model and
every screen say `text`.

**`createdAt` and `localDay`** are computed once at write time, in the repository. `createdAt`
places the mark on the timeline and is the moment the chit was **saved** (ADR-040), which is also
when the ambient reading was taken; `localDay` decides which day the chit belongs to, and nothing
recomputes it when the device changes timezone (ADR-006).

**`body`** is `NULL` on a chit that is only a recording, and **blank is not a value**: the
repository trims what it is given and stores whitespace-only text as `NULL`, the column enforcing
the same so no other caller can disagree. **`audioPath`** is relative, always. **`lat`/`lon`** are
stored and never displayed (ADR-066), and are as precise as the fix was (ADR-016) — so **the row is
precise enough to reconstruct an address**, a fact about this database rather than the UI, and a
constraint on any sync design. **`motion`** is read off the speed of that same fix (ADR-037), so it
costs no second permission; it is `NULL` when no usable speed arrived, which is most chits, and
`stationary` is both stored-and-never-drawn and where an unusable reading lands. There is
deliberately **no `CHECK (motion IS NULL OR lat IS NOT NULL)`**: motion comes off the fix because
that is how this milestone reads it, which is a fact about the implementation and not about what a
chit *is*.

**`updatedAt`** is set at insert to the same instant as `createdAt` — **`stamp.capturedAt` itself,
never a second reading of the clock**, which is milliseconds and an audio file-move later and would
make every chit ever saved look edited — and diverges on the first edit. Editing never changes
`createdAt` or `localDay`, and **`updateAmbient` moves neither** (ADR-042) — the patch that follows
a save must not move the chit in the thread, nor claim the user had edited something. An edit is the
user's act and nothing else may claim to be one. **This equality is now drawn**: `Chit.wasEdited`
compares the two and a saved chit that has moved says `edited` (ADR-080), so anything that touches
`updatedAt` without the user asking is visible on the screen. A fake clock returns one instant to
both reads, so **a test cannot catch a regression here** — the repository suite pins it by moving
the clock between the stamp and the save.

## 2. The invariant

> **At least one of `text` and `audioPath` is present.** — README §5

Three legal shapes, none of them a lifecycle: words alone, words and a recording, a recording alone.
Held in **three places**, each tested where it lives, because an assert is compiled out of a release
build, a check constraint says nothing about *why*, and a repository is one caller among however
many a later milestone adds.

```sql
CHECK (body IS NOT NULL OR audio_path IS NOT NULL)
CHECK (body IS NULL OR length(trim(body)) > 0)
CHECK ((audio_path IS NULL) = (audio_ms IS NULL))
CHECK ((lat IS NULL) = (lon IS NULL))
```

Half a recording and half a coordinate are each a row that means nothing. Every one of these rows is
written by hand in the tests, *around* the repository, which is the only way to know the constraint
is doing the work rather than the caller. **The domain model** is the second place — a `freezed`
class with a private constructor and asserts, not a bag of public nullables, a sealed union buying
ceremony rather than safety when the shapes differ only by which fields are populated; the UI asks
`hasText` and `hasAudio`. One assert is weaker than the rule it stands for, a `const` constructor
being unable to call `trim()`, so the model catches the empty string and leaves whitespace to the
other two. **The repository** is the third, refusing an illegal chit with an `ArgumentError` naming
what was wrong.

**There is no `source` column.** Whether a chit has audio is `audioPath != null`, and nothing infers
behaviour from a mode. A chit with both renders the text *and* the pill — the pill is not a fallback
for missing words, it is the recording.

## 3. Domain types and queries

`enum WeatherCondition { raining, clear, overcast, windy, clearNight }` is what makes §3.6's five
words a closed set. WMO codes map into it by one pure function — a code, the `is_day` flag, and a
wind threshold; `windy` has no WMO code of its own and is applied after the lookup, winning over
`clear` but not over `raining` (ADR-043). `AmbientStamp` bundles what was captured, being captured
at one instant and drawn as one row.

| Screen | Query |
|---|---|
| Today, the thread | `watchDay` — `WHERE localDay = ? ORDER BY createdAt DESC` |
| Today, the timeline | `watchDayRange` — three days, **oldest first** |
| Calendar, density **and** summary | `watchDaySummaries` — one query; the total is the rows' sum, the day count their length |
| Archive | `watchArchive` — one month, `ORDER BY localDay DESC, createdAt DESC` (ADR-079) |
| Archive, filtered | `watchDay` — *one day's chits, newest first* is one question |
| Calendar, the chevrons | `watchWrittenMonths` — `GROUP BY localDay / 100` (ADR-047) |
| Find | `watchEvery` — every row, same order, **and no `WHERE` at all** (ADR-083) |

**`watchEvery` is the one unbounded query, and it is deliberate.** Find narrows on four axes, two of
which — people and topics — live inside the body text and have **no index to ask**, so the rows come
to Dart and are filtered there; weather and motion could be pushed into SQL and are not, a half-
pushed filter being two places to be wrong. ADR-077 deleted the `weather` index *because it served
this and nothing else*, and it has not come back: bringing it back is a schema change and ADR-059's
reinstall, and nothing has measured slow yet. **This is the first thing to suspect if find stutters**
— open item 49.

**Six queries behind seven readings**, which is the mechanism behind *the tabs never disagree*:
they are not kept in step, they are the same data. A thread is read down and a strip is read along,
which is why `watchDayRange` reads oldest first where `watchDay` reads newest first — each query
hands its screen the order it draws in. Count-to-density is **not** in the query: it is a design
scale, living in the presentation layer where it can be re-tuned without touching the database.

## 4. Audio on disk

```
<app documents>/audio/<chit-id>.m4a
<app cache>/recording-<timestamp>.m4a     ← in flight; moved on Save, deleted on Remove
```

AAC in an m4a container: small, hardware-encoded on both platforms, playable without a codec
dependency.

**One ordering rule governs every path** (ADR-063): a row pointing at nothing is a corruption, a
file nobody points at is only an orphan, **so the row is never the one left wrong.** A save moves
the file in before the insert; a replacement moves in *before* the row is written, over the old file
since the name is the chit's id; a removal is written to the row *first* and its file deleted after;
a delete drops the row, then the file. `update` checks the invariant on what the row *will* hold
before any of this starts, so a refused edit leaves the disk untouched. **Reconciliation** runs once
at startup, off the critical path, both ways: a file with no row is deleted, and a row whose file
has vanished keeps rendering as a chit without a pill. A missing recording is a loss, not a
corruption.

## 5. Migrations

**There are none, on purpose** (ADR-059). `schemaVersion` is **1** and stays there; changing a table
changes the schema, and an install carrying the old shape is reinstalled — `onUpgrade` throws a
message saying exactly that, a database the app cannot trust having to fail at `open` rather than
three screens later as a column quietly missing.

**The trigger to bring them back is data somebody would miss** — the first install that is not a
development one. Open item 38 carries it, and what returns is all of it: `drift_dev schema dump` and
`schema generate`, plus the four rules the deleted harness taught, which are why this section exists
rather than only git.

- One `from → to` step per version, and **once a version has shipped, its step and its snapshot are
  never edited**.
- **Steps gated on both ends** — `from < n && to >= n`. A step that ignored `to` would rebuild a v2
  database into the v3 shape and still call it v2. That bug was real.
- A test that migrates **and reads rows back**. `migrateAndValidate` inspects the schema, not the
  contents, and a table rebuild produces the right shape while losing what was in it.
- **Nothing is backfilled.** There is no way to know what a phone was doing last Tuesday, and a
  guess written into a row is indistinguishable from a fact a month later.

On the horizon: the editor needs no schema change; backlog 1 is new nullable columns; backlog 7 is a
nullable `replyToId`. None break §2's invariant, which is the part worth protecting.

## 6. Seed data for development

```bash
flutter run --dart-define=CHIT_SEED=seed     # writes the fixture; a second run writes nothing
flutter run --dart-define=CHIT_SEED=stress   # 2,000 rows over three years, 40 of them recorded
flutter run --dart-define=CHIT_SEED=clear    # removes either, and exactly what was seeded
flutter run --profile --dart-define=CHIT_FRAMES=true   # frame times, every 120 frames, to the log
```

**Any build mode, `--release` included** — the define is already the explicit act, and a second gate
behind `kDebugMode` protected nothing while costing a device pass. It runs off the critical path,
and **the console is the only place it reports**.

**Sixty chits over three months, dated relative to the day it runs.** Yesterday and the day before
hold five each — density step four, and ten marks across two days on the strip — then threes, twos
and singles thinning backwards over eighty-nine days and four calendar months, so the chevrons have
somewhere to go and one month holds more than a screenful. **Twelve days in the middle hold nothing**,
which is the only thing that draws the week a past month leaves out (ADR-048). **Today is left
alone**: it belongs to whoever is holding the phone. **Every seeded id starts with `seed-`**,
which is the whole of how the rows are told apart from a person's own — no ledger, no preference, no
column added for a tool. Seeding is idempotent; clearing deletes exactly the seeded rows and their
recordings. It writes through the DAO rather than the repository, which generates its own ids, but
`localDay` still comes from `Chit.localDayOf`.

**The pinned chits walk the world, newest first** (ADR-089) — Tokyo, New York, London, Cape Town,
Sydney, Rio, Paris, Istanbul, Bangalore, Cairo, San Francisco, Mumbai, and round again. **Mumbai is
last and not first**, because this gets looked at from a handset that is usually in it: a newest
seeded chit there would draw the map the real one already drew, and the first delete would read as
nothing having happened. **That order is the feature**: the map behind find draws the newest chit that carries a fix, so deleting the
newest chit and opening find again lands it on the next city, which is the only way to see the map
anywhere but where the handset is. **Each of the twelve was checked against `outline.bin` for a
built-up area to fill** rather than assumed — a place Natural Earth holds no city for draws a map
with nothing filled, which reads as a broken map rather than as a small town, and that is why
Reykjavík and Singapore are not on the list. The console names them on every seed.

**`stress` is for measuring, not for looking at** (ADR-077): 2,000 rows spread evenly over 1,095
days, ids `seed-s00000` upward, written in one transaction, with four rotating bodies of different
lengths so the rows are not all one height. `clear` takes them too — they carry the same `seed-`
prefix. **Its numbers are how a performance claim gets re-checked**: `CHIT_FRAMES=true` prints build and
raster times **and the resident set size** every 120 frames, and **profile is the only mode worth
reading** — a debug build renders through an unoptimised path and is slow whatever the code does. A
rising RSS is not yet a leak: `adb shell am send-trim-memory <pkg> RUNNING_CRITICAL` collects, and
what does not come back is the leak (open item 46).

**Its recordings are WAVs wearing an `.m4a` extension** — a quiet 440Hz tone at the length the row
claims. Encoding AAC in Dart is not on the table and Android's extractor sniffs the content; **iOS
may refuse them** (open item 37). A file no decoder can open draws a control that does nothing,
which §6.4 forbids, and a **tone rather than silence** because silence cannot be told apart from a
player that is not working. They are written to the app's cache and moved by `AudioStore.keep` —
`Directory.systemTemp` is not writable on Android.

Sample text is four words and mundane. The fixture covers all three shapes of §2 — especially the
recording with `NULL` text, the shape most likely to be forgotten — every weather word, a chit with
no fix, a chit with no weather, and each of the three motion marks.
