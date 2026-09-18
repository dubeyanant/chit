// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audio_edit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AudioEdit {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AudioEdit);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AudioEdit()';
}


}

/// @nodoc
class $AudioEditCopyWith<$Res>  {
$AudioEditCopyWith(AudioEdit _, $Res Function(AudioEdit) __);
}


/// Adds pattern-matching-related methods to [AudioEdit].
extension AudioEditPatterns on AudioEdit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( KeepAudio value)?  keep,TResult Function( RemoveAudio value)?  remove,TResult Function( ReplaceAudio value)?  replace,required TResult orElse(),}){
final _that = this;
switch (_that) {
case KeepAudio() when keep != null:
return keep(_that);case RemoveAudio() when remove != null:
return remove(_that);case ReplaceAudio() when replace != null:
return replace(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( KeepAudio value)  keep,required TResult Function( RemoveAudio value)  remove,required TResult Function( ReplaceAudio value)  replace,}){
final _that = this;
switch (_that) {
case KeepAudio():
return keep(_that);case RemoveAudio():
return remove(_that);case ReplaceAudio():
return replace(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( KeepAudio value)?  keep,TResult? Function( RemoveAudio value)?  remove,TResult? Function( ReplaceAudio value)?  replace,}){
final _that = this;
switch (_that) {
case KeepAudio() when keep != null:
return keep(_that);case RemoveAudio() when remove != null:
return remove(_that);case ReplaceAudio() when replace != null:
return replace(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  keep,TResult Function()?  remove,TResult Function( String tempPath,  Duration duration)?  replace,required TResult orElse(),}) {final _that = this;
switch (_that) {
case KeepAudio() when keep != null:
return keep();case RemoveAudio() when remove != null:
return remove();case ReplaceAudio() when replace != null:
return replace(_that.tempPath,_that.duration);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  keep,required TResult Function()  remove,required TResult Function( String tempPath,  Duration duration)  replace,}) {final _that = this;
switch (_that) {
case KeepAudio():
return keep();case RemoveAudio():
return remove();case ReplaceAudio():
return replace(_that.tempPath,_that.duration);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  keep,TResult? Function()?  remove,TResult? Function( String tempPath,  Duration duration)?  replace,}) {final _that = this;
switch (_that) {
case KeepAudio() when keep != null:
return keep();case RemoveAudio() when remove != null:
return remove();case ReplaceAudio() when replace != null:
return replace(_that.tempPath,_that.duration);case _:
  return null;

}
}

}

/// @nodoc


class KeepAudio implements AudioEdit {
  const KeepAudio();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is KeepAudio);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AudioEdit.keep()';
}


}




/// @nodoc


class RemoveAudio implements AudioEdit {
  const RemoveAudio();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoveAudio);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AudioEdit.remove()';
}


}




/// @nodoc


class ReplaceAudio implements AudioEdit {
  const ReplaceAudio({required this.tempPath, required this.duration});
  

 final  String tempPath;
 final  Duration duration;

/// Create a copy of AudioEdit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReplaceAudioCopyWith<ReplaceAudio> get copyWith => _$ReplaceAudioCopyWithImpl<ReplaceAudio>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ReplaceAudio&&(identical(other.tempPath, tempPath) || other.tempPath == tempPath)&&(identical(other.duration, duration) || other.duration == duration));
}


@override
int get hashCode {
    return Object.hash(runtimeType,tempPath,duration);
}

@override
String toString() {
    return 'AudioEdit.replace(tempPath: $tempPath, duration: $duration)';
}


}

/// @nodoc
abstract mixin class $ReplaceAudioCopyWith<$Res> implements $AudioEditCopyWith<$Res> {
  factory $ReplaceAudioCopyWith(ReplaceAudio value, $Res Function(ReplaceAudio) _then) = _$ReplaceAudioCopyWithImpl;
@useResult
$Res call({
 String tempPath, Duration duration
});




}
/// @nodoc
class _$ReplaceAudioCopyWithImpl<$Res>
    implements $ReplaceAudioCopyWith<$Res> {
  _$ReplaceAudioCopyWithImpl(this._self, this._then);

  final ReplaceAudio _self;
  final $Res Function(ReplaceAudio) _then;

/// Create a copy of AudioEdit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? tempPath = null,Object? duration = null,}) {
  return _then(ReplaceAudio(
tempPath: null == tempPath ? _self.tempPath : tempPath // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}

// dart format on
