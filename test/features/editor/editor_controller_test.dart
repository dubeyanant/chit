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
import 'package:chit/domain/services/audio_player.dart';
import 'package:chit/domain/services/audio_recorder.dart';
import 'package:chit/features/composer/application/recording_controller.dart';
import 'package:chit/features/editor/application/editor_controller.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../support/fake_audio_player.dart';
import '../../support/fake_audio_recorder.dart';
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
  late FakeAudioPlayer player;
  late FakeAudioRecorder recorder;
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
    player = FakeAudioPlayer();
    recorder = FakeAudioRecorder();
    container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(clock),
        chitRepositoryProvider.overrideWithValue(repo),
        audioPlayerProvider.overrideWithValue(player),
        audioRecorderProvider.overrideWithValue(recorder),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await recorder.dispose();
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

    test('answering *discard* leaves the row exactly as it was', () async {
      // BUILD-PLAN.md M6's statement of done, as far as a test can hold it:
      // an edit lives only in the controller until Save, so leaving without
      // saving is not an undo — there is nothing to undo.
      final Chit chit = await given('Room too cold, again.', recorded: true);
      final EditorController editor = await open(chit);

      editor.edit('Something else entirely.');
      expect(stateOf(chit).shouldPromptOnLeave, isTrue);
      // The screen pops; nothing calls save.

      expect(await repo.byId(chit.id), chit);
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

  group('the voice, staged until Save — D5, D6', () {
    /// A take on disk, as the recorder would leave it.
    Future<Recording> aTake([String name = 'new-take']) async {
      final File file = File(p.join(root.path, '$name.m4a'));
      await file.writeAsString('a different take');
      return Recording(
        tempPath: file.path,
        duration: const Duration(seconds: 21),
      );
    }

    File storedFileOf(Chit chit) =>
        File(p.join(root.path, 'audio', '${chit.id}.m4a'));

    test('Remove stages a removal and touches no file', () async {
      final Chit both = await given('Words too.', recorded: true);
      final EditorController editor = await open(both);

      await editor.removeAudio();

      expect(stateOf(both).audio, const AudioEdit.remove());
      expect(stateOf(both).hasAudio, isFalse, reason: 'the microphone returns');
      expect(stateOf(both).audioPath, isNull);
      expect(stateOf(both).isDirty, isTrue);
      expect(stateOf(both).canSave, isTrue, reason: 'the words remain');
      expect(storedFileOf(both).existsSync(), isTrue, reason: 'staged only');
      expect((await repo.byId(both.id))!.hasAudio, isTrue);
    });

    test('removing a recording-only chit\'s take withholds Save', () async {
      final Chit voice = await given(null, recorded: true);
      final EditorController editor = await open(voice);

      await editor.removeAudio();

      expect(stateOf(voice).holdsAnything, isFalse);
      expect(stateOf(voice).canSave, isFalse);
      expect(
        stateOf(voice).shouldPromptOnLeave,
        isTrue,
        reason: 'Cancel is still a change to abandon',
      );
    });

    test('Remove stops the recording sounding', () async {
      final Chit both = await given('Words too.', recorded: true);
      final EditorController editor = await open(both);
      await player.play(id: both.id, path: both.audioPath!);
      expect(player.now.playing, isTrue);

      await editor.removeAudio();

      expect(player.now, Playback.silent);
    });

    test(
      'a kept take is staged as a replacement, and the pill plays it',
      () async {
        final Chit both = await given('Words too.', recorded: true);
        final EditorController editor = await open(both);
        final Recording take = await aTake();

        editor.keepRecording(take);

        expect(stateOf(both).audio, isA<ReplaceAudio>());
        expect(stateOf(both).hasAudio, isTrue);
        expect(stateOf(both).audioPath, take.tempPath, reason: 'absolute');
        expect(stateOf(both).audioDuration, take.duration);
        expect(stateOf(both).isDirty, isTrue);
      },
    );

    test('a take that wrote nothing is nothing kept', () async {
      final Chit both = await given('Words too.', recorded: true);
      final EditorController editor = await open(both);

      editor.keepRecording(null);

      expect(stateOf(both).audio, const AudioEdit.keep());
      expect(stateOf(both).isDirty, isFalse);
    });

    test(
      'a take recorded and removed again on a text-only chit is no change',
      () async {
        final Chit words = await given('Only words.');
        final EditorController editor = await open(words);
        final Recording take = await aTake();

        editor.keepRecording(take);
        expect(stateOf(words).isDirty, isTrue);
        await editor.removeAudio();

        expect(stateOf(words).audio, const AudioEdit.keep());
        expect(stateOf(words).isDirty, isFalse);
        expect(
          File(take.tempPath).existsSync(),
          isFalse,
          reason: 'a staged take nobody will move is discarded',
        );
      },
    );

    test(
      'abandoning discards a staged take and leaves the row alone',
      () async {
        final Chit both = await given('Words too.', recorded: true);
        final EditorController editor = await open(both);
        final Recording take = await aTake();
        editor.keepRecording(take);

        await editor.abandon();

        expect(File(take.tempPath).existsSync(), isFalse);
        expect(storedFileOf(both).existsSync(), isTrue);
        expect(await repo.byId(both.id), both);
      },
    );

    test('saving a replacement moves it in and moves updatedAt', () async {
      final Chit both = await given('Words too.', recorded: true);
      final EditorController editor = await open(both);
      final Recording take = await aTake();
      editor.keepRecording(take);

      clock.moveTo(DateTime(2026, 9, 18, 8, 0));
      await editor.save();

      final Chit edited = (await repo.byId(both.id))!;
      expect(edited.audioDuration, take.duration);
      expect(edited.updatedAt, DateTime(2026, 9, 18, 8, 0));
      expect(edited.text, both.text);
      expect(File(take.tempPath).existsSync(), isFalse, reason: 'moved');
      expect(storedFileOf(both).readAsStringSync(), 'a different take');
    });

    test('saving a removal clears the row and deletes the file', () async {
      final Chit both = await given('Words too.', recorded: true);
      final EditorController editor = await open(both);
      await editor.removeAudio();

      await editor.save();

      final Chit edited = (await repo.byId(both.id))!;
      expect(edited.hasAudio, isFalse);
      expect(storedFileOf(both).existsSync(), isFalse);
    });

    test('saving stops a recording that is about to move', () async {
      final Chit both = await given('Words too.', recorded: true);
      final EditorController editor = await open(both);
      editor.keepRecording(await aTake());
      await player.play(id: both.id, path: both.audioPath!);

      await editor.save();

      expect(player.now, Playback.silent);
    });

    test(
      'a take started for the editor lands in the editor — ADR-065',
      () async {
        // The whole point of the sink: the same recording controller, the same
        // sheet, and Stop & keep arrives here rather than on the open chit.
        final Chit words = await given('Only words.');
        final EditorController editor = await open(words);
        final RecordingController sheet = container.read(
          recordingControllerProvider.notifier,
        );

        expect(await sheet.start(into: editor), isTrue);
        await sheet.stopAndKeep();

        expect(stateOf(words).audio, isA<ReplaceAudio>());
        expect(stateOf(words).audioPath, recorder.take!.tempPath);
      },
    );

    test('a cancelled take leaves the editor as it was', () async {
      final Chit words = await given('Only words.');
      final EditorController editor = await open(words);
      final RecordingController sheet = container.read(
        recordingControllerProvider.notifier,
      );

      await sheet.start(into: editor);
      await sheet.cancel();

      expect(stateOf(words).audio, const AudioEdit.keep());
      expect(stateOf(words).isDirty, isFalse);
    });

    test('a refusal at the tap is recorded on the editor', () async {
      final Chit words = await given('Only words.');
      final EditorController editor = await open(words);
      recorder.permitted = false;

      expect(
        await container
            .read(recordingControllerProvider.notifier)
            .start(into: editor),
        isFalse,
      );

      expect(stateOf(words).microphoneRefused, isTrue);
    });

    test(
      'a refused microphone is said, and unsaid once one is allowed',
      () async {
        final Chit words = await given('Only words.');
        final EditorController editor = await open(words);

        editor.microphoneWasRefused();
        expect(stateOf(words).microphoneRefused, isTrue);
        expect(
          stateOf(words).isDirty,
          isFalse,
          reason: 'a refusal is not an edit',
        );

        editor.recordingStarted();
        expect(stateOf(words).microphoneRefused, isFalse);
      },
    );
  });
}
