// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'editor_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EditorState {

 Chit get chit; String get text; AudioEdit get audio; PhotoEdit get photo; bool get microphoneRefused;
/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditorStateCopyWith<EditorState> get copyWith => _$EditorStateCopyWithImpl<EditorState>(this as EditorState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EditorState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditorState&&(identical(other.chit, _this.chit) || other.chit == _this.chit)&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.audio, _this.audio) || other.audio == _this.audio)&&(identical(other.photo, _this.photo) || other.photo == _this.photo)&&(identical(other.microphoneRefused, _this.microphoneRefused) || other.microphoneRefused == _this.microphoneRefused));
}


@override
int get hashCode {
  final _this = this as EditorState;
  return Object.hash(runtimeType,_this.chit,_this.text,_this.audio,_this.photo,_this.microphoneRefused);
}

@override
String toString() {
  final _this = this as EditorState;
  return 'EditorState(chit: ${_this.chit}, text: ${_this.text}, audio: ${_this.audio}, photo: ${_this.photo}, microphoneRefused: ${_this.microphoneRefused})';
}


}

/// @nodoc
abstract mixin class $EditorStateCopyWith<$Res>  {
  factory $EditorStateCopyWith(EditorState value, $Res Function(EditorState) _then) = _$EditorStateCopyWithImpl;
@useResult
$Res call({
 Chit chit, String text, AudioEdit audio, PhotoEdit photo, bool microphoneRefused
});


$ChitCopyWith<$Res> get chit;$AudioEditCopyWith<$Res> get audio;$PhotoEditCopyWith<$Res> get photo;

}
/// @nodoc
class _$EditorStateCopyWithImpl<$Res>
    implements $EditorStateCopyWith<$Res> {
  _$EditorStateCopyWithImpl(this._self, this._then);

  final EditorState _self;
  final $Res Function(EditorState) _then;

/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chit = null,Object? text = null,Object? audio = null,Object? photo = null,Object? microphoneRefused = null,}) {
  return _then(EditorState(
chit: null == chit ? _self.chit : chit // ignore: cast_nullable_to_non_nullable
as Chit,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,audio: null == audio ? _self.audio : audio // ignore: cast_nullable_to_non_nullable
as AudioEdit,photo: null == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as PhotoEdit,microphoneRefused: null == microphoneRefused ? _self.microphoneRefused : microphoneRefused // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChitCopyWith<$Res> get chit {
  
  return $ChitCopyWith<$Res>(_self.chit, (value) {
    return _then(_self.copyWith(chit: value));
  });
}/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AudioEditCopyWith<$Res> get audio {
  
  return $AudioEditCopyWith<$Res>(_self.audio, (value) {
    return _then(_self.copyWith(audio: value));
  });
}/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PhotoEditCopyWith<$Res> get photo {
  
  return $PhotoEditCopyWith<$Res>(_self.photo, (value) {
    return _then(_self.copyWith(photo: value));
  });
}
}


/// Adds pattern-matching-related methods to [EditorState].
extension EditorStatePatterns on EditorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EditorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EditorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EditorState value)  $default,){
final _that = this;
switch (_that) {
case _EditorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EditorState value)?  $default,){
final _that = this;
switch (_that) {
case _EditorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Chit chit,  String text,  AudioEdit audio,  PhotoEdit photo,  bool microphoneRefused)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EditorState() when $default != null:
return $default(_that.chit,_that.text,_that.audio,_that.photo,_that.microphoneRefused);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Chit chit,  String text,  AudioEdit audio,  PhotoEdit photo,  bool microphoneRefused)  $default,) {final _that = this;
switch (_that) {
case _EditorState():
return $default(_that.chit,_that.text,_that.audio,_that.photo,_that.microphoneRefused);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Chit chit,  String text,  AudioEdit audio,  PhotoEdit photo,  bool microphoneRefused)?  $default,) {final _that = this;
switch (_that) {
case _EditorState() when $default != null:
return $default(_that.chit,_that.text,_that.audio,_that.photo,_that.microphoneRefused);case _:
  return null;

}
}

}

/// @nodoc


class _EditorState extends EditorState {
  const _EditorState({required this.chit, required this.text, this.audio = const AudioEdit.keep(), this.photo = const PhotoEdit.keep(), this.microphoneRefused = false}): super._();
  

@override final  Chit chit;
@override final  String text;
@override@JsonKey() final  AudioEdit audio;
@override@JsonKey() final  PhotoEdit photo;
@override@JsonKey() final  bool microphoneRefused;

/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EditorStateCopyWith<_EditorState> get copyWith => __$EditorStateCopyWithImpl<_EditorState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EditorState&&(identical(other.chit, chit) || other.chit == chit)&&(identical(other.text, text) || other.text == text)&&(identical(other.audio, audio) || other.audio == audio)&&(identical(other.photo, photo) || other.photo == photo)&&(identical(other.microphoneRefused, microphoneRefused) || other.microphoneRefused == microphoneRefused));
}


@override
int get hashCode {
    return Object.hash(runtimeType,chit,text,audio,photo,microphoneRefused);
}

@override
String toString() {
    return 'EditorState(chit: $chit, text: $text, audio: $audio, photo: $photo, microphoneRefused: $microphoneRefused)';
}


}

/// @nodoc
abstract mixin class _$EditorStateCopyWith<$Res> implements $EditorStateCopyWith<$Res> {
  factory _$EditorStateCopyWith(_EditorState value, $Res Function(_EditorState) _then) = __$EditorStateCopyWithImpl;
@override @useResult
$Res call({
 Chit chit, String text, AudioEdit audio, PhotoEdit photo, bool microphoneRefused
});


@override $ChitCopyWith<$Res> get chit;@override $AudioEditCopyWith<$Res> get audio;@override $PhotoEditCopyWith<$Res> get photo;

}
/// @nodoc
class __$EditorStateCopyWithImpl<$Res>
    implements _$EditorStateCopyWith<$Res> {
  __$EditorStateCopyWithImpl(this._self, this._then);

  final _EditorState _self;
  final $Res Function(_EditorState) _then;

/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chit = null,Object? text = null,Object? audio = null,Object? photo = null,Object? microphoneRefused = null,}) {
  return _then(_EditorState(
chit: null == chit ? _self.chit : chit // ignore: cast_nullable_to_non_nullable
as Chit,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,audio: null == audio ? _self.audio : audio // ignore: cast_nullable_to_non_nullable
as AudioEdit,photo: null == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as PhotoEdit,microphoneRefused: null == microphoneRefused ? _self.microphoneRefused : microphoneRefused // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChitCopyWith<$Res> get chit {
  
  return $ChitCopyWith<$Res>(_self.chit, (value) {
    return _then(_self.copyWith(chit: value));
  });
}/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AudioEditCopyWith<$Res> get audio {
  
  return $AudioEditCopyWith<$Res>(_self.audio, (value) {
    return _then(_self.copyWith(audio: value));
  });
}/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PhotoEditCopyWith<$Res> get photo {
  
  return $PhotoEditCopyWith<$Res>(_self.photo, (value) {
    return _then(_self.copyWith(photo: value));
  });
}
}

// dart format on
