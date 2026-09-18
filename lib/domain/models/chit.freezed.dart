part of 'chit.dart';

T _$identity<T>(T value) => value;

mixin _$Chit {
  String get id;
  DateTime get createdAt;

  int get localDay;

  DateTime get updatedAt;

  String? get text;

  String? get audioPath;
  Duration? get audioDuration;
  WeatherCondition? get weather;
  double? get lat;
  double? get lon;

  MotionState? get motion;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChitCopyWith<Chit> get copyWith =>
      _$ChitCopyWithImpl<Chit>(this as Chit, _$identity);

  @override
  bool operator ==(Object other) {
    final _this = this as Chit;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Chit &&
            (identical(other.id, _this.id) || other.id == _this.id) &&
            (identical(other.createdAt, _this.createdAt) ||
                other.createdAt == _this.createdAt) &&
            (identical(other.localDay, _this.localDay) ||
                other.localDay == _this.localDay) &&
            (identical(other.updatedAt, _this.updatedAt) ||
                other.updatedAt == _this.updatedAt) &&
            (identical(other.text, _this.text) || other.text == _this.text) &&
            (identical(other.audioPath, _this.audioPath) ||
                other.audioPath == _this.audioPath) &&
            (identical(other.audioDuration, _this.audioDuration) ||
                other.audioDuration == _this.audioDuration) &&
            (identical(other.weather, _this.weather) ||
                other.weather == _this.weather) &&
            (identical(other.lat, _this.lat) || other.lat == _this.lat) &&
            (identical(other.lon, _this.lon) || other.lon == _this.lon) &&
            (identical(other.motion, _this.motion) ||
                other.motion == _this.motion));
  }

  @override
  int get hashCode {
    final _this = this as Chit;
    return Object.hash(
      runtimeType,
      _this.id,
      _this.createdAt,
      _this.localDay,
      _this.updatedAt,
      _this.text,
      _this.audioPath,
      _this.audioDuration,
      _this.weather,
      _this.lat,
      _this.lon,
      _this.motion,
    );
  }

  @override
  String toString() {
    final _this = this as Chit;
    return 'Chit(id: ${_this.id}, createdAt: ${_this.createdAt}, localDay: ${_this.localDay}, updatedAt: ${_this.updatedAt}, text: ${_this.text}, audioPath: ${_this.audioPath}, audioDuration: ${_this.audioDuration}, weather: ${_this.weather}, lat: ${_this.lat}, lon: ${_this.lon}, motion: ${_this.motion})';
  }
}

abstract mixin class $ChitCopyWith<$Res> {
  factory $ChitCopyWith(Chit value, $Res Function(Chit) _then) =
      _$ChitCopyWithImpl;
  @useResult
  $Res call({
    String id,
    DateTime createdAt,
    int localDay,
    DateTime updatedAt,
    String? text,
    String? audioPath,
    Duration? audioDuration,
    WeatherCondition? weather,
    double? lat,
    double? lon,
    MotionState? motion,
  });
}

class _$ChitCopyWithImpl<$Res> implements $ChitCopyWith<$Res> {
  _$ChitCopyWithImpl(this._self, this._then);

  final Chit _self;
  final $Res Function(Chit) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? localDay = null,
    Object? updatedAt = null,
    Object? text = freezed,
    Object? audioPath = freezed,
    Object? audioDuration = freezed,
    Object? weather = freezed,
    Object? lat = freezed,
    Object? lon = freezed,
    Object? motion = freezed,
  }) {
    return _then(
      Chit(
        id: null == id ? _self.id : id as String,
        createdAt: null == createdAt ? _self.createdAt : createdAt as DateTime,
        localDay: null == localDay ? _self.localDay : localDay as int,
        updatedAt: null == updatedAt ? _self.updatedAt : updatedAt as DateTime,
        text: freezed == text ? _self.text : text as String?,
        audioPath: freezed == audioPath
            ? _self.audioPath
            : audioPath as String?,
        audioDuration: freezed == audioDuration
            ? _self.audioDuration
            : audioDuration as Duration?,
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

extension ChitPatterns on Chit {
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Chit value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Chit() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult map<TResult extends Object?>(TResult Function(_Chit value) $default) {
    final _that = this;
    switch (_that) {
      case _Chit():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Chit value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Chit() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      String id,
      DateTime createdAt,
      int localDay,
      DateTime updatedAt,
      String? text,
      String? audioPath,
      Duration? audioDuration,
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
      case _Chit() when $default != null:
        return $default(
          _that.id,
          _that.createdAt,
          _that.localDay,
          _that.updatedAt,
          _that.text,
          _that.audioPath,
          _that.audioDuration,
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
      String id,
      DateTime createdAt,
      int localDay,
      DateTime updatedAt,
      String? text,
      String? audioPath,
      Duration? audioDuration,
      WeatherCondition? weather,
      double? lat,
      double? lon,
      MotionState? motion,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Chit():
        return $default(
          _that.id,
          _that.createdAt,
          _that.localDay,
          _that.updatedAt,
          _that.text,
          _that.audioPath,
          _that.audioDuration,
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
      String id,
      DateTime createdAt,
      int localDay,
      DateTime updatedAt,
      String? text,
      String? audioPath,
      Duration? audioDuration,
      WeatherCondition? weather,
      double? lat,
      double? lon,
      MotionState? motion,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Chit() when $default != null:
        return $default(
          _that.id,
          _that.createdAt,
          _that.localDay,
          _that.updatedAt,
          _that.text,
          _that.audioPath,
          _that.audioDuration,
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

class _Chit extends Chit {
  const _Chit({
    required this.id,
    required this.createdAt,
    required this.localDay,
    required this.updatedAt,
    this.text,
    this.audioPath,
    this.audioDuration,
    this.weather,
    this.lat,
    this.lon,
    this.motion,
  }) : assert(
         text != null || audioPath != null,
         'a chit with neither text nor audio is not a chit — README §5',
       ),
       assert(
         text == null || text != '',
         'empty text is no text: an empty field is the chit §3.1 refuses to save',
       ),
       assert(
         (lat == null) == (lon == null),
         'a coordinate is both halves or neither',
       ),
       assert(
         (audioPath == null) == (audioDuration == null),
         'a recording has a length; a length without a recording is nothing',
       ),
       super._();

  @override
  final String id;

  @override
  final DateTime createdAt;

  @override
  final int localDay;

  @override
  final DateTime updatedAt;

  @override
  final String? text;

  @override
  final String? audioPath;

  @override
  final Duration? audioDuration;

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
  _$ChitCopyWith<_Chit> get copyWith =>
      __$ChitCopyWithImpl<_Chit>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Chit &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.localDay, localDay) ||
                other.localDay == localDay) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.audioPath, audioPath) ||
                other.audioPath == audioPath) &&
            (identical(other.audioDuration, audioDuration) ||
                other.audioDuration == audioDuration) &&
            (identical(other.weather, weather) || other.weather == weather) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lon, lon) || other.lon == lon) &&
            (identical(other.motion, motion) || other.motion == motion));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      id,
      createdAt,
      localDay,
      updatedAt,
      text,
      audioPath,
      audioDuration,
      weather,
      lat,
      lon,
      motion,
    );
  }

  @override
  String toString() {
    return 'Chit(id: $id, createdAt: $createdAt, localDay: $localDay, updatedAt: $updatedAt, text: $text, audioPath: $audioPath, audioDuration: $audioDuration, weather: $weather, lat: $lat, lon: $lon, motion: $motion)';
  }
}

abstract mixin class _$ChitCopyWith<$Res> implements $ChitCopyWith<$Res> {
  factory _$ChitCopyWith(_Chit value, $Res Function(_Chit) _then) =
      __$ChitCopyWithImpl;
  @override
  @useResult
  $Res call({
    String id,
    DateTime createdAt,
    int localDay,
    DateTime updatedAt,
    String? text,
    String? audioPath,
    Duration? audioDuration,
    WeatherCondition? weather,
    double? lat,
    double? lon,
    MotionState? motion,
  });
}

class __$ChitCopyWithImpl<$Res> implements _$ChitCopyWith<$Res> {
  __$ChitCopyWithImpl(this._self, this._then);

  final _Chit _self;
  final $Res Function(_Chit) _then;

  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? localDay = null,
    Object? updatedAt = null,
    Object? text = freezed,
    Object? audioPath = freezed,
    Object? audioDuration = freezed,
    Object? weather = freezed,
    Object? lat = freezed,
    Object? lon = freezed,
    Object? motion = freezed,
  }) {
    return _then(
      _Chit(
        id: null == id ? _self.id : id as String,
        createdAt: null == createdAt ? _self.createdAt : createdAt as DateTime,
        localDay: null == localDay ? _self.localDay : localDay as int,
        updatedAt: null == updatedAt ? _self.updatedAt : updatedAt as DateTime,
        text: freezed == text ? _self.text : text as String?,
        audioPath: freezed == audioPath
            ? _self.audioPath
            : audioPath as String?,
        audioDuration: freezed == audioDuration
            ? _self.audioDuration
            : audioDuration as Duration?,
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
