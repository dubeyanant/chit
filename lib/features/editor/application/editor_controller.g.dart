// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A saved chit being edited — **ADR-017, ADR-062**.
///
/// **Loaded once, not watched.** The thread and the calendar watch, because
/// two tabs must never disagree (DESIGN-SYSTEM.md §7); the editor is a screen
/// somebody is typing on, and a row re-emitting under a caret is a screen that
/// fights its own user. The only thing that writes this row while the editor
/// is open is the editor.
///
/// **Null means the chit is gone.** The screen leaves rather than drawing
/// nothing — an id can outlive its row across a delete, and a blank screen
/// with a back arrow is a dead end that says nothing about why.
///
/// **Everything done to the recording is staged** (TASKS.md D6): `audio` is
/// an [AudioEdit] that the repository applies at Save and that Cancel throws
/// away. It cannot be otherwise — a chit with neither words nor a take is a
/// row the database refuses — and it is what makes Cancel honest.
///
/// Keyed by id so two chits opened in one session are two states, and
/// auto-disposed so leaving the screen forgets it: unlike the recording
/// controller (ADR-057) nothing here outlives the screen. **Every decision the
/// screen draws is a getter on [EditorState]** (TASKS.md D11), which is what
/// lets ADR-031 hold: there is nothing here a test would need a widget for.

@ProviderFor(EditorController)
final editorControllerProvider = EditorControllerFamily._();

/// A saved chit being edited — **ADR-017, ADR-062**.
///
/// **Loaded once, not watched.** The thread and the calendar watch, because
/// two tabs must never disagree (DESIGN-SYSTEM.md §7); the editor is a screen
/// somebody is typing on, and a row re-emitting under a caret is a screen that
/// fights its own user. The only thing that writes this row while the editor
/// is open is the editor.
///
/// **Null means the chit is gone.** The screen leaves rather than drawing
/// nothing — an id can outlive its row across a delete, and a blank screen
/// with a back arrow is a dead end that says nothing about why.
///
/// **Everything done to the recording is staged** (TASKS.md D6): `audio` is
/// an [AudioEdit] that the repository applies at Save and that Cancel throws
/// away. It cannot be otherwise — a chit with neither words nor a take is a
/// row the database refuses — and it is what makes Cancel honest.
///
/// Keyed by id so two chits opened in one session are two states, and
/// auto-disposed so leaving the screen forgets it: unlike the recording
/// controller (ADR-057) nothing here outlives the screen. **Every decision the
/// screen draws is a getter on [EditorState]** (TASKS.md D11), which is what
/// lets ADR-031 hold: there is nothing here a test would need a widget for.
final class EditorControllerProvider
    extends $AsyncNotifierProvider<EditorController, EditorState?> {
  /// A saved chit being edited — **ADR-017, ADR-062**.
  ///
  /// **Loaded once, not watched.** The thread and the calendar watch, because
  /// two tabs must never disagree (DESIGN-SYSTEM.md §7); the editor is a screen
  /// somebody is typing on, and a row re-emitting under a caret is a screen that
  /// fights its own user. The only thing that writes this row while the editor
  /// is open is the editor.
  ///
  /// **Null means the chit is gone.** The screen leaves rather than drawing
  /// nothing — an id can outlive its row across a delete, and a blank screen
  /// with a back arrow is a dead end that says nothing about why.
  ///
  /// **Everything done to the recording is staged** (TASKS.md D6): `audio` is
  /// an [AudioEdit] that the repository applies at Save and that Cancel throws
  /// away. It cannot be otherwise — a chit with neither words nor a take is a
  /// row the database refuses — and it is what makes Cancel honest.
  ///
  /// Keyed by id so two chits opened in one session are two states, and
  /// auto-disposed so leaving the screen forgets it: unlike the recording
  /// controller (ADR-057) nothing here outlives the screen. **Every decision the
  /// screen draws is a getter on [EditorState]** (TASKS.md D11), which is what
  /// lets ADR-031 hold: there is nothing here a test would need a widget for.
  EditorControllerProvider._({
    required EditorControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'editorControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$editorControllerHash();

  @override
  String toString() {
    return r'editorControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EditorController create() => EditorController();

  @override
  bool operator ==(Object other) {
    return other is EditorControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$editorControllerHash() => r'a3ebcb2c53b2536878e1535d6e1ed048f86b8c6c';

/// A saved chit being edited — **ADR-017, ADR-062**.
///
/// **Loaded once, not watched.** The thread and the calendar watch, because
/// two tabs must never disagree (DESIGN-SYSTEM.md §7); the editor is a screen
/// somebody is typing on, and a row re-emitting under a caret is a screen that
/// fights its own user. The only thing that writes this row while the editor
/// is open is the editor.
///
/// **Null means the chit is gone.** The screen leaves rather than drawing
/// nothing — an id can outlive its row across a delete, and a blank screen
/// with a back arrow is a dead end that says nothing about why.
///
/// **Everything done to the recording is staged** (TASKS.md D6): `audio` is
/// an [AudioEdit] that the repository applies at Save and that Cancel throws
/// away. It cannot be otherwise — a chit with neither words nor a take is a
/// row the database refuses — and it is what makes Cancel honest.
///
/// Keyed by id so two chits opened in one session are two states, and
/// auto-disposed so leaving the screen forgets it: unlike the recording
/// controller (ADR-057) nothing here outlives the screen. **Every decision the
/// screen draws is a getter on [EditorState]** (TASKS.md D11), which is what
/// lets ADR-031 hold: there is nothing here a test would need a widget for.

final class EditorControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          EditorController,
          AsyncValue<EditorState?>,
          EditorState?,
          FutureOr<EditorState?>,
          String
        > {
  EditorControllerFamily._()
    : super(
        retry: null,
        name: r'editorControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A saved chit being edited — **ADR-017, ADR-062**.
  ///
  /// **Loaded once, not watched.** The thread and the calendar watch, because
  /// two tabs must never disagree (DESIGN-SYSTEM.md §7); the editor is a screen
  /// somebody is typing on, and a row re-emitting under a caret is a screen that
  /// fights its own user. The only thing that writes this row while the editor
  /// is open is the editor.
  ///
  /// **Null means the chit is gone.** The screen leaves rather than drawing
  /// nothing — an id can outlive its row across a delete, and a blank screen
  /// with a back arrow is a dead end that says nothing about why.
  ///
  /// **Everything done to the recording is staged** (TASKS.md D6): `audio` is
  /// an [AudioEdit] that the repository applies at Save and that Cancel throws
  /// away. It cannot be otherwise — a chit with neither words nor a take is a
  /// row the database refuses — and it is what makes Cancel honest.
  ///
  /// Keyed by id so two chits opened in one session are two states, and
  /// auto-disposed so leaving the screen forgets it: unlike the recording
  /// controller (ADR-057) nothing here outlives the screen. **Every decision the
  /// screen draws is a getter on [EditorState]** (TASKS.md D11), which is what
  /// lets ADR-031 hold: there is nothing here a test would need a widget for.

  EditorControllerProvider call(String id) =>
      EditorControllerProvider._(argument: id, from: this);

  @override
  String toString() => r'editorControllerProvider';
}

/// A saved chit being edited — **ADR-017, ADR-062**.
///
/// **Loaded once, not watched.** The thread and the calendar watch, because
/// two tabs must never disagree (DESIGN-SYSTEM.md §7); the editor is a screen
/// somebody is typing on, and a row re-emitting under a caret is a screen that
/// fights its own user. The only thing that writes this row while the editor
/// is open is the editor.
///
/// **Null means the chit is gone.** The screen leaves rather than drawing
/// nothing — an id can outlive its row across a delete, and a blank screen
/// with a back arrow is a dead end that says nothing about why.
///
/// **Everything done to the recording is staged** (TASKS.md D6): `audio` is
/// an [AudioEdit] that the repository applies at Save and that Cancel throws
/// away. It cannot be otherwise — a chit with neither words nor a take is a
/// row the database refuses — and it is what makes Cancel honest.
///
/// Keyed by id so two chits opened in one session are two states, and
/// auto-disposed so leaving the screen forgets it: unlike the recording
/// controller (ADR-057) nothing here outlives the screen. **Every decision the
/// screen draws is a getter on [EditorState]** (TASKS.md D11), which is what
/// lets ADR-031 hold: there is nothing here a test would need a widget for.

abstract class _$EditorController extends $AsyncNotifier<EditorState?> {
  late final _$args = ref.$arg as String;
  String get id => _$args;

  FutureOr<EditorState?> build(String id);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<EditorState?>, EditorState?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<EditorState?>, EditorState?>,
              AsyncValue<EditorState?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
