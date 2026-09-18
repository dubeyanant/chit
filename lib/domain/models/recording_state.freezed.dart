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
 Duration get elapsed;/// The input level, 0 to 1 (ADR-052, TASKS.md D4).
///
/// **One number, not a history.** The prototype's waveform is twenty bars
/// with fixed heights, each bobbing on its own loop, so what it needs from
/// here is the current loudness and nothing else — keeping a rolling
/// buffer would be state nobody reads.
 double get level;/// What has been heard, split where §3.4 draws it.
 Transcript get transcript;/// Whether the recogniser stopped before the take did.
///
/// It has no note and no icon: §3.5 is stated once, at Stop & keep, on the
/// open chit. What this is for is [transcript] having stopped growing for
/// a reason, and for Stop & keep knowing there is nothing left to wait on.
 bool get recognitionGaveUp;
/// Create a copy of RecordingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecordingStateCopyWith<RecordingState> get copyWith => _$RecordingStateCopyWithImpl<RecordingState>(this as RecordingState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RecordingState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecordingState&&(identical(other.elapsed, _this.elapsed) || other.elapsed == _this.elapsed)&&(identical(other.level, _this.level) || other.level == _this.level)&&(identical(other.transcript, _this.transcript) || other.transcript == _this.transcript)&&(identical(other.recognitionGaveUp, _this.recognitionGaveUp) || other.recognitionGaveUp == _this.recognitionGaveUp));
}


@override
int get hashCode {
  final _this = this as RecordingState;
  return Object.hash(runtimeType,_this.elapsed,_this.level,_this.transcript,_this.recognitionGaveUp);
}

@override
String toString() {
  final _this = this as RecordingState;
  return 'RecordingState(elapsed: ${_this.elapsed}, level: ${_this.level}, transcript: ${_this.transcript}, recognitionGaveUp: ${_this.recognitionGaveUp})';
}


}

/// @nodoc
abstract mixin class $RecordingStateCopyWith<$Res>  {
  factory $RecordingStateCopyWith(RecordingState value, $Res Function(RecordingState) _then) = _$RecordingStateCopyWithImpl;
@useResult
$Res call({
 Duration elapsed, double level, Transcript transcript, bool recognitionGaveUp
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
@pragma('vm:prefer-inline') @override $Res call({Object? elapsed = null,Object? level = null,Object? transcript = null,Object? recognitionGaveUp = null,}) {
  return _then(RecordingState(
elapsed: null == elapsed ? _self.elapsed : elapsed // ignore: cast_nullable_to_non_nullable
as Duration,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as double,transcript: null == transcript ? _self.transcript : transcript // ignore: cast_nullable_to_non_nullable
as Transcript,recognitionGaveUp: null == recognitionGaveUp ? _self.recognitionGaveUp : recognitionGaveUp // ignore: cast_nullable_to_non_nullable
as bool,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Duration elapsed,  double level,  Transcript transcript,  bool recognitionGaveUp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecordingState() when $default != null:
return $default(_that.elapsed,_that.level,_that.transcript,_that.recognitionGaveUp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Duration elapsed,  double level,  Transcript transcript,  bool recognitionGaveUp)  $default,) {final _that = this;
switch (_that) {
case _RecordingState():
return $default(_that.elapsed,_that.level,_that.transcript,_that.recognitionGaveUp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Duration elapsed,  double level,  Transcript transcript,  bool recognitionGaveUp)?  $default,) {final _that = this;
switch (_that) {
case _RecordingState() when $default != null:
return $default(_that.elapsed,_that.level,_that.transcript,_that.recognitionGaveUp);case _:
  return null;

}
}

}

/// @nodoc


class _RecordingState extends RecordingState {
  const _RecordingState({this.elapsed = Duration.zero, this.level = 0, this.transcript = Transcript.nothing, this.recognitionGaveUp = false}): super._();
  

/// How long it has run, off the clock (ADR-012, ADR-052). The sheet draws
/// this in tabular figures; the kept take's length is the recorder's own
/// measurement, not this.
@override@JsonKey() final  Duration elapsed;
/// The input level, 0 to 1 (ADR-052, TASKS.md D4).
///
/// **One number, not a history.** The prototype's waveform is twenty bars
/// with fixed heights, each bobbing on its own loop, so what it needs from
/// here is the current loudness and nothing else — keeping a rolling
/// buffer would be state nobody reads.
@override@JsonKey() final  double level;
/// What has been heard, split where §3.4 draws it.
@override@JsonKey() final  Transcript transcript;
/// Whether the recogniser stopped before the take did.
///
/// It has no note and no icon: §3.5 is stated once, at Stop & keep, on the
/// open chit. What this is for is [transcript] having stopped growing for
/// a reason, and for Stop & keep knowing there is nothing left to wait on.
@override@JsonKey() final  bool recognitionGaveUp;

/// Create a copy of RecordingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecordingStateCopyWith<_RecordingState> get copyWith => __$RecordingStateCopyWithImpl<_RecordingState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecordingState&&(identical(other.elapsed, elapsed) || other.elapsed == elapsed)&&(identical(other.level, level) || other.level == level)&&(identical(other.transcript, transcript) || other.transcript == transcript)&&(identical(other.recognitionGaveUp, recognitionGaveUp) || other.recognitionGaveUp == recognitionGaveUp));
}


@override
int get hashCode {
    return Object.hash(runtimeType,elapsed,level,transcript,recognitionGaveUp);
}

@override
String toString() {
    return 'RecordingState(elapsed: $elapsed, level: $level, transcript: $transcript, recognitionGaveUp: $recognitionGaveUp)';
}


}

/// @nodoc
abstract mixin class _$RecordingStateCopyWith<$Res> implements $RecordingStateCopyWith<$Res> {
  factory _$RecordingStateCopyWith(_RecordingState value, $Res Function(_RecordingState) _then) = __$RecordingStateCopyWithImpl;
@override @useResult
$Res call({
 Duration elapsed, double level, Transcript transcript, bool recognitionGaveUp
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
@override @pragma('vm:prefer-inline') $Res call({Object? elapsed = null,Object? level = null,Object? transcript = null,Object? recognitionGaveUp = null,}) {
  return _then(_RecordingState(
elapsed: null == elapsed ? _self.elapsed : elapsed // ignore: cast_nullable_to_non_nullable
as Duration,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as double,transcript: null == transcript ? _self.transcript : transcript // ignore: cast_nullable_to_non_nullable
as Transcript,recognitionGaveUp: null == recognitionGaveUp ? _self.recognitionGaveUp : recognitionGaveUp // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
