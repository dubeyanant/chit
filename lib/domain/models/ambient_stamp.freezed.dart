part of 'ambient_stamp.dart';

T _$identity<T>(T value) => value;

mixin _$AmbientStamp {
  DateTime get capturedAt;
  WeatherCondition? get weather;
  double? get lat;
  double? get lon;

  MotionState? get motion;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AmbientStampCopyWith<AmbientStamp> get copyWith =>
      _$AmbientStampCopyWithImpl<AmbientStamp>(
        this as AmbientStamp,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    final _this = this as AmbientStamp;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AmbientStamp &&
            (identical(other.capturedAt, _this.capturedAt) ||
                other.capturedAt == _this.capturedAt) &&
            (identical(other.weather, _this.weather) ||
                other.weather == _this.weather) &&
            (identical(other.lat, _this.lat) || other.lat == _this.lat) &&
            (identical(other.lon, _this.lon) || other.lon == _this.lon) &&
            (identical(other.motion, _this.motion) ||
                other.motion == _this.motion));
  }

  @override
  int get hashCode {
    final _this = this as AmbientStamp;
    return Object.hash(
      runtimeType,
      _this.capturedAt,
      _this.weather,
      _this.lat,
      _this.lon,
      _this.motion,
    );
  }

  @override
  String toString() {
    final _this = this as AmbientStamp;
    return 'AmbientStamp(capturedAt: ${_this.capturedAt}, weather: ${_this.weather}, lat: ${_this.lat}, lon: ${_this.lon}, motion: ${_this.motion})';
  }
}

abstract mixin class $AmbientStampCopyWith<$Res> {
  factory $AmbientStampCopyWith(
    AmbientStamp value,
    $Res Function(AmbientStamp) _then,
  ) = _$AmbientStampCopyWithImpl;
  @useResult
  $Res call({
    DateTime capturedAt,
    WeatherCondition? weather,
    double? lat,
    double? lon,
    MotionState? motion,
  });
}

class _$AmbientStampCopyWithImpl<$Res> implements $AmbientStampCopyWith<$Res> {
  _$AmbientStampCopyWithImpl(this._self, this._then);

  final AmbientStamp _self;
  final $Res Function(AmbientStamp) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? capturedAt = null,
    Object? weather = freezed,
    Object? lat = freezed,
    Object? lon = freezed,
    Object? motion = freezed,
  }) {
    return _then(
      AmbientStamp(
        capturedAt: null == capturedAt
            ? _self.capturedAt
            : capturedAt as DateTime,
        weather: freezed == weather
            ? _self.weather
            : weather as WeatherCondition?,
        lat: freezed == lat ? _self.lat : lat as double?,
        lon: freezed == lon ? _self.lon : lon as double?,
        motion: freezed == motion ? _self.motion : motion as MotionState?,
      ),
    );
  }
}

extension AmbientStampPatterns on AmbientStamp {
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_AmbientStamp value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AmbientStamp() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_AmbientStamp value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AmbientStamp():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_AmbientStamp value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AmbientStamp() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      DateTime capturedAt,
      WeatherCondition? weather,
      double? lat,
      double? lon,
      MotionState? motion,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AmbientStamp() when $default != null:
        return $default(
          _that.capturedAt,
          _that.weather,
          _that.lat,
          _that.lon,
          _that.motion,
        );
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      DateTime capturedAt,
      WeatherCondition? weather,
      double? lat,
      double? lon,
      MotionState? motion,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AmbientStamp():
        return $default(
          _that.capturedAt,
          _that.weather,
          _that.lat,
          _that.lon,
          _that.motion,
        );
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      DateTime capturedAt,
      WeatherCondition? weather,
      double? lat,
      double? lon,
      MotionState? motion,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AmbientStamp() when $default != null:
        return $default(
          _that.capturedAt,
          _that.weather,
          _that.lat,
          _that.lon,
          _that.motion,
        );
      case _:
        return null;
    }
  }
}

class _AmbientStamp extends AmbientStamp {
  const _AmbientStamp({
    required this.capturedAt,
    this.weather,
    this.lat,
    this.lon,
    this.motion,
  }) : assert(
         (lat == null) == (lon == null),
         'a coordinate is both halves or neither — half a fix is not a place',
       ),
       super._();

  @override
  final DateTime capturedAt;

  @override
  final WeatherCondition? weather;

  @override
  final double? lat;

  @override
  final double? lon;

  @override
  final MotionState? motion;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AmbientStampCopyWith<_AmbientStamp> get copyWith =>
      __$AmbientStampCopyWithImpl<_AmbientStamp>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AmbientStamp &&
            (identical(other.capturedAt, capturedAt) ||
                other.capturedAt == capturedAt) &&
            (identical(other.weather, weather) || other.weather == weather) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lon, lon) || other.lon == lon) &&
            (identical(other.motion, motion) || other.motion == motion));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, capturedAt, weather, lat, lon, motion);
  }

  @override
  String toString() {
    return 'AmbientStamp(capturedAt: $capturedAt, weather: $weather, lat: $lat, lon: $lon, motion: $motion)';
  }
}

abstract mixin class _$AmbientStampCopyWith<$Res>
    implements $AmbientStampCopyWith<$Res> {
  factory _$AmbientStampCopyWith(
    _AmbientStamp value,
    $Res Function(_AmbientStamp) _then,
  ) = __$AmbientStampCopyWithImpl;
  @override
  @useResult
  $Res call({
    DateTime capturedAt,
    WeatherCondition? weather,
    double? lat,
    double? lon,
    MotionState? motion,
  });
}

class __$AmbientStampCopyWithImpl<$Res>
    implements _$AmbientStampCopyWith<$Res> {
  __$AmbientStampCopyWithImpl(this._self, this._then);

  final _AmbientStamp _self;
  final $Res Function(_AmbientStamp) _then;

  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? capturedAt = null,
    Object? weather = freezed,
    Object? lat = freezed,
    Object? lon = freezed,
    Object? motion = freezed,
  }) {
    return _then(
      _AmbientStamp(
        capturedAt: null == capturedAt
            ? _self.capturedAt
            : capturedAt as DateTime,
        weather: freezed == weather
            ? _self.weather
            : weather as WeatherCondition?,
        lat: freezed == lat ? _self.lat : lat as double?,
        lon: freezed == lon ? _self.lon : lon as double?,
        motion: freezed == motion ? _self.motion : motion as MotionState?,
      ),
    );
  }
}
