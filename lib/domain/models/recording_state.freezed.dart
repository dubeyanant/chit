part of 'recording_state.dart';

T _$identity<T>(T value) => value;

mixin _$RecordingState {
  Duration get elapsed;

  List<double> get levels;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RecordingStateCopyWith<RecordingState> get copyWith =>
      _$RecordingStateCopyWithImpl<RecordingState>(
        this as RecordingState,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    final _this = this as RecordingState;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RecordingState &&
            (identical(other.elapsed, _this.elapsed) ||
                other.elapsed == _this.elapsed) &&
            const DeepCollectionEquality().equals(other.levels, _this.levels));
  }

  @override
  int get hashCode {
    final _this = this as RecordingState;
    return Object.hash(
      runtimeType,
      _this.elapsed,
      const DeepCollectionEquality().hash(_this.levels),
    );
  }

  @override
  String toString() {
    final _this = this as RecordingState;
    return 'RecordingState(elapsed: ${_this.elapsed}, levels: ${_this.levels})';
  }
}

abstract mixin class $RecordingStateCopyWith<$Res> {
  factory $RecordingStateCopyWith(
    RecordingState value,
    $Res Function(RecordingState) _then,
  ) = _$RecordingStateCopyWithImpl;
  @useResult
  $Res call({Duration elapsed, List<double> levels});
}

class _$RecordingStateCopyWithImpl<$Res>
    implements $RecordingStateCopyWith<$Res> {
  _$RecordingStateCopyWithImpl(this._self, this._then);

  final RecordingState _self;
  final $Res Function(RecordingState) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? elapsed = null, Object? levels = null}) {
    return _then(
      RecordingState(
        elapsed: null == elapsed ? _self.elapsed : elapsed as Duration,
        levels: null == levels ? _self.levels : levels as List<double>,
      ),
    );
  }
}

extension RecordingStatePatterns on RecordingState {
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_RecordingState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RecordingState() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_RecordingState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecordingState():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_RecordingState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecordingState() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(Duration elapsed, List<double> levels)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RecordingState() when $default != null:
        return $default(_that.elapsed, _that.levels);
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(Duration elapsed, List<double> levels) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecordingState():
        return $default(_that.elapsed, _that.levels);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(Duration elapsed, List<double> levels)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecordingState() when $default != null:
        return $default(_that.elapsed, _that.levels);
      case _:
        return null;
    }
  }
}

class _RecordingState extends RecordingState {
  const _RecordingState({
    this.elapsed = Duration.zero,
    List<double> levels = const <double>[],
  }) : _levels = levels,
       super._();

  @override
  @JsonKey()
  final Duration elapsed;

  final List<double> _levels;

  @override
  @JsonKey()
  List<double> get levels {
    if (_levels is EqualUnmodifiableListView) return _levels;

    return EqualUnmodifiableListView(_levels);
  }

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RecordingStateCopyWith<_RecordingState> get copyWith =>
      __$RecordingStateCopyWithImpl<_RecordingState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RecordingState &&
            (identical(other.elapsed, elapsed) || other.elapsed == elapsed) &&
            const DeepCollectionEquality().equals(other.levels, _levels));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      elapsed,
      const DeepCollectionEquality().hash(_levels),
    );
  }

  @override
  String toString() {
    return 'RecordingState(elapsed: $elapsed, levels: $levels)';
  }
}

abstract mixin class _$RecordingStateCopyWith<$Res>
    implements $RecordingStateCopyWith<$Res> {
  factory _$RecordingStateCopyWith(
    _RecordingState value,
    $Res Function(_RecordingState) _then,
  ) = __$RecordingStateCopyWithImpl;
  @override
  @useResult
  $Res call({Duration elapsed, List<double> levels});
}

class __$RecordingStateCopyWithImpl<$Res>
    implements _$RecordingStateCopyWith<$Res> {
  __$RecordingStateCopyWithImpl(this._self, this._then);

  final _RecordingState _self;
  final $Res Function(_RecordingState) _then;

  @override
  @pragma('vm:prefer-inline')
  $Res call({Object? elapsed = null, Object? levels = null}) {
    return _then(
      _RecordingState(
        elapsed: null == elapsed ? _self.elapsed : elapsed as Duration,
        levels: null == levels ? _self._levels : levels as List<double>,
      ),
    );
  }
}
