// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'composer_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ComposerState {

/// Captured when the chit opened. Weather and location may arrive a moment
/// later (ADR-007); [AmbientStamp.capturedAt] does not move when they do.
 AmbientStamp get stamp;/// The field's live content. The user owns it throughout — the recogniser
/// writes into it once and never again (BEHAVIOUR.md §3.4.1).
 String get text;/// Where those words came from. `null` while there are none.
 TextOrigin? get textOrigin;/// Whether the five-second prompt is being offered — BEHAVIOUR.md §3.3.
///
/// It is state rather than a widget's own business because the five
/// seconds have to survive a rebuild: a timer in the widget restarts
/// every time the field is laid out again (ARCHITECTURE.md §4.3).
 bool get showPrompt;/// Set once a recording is kept, and cleared only by Discard. **M5.**
 String? get audioTempPath;/// How long that recording runs. **M5.**
 Duration? get audioDuration;/// Whether the recording sheet is up. **M5.**
 bool get isRecording;/// Drives the note of BEHAVIOUR.md §3.5 and nothing else. **M5.**
///
/// The note is a property of the state and never a value of [text]: a
/// failure written into the field is a failure the user has to delete
/// before they can write.
 bool get sttFailed;
/// Create a copy of ComposerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComposerStateCopyWith<ComposerState> get copyWith => _$ComposerStateCopyWithImpl<ComposerState>(this as ComposerState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ComposerState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComposerState&&(identical(other.stamp, _this.stamp) || other.stamp == _this.stamp)&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.textOrigin, _this.textOrigin) || other.textOrigin == _this.textOrigin)&&(identical(other.showPrompt, _this.showPrompt) || other.showPrompt == _this.showPrompt)&&(identical(other.audioTempPath, _this.audioTempPath) || other.audioTempPath == _this.audioTempPath)&&(identical(other.audioDuration, _this.audioDuration) || other.audioDuration == _this.audioDuration)&&(identical(other.isRecording, _this.isRecording) || other.isRecording == _this.isRecording)&&(identical(other.sttFailed, _this.sttFailed) || other.sttFailed == _this.sttFailed));
}


@override
int get hashCode {
  final _this = this as ComposerState;
  return Object.hash(runtimeType,_this.stamp,_this.text,_this.textOrigin,_this.showPrompt,_this.audioTempPath,_this.audioDuration,_this.isRecording,_this.sttFailed);
}

@override
String toString() {
  final _this = this as ComposerState;
  return 'ComposerState(stamp: ${_this.stamp}, text: ${_this.text}, textOrigin: ${_this.textOrigin}, showPrompt: ${_this.showPrompt}, audioTempPath: ${_this.audioTempPath}, audioDuration: ${_this.audioDuration}, isRecording: ${_this.isRecording}, sttFailed: ${_this.sttFailed})';
}


}

/// @nodoc
abstract mixin class $ComposerStateCopyWith<$Res>  {
  factory $ComposerStateCopyWith(ComposerState value, $Res Function(ComposerState) _then) = _$ComposerStateCopyWithImpl;
@useResult
$Res call({
 AmbientStamp stamp, String text, TextOrigin? textOrigin, bool showPrompt, String? audioTempPath, Duration? audioDuration, bool isRecording, bool sttFailed
});


$AmbientStampCopyWith<$Res> get stamp;

}
/// @nodoc
class _$ComposerStateCopyWithImpl<$Res>
    implements $ComposerStateCopyWith<$Res> {
  _$ComposerStateCopyWithImpl(this._self, this._then);

  final ComposerState _self;
  final $Res Function(ComposerState) _then;

/// Create a copy of ComposerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stamp = null,Object? text = null,Object? textOrigin = freezed,Object? showPrompt = null,Object? audioTempPath = freezed,Object? audioDuration = freezed,Object? isRecording = null,Object? sttFailed = null,}) {
  return _then(ComposerState(
stamp: null == stamp ? _self.stamp : stamp // ignore: cast_nullable_to_non_nullable
as AmbientStamp,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,textOrigin: freezed == textOrigin ? _self.textOrigin : textOrigin // ignore: cast_nullable_to_non_nullable
as TextOrigin?,showPrompt: null == showPrompt ? _self.showPrompt : showPrompt // ignore: cast_nullable_to_non_nullable
as bool,audioTempPath: freezed == audioTempPath ? _self.audioTempPath : audioTempPath // ignore: cast_nullable_to_non_nullable
as String?,audioDuration: freezed == audioDuration ? _self.audioDuration : audioDuration // ignore: cast_nullable_to_non_nullable
as Duration?,isRecording: null == isRecording ? _self.isRecording : isRecording // ignore: cast_nullable_to_non_nullable
as bool,sttFailed: null == sttFailed ? _self.sttFailed : sttFailed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ComposerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AmbientStampCopyWith<$Res> get stamp {
  
  return $AmbientStampCopyWith<$Res>(_self.stamp, (value) {
    return _then(_self.copyWith(stamp: value));
  });
}
}


/// Adds pattern-matching-related methods to [ComposerState].
extension ComposerStatePatterns on ComposerState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComposerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComposerState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComposerState value)  $default,){
final _that = this;
switch (_that) {
case _ComposerState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComposerState value)?  $default,){
final _that = this;
switch (_that) {
case _ComposerState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AmbientStamp stamp,  String text,  TextOrigin? textOrigin,  bool showPrompt,  String? audioTempPath,  Duration? audioDuration,  bool isRecording,  bool sttFailed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComposerState() when $default != null:
return $default(_that.stamp,_that.text,_that.textOrigin,_that.showPrompt,_that.audioTempPath,_that.audioDuration,_that.isRecording,_that.sttFailed);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AmbientStamp stamp,  String text,  TextOrigin? textOrigin,  bool showPrompt,  String? audioTempPath,  Duration? audioDuration,  bool isRecording,  bool sttFailed)  $default,) {final _that = this;
switch (_that) {
case _ComposerState():
return $default(_that.stamp,_that.text,_that.textOrigin,_that.showPrompt,_that.audioTempPath,_that.audioDuration,_that.isRecording,_that.sttFailed);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AmbientStamp stamp,  String text,  TextOrigin? textOrigin,  bool showPrompt,  String? audioTempPath,  Duration? audioDuration,  bool isRecording,  bool sttFailed)?  $default,) {final _that = this;
switch (_that) {
case _ComposerState() when $default != null:
return $default(_that.stamp,_that.text,_that.textOrigin,_that.showPrompt,_that.audioTempPath,_that.audioDuration,_that.isRecording,_that.sttFailed);case _:
  return null;

}
}

}

/// @nodoc


class _ComposerState extends ComposerState {
  const _ComposerState({required this.stamp, this.text = '', this.textOrigin, this.showPrompt = false, this.audioTempPath, this.audioDuration, this.isRecording = false, this.sttFailed = false}): super._();
  

/// Captured when the chit opened. Weather and location may arrive a moment
/// later (ADR-007); [AmbientStamp.capturedAt] does not move when they do.
@override final  AmbientStamp stamp;
/// The field's live content. The user owns it throughout — the recogniser
/// writes into it once and never again (BEHAVIOUR.md §3.4.1).
@override@JsonKey() final  String text;
/// Where those words came from. `null` while there are none.
@override final  TextOrigin? textOrigin;
/// Whether the five-second prompt is being offered — BEHAVIOUR.md §3.3.
///
/// It is state rather than a widget's own business because the five
/// seconds have to survive a rebuild: a timer in the widget restarts
/// every time the field is laid out again (ARCHITECTURE.md §4.3).
@override@JsonKey() final  bool showPrompt;
/// Set once a recording is kept, and cleared only by Discard. **M5.**
@override final  String? audioTempPath;
/// How long that recording runs. **M5.**
@override final  Duration? audioDuration;
/// Whether the recording sheet is up. **M5.**
@override@JsonKey() final  bool isRecording;
/// Drives the note of BEHAVIOUR.md §3.5 and nothing else. **M5.**
///
/// The note is a property of the state and never a value of [text]: a
/// failure written into the field is a failure the user has to delete
/// before they can write.
@override@JsonKey() final  bool sttFailed;

/// Create a copy of ComposerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComposerStateCopyWith<_ComposerState> get copyWith => __$ComposerStateCopyWithImpl<_ComposerState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComposerState&&(identical(other.stamp, stamp) || other.stamp == stamp)&&(identical(other.text, text) || other.text == text)&&(identical(other.textOrigin, textOrigin) || other.textOrigin == textOrigin)&&(identical(other.showPrompt, showPrompt) || other.showPrompt == showPrompt)&&(identical(other.audioTempPath, audioTempPath) || other.audioTempPath == audioTempPath)&&(identical(other.audioDuration, audioDuration) || other.audioDuration == audioDuration)&&(identical(other.isRecording, isRecording) || other.isRecording == isRecording)&&(identical(other.sttFailed, sttFailed) || other.sttFailed == sttFailed));
}


@override
int get hashCode {
    return Object.hash(runtimeType,stamp,text,textOrigin,showPrompt,audioTempPath,audioDuration,isRecording,sttFailed);
}

@override
String toString() {
    return 'ComposerState(stamp: $stamp, text: $text, textOrigin: $textOrigin, showPrompt: $showPrompt, audioTempPath: $audioTempPath, audioDuration: $audioDuration, isRecording: $isRecording, sttFailed: $sttFailed)';
}


}

/// @nodoc
abstract mixin class _$ComposerStateCopyWith<$Res> implements $ComposerStateCopyWith<$Res> {
  factory _$ComposerStateCopyWith(_ComposerState value, $Res Function(_ComposerState) _then) = __$ComposerStateCopyWithImpl;
@override @useResult
$Res call({
 AmbientStamp stamp, String text, TextOrigin? textOrigin, bool showPrompt, String? audioTempPath, Duration? audioDuration, bool isRecording, bool sttFailed
});


@override $AmbientStampCopyWith<$Res> get stamp;

}
/// @nodoc
class __$ComposerStateCopyWithImpl<$Res>
    implements _$ComposerStateCopyWith<$Res> {
  __$ComposerStateCopyWithImpl(this._self, this._then);

  final _ComposerState _self;
  final $Res Function(_ComposerState) _then;

/// Create a copy of ComposerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stamp = null,Object? text = null,Object? textOrigin = freezed,Object? showPrompt = null,Object? audioTempPath = freezed,Object? audioDuration = freezed,Object? isRecording = null,Object? sttFailed = null,}) {
  return _then(_ComposerState(
stamp: null == stamp ? _self.stamp : stamp // ignore: cast_nullable_to_non_nullable
as AmbientStamp,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,textOrigin: freezed == textOrigin ? _self.textOrigin : textOrigin // ignore: cast_nullable_to_non_nullable
as TextOrigin?,showPrompt: null == showPrompt ? _self.showPrompt : showPrompt // ignore: cast_nullable_to_non_nullable
as bool,audioTempPath: freezed == audioTempPath ? _self.audioTempPath : audioTempPath // ignore: cast_nullable_to_non_nullable
as String?,audioDuration: freezed == audioDuration ? _self.audioDuration : audioDuration // ignore: cast_nullable_to_non_nullable
as Duration?,isRecording: null == isRecording ? _self.isRecording : isRecording // ignore: cast_nullable_to_non_nullable
as bool,sttFailed: null == sttFailed ? _self.sttFailed : sttFailed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ComposerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AmbientStampCopyWith<$Res> get stamp {
  
  return $AmbientStampCopyWith<$Res>(_self.stamp, (value) {
    return _then(_self.copyWith(stamp: value));
  });
}
}

// dart format on
