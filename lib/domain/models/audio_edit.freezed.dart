part of 'audio_edit.dart';

T _$identity<T>(T value) => value;

mixin _$AudioEdit {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AudioEdit);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AudioEdit()';
  }
}

class $AudioEditCopyWith<$Res> {
  $AudioEditCopyWith(AudioEdit _, $Res Function(AudioEdit) __);
}

extension AudioEditPatterns on AudioEdit {
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(KeepAudio value)? keep,
    TResult Function(RemoveAudio value)? remove,
    TResult Function(ReplaceAudio value)? replace,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case KeepAudio() when keep != null:
        return keep(_that);
      case RemoveAudio() when remove != null:
        return remove(_that);
      case ReplaceAudio() when replace != null:
        return replace(_that);
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(KeepAudio value) keep,
    required TResult Function(RemoveAudio value) remove,
    required TResult Function(ReplaceAudio value) replace,
  }) {
    final _that = this;
    switch (_that) {
      case KeepAudio():
        return keep(_that);
      case RemoveAudio():
        return remove(_that);
      case ReplaceAudio():
        return replace(_that);
    }
  }

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(KeepAudio value)? keep,
    TResult? Function(RemoveAudio value)? remove,
    TResult? Function(ReplaceAudio value)? replace,
  }) {
    final _that = this;
    switch (_that) {
      case KeepAudio() when keep != null:
        return keep(_that);
      case RemoveAudio() when remove != null:
        return remove(_that);
      case ReplaceAudio() when replace != null:
        return replace(_that);
      case _:
        return null;
    }
  }

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? keep,
    TResult Function()? remove,
    TResult Function(String tempPath, Duration duration)? replace,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case KeepAudio() when keep != null:
        return keep();
      case RemoveAudio() when remove != null:
        return remove();
      case ReplaceAudio() when replace != null:
        return replace(_that.tempPath, _that.duration);
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() keep,
    required TResult Function() remove,
    required TResult Function(String tempPath, Duration duration) replace,
  }) {
    final _that = this;
    switch (_that) {
      case KeepAudio():
        return keep();
      case RemoveAudio():
        return remove();
      case ReplaceAudio():
        return replace(_that.tempPath, _that.duration);
    }
  }

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? keep,
    TResult? Function()? remove,
    TResult? Function(String tempPath, Duration duration)? replace,
  }) {
    final _that = this;
    switch (_that) {
      case KeepAudio() when keep != null:
        return keep();
      case RemoveAudio() when remove != null:
        return remove();
      case ReplaceAudio() when replace != null:
        return replace(_that.tempPath, _that.duration);
      case _:
        return null;
    }
  }
}

class KeepAudio implements AudioEdit {
  const KeepAudio();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is KeepAudio);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AudioEdit.keep()';
  }
}

class RemoveAudio implements AudioEdit {
  const RemoveAudio();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is RemoveAudio);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AudioEdit.remove()';
  }
}

class ReplaceAudio implements AudioEdit {
  const ReplaceAudio({required this.tempPath, required this.duration});

  final String tempPath;
  final Duration duration;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ReplaceAudioCopyWith<ReplaceAudio> get copyWith =>
      _$ReplaceAudioCopyWithImpl<ReplaceAudio>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ReplaceAudio &&
            (identical(other.tempPath, tempPath) ||
                other.tempPath == tempPath) &&
            (identical(other.duration, duration) ||
                other.duration == duration));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, tempPath, duration);
  }

  @override
  String toString() {
    return 'AudioEdit.replace(tempPath: $tempPath, duration: $duration)';
  }
}

abstract mixin class $ReplaceAudioCopyWith<$Res>
    implements $AudioEditCopyWith<$Res> {
  factory $ReplaceAudioCopyWith(
    ReplaceAudio value,
    $Res Function(ReplaceAudio) _then,
  ) = _$ReplaceAudioCopyWithImpl;
  @useResult
  $Res call({String tempPath, Duration duration});
}

class _$ReplaceAudioCopyWithImpl<$Res> implements $ReplaceAudioCopyWith<$Res> {
  _$ReplaceAudioCopyWithImpl(this._self, this._then);

  final ReplaceAudio _self;
  final $Res Function(ReplaceAudio) _then;

  @pragma('vm:prefer-inline')
  $Res call({Object? tempPath = null, Object? duration = null}) {
    return _then(
      ReplaceAudio(
        tempPath: null == tempPath ? _self.tempPath : tempPath as String,
        duration: null == duration ? _self.duration : duration as Duration,
      ),
    );
  }
}
