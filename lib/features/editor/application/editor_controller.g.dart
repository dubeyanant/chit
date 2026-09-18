// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EditorController)
final editorControllerProvider = EditorControllerFamily._();

final class EditorControllerProvider
    extends $AsyncNotifierProvider<EditorController, EditorState?> {
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

  EditorControllerProvider call(String id) =>
      EditorControllerProvider._(argument: id, from: this);

  @override
  String toString() => r'editorControllerProvider';
}

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
