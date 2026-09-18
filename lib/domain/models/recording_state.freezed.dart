// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recording_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecordingState {

/// How long it has run, off the clock (ADR-012, ADR-052). The sheet draws
/// this in tabular figures; the kept take's length is the recorder's own
/// measurement, not this.
 Duration get elapsed;/// The most recent input levels, 0 to 1, oldest first (ADR-052, D4).
///
/// **A short rolling window, not the whole take** — one bar per reading,
/// the newest at the right, so the wave draws the shape of what was just
/// said rather than one loudness split twenty ways. It holds
/// `RecordingController.levelWindow` readings and is empty until the first
/// one lands.
///
/// *ADR-054 originally kept a single number, on the reading that v6's wave
/// is twenty bars each bobbing on its own loop. It is a buffer because the
/// bars are drawn from the microphone instead.*
 List<double> get levels;
/// Create a copy of RecordingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecordingStateCopyWith<RecordingState> get copyWith => _$RecordingStateCopyWithImpl<RecordingState>(this as RecordingState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RecordingState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecordingState&&(identical(other.elapsed, _this.elapsed) || other.elapsed == _this.elapsed)&&const DeepCollectionEquality().equals(other.levels, _this.levels));
}


@override
int get hashCode {
  final _this = this as RecordingState;
  return Object.hash(runtimeType,_this.elapsed,const DeepCollectionEquality().hash(_this.levels));
}

@override
String toString() {
  final _this = this as RecordingState;
  return 'RecordingState(elapsed: ${_this.elapsed}, levels: ${_this.levels})';
}


}

/// @nodoc
abstract mixin class $RecordingStateCopyWith<$Res>  {
  factory $RecordingStateCopyWith(RecordingState value, $Res Function(RecordingState) _then) = _$RecordingStateCopyWithImpl;
@useResult
$Res call({
 Duration elapsed, List<double> levels
});




}
/// @nodoc
class _$RecordingStateCopyWithImpl<$Res>
    implements $RecordingStateCopyWith<$Res> {
  _$RecordingStateCopyWithImpl(this._self, this._then);

  final RecordingState _self;
  final $Res Function(RecordingState) _then;

/// Create a copy of RecordingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? elapsed = null,Object? levels = null,}) {
  return _then(RecordingState(
elapsed: null == elapsed ? _self.elapsed : elapsed // ignore: cast_nullable_to_non_nullable
as Duration,levels: null == levels ? _self.levels : levels // ignore: cast_nullable_to_non_nullable
as List<double>,
  ));
}

}


/// Adds pattern-matching-related methods to [RecordingState].
extension RecordingStatePatterns on RecordingState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecordingState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecordingState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecordingState value)  $default,){
final _that = this;
switch (_that) {
case _RecordingState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecordingState value)?  $default,){
final _that = this;
switch (_that) {
case _RecordingState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Duration elapsed,  List<double> levels)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecordingState() when $default != null:
return $default(_that.elapsed,_that.levels);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Duration elapsed,  List<double> levels)  $default,) {final _that = this;
switch (_that) {
case _RecordingState():
return $default(_that.elapsed,_that.levels);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Duration elapsed,  List<double> levels)?  $default,) {final _that = this;
switch (_that) {
case _RecordingState() when $default != null:
return $default(_that.elapsed,_that.levels);case _:
  return null;

}
}

}

/// @nodoc


class _RecordingState extends RecordingState {
  const _RecordingState({this.elapsed = Duration.zero,  List<double> levels = const <double>[]}): _levels = levels,super._();
  

/// How long it has run, off the clock (ADR-012, ADR-052). The sheet draws
/// this in tabular figures; the kept take's length is the recorder's own
/// measurement, not this.
@override@JsonKey() final  Duration elapsed;
/// The most recent input levels, 0 to 1, oldest first (ADR-052, D4).
///
/// **A short rolling window, not the whole take** — one bar per reading,
/// the newest at the right, so the wave draws the shape of what was just
/// said rather than one loudness split twenty ways. It holds
/// `RecordingController.levelWindow` readings and is empty until the first
/// one lands.
///
/// *ADR-054 originally kept a single number, on the reading that v6's wave
/// is twenty bars each bobbing on its own loop. It is a buffer because the
/// bars are drawn from the microphone instead.*
 final  List<double> _levels;
/// The most recent input levels, 0 to 1, oldest first (ADR-052, D4).
///
/// **A short rolling window, not the whole take** — one bar per reading,
/// the newest at the right, so the wave draws the shape of what was just
/// said rather than one loudness split twenty ways. It holds
/// `RecordingController.levelWindow` readings and is empty until the first
/// one lands.
///
/// *ADR-054 originally kept a single number, on the reading that v6's wave
/// is twenty bars each bobbing on its own loop. It is a buffer because the
/// bars are drawn from the microphone instead.*
@override@JsonKey() List<double> get levels {
  if (_levels is EqualUnmodifiableListView) return _levels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_levels);
}


/// Create a copy of RecordingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecordingStateCopyWith<_RecordingState> get copyWith => __$RecordingStateCopyWithImpl<_RecordingState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecordingState&&(identical(other.elapsed, elapsed) || other.elapsed == elapsed)&&const DeepCollectionEquality().equals(other.levels, _levels));
}


@override
int get hashCode {
    return Object.hash(runtimeType,elapsed,const DeepCollectionEquality().hash(_levels));
}

@override
String toString() {
    return 'RecordingState(elapsed: $elapsed, levels: $levels)';
}


}

/// @nodoc
abstract mixin class _$RecordingStateCopyWith<$Res> implements $RecordingStateCopyWith<$Res> {
  factory _$RecordingStateCopyWith(_RecordingState value, $Res Function(_RecordingState) _then) = __$RecordingStateCopyWithImpl;
@override @useResult
$Res call({
 Duration elapsed, List<double> levels
});




}
/// @nodoc
class __$RecordingStateCopyWithImpl<$Res>
    implements _$RecordingStateCopyWith<$Res> {
  __$RecordingStateCopyWithImpl(this._self, this._then);

  final _RecordingState _self;
  final $Res Function(_RecordingState) _then;

/// Create a copy of RecordingState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? elapsed = null,Object? levels = null,}) {
  return _then(_RecordingState(
elapsed: null == elapsed ? _self.elapsed : elapsed // ignore: cast_nullable_to_non_nullable
as Duration,levels: null == levels ? _self._levels : levels // ignore: cast_nullable_to_non_nullable
as List<double>,
  ));
}


}

// dart format on
