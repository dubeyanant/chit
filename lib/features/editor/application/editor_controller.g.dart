// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(editorChit)
final editorChitProvider = EditorChitFamily._();

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

final class EditorChitProvider
    extends $FunctionalProvider<AsyncValue<Chit?>, Chit?, FutureOr<Chit?>>
    with $FutureModifier<Chit?>, $FutureProvider<Chit?> {
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
  EditorChitProvider._({
    required EditorChitFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'editorChitProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$editorChitHash();

  @override
  String toString() {
    return r'editorChitProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Chit?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Chit?> create(Ref ref) {
    final argument = this.argument as String;
    return editorChit(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EditorChitProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$editorChitHash() => r'acbed83d43abc01f608ab9c2eacdd14249dd2707';

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

final class EditorChitFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Chit?>, String> {
  EditorChitFamily._()
    : super(
        retry: null,
        name: r'editorChitProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

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

  EditorChitProvider call(String id) =>
      EditorChitProvider._(argument: id, from: this);

  @override
  String toString() => r'editorChitProvider';
}
