// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chit_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChitFilter {

 Set<WeatherCondition> get weather; Set<MotionState> get motion;/// [TagSpan.key]s, so `@Anant_Dubey` and `@anant dubey` are one person.
 Set<String> get people;/// [TagSpan.key]s, the same way.
 Set<String> get topics;
/// Create a copy of ChitFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChitFilterCopyWith<ChitFilter> get copyWith => _$ChitFilterCopyWithImpl<ChitFilter>(this as ChitFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ChitFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChitFilter&&const DeepCollectionEquality().equals(other.weather, _this.weather)&&const DeepCollectionEquality().equals(other.motion, _this.motion)&&const DeepCollectionEquality().equals(other.people, _this.people)&&const DeepCollectionEquality().equals(other.topics, _this.topics));
}


@override
int get hashCode {
  final _this = this as ChitFilter;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.weather),const DeepCollectionEquality().hash(_this.motion),const DeepCollectionEquality().hash(_this.people),const DeepCollectionEquality().hash(_this.topics));
}

@override
String toString() {
  final _this = this as ChitFilter;
  return 'ChitFilter(weather: ${_this.weather}, motion: ${_this.motion}, people: ${_this.people}, topics: ${_this.topics})';
}


}

/// @nodoc
abstract mixin class $ChitFilterCopyWith<$Res>  {
  factory $ChitFilterCopyWith(ChitFilter value, $Res Function(ChitFilter) _then) = _$ChitFilterCopyWithImpl;
@useResult
$Res call({
 Set<WeatherCondition> weather, Set<MotionState> motion, Set<String> people, Set<String> topics
});




}
/// @nodoc
class _$ChitFilterCopyWithImpl<$Res>
    implements $ChitFilterCopyWith<$Res> {
  _$ChitFilterCopyWithImpl(this._self, this._then);

  final ChitFilter _self;
  final $Res Function(ChitFilter) _then;

/// Create a copy of ChitFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weather = null,Object? motion = null,Object? people = null,Object? topics = null,}) {
  return _then(ChitFilter(
weather: null == weather ? _self.weather : weather // ignore: cast_nullable_to_non_nullable
as Set<WeatherCondition>,motion: null == motion ? _self.motion : motion // ignore: cast_nullable_to_non_nullable
as Set<MotionState>,people: null == people ? _self.people : people // ignore: cast_nullable_to_non_nullable
as Set<String>,topics: null == topics ? _self.topics : topics // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ChitFilter].
extension ChitFilterPatterns on ChitFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChitFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChitFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChitFilter value)  $default,){
final _that = this;
switch (_that) {
case _ChitFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChitFilter value)?  $default,){
final _that = this;
switch (_that) {
case _ChitFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Set<WeatherCondition> weather,  Set<MotionState> motion,  Set<String> people,  Set<String> topics)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChitFilter() when $default != null:
return $default(_that.weather,_that.motion,_that.people,_that.topics);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Set<WeatherCondition> weather,  Set<MotionState> motion,  Set<String> people,  Set<String> topics)  $default,) {final _that = this;
switch (_that) {
case _ChitFilter():
return $default(_that.weather,_that.motion,_that.people,_that.topics);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Set<WeatherCondition> weather,  Set<MotionState> motion,  Set<String> people,  Set<String> topics)?  $default,) {final _that = this;
switch (_that) {
case _ChitFilter() when $default != null:
return $default(_that.weather,_that.motion,_that.people,_that.topics);case _:
  return null;

}
}

}

/// @nodoc


class _ChitFilter extends ChitFilter {
  const _ChitFilter({ Set<WeatherCondition> weather = const <WeatherCondition>{},  Set<MotionState> motion = const <MotionState>{},  Set<String> people = const <String>{},  Set<String> topics = const <String>{}}): _weather = weather,_motion = motion,_people = people,_topics = topics,super._();
  

 final  Set<WeatherCondition> _weather;
@override@JsonKey() Set<WeatherCondition> get weather {
  if (_weather is EqualUnmodifiableSetView) return _weather;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_weather);
}

 final  Set<MotionState> _motion;
@override@JsonKey() Set<MotionState> get motion {
  if (_motion is EqualUnmodifiableSetView) return _motion;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_motion);
}

/// [TagSpan.key]s, so `@Anant_Dubey` and `@anant dubey` are one person.
 final  Set<String> _people;
/// [TagSpan.key]s, so `@Anant_Dubey` and `@anant dubey` are one person.
@override@JsonKey() Set<String> get people {
  if (_people is EqualUnmodifiableSetView) return _people;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_people);
}

/// [TagSpan.key]s, the same way.
 final  Set<String> _topics;
/// [TagSpan.key]s, the same way.
@override@JsonKey() Set<String> get topics {
  if (_topics is EqualUnmodifiableSetView) return _topics;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_topics);
}


/// Create a copy of ChitFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChitFilterCopyWith<_ChitFilter> get copyWith => __$ChitFilterCopyWithImpl<_ChitFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChitFilter&&const DeepCollectionEquality().equals(other.weather, _weather)&&const DeepCollectionEquality().equals(other.motion, _motion)&&const DeepCollectionEquality().equals(other.people, _people)&&const DeepCollectionEquality().equals(other.topics, _topics));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_weather),const DeepCollectionEquality().hash(_motion),const DeepCollectionEquality().hash(_people),const DeepCollectionEquality().hash(_topics));
}

@override
String toString() {
    return 'ChitFilter(weather: $weather, motion: $motion, people: $people, topics: $topics)';
}


}

/// @nodoc
abstract mixin class _$ChitFilterCopyWith<$Res> implements $ChitFilterCopyWith<$Res> {
  factory _$ChitFilterCopyWith(_ChitFilter value, $Res Function(_ChitFilter) _then) = __$ChitFilterCopyWithImpl;
@override @useResult
$Res call({
 Set<WeatherCondition> weather, Set<MotionState> motion, Set<String> people, Set<String> topics
});




}
/// @nodoc
class __$ChitFilterCopyWithImpl<$Res>
    implements _$ChitFilterCopyWith<$Res> {
  __$ChitFilterCopyWithImpl(this._self, this._then);

  final _ChitFilter _self;
  final $Res Function(_ChitFilter) _then;

/// Create a copy of ChitFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weather = null,Object? motion = null,Object? people = null,Object? topics = null,}) {
  return _then(_ChitFilter(
weather: null == weather ? _self._weather : weather // ignore: cast_nullable_to_non_nullable
as Set<WeatherCondition>,motion: null == motion ? _self._motion : motion // ignore: cast_nullable_to_non_nullable
as Set<MotionState>,people: null == people ? _self._people : people // ignore: cast_nullable_to_non_nullable
as Set<String>,topics: null == topics ? _self._topics : topics // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}


}

// dart format on
