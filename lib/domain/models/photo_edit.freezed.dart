// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_edit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PhotoEdit {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoEdit);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PhotoEdit()';
}


}

/// @nodoc
class $PhotoEditCopyWith<$Res>  {
$PhotoEditCopyWith(PhotoEdit _, $Res Function(PhotoEdit) __);
}


/// Adds pattern-matching-related methods to [PhotoEdit].
extension PhotoEditPatterns on PhotoEdit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( KeepPhoto value)?  keep,TResult Function( RemovePhoto value)?  remove,TResult Function( ReplacePhoto value)?  replace,required TResult orElse(),}){
final _that = this;
switch (_that) {
case KeepPhoto() when keep != null:
return keep(_that);case RemovePhoto() when remove != null:
return remove(_that);case ReplacePhoto() when replace != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( KeepPhoto value)  keep,required TResult Function( RemovePhoto value)  remove,required TResult Function( ReplacePhoto value)  replace,}){
final _that = this;
switch (_that) {
case KeepPhoto():
return keep(_that);case RemovePhoto():
return remove(_that);case ReplacePhoto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( KeepPhoto value)?  keep,TResult? Function( RemovePhoto value)?  remove,TResult? Function( ReplacePhoto value)?  replace,}){
final _that = this;
switch (_that) {
case KeepPhoto() when keep != null:
return keep(_that);case RemovePhoto() when remove != null:
return remove(_that);case ReplacePhoto() when replace != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  keep,TResult Function()?  remove,TResult Function( String tempPath)?  replace,required TResult orElse(),}) {final _that = this;
switch (_that) {
case KeepPhoto() when keep != null:
return keep();case RemovePhoto() when remove != null:
return remove();case ReplacePhoto() when replace != null:
return replace(_that.tempPath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  keep,required TResult Function()  remove,required TResult Function( String tempPath)  replace,}) {final _that = this;
switch (_that) {
case KeepPhoto():
return keep();case RemovePhoto():
return remove();case ReplacePhoto():
return replace(_that.tempPath);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  keep,TResult? Function()?  remove,TResult? Function( String tempPath)?  replace,}) {final _that = this;
switch (_that) {
case KeepPhoto() when keep != null:
return keep();case RemovePhoto() when remove != null:
return remove();case ReplacePhoto() when replace != null:
return replace(_that.tempPath);case _:
  return null;

}
}

}

/// @nodoc


class KeepPhoto implements PhotoEdit {
  const KeepPhoto();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is KeepPhoto);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PhotoEdit.keep()';
}


}




/// @nodoc


class RemovePhoto implements PhotoEdit {
  const RemovePhoto();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is RemovePhoto);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PhotoEdit.remove()';
}


}




/// @nodoc


class ReplacePhoto implements PhotoEdit {
  const ReplacePhoto({required this.tempPath});
  

 final  String tempPath;

/// Create a copy of PhotoEdit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReplacePhotoCopyWith<ReplacePhoto> get copyWith => _$ReplacePhotoCopyWithImpl<ReplacePhoto>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ReplacePhoto&&(identical(other.tempPath, tempPath) || other.tempPath == tempPath));
}


@override
int get hashCode {
    return Object.hash(runtimeType,tempPath);
}

@override
String toString() {
    return 'PhotoEdit.replace(tempPath: $tempPath)';
}


}

/// @nodoc
abstract mixin class $ReplacePhotoCopyWith<$Res> implements $PhotoEditCopyWith<$Res> {
  factory $ReplacePhotoCopyWith(ReplacePhoto value, $Res Function(ReplacePhoto) _then) = _$ReplacePhotoCopyWithImpl;
@useResult
$Res call({
 String tempPath
});




}
/// @nodoc
class _$ReplacePhotoCopyWithImpl<$Res>
    implements $ReplacePhotoCopyWith<$Res> {
  _$ReplacePhotoCopyWithImpl(this._self, this._then);

  final ReplacePhoto _self;
  final $Res Function(ReplacePhoto) _then;

/// Create a copy of PhotoEdit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? tempPath = null,}) {
  return _then(ReplacePhoto(
tempPath: null == tempPath ? _self.tempPath : tempPath // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
