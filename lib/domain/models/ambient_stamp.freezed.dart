// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ambient_stamp.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AmbientStamp {

/// The moment the chit was opened, in the device's local zone.
 DateTime get capturedAt;/// The condition, if the call came back in time.
 WeatherCondition? get weather;/// Latitude, if a fix came back in time. Stored, never displayed.
 double? get lat;/// Longitude, if a fix came back in time. Stored, never displayed.
 double? get lon;
/// Create a copy of AmbientStamp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AmbientStampCopyWith<AmbientStamp> get copyWith => _$AmbientStampCopyWithImpl<AmbientStamp>(this as AmbientStamp, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AmbientStamp;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AmbientStamp&&(identical(other.capturedAt, _this.capturedAt) || other.capturedAt == _this.capturedAt)&&(identical(other.weather, _this.weather) || other.weather == _this.weather)&&(identical(other.lat, _this.lat) || other.lat == _this.lat)&&(identical(other.lon, _this.lon) || other.lon == _this.lon));
}


@override
int get hashCode {
  final _this = this as AmbientStamp;
  return Object.hash(runtimeType,_this.capturedAt,_this.weather,_this.lat,_this.lon);
}

@override
String toString() {
  final _this = this as AmbientStamp;
  return 'AmbientStamp(capturedAt: ${_this.capturedAt}, weather: ${_this.weather}, lat: ${_this.lat}, lon: ${_this.lon})';
}


}

/// @nodoc
abstract mixin class $AmbientStampCopyWith<$Res>  {
  factory $AmbientStampCopyWith(AmbientStamp value, $Res Function(AmbientStamp) _then) = _$AmbientStampCopyWithImpl;
@useResult
$Res call({
 DateTime capturedAt, WeatherCondition? weather, double? lat, double? lon
});




}
/// @nodoc
class _$AmbientStampCopyWithImpl<$Res>
    implements $AmbientStampCopyWith<$Res> {
  _$AmbientStampCopyWithImpl(this._self, this._then);

  final AmbientStamp _self;
  final $Res Function(AmbientStamp) _then;

/// Create a copy of AmbientStamp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? capturedAt = null,Object? weather = freezed,Object? lat = freezed,Object? lon = freezed,}) {
  return _then(AmbientStamp(
capturedAt: null == capturedAt ? _self.capturedAt : capturedAt // ignore: cast_nullable_to_non_nullable
as DateTime,weather: freezed == weather ? _self.weather : weather // ignore: cast_nullable_to_non_nullable
as WeatherCondition?,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lon: freezed == lon ? _self.lon : lon // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [AmbientStamp].
extension AmbientStampPatterns on AmbientStamp {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AmbientStamp value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AmbientStamp() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AmbientStamp value)  $default,){
final _that = this;
switch (_that) {
case _AmbientStamp():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AmbientStamp value)?  $default,){
final _that = this;
switch (_that) {
case _AmbientStamp() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime capturedAt,  WeatherCondition? weather,  double? lat,  double? lon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AmbientStamp() when $default != null:
return $default(_that.capturedAt,_that.weather,_that.lat,_that.lon);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime capturedAt,  WeatherCondition? weather,  double? lat,  double? lon)  $default,) {final _that = this;
switch (_that) {
case _AmbientStamp():
return $default(_that.capturedAt,_that.weather,_that.lat,_that.lon);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime capturedAt,  WeatherCondition? weather,  double? lat,  double? lon)?  $default,) {final _that = this;
switch (_that) {
case _AmbientStamp() when $default != null:
return $default(_that.capturedAt,_that.weather,_that.lat,_that.lon);case _:
  return null;

}
}

}

/// @nodoc


class _AmbientStamp extends AmbientStamp {
  const _AmbientStamp({required this.capturedAt, this.weather, this.lat, this.lon}): assert((lat == null) == (lon == null), 'a coordinate is both halves or neither — half a fix is not a place'),super._();
  

/// The moment the chit was opened, in the device's local zone.
@override final  DateTime capturedAt;
/// The condition, if the call came back in time.
@override final  WeatherCondition? weather;
/// Latitude, if a fix came back in time. Stored, never displayed.
@override final  double? lat;
/// Longitude, if a fix came back in time. Stored, never displayed.
@override final  double? lon;

/// Create a copy of AmbientStamp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AmbientStampCopyWith<_AmbientStamp> get copyWith => __$AmbientStampCopyWithImpl<_AmbientStamp>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AmbientStamp&&(identical(other.capturedAt, capturedAt) || other.capturedAt == capturedAt)&&(identical(other.weather, weather) || other.weather == weather)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lon, lon) || other.lon == lon));
}


@override
int get hashCode {
    return Object.hash(runtimeType,capturedAt,weather,lat,lon);
}

@override
String toString() {
    return 'AmbientStamp(capturedAt: $capturedAt, weather: $weather, lat: $lat, lon: $lon)';
}


}

/// @nodoc
abstract mixin class _$AmbientStampCopyWith<$Res> implements $AmbientStampCopyWith<$Res> {
  factory _$AmbientStampCopyWith(_AmbientStamp value, $Res Function(_AmbientStamp) _then) = __$AmbientStampCopyWithImpl;
@override @useResult
$Res call({
 DateTime capturedAt, WeatherCondition? weather, double? lat, double? lon
});




}
/// @nodoc
class __$AmbientStampCopyWithImpl<$Res>
    implements _$AmbientStampCopyWith<$Res> {
  __$AmbientStampCopyWithImpl(this._self, this._then);

  final _AmbientStamp _self;
  final $Res Function(_AmbientStamp) _then;

/// Create a copy of AmbientStamp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? capturedAt = null,Object? weather = freezed,Object? lat = freezed,Object? lon = freezed,}) {
  return _then(_AmbientStamp(
capturedAt: null == capturedAt ? _self.capturedAt : capturedAt // ignore: cast_nullable_to_non_nullable
as DateTime,weather: freezed == weather ? _self.weather : weather // ignore: cast_nullable_to_non_nullable
as WeatherCondition?,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lon: freezed == lon ? _self.lon : lon // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
