// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speech_recognizer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The recogniser the app runs on.
///
/// Unimplemented on purpose, for the reason `audioRecorderProvider` is:
/// `domain` cannot import `data` (ARCHITECTURE.md §1), so `main.dart` supplies
/// `OnDeviceSpeechRecognizer` and tests supply a fake.

@ProviderFor(speechRecognizer)
final speechRecognizerProvider = SpeechRecognizerProvider._();

/// The recogniser the app runs on.
///
/// Unimplemented on purpose, for the reason `audioRecorderProvider` is:
/// `domain` cannot import `data` (ARCHITECTURE.md §1), so `main.dart` supplies
/// `OnDeviceSpeechRecognizer` and tests supply a fake.

final class SpeechRecognizerProvider
    extends
        $FunctionalProvider<
          SpeechRecognizer,
          SpeechRecognizer,
          SpeechRecognizer
        >
    with $Provider<SpeechRecognizer> {
  /// The recogniser the app runs on.
  ///
  /// Unimplemented on purpose, for the reason `audioRecorderProvider` is:
  /// `domain` cannot import `data` (ARCHITECTURE.md §1), so `main.dart` supplies
  /// `OnDeviceSpeechRecognizer` and tests supply a fake.
  SpeechRecognizerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'speechRecognizerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$speechRecognizerHash();

  @$internal
  @override
  $ProviderElement<SpeechRecognizer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SpeechRecognizer create(Ref ref) {
    return speechRecognizer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpeechRecognizer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpeechRecognizer>(value),
    );
  }
}

String _$speechRecognizerHash() => r'4bea6e063c8738d2bc3adf37402bacdf685784f9';
