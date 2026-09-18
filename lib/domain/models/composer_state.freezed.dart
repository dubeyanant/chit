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

 AmbientStamp get stamp; String get text; bool get showPrompt; String? get audioTempPath; Duration? get audioDuration; bool get isRecording; bool get microphoneRefused;
/// Create a copy of ComposerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComposerStateCopyWith<ComposerState> get copyWith => _$ComposerStateCopyWithImpl<ComposerState>(this as ComposerState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ComposerState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComposerState&&(identical(other.stamp, _this.stamp) || other.stamp == _this.stamp)&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.showPrompt, _this.showPrompt) || other.showPrompt == _this.showPrompt)&&(identical(other.audioTempPath, _this.audioTempPath) || other.audioTempPath == _this.audioTempPath)&&(identical(other.audioDuration, _this.audioDuration) || other.audioDuration == _this.audioDuration)&&(identical(other.isRecording, _this.isRecording) || other.isRecording == _this.isRecording)&&(identical(other.microphoneRefused, _this.microphoneRefused) || other.microphoneRefused == _this.microphoneRefused));
}


@override
int get hashCode {
  final _this = this as ComposerState;
  return Object.hash(runtimeType,_this.stamp,_this.text,_this.showPrompt,_this.audioTempPath,_this.audioDuration,_this.isRecording,_this.microphoneRefused);
}

@override
String toString() {
  final _this = this as ComposerState;
  return 'ComposerState(stamp: ${_this.stamp}, text: ${_this.text}, showPrompt: ${_this.showPrompt}, audioTempPath: ${_this.audioTempPath}, audioDuration: ${_this.audioDuration}, isRecording: ${_this.isRecording}, microphoneRefused: ${_this.microphoneRefused})';
}


}

/// @nodoc
abstract mixin class $ComposerStateCopyWith<$Res>  {
  factory $ComposerStateCopyWith(ComposerState value, $Res Function(ComposerState) _then) = _$ComposerStateCopyWithImpl;
@useResult
$Res call({
 AmbientStamp stamp, String text, bool showPrompt, String? audioTempPath, Duration? audioDuration, bool isRecording, bool microphoneRefused
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
@pragma('vm:prefer-inline') @override $Res call({Object? stamp = null,Object? text = null,Object? showPrompt = null,Object? audioTempPath = freezed,Object? audioDuration = freezed,Object? isRecording = null,Object? microphoneRefused = null,}) {
  return _then(ComposerState(
stamp: null == stamp ? _self.stamp : stamp // ignore: cast_nullable_to_non_nullable
as AmbientStamp,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,showPrompt: null == showPrompt ? _self.showPrompt : showPrompt // ignore: cast_nullable_to_non_nullable
as bool,audioTempPath: freezed == audioTempPath ? _self.audioTempPath : audioTempPath // ignore: cast_nullable_to_non_nullable
as String?,audioDuration: freezed == audioDuration ? _self.audioDuration : audioDuration // ignore: cast_nullable_to_non_nullable
as Duration?,isRecording: null == isRecording ? _self.isRecording : isRecording // ignore: cast_nullable_to_non_nullable
as bool,microphoneRefused: null == microphoneRefused ? _self.microphoneRefused : microphoneRefused // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AmbientStamp stamp,  String text,  bool showPrompt,  String? audioTempPath,  Duration? audioDuration,  bool isRecording,  bool microphoneRefused)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComposerState() when $default != null:
return $default(_that.stamp,_that.text,_that.showPrompt,_that.audioTempPath,_that.audioDuration,_that.isRecording,_that.microphoneRefused);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AmbientStamp stamp,  String text,  bool showPrompt,  String? audioTempPath,  Duration? audioDuration,  bool isRecording,  bool microphoneRefused)  $default,) {final _that = this;
switch (_that) {
case _ComposerState():
return $default(_that.stamp,_that.text,_that.showPrompt,_that.audioTempPath,_that.audioDuration,_that.isRecording,_that.microphoneRefused);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AmbientStamp stamp,  String text,  bool showPrompt,  String? audioTempPath,  Duration? audioDuration,  bool isRecording,  bool microphoneRefused)?  $default,) {final _that = this;
switch (_that) {
case _ComposerState() when $default != null:
return $default(_that.stamp,_that.text,_that.showPrompt,_that.audioTempPath,_that.audioDuration,_that.isRecording,_that.microphoneRefused);case _:
  return null;

}
}

}

/// @nodoc


class _ComposerState extends ComposerState {
  const _ComposerState({required this.stamp, this.text = '', this.showPrompt = false, this.audioTempPath, this.audioDuration, this.isRecording = false, this.microphoneRefused = false}): super._();
  

@override final  AmbientStamp stamp;
@override@JsonKey() final  String text;
@override@JsonKey() final  bool showPrompt;
@override final  String? audioTempPath;
@override final  Duration? audioDuration;
@override@JsonKey() final  bool isRecording;
@override@JsonKey() final  bool microphoneRefused;

/// Create a copy of ComposerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComposerStateCopyWith<_ComposerState> get copyWith => __$ComposerStateCopyWithImpl<_ComposerState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComposerState&&(identical(other.stamp, stamp) || other.stamp == stamp)&&(identical(other.text, text) || other.text == text)&&(identical(other.showPrompt, showPrompt) || other.showPrompt == showPrompt)&&(identical(other.audioTempPath, audioTempPath) || other.audioTempPath == audioTempPath)&&(identical(other.audioDuration, audioDuration) || other.audioDuration == audioDuration)&&(identical(other.isRecording, isRecording) || other.isRecording == isRecording)&&(identical(other.microphoneRefused, microphoneRefused) || other.microphoneRefused == microphoneRefused));
}


@override
int get hashCode {
    return Object.hash(runtimeType,stamp,text,showPrompt,audioTempPath,audioDuration,isRecording,microphoneRefused);
}

@override
String toString() {
    return 'ComposerState(stamp: $stamp, text: $text, showPrompt: $showPrompt, audioTempPath: $audioTempPath, audioDuration: $audioDuration, isRecording: $isRecording, microphoneRefused: $microphoneRefused)';
}


}

/// @nodoc
abstract mixin class _$ComposerStateCopyWith<$Res> implements $ComposerStateCopyWith<$Res> {
  factory _$ComposerStateCopyWith(_ComposerState value, $Res Function(_ComposerState) _then) = __$ComposerStateCopyWithImpl;
@override @useResult
$Res call({
 AmbientStamp stamp, String text, bool showPrompt, String? audioTempPath, Duration? audioDuration, bool isRecording, bool microphoneRefused
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
@override @pragma('vm:prefer-inline') $Res call({Object? stamp = null,Object? text = null,Object? showPrompt = null,Object? audioTempPath = freezed,Object? audioDuration = freezed,Object? isRecording = null,Object? microphoneRefused = null,}) {
  return _then(_ComposerState(
stamp: null == stamp ? _self.stamp : stamp // ignore: cast_nullable_to_non_nullable
as AmbientStamp,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,showPrompt: null == showPrompt ? _self.showPrompt : showPrompt // ignore: cast_nullable_to_non_nullable
as bool,audioTempPath: freezed == audioTempPath ? _self.audioTempPath : audioTempPath // ignore: cast_nullable_to_non_nullable
as String?,audioDuration: freezed == audioDuration ? _self.audioDuration : audioDuration // ignore: cast_nullable_to_non_nullable
as Duration?,isRecording: null == isRecording ? _self.isRecording : isRecording // ignore: cast_nullable_to_non_nullable
as bool,microphoneRefused: null == microphoneRefused ? _self.microphoneRefused : microphoneRefused // ignore: cast_nullable_to_non_nullable
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
