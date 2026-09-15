# Data model

Expands README §5 into the schema, the invariants, and the queries the screens actually run.
Storage decisions are ADR-003, ADR-006 and ADR-008.

---

## 1. The one table

```dart
@DataClassName('ChitRow')
class Chits extends Table {
  TextColumn    get id           => text()();                    // uuid v4, client-generated
  IntColumn     get createdAt    => integer()();                 // UTC milliseconds
  IntColumn     get localDay     => integer()();                 // yyyymmdd, device-local
  TextColumn    get body         => text().nullable()();          // README §5 calls it `text`
  TextColumn    get audioPath    => text().nullable()();          // relative to app documents
  TextColumn    get textOrigin   => textEnum<TextOrigin>().nullable()();  // null iff body is null
  IntColumn     get audioMs      => integer().nullable()();
  TextColumn    get weather      => textEnum<WeatherCondition>().nullable()();
  RealColumn    get lat          => real().nullable()();
  RealColumn    get lon          => real().nullable()();
  IntColumn     get updatedAt    => integer()();

  @override Set<Column> get primaryKey => {id};
}
```

Indexes: `localDay` (every calendar and archive query groups on it), `createdAt` (the arc and
ordering within a day), `weather` (backlog item 2, and it costs nothing now).

**Two names here changed in M1, and both were forced.**

*This block used to read `TextColumn get text` and to let Drift name the row class.* Neither
compiles. `text` is the name of Drift's own column builder, so a getter called `text` is a
compile error in a `Table` — and the versioned-schema classes that `drift_dev schema generate`
writes for the migration test derive their Dart names from the SQL, so a column named `text`
breaks the migration harness at exactly the version where it first has work to do. The column
is therefore `body`, which is the word this document already used for a chit's words. Drift's
row class would likewise have been called `Chit` and collided with the domain model, so it is
`ChitRow`: a row is not a chit, and the repository is where one becomes the other.

**The rename stops at the data layer.** README §5 calls the field `text`, the domain model calls
it `text`, and every screen will call it `text`. Only the column and the row getter are `body`.

### Field notes

**`id`** — a UUID rather than an autoincrement integer, so the row keeps its identity if a sync
layer ever arrives (ADR-004).

**`createdAt` and `localDay` together** — `createdAt` places the mark on the day arc;
`localDay` decides which day the chit belongs to. Computed once, at write time, in the
repository. A chit written at 00:20 IST belongs to that morning permanently, and nothing
recomputes it when the device changes timezone (ADR-006).

`createdAt` is the moment the chit was **opened**, not the moment it was saved — it is the same
instant the ambient stamp was captured, because there is one time column and the stamp is what
it holds (ADR-021).

**`body`** — what the chit says: typed, transcribed, or transcribed and then corrected. `NULL`
only when a recording produced nothing and the user wrote nothing either. The failure note the
user sees is never stored here; it is a property of the UI state, not of the chit (BEHAVIOUR.md §3.5,
and the design log is explicit about why — and stricter now that the body is an editable field).

**Blank is not a value.** The repository trims what it is given and stores whitespace-only text
as `NULL`, so a field of spaces beside a recording is the ordinary §3.5 shape rather than an
error, and a field of spaces on its own is the chit §3.1 refuses to save. The column enforces
the same thing — `length(trim(body)) > 0` — so no other caller can disagree. Storing the
trimmed text is a choice: the edges of a slip are not content, and nothing in the design asks
for leading whitespace to survive.

**`textOrigin`** — `typed | transcript | transcriptEdited`, and `NULL` exactly when `text` is.
Provenance only: nothing in the UI renders differently because of it. It exists so a future
re-transcription (OPEN-QUESTIONS.md §8.2) can tell whether it would be overwriting the machine's words or
the user's. A transcript that the user then edits becomes `transcriptEdited` and never goes
back.

**`audioPath`** — relative, always. An absolute iOS container path saved today is dead after
the next app update.

**`lat` / `lon`** — stored, never displayed. BEHAVIOUR.md §3.6: the pin says a place was recorded and
stops there. Nothing in the app reverse-geocodes these, and if a future feature wants coarse
places ("home", "office") that is a new decision, not an existing capability.

They are as precise as the fix was. ADR-016 asks for high accuracy and accepts a coarse fix
when that is all the user granted, so this column may hold anything from a rooftop-accurate
position to a neighbourhood. The display promise is unchanged — no name, no coordinate, no map
— but the *row* is now precise enough to reconstruct an address, which is a fact about this
database rather than about the UI. It is why ADR-004's "local only" is load-bearing, and it is
a constraint on any sync design rather than an argument against the accuracy.

**`updatedAt`** — written on every edit (ADR-014), and set at insert to the moment the row was
written. It is the only column that reads the clock at save time; everything else about when a
chit happened comes from the stamp. Editing does **not** change `createdAt` or `localDay`: a
chit belongs to the moment it was written, and correcting a typo the next morning must not move
it in the thread or relight a calendar tile.

---

## 2. The invariant

> **At least one of `text` and `audioPath` is present.** — README §5

A chit with neither is not a chit; it is the untouched composer that §3.1 refuses to save.
That leaves four legal shapes, all ordinary:

| | `text` | `audioPath` | `textOrigin` |
|---|---|---|---|
| typed | ● | — | `typed` |
| recorded, transcribed | ● | ● | `transcript` |
| recorded, transcript corrected | ● | ● | `transcriptEdited` |
| recorded, nothing recognised (§3.5) | — | ● | — |

Nothing in the schema orders these; they are states a row can be in, not a lifecycle it walks.
Recording into a chit that already had typed text lands in the **third** shape, not the second —
the words are then partly the user's, and `textOrigin` says so from the start.

Held in three places, because one is not enough — and each is tested where it lives, because an
assert is compiled out of a release build, a check constraint says nothing about *why*, and a
repository is one caller among however many a later milestone adds.

1. **Five table check constraints**, which is what survives a release build:

   ```sql
   CHECK (body IS NOT NULL OR audio_path IS NOT NULL)
   CHECK ((body IS NULL) = (text_origin IS NULL))
   CHECK (body IS NULL OR length(trim(body)) > 0)
   CHECK ((audio_path IS NULL) = (audio_ms IS NULL))
   CHECK ((lat IS NULL) = (lon IS NULL))
   ```

   The last two were added in M1 and are the same kind of rule: half a recording and half a
   coordinate are each a row that means nothing. `test/data/db/chits_table_test.dart` writes
   every one of these rows by hand, around the repository, which is the only way to know the
   constraint is doing the work rather than the caller.

2. **The domain model**, as a `freezed` class with a private constructor and asserts, rather
   than a bag of public nullables:

   ```
   Chit._({ String? text, String? audioPath, TextOrigin? textOrigin, ... })
     : assert(text != null || audioPath != null);

   bool get hasAudio => audioPath != null;
   bool get hasText  => text != null;
   ```

   A sealed union was the shape here while a chit was typed *or* spoken (ADR-013 removed the
   exclusivity). With four shapes that differ only by which fields are populated, a union buys
   ceremony rather than safety — the UI asks `hasAudio` and `hasText`, which is what it actually
   wants to know.

   One assert is weaker than the rule it stands for: a `const` constructor's assert cannot call
   `trim()`, so the model catches the empty string and leaves whitespace-only text to the check
   constraint and the repository. That is a fair division and it is why there are three places.

3. **The repository**, which refuses an illegal chit with an `ArgumentError` naming what was
   wrong before either of the other two has to — and the tests in
   `test/data/chit_repository_test.dart` for every illegal shape: neither field present; text
   without an origin; a recording without a length; a length without a recording.

**There is no `source` column.** Whether a chit has audio is `audioPath != null`, and nothing
infers behaviour from a mode.

A chit with audio and no text renders as its audio pill alone. One with both renders the text
*and* the pill — the pill is not a fallback for missing words, it is the recording, and the
recording is always there when it was made (ADR-013).

---

## 3. Domain types

```
enum TextOrigin        { typed, transcript, transcriptEdited }
enum WeatherCondition  { raining, clear, overcast, windy, clearNight }
```

The five weather words are the ones BEHAVIOUR.md §3.6 allows, and the enum is what makes that a
closed set. Open-Meteo's WMO codes are mapped into it by one pure function
(`domain/weather/wmo_mapping.dart`) — a code plus the `is_day` flag plus a wind-speed threshold.
`windy` has no WMO code of its own; it is our threshold, applied after the code lookup, and it
wins over `clear` but not over `raining`.

`AmbientStamp` bundles what was captured — a `DateTime`, a nullable `WeatherCondition`, a
nullable coordinate — because all three are captured at the same instant and drawn as one row.

---

## 4. Queries the screens need

Every one of these lives in the DAO and returns a stream.

| Screen | Query |
|---|---|
| Today, the thread | `WHERE localDay = ? ORDER BY createdAt DESC` |
| Today, the day arc | same rows; positions derived in Dart from `createdAt` |
| Calendar, the heat | `SELECT localDay, COUNT(*) WHERE localDay BETWEEN ? AND ? GROUP BY localDay` |
| Calendar, the summary | the same rows: the total is their sum, the distinct-day count is how many there are |
| Archive | `ORDER BY localDay DESC, createdAt DESC`, paged |
| Archive, filtered | the same with `WHERE localDay = ?` |
| Backlog: weather search | `WHERE weather = ?` — the index is already there |

The thread and the arc read **one** query; the calendar's heat and its month summary read one
more between them. *This used to say the summary was a second query of its own; it is not —
`COUNT(*)` and `COUNT(DISTINCT localDay)` over a month are the sum and the length of the rows
the heat already has, and a second round trip to learn them would be a second thing to keep in
step.* Three queries behind six readings. That is the mechanism behind DESIGN-SYSTEM.md §7's
requirement that the two tabs never disagree: they are not kept in step, they are the same data.

As of M1 the DAO holds the three: `watchDay`, `watchDaySummaries` and `watchArchive`. Filtering
the archive by date and searching on weather arrive with the screens that ask for them (M4, and
the backlog) — a query with no caller is a query nobody has run.

Count-to-warmth (four steps, BEHAVIOUR.md §4.2) is *not* in the query. It is a design scale and lives
in the presentation layer, where it can be re-tuned without a migration.

---

## 5. Audio on disk

```
<app documents>/
└── audio/
    ├── <chit-id>.m4a
    └── ...
<app cache>/
└── recording-<timestamp>.m4a     ← in flight; moved on Save, deleted on Discard
```

AAC in an m4a container: small, hardware-encoded on both platforms, and playable by
`just_audio` without a codec dependency.

**Lifecycle.** Record to cache → **Save** moves it to `audio/<chit-id>.m4a` and writes the row
in one repository call → **Discard** deletes it. The move happens before the insert, so a
failed move never leaves a row pointing at nothing.

**Reconciliation** runs once at startup, off the critical path, and handles both directions:
a file with no row is deleted; a row whose file has vanished keeps rendering as a chit without
a pill. A missing recording is a loss, not a corruption, and the words — if there are any —
are still the record.

**Editing never touches this.** ADR-014 gives the repository an update path for `text` and
`textOrigin` and no path that changes or removes `audioPath` on an existing chit. Deleting the
whole chit is the only thing that deletes a recording.

---

## 6. Migrations

Drift's `MigrationStrategy`, one `from → to` step per schema version, each with a test against
a checked-in schema snapshot. Snapshots are committed.

```bash
dart run drift_dev schema dump lib/data/db/app_database.dart drift_schemas/
dart run drift_dev schema generate drift_schemas/ test/data/db/generated/
```

The first writes `drift_schemas/drift_schema_v<n>.json` — the shape as it shipped. The second
writes the helper `test/data/db/migration_test.dart` reads. **Run both when `schemaVersion`
changes**; there is a test that fails if a version has no snapshot, because a migration with
nothing to migrate *from* is not a migration.

**The rule:** once a version has shipped to a real handset, its migration step and its snapshot
are never edited.

v1 was taken in M1, before there was anything to migrate. That is the point: the first
migration is not the moment to find out the harness does not work. It earned its keep
immediately — it is what proved the text column could not be called `text` (§1).

There is no `onUpgrade` step yet and the strategy throws rather than opening a database whose
shape nobody has looked at. The first real migration replaces that throw; it does not add to it.

Changes already visible on the horizon, so the shape does not surprise us:

- OPEN-QUESTIONS.md §8.1 (where the editor lives) — no schema change at all; the columns are already here.
- OPEN-QUESTIONS.md §8.2 (re-transcription) — probably a nullable `transcriptionAttemptedAt`, or nothing
  at all if a null `text` beside a non-null `audioPath` is treated as the signal. `textOrigin`
  is what keeps such an attempt from overwriting words the user typed.
- Backlog 1 (coarse place, what was playing) — new nullable columns.
- Backlog 7 (chit threading) — a nullable `replyToId` self-reference.

None of these break the invariant of §2, which is the part worth protecting.

---

## 7. Seed data for development

A debug-only seeder behind a flag, writing chits across about six weeks so the calendar has
something to shade and the archive has something to page.

Sample text is four words and mundane — *"Train 20 late."* The design log is right that
literary placeholder copy makes a screen read as a demonstration, and it will mislead us here
exactly as it did there. A seeded day should cover all four shapes of §2 — and especially the
recording with `NULL` text, because §3.5 is the state most likely to be forgotten until it
appears in front of a user.
