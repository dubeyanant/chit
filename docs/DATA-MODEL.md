# Data model

Expands README §5 into the schema, the invariants, and the queries the screens actually run.
Storage decisions are ADR-003, ADR-006 and ADR-008.

---

## 1. The one table

```dart
class Chits extends Table {
  TextColumn    get id           => text()();                    // uuid v4, client-generated
  IntColumn     get createdAt    => integer()();                 // UTC milliseconds
  IntColumn     get localDay     => integer()();                 // yyyymmdd, device-local
  TextColumn    get text         => text().nullable()();
  TextColumn    get audioPath    => text().nullable()();          // relative to app documents
  TextColumn    get textOrigin   => textEnum<TextOrigin>().nullable()();  // null iff text is null
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

### Field notes

**`id`** — a UUID rather than an autoincrement integer, so the row keeps its identity if a sync
layer ever arrives (ADR-004).

**`createdAt` and `localDay` together** — `createdAt` places the mark on the day arc;
`localDay` decides which day the chit belongs to. Computed once, at write time, in the
repository. A chit written at 00:20 IST belongs to that morning permanently, and nothing
recomputes it when the device changes timezone (ADR-006).

**`text`** — what the chit says: typed, transcribed, or transcribed and then corrected. `NULL`
only when a recording produced nothing and the user wrote nothing either. The failure note the
user sees is never stored here; it is a property of the UI state, not of the chit (BEHAVIOUR.md §3.5,
and the design log is explicit about why — and stricter now that the body is an editable field).

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

**`updatedAt`** — written on every edit (ADR-014). Editing does **not** change `createdAt` or
`localDay`: a chit belongs to the moment it was written, and correcting a typo the next morning
must not move it in the thread or relight a calendar tile.

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

Held in three places, because one is not enough:

1. **A table check constraint** — `text IS NOT NULL OR audioPath IS NOT NULL`, plus
   `(text IS NULL) = (textOrigin IS NULL)`.
2. **The domain model**, as a `freezed` class with a private constructor and an assert, rather
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
3. **Repository tests** for every illegal shape: neither field present; text without an origin;
   an origin without text.

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
| Calendar, the summary | `COUNT(*)` and `COUNT(DISTINCT localDay)` over the month |
| Archive | `ORDER BY localDay DESC, createdAt DESC`, paged |
| Archive, filtered | the same with `WHERE localDay = ?` |
| Backlog: weather search | `WHERE weather = ?` — the index is already there |

The thread and the arc read **one** query; the calendar's heat and its summary are two more.
Three queries behind six readings. That is the mechanism behind DESIGN-SYSTEM.md §7's requirement that the two tabs never disagree: they are
not kept in step, they are the same data.

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
a checked-in schema snapshot (`drift_dev schema dump` / `schema generate`). Snapshots are
committed.

**The rule:** once a version has shipped to a real handset, its migration step is never edited.

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
