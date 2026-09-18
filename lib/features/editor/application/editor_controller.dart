import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/chit.dart';
import '../../../domain/repositories/chit_repository.dart';

part 'editor_controller.g.dart';

/// The chit the editor is showing — **ADR-017**.
///
/// A one-shot read rather than a stream. The thread and the calendar watch,
/// because two tabs must never disagree (DESIGN-SYSTEM.md §7); the editor is
/// a screen somebody is typing on, and a row re-emitting under a caret is a
/// screen that fights its own user. The only thing that writes this row while
/// the editor is open is the editor.
///
/// **Null means the chit is gone.** The screen leaves rather than drawing
/// nothing — an id can outlive its row across a delete, and a blank screen
/// with a back arrow is a dead end that says nothing about why.
///
/// Keyed by id so two chits opened in one session are two states, and
/// auto-disposed so leaving the screen forgets it: unlike the recording
/// controller (ADR-057) nothing here outlives the screen.
@riverpod
Future<Chit?> editorChit(Ref ref, String id) =>
    ref.watch(chitRepositoryProvider).byId(id);
