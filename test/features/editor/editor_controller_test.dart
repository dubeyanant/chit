import 'dart:io';

import 'package:chit/core/clock.dart';
import 'package:chit/data/audio/audio_store.dart';
import 'package:chit/data/db/app_database.dart';
import 'package:chit/data/repositories/chit_repository_impl.dart';
import 'package:chit/domain/models/ambient_stamp.dart';
import 'package:chit/domain/models/audio_edit.dart';
import 'package:chit/domain/models/chit.dart';
import 'package:chit/domain/models/editor_state.dart';
import 'package:chit/domain/repositories/chit_repository.dart';
import 'package:chit/features/editor/application/editor_controller.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../support/fake_clock.dart';

/// The editor through a bare `ProviderContainer` — ADR-031, TASKS.md D11.
///
/// Every control on the screen turns on a getter of [EditorState], and this
/// is where those getters are held to their meaning: dirty is *differs from
/// what was loaded*, Save needs a change *and* a chit to write, and the prompt
/// guards a change. What the slip looks like is a device check.
void main() {
  late Directory root;
  late AppDatabase db;
  late FakeClock clock;
  late ChitRepository repo;
  late ProviderContainer container;

  /// Thursday 17 September 2026, 3pm.
  final DateTime afternoon = DateTime(2026, 9, 17, 15);

  setUp(() async {
    root = await Directory.systemTemp.createTemp('chit-editor-test');
    db = AppDatabase(NativeDatabase.memory());
    clock = FakeClock(afternoon);
    repo = ChitRepositoryImpl(
      dao: db.chitDao,
      audio: AudioStore(Future<Directory>.value(root)),
      clock: clock,
    );
    container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(clock),
        chitRepositoryProvider.overrideWithValue(repo),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
    if (root.existsSync()) await root.delete(recursive: true);
  });

  Future<Chit> given(String? text, {bool recorded = false}) async {
    String? temp;
    if (recorded) {
      temp = p.join(root.path, 'take.m4a');
      await File(temp).writeAsString('audio');
    }
    return repo.save(
      stamp: AmbientStamp(capturedAt: afternoon),
      text: text,
      audioTempPath: temp,
      audioDuration: recorded ? const Duration(seconds: 4) : null,
    );
  }

  /// The editor open on [chit], held so the auto-dispose family survives the
  /// test the way the screen holds it.
  Future<EditorController> open(Chit chit) async {
    container.listen<AsyncValue<EditorState?>>(
      editorControllerProvider(chit.id),
      (AsyncValue<EditorState?>? _, AsyncValue<EditorState?> _) {},
    );
    await container.read(editorControllerProvider(chit.id).future);
    return container.read(editorControllerProvider(chit.id).notifier);
  }

  EditorState stateOf(Chit chit) =>
      container.read(editorControllerProvider(chit.id)).value!;

  group('loading', () {
    test('it opens on the chit the id names', () async {
      final Chit wanted = await given('Room too cold, again.');
      await given('And a second one, so the id has to do work.');

      await open(wanted);

      expect(stateOf(wanted).chit, wanted);
      expect(stateOf(wanted).text, 'Room too cold, again.');
    });

    test(
      'an id with no row answers null, and the screen leaves on it',
      () async {
        // An id outlives its row across a delete (group F), which is the case
        // this exists for. `byId` answers null rather than throwing.
        expect(
          await container.read(editorControllerProvider('gone').future),
          isNull,
        );
      },
    );

    test('a recording-only chit opens with an empty field', () async {
      final Chit voice = await given(null, recorded: true);
      await open(voice);
      expect(stateOf(voice).text, '');
      expect(stateOf(voice).hasAudio, isTrue);
    });
  });

  group('dirty is *differs from what was loaded*', () {
    test('an untouched chit is not dirty, and offers no Save', () async {
      final Chit chit = await given('Room too cold, again.');
      await open(chit);

      expect(stateOf(chit).isDirty, isFalse);
      expect(stateOf(chit).canSave, isFalse);
      expect(stateOf(chit).shouldPromptOnLeave, isFalse);
    });

    test('a changed word is dirty', () async {
      final Chit chit = await given('Room too cold, again.');
      final EditorController editor = await open(chit);

      editor.edit('Room too warm, again.');

      expect(stateOf(chit).isDirty, isTrue);
      expect(stateOf(chit).canSave, isTrue);
      expect(stateOf(chit).shouldPromptOnLeave, isTrue);
    });

    test('typing a character and deleting it again is not a change', () async {
      final Chit chit = await given('Room too cold, again.');
      final EditorController editor = await open(chit);

      editor.edit('Room too cold, again.x');
      editor.edit('Room too cold, again.');

      expect(stateOf(chit).isDirty, isFalse);
    });

    test('a trailing space the save would trim is not a change', () async {
      final Chit chit = await given('Room too cold, again.');
      final EditorController editor = await open(chit);

      editor.edit('Room too cold, again. ');

      expect(stateOf(chit).isDirty, isFalse);
    });
  });

  group('Save needs a change and a chit to write — D7', () {
    test('emptying a text-only chit withholds Save', () async {
      final Chit chit = await given('Room too cold, again.');
      final EditorController editor = await open(chit);

      editor.edit('   ');

      expect(stateOf(chit).isDirty, isTrue, reason: 'it *is* a change');
      expect(stateOf(chit).holdsAnything, isFalse);
      expect(stateOf(chit).canSave, isFalse);
      expect(
        stateOf(chit).shouldPromptOnLeave,
        isTrue,
        reason: 'the prompt guards a change, not an available Save',
      );
    });

    test('emptying the words of a recorded chit still saves', () async {
      final Chit both = await given('Words too.', recorded: true);
      final EditorController editor = await open(both);

      editor.edit('');

      expect(stateOf(both).holdsAnything, isTrue);
      expect(stateOf(both).canSave, isTrue);
    });
  });

  group('save', () {
    test('writes the words and moves updatedAt, and nothing else', () async {
      final Chit chit = await given('Trane 20 late.');
      final EditorController editor = await open(chit);

      editor.edit('Train 20 late.');
      clock.moveTo(DateTime(2026, 9, 18, 8, 0));
      await editor.save();

      final Chit edited = (await repo.byId(chit.id))!;
      expect(edited.text, 'Train 20 late.');
      expect(edited.updatedAt, DateTime(2026, 9, 18, 8, 0));
      expect(edited.createdAt, chit.createdAt);
      expect(edited.localDay, chit.localDay);
      expect(edited.stamp, chit.stamp);
    });

    test('does nothing when there is nothing to save', () async {
      final Chit chit = await given('Room too cold, again.');
      final EditorController editor = await open(chit);

      clock.moveTo(DateTime(2026, 9, 18, 8, 0));
      await editor.save();

      expect((await repo.byId(chit.id))!.updatedAt, chit.updatedAt);
    });

    test('a text-only edit sends AudioEdit.keep', () async {
      // The default is *leave it alone*. Group E adds the other two; until
      // then nothing the controller does can reach a recording.
      final Chit both = await given('Words too.', recorded: true);
      final EditorController editor = await open(both);

      editor.edit('Different words.');
      expect(stateOf(both).audio, const AudioEdit.keep());
      await editor.save();

      expect((await repo.byId(both.id))!.audioPath, both.audioPath);
    });
  });
}
