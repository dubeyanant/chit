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
  IntColumn     get audioMs      => integer().nullable()();
  TextColumn    get weather      => textEnum<WeatherCondition>().nullable()();
  RealColumn    get lat          => real().nullable()();
  RealColumn    get lon          => real().nullable()();
  TextColumn    get motion       => textEnum<MotionState>().nullable()();  // v2, ADR-037
  IntColumn     get updatedAt    => integer()();

  @override Set<Column> get primaryKey => {id};
}
```

Indexes: `localDay` (every calendar and archive query groups on it), `createdAt` (the timeline and
ordering within a day), `weather` (backlog item 2, and it costs nothing now). **Not `motion`** —
nothing queries it, and an index on speculation is the thing YAGNI forbids.

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

**`createdAt` and `localDay` together** — `createdAt` places the mark on the timeline;
`localDay` decides which day the chit belongs to. Computed once, at write time, in the
repository. A chit written at 00:20 IST belongs to that morning permanently, and nothing
recomputes it when the device changes timezone (ADR-006).

`createdAt` is the moment the chit was **saved** — ADR-040. There is one time column and the
stamp is what it holds, so this is also the instant the ambient reading was taken. *It used to
be the moment the chit was **opened** (ADR-021), which meant a chit opened at 23:58 and saved at
00:05 was filed on the previous day; that failure is now unreachable rather than defended
against.*

**`body`** — what the chit says, typed. `NULL` on a chit that is only a recording.

**Blank is not a value.** The repository trims what it is given and stores whitespace-only text
as `NULL`, so a field of spaces beside a recording is an ordinary recording-only chit rather than an
error, and a field of spaces on its own is the chit §3.1 refuses to save. The column enforces
the same thing — `length(trim(body)) > 0` — so no other caller can disagree. Storing the
trimmed text is a choice: the edges of a slip are not content, and nothing in the design asks
for leading whitespace to survive.

*There was a `textOrigin` column here, saying whether the words were typed, transcribed, or a
transcript the user had corrected. It went with transcription in **schema v3** — ADR-058.*

**`audioPath`** — relative, always. An absolute iOS container path saved today is dead after
the next app update.

**`lat` / `lon`** — stored, never displayed. BEHAVIOUR.md §3.6: the pin says a place was recorded and
stops there. Nothing in the app reverse-geocodes these, and if a future feature wants coarse
places ("home", "office") that is a new decision, not an existing capability.

**`motion`** — what the phone was doing when the chit was opened. Added in **schema v2**
(ADR-037), and read off the speed of the same fix that produced `lat`/`lon`, so it costs no
second permission and no second call. One of `stationary`, `walking`, `traveling`, `flying`, or
`NULL` when no usable speed arrived — which is most chits, since indoors there is rarely one.

`stationary` is stored and never drawn (BEHAVIOUR.md §3.6.1). It is also where an unusable
reading lands, so a noisy speed can slow a chit down and can never put a plane on one.

**There is no `CHECK (motion IS NULL OR lat IS NOT NULL)`**, though it would hold for every row
the app writes today. Motion comes off the fix because that is how this milestone reads it —
that is a fact about the implementation, not about what a chit *is*, and the five constraints in
§2 are all the second kind.

They are as precise as the fix was. ADR-016 asks for high accuracy and accepts a coarse fix
when that is all the user granted, so this column may hold anything from a rooftop-accurate
position to a neighbourhood. The display promise is unchanged — no name, no coordinate, no map
— but the *row* is now precise enough to reconstruct an address, which is a fact about this
database rather than about the UI. It is why ADR-004's "local only" is load-bearing, and it is
a constraint on any sync design rather than an argument against the accuracy.

**`updatedAt`** — written on every edit (ADR-014), and set at insert to the moment the row was
written. Editing does **not** change `createdAt` or `localDay`: a chit belongs to the moment it
was written, and correcting a typo the next morning must not move it in the thread or relight a
calendar tile.

Since ADR-040 `createdAt` and `updatedAt` are **the same instant at insert**, because the chit
is stamped when it is saved rather than when it was opened. They diverge on the first edit and
never before.

**`updateAmbient` moves neither of them**, and that is a rule rather than an oversight — ADR-042.
A save writes the row and then patches the three ambient fields when a fresh reading lands a
moment later; that patch must not move `createdAt` (it would move the chit in the thread and,
across a midnight, onto another day) and must not move `updatedAt` (it would claim the user had
edited something). An edit is the user's act and nothing else may claim to be one.

---

## 2. The invariant

> **At least one of `text` and `audioPath` is present.** — README §5

A chit with neither is not a chit; it is the untouched composer that §3.1 refuses to save.
That leaves three legal shapes, all ordinary:

| | `text` | `audioPath` |
|---|---|---|
| words alone | ● | — |
| words and a recording | ● | ● |
| a recording alone | — | ● |

Nothing in the schema orders these; they are states a row can be in, not a lifecycle it walks.
*There were four until ADR-058, because `textOrigin` split the middle one into a transcript and
a corrected transcript.*

Held in three places, because one is not enough — and each is tested where it lives, because an
assert is compiled out of a release build, a check constraint says nothing about *why*, and a
repository is one caller among however many a later milestone adds.

1. **Five table check constraints**, which is what survives a release build:

   ```sql
   CHECK (body IS NOT NULL OR audio_path IS NOT NULL)
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
   Chit._({ String? text, String? audioPath, ... })
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
| Today, the timeline | `WHERE localDay BETWEEN ? AND ?` over three days; positions derived in Dart from `createdAt` |
| Calendar, the heat | `SELECT localDay, COUNT(*) WHERE localDay BETWEEN ? AND ? GROUP BY localDay` |
| Calendar, the summary | the same rows: the total is their sum, the distinct-day count is how many there are |
| Archive | `ORDER BY localDay DESC, createdAt DESC`, paged |
| Archive, filtered | `watchDay` — the thread's own query, because *one day's chits, newest first* is one question |
| Calendar, the chevrons | `SELECT localDay / 100 GROUP BY localDay / 100` — every written month, so a chevron never lands on an empty one (ADR-047) |
| Backlog: weather search | `WHERE weather = ?` — the index is already there |

The calendar's density and its month summary read one query between them. *This used to say the
summary was a second query of its own; it is not — `COUNT(*)` and `COUNT(DISTINCT localDay)`
over a month are the sum and the length of the rows the density already has, and a second round
trip to learn them would be a second thing to keep in step.* Four queries behind six readings,
and that is the mechanism behind DESIGN-SYSTEM.md §7's requirement that the two tabs never
disagree: they are not kept in step, they are the same data.

*It was three until ADR-024.* The thread and the arc used to read the same rows, which was a
small and pleasing property; the timeline covers three days and the thread covers one, so they
cannot any more. That is a real cost of the decision and it is written in the ADR as one.

The DAO holds five. `watchDay`, `watchDaySummaries` and `watchArchive` arrived with M1;
**`watchDayRange(fromDay, toDay)` arrived with M2 group H**, for the timeline. It reads
**oldest first**, where `watchDay` reads newest first: a thread is read down and a strip is
read along, so each query hands its screen the order it draws in. **`watchWrittenMonths`
arrived with M4** (ADR-047), a `GROUP BY` over the indexed `localDay` that answers `yyyymm`
values, so the chevrons know where they may land. Filtering the archive by date turned out to
need no query of its own — it is `watchDay`. Searching on weather arrives with the screen that
asks for it (the backlog) — a query with no caller is a query nobody has run.

Count-to-density (four steps, BEHAVIOUR.md §4.2) is *not* in the query. It is a design scale and lives
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
and no path that changes or removes `audioPath` on an existing chit. Deleting the
whole chit is the only thing that deletes a recording.

---

## 6. Migrations

**There are none, on purpose** — ADR-059. `schemaVersion` is **1** and stays there; changing a
table changes the schema, and an install carrying the old shape is reinstalled. `onUpgrade`
throws a message saying exactly that, because a database the app cannot trust should fail at
`open` rather than three screens later as a column that is quietly missing.

*There were three versions, with a step each and a committed snapshot each: v1 from M1, v2
adding `chits.motion` (ADR-037), v3 dropping `chits.text_origin` (ADR-058). They went along with
`drift_schemas/`, `test/data/db/generated/` and `migration_test.dart` while chit was still only
ever installed on the owner's own phone.* A migration is a promise made to rows that exist, and
the app has none it would be sad to lose.

### What comes back, and when

**The trigger is data somebody would miss** — the first install that is not a development one.
Open item 38 carries it. What returns is all of it, not half:

```bash
dart run drift_dev schema dump lib/data/db/app_database.dart drift_schemas/
dart run drift_dev schema generate drift_schemas/ test/data/db/generated/
```

- One `from → to` step per version, and **once a version has shipped, its step and its snapshot
  are never edited**.
- **Steps gated on both ends** — `from < n && to >= n`. A step that ignored `to` would rebuild a
  v2 database into the v3 shape and still call it v2. That bug was real, and the test caught it
  by asking for an intermediate version on the way past.
- A test that migrates **and reads rows back**. `migrateAndValidate` inspects the schema, not the
  contents; a table rebuild is exactly the kind of migration that produces the right shape and
  loses what was in it.
- **Nothing is backfilled.** There is no way to know what a phone was doing last Tuesday, and a
  guess written into a row is indistinguishable from a fact a month later.

Those four lines are the whole of what was learned the first time round, which is why they are
here rather than only in git.

Changes already visible on the horizon, so the shape does not surprise us:

- OPEN-QUESTIONS.md §8.1 (where the editor lives) — no schema change at all; the columns are already here.
- Backlog 1 (coarse place, what was playing) — new nullable columns.
- Backlog 7 (chit threading) — a nullable `replyToId` self-reference.

None of these break the invariant of §2, which is the part worth protecting.

---

## 7. Seed data for development

A seeder behind a compile-time flag, writing chits across about six weeks so the calendar has
something to shade and the archive has something to page. **It exists as of M4 group A** —
`lib/data/dev/debug_seeder.dart`, owed since M2 as PROGRESS.md open item 10.

```bash
flutter run --dart-define=CHIT_SEED=seed     # writes the fixture; a second run writes nothing
flutter run --dart-define=CHIT_SEED=clear    # removes exactly what was seeded
```

**Any build mode, `--release` included**, as long as the define is given; a build that was not
given it does not carry the branch. *It was gated on `kDebugMode` as well for one commit, and
that cost a device pass: a handset run in release ignored the flag without a word.* The define
is already the explicit act, and a second gate behind it protected nothing. It runs off the
critical path like the orphan sweep, and the console says what it did — which means **watch
the console**: an error there is the only place a seeder that fell over will say so.

Its recordings are written to the app's cache directory — §5's `<app cache>`, where a real
recording sits before Save — and moved by `AudioStore.keep` like any other.
*`Directory.systemTemp` was tried first and is not writable on Android.*

**They are playable, and they were not until M5.** Each is a quiet 440Hz tone at the length the
row claims — a WAV wearing the `.m4a` extension ADR-008 fixes, since encoding AAC in Dart is not
on the table and Android's extractor sniffs the content anyway (iOS is open item 37). *They were
thirty-eight bytes of ASCII until the first handset pass tried to play one*: a file no decoder
can open draws a control that does nothing, which DESIGN-SYSTEM.md §6.4 forbids, and it is
indistinguishable from playback being broken. A **tone rather than silence**, for the same
reason — silence cannot be told apart from a player that is not working, and telling those two
apart is open item 32.

**Twenty chits, dated relative to the day it runs.** Yesterday and the day before hold five
each — density step four on the calendar, and ten marks across two days on the timeline, which
is the crowding PROGRESS.md item 15 has wanted to look at since M2. Then a three, a two, and
singles back to six weeks ago, three of them in the previous month so the chevrons have
somewhere to go. Today is left alone: it belongs to whoever is holding the phone.

**Every seeded id starts with `seed-`**, and that is the whole of how the rows are told apart
from a person's own. Seeding is idempotent — a row whose id exists is skipped — and clearing
deletes exactly the seeded rows and the recordings they point at, with no ledger, no preference
and no column added for a tool. It writes through the DAO rather than the repository because
the repository generates its ids; `localDay` still comes from `Chit.localDayOf`, so the pairing
ADR-006 protects holds. A seeded recording is a real file placed by `AudioStore.keep`, so the
row points at something the way a real one does; it is not audio, and these rows are cleared
before M5 gives the pill anything to play.

Sample text is four words and mundane — *"Train 20 late."* The design log is right that
literary placeholder copy makes a screen read as a demonstration, and it will mislead us here
exactly as it did there. The fixture covers all three shapes of §2 — and especially the
recording with `NULL` text, which is the shape most likely to be forgotten until it appears in
front of a user — plus every weather word, a chit with no fix, a chit with no
weather, and each of the three motion marks. `test/data/debug_seeder_test.dart` holds all of
that, and the two claims that fail quietly on a handset: that seeding twice doubles nothing,
and that clearing leaves a chit somebody wrote alone.
