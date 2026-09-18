part of 'day_summary.dart';

T _$identity<T>(T value) => value;

mixin _$DaySummary {
  int get localDay;

  int get count;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DaySummaryCopyWith<DaySummary> get copyWith =>
      _$DaySummaryCopyWithImpl<DaySummary>(this as DaySummary, _$identity);

  @override
  bool operator ==(Object other) {
    final _this = this as DaySummary;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DaySummary &&
            (identical(other.localDay, _this.localDay) ||
                other.localDay == _this.localDay) &&
            (identical(other.count, _this.count) ||
                other.count == _this.count));
  }

  @override
  int get hashCode {
    final _this = this as DaySummary;
    return Object.hash(runtimeType, _this.localDay, _this.count);
  }

  @override
  String toString() {
    final _this = this as DaySummary;
    return 'DaySummary(localDay: ${_this.localDay}, count: ${_this.count})';
  }
}

abstract mixin class $DaySummaryCopyWith<$Res> {
  factory $DaySummaryCopyWith(
    DaySummary value,
    $Res Function(DaySummary) _then,
  ) = _$DaySummaryCopyWithImpl;
  @useResult
  $Res call({int localDay, int count});
}

class _$DaySummaryCopyWithImpl<$Res> implements $DaySummaryCopyWith<$Res> {
  _$DaySummaryCopyWithImpl(this._self, this._then);

  final DaySummary _self;
  final $Res Function(DaySummary) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? localDay = null, Object? count = null}) {
    return _then(
      DaySummary(
        localDay: null == localDay ? _self.localDay : localDay as int,
        count: null == count ? _self.count : count as int,
      ),
    );
  }
}

extension DaySummaryPatterns on DaySummary {
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_DaySummary value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DaySummary() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_DaySummary value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DaySummary():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_DaySummary value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DaySummary() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(int localDay, int count)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DaySummary() when $default != null:
        return $default(_that.localDay, _that.count);
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(int localDay, int count) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DaySummary():
        return $default(_that.localDay, _that.count);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(int localDay, int count)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DaySummary() when $default != null:
        return $default(_that.localDay, _that.count);
      case _:
        return null;
    }
  }
}

class _DaySummary implements DaySummary {
  const _DaySummary({required this.localDay, required this.count});

  @override
  final int localDay;

  @override
  final int count;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DaySummaryCopyWith<_DaySummary> get copyWith =>
      __$DaySummaryCopyWithImpl<_DaySummary>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DaySummary &&
            (identical(other.localDay, localDay) ||
                other.localDay == localDay) &&
            (identical(other.count, count) || other.count == count));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, localDay, count);
  }

  @override
  String toString() {
    return 'DaySummary(localDay: $localDay, count: $count)';
  }
}

abstract mixin class _$DaySummaryCopyWith<$Res>
    implements $DaySummaryCopyWith<$Res> {
  factory _$DaySummaryCopyWith(
    _DaySummary value,
    $Res Function(_DaySummary) _then,
  ) = __$DaySummaryCopyWithImpl;
  @override
  @useResult
  $Res call({int localDay, int count});
}

class __$DaySummaryCopyWithImpl<$Res> implements _$DaySummaryCopyWith<$Res> {
  __$DaySummaryCopyWithImpl(this._self, this._then);

  final _DaySummary _self;
  final $Res Function(_DaySummary) _then;

  @override
  @pragma('vm:prefer-inline')
  $Res call({Object? localDay = null, Object? count = null}) {
    return _then(
      _DaySummary(
        localDay: null == localDay ? _self.localDay : localDay as int,
        count: null == count ? _self.count : count as int,
      ),
    );
  }
}
