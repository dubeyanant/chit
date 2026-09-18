part of 'editor_state.dart';

T _$identity<T>(T value) => value;

mixin _$EditorState {
  Chit get chit;
  String get text;
  AudioEdit get audio;

  bool get microphoneRefused;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $EditorStateCopyWith<EditorState> get copyWith =>
      _$EditorStateCopyWithImpl<EditorState>(this as EditorState, _$identity);

  @override
  bool operator ==(Object other) {
    final _this = this as EditorState;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is EditorState &&
            (identical(other.chit, _this.chit) || other.chit == _this.chit) &&
            (identical(other.text, _this.text) || other.text == _this.text) &&
            (identical(other.audio, _this.audio) ||
                other.audio == _this.audio) &&
            (identical(other.microphoneRefused, _this.microphoneRefused) ||
                other.microphoneRefused == _this.microphoneRefused));
  }

  @override
  int get hashCode {
    final _this = this as EditorState;
    return Object.hash(
      runtimeType,
      _this.chit,
      _this.text,
      _this.audio,
      _this.microphoneRefused,
    );
  }

  @override
  String toString() {
    final _this = this as EditorState;
    return 'EditorState(chit: ${_this.chit}, text: ${_this.text}, audio: ${_this.audio}, microphoneRefused: ${_this.microphoneRefused})';
  }
}

abstract mixin class $EditorStateCopyWith<$Res> {
  factory $EditorStateCopyWith(
    EditorState value,
    $Res Function(EditorState) _then,
  ) = _$EditorStateCopyWithImpl;
  @useResult
  $Res call({Chit chit, String text, AudioEdit audio, bool microphoneRefused});

  $ChitCopyWith<$Res> get chit;
  $AudioEditCopyWith<$Res> get audio;
}

class _$EditorStateCopyWithImpl<$Res> implements $EditorStateCopyWith<$Res> {
  _$EditorStateCopyWithImpl(this._self, this._then);

  final EditorState _self;
  final $Res Function(EditorState) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chit = null,
    Object? text = null,
    Object? audio = null,
    Object? microphoneRefused = null,
  }) {
    return _then(
      EditorState(
        chit: null == chit ? _self.chit : chit as Chit,
        text: null == text ? _self.text : text as String,
        audio: null == audio ? _self.audio : audio as AudioEdit,
        microphoneRefused: null == microphoneRefused
            ? _self.microphoneRefused
            : microphoneRefused as bool,
      ),
    );
  }

  @override
  @pragma('vm:prefer-inline')
  $ChitCopyWith<$Res> get chit {
    return $ChitCopyWith<$Res>(_self.chit, (value) {
      return _then(_self.copyWith(chit: value));
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $AudioEditCopyWith<$Res> get audio {
    return $AudioEditCopyWith<$Res>(_self.audio, (value) {
      return _then(_self.copyWith(audio: value));
    });
  }
}

extension EditorStatePatterns on EditorState {
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_EditorState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EditorState() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_EditorState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EditorState():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_EditorState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EditorState() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      Chit chit,
      String text,
      AudioEdit audio,
      bool microphoneRefused,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EditorState() when $default != null:
        return $default(
          _that.chit,
          _that.text,
          _that.audio,
          _that.microphoneRefused,
        );
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      Chit chit,
      String text,
      AudioEdit audio,
      bool microphoneRefused,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EditorState():
        return $default(
          _that.chit,
          _that.text,
          _that.audio,
          _that.microphoneRefused,
        );
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      Chit chit,
      String text,
      AudioEdit audio,
      bool microphoneRefused,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EditorState() when $default != null:
        return $default(
          _that.chit,
          _that.text,
          _that.audio,
          _that.microphoneRefused,
        );
      case _:
        return null;
    }
  }
}

class _EditorState extends EditorState {
  const _EditorState({
    required this.chit,
    required this.text,
    this.audio = const AudioEdit.keep(),
    this.microphoneRefused = false,
  }) : super._();

  @override
  final Chit chit;

  @override
  final String text;

  @override
  @JsonKey()
  final AudioEdit audio;

  @override
  @JsonKey()
  final bool microphoneRefused;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EditorStateCopyWith<_EditorState> get copyWith =>
      __$EditorStateCopyWithImpl<_EditorState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _EditorState &&
            (identical(other.chit, chit) || other.chit == chit) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.audio, audio) || other.audio == audio) &&
            (identical(other.microphoneRefused, microphoneRefused) ||
                other.microphoneRefused == microphoneRefused));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, chit, text, audio, microphoneRefused);
  }

  @override
  String toString() {
    return 'EditorState(chit: $chit, text: $text, audio: $audio, microphoneRefused: $microphoneRefused)';
  }
}

abstract mixin class _$EditorStateCopyWith<$Res>
    implements $EditorStateCopyWith<$Res> {
  factory _$EditorStateCopyWith(
    _EditorState value,
    $Res Function(_EditorState) _then,
  ) = __$EditorStateCopyWithImpl;
  @override
  @useResult
  $Res call({Chit chit, String text, AudioEdit audio, bool microphoneRefused});

  @override
  $ChitCopyWith<$Res> get chit;
  @override
  $AudioEditCopyWith<$Res> get audio;
}

class __$EditorStateCopyWithImpl<$Res> implements _$EditorStateCopyWith<$Res> {
  __$EditorStateCopyWithImpl(this._self, this._then);

  final _EditorState _self;
  final $Res Function(_EditorState) _then;

  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? chit = null,
    Object? text = null,
    Object? audio = null,
    Object? microphoneRefused = null,
  }) {
    return _then(
      _EditorState(
        chit: null == chit ? _self.chit : chit as Chit,
        text: null == text ? _self.text : text as String,
        audio: null == audio ? _self.audio : audio as AudioEdit,
        microphoneRefused: null == microphoneRefused
            ? _self.microphoneRefused
            : microphoneRefused as bool,
      ),
    );
  }

  @override
  @pragma('vm:prefer-inline')
  $ChitCopyWith<$Res> get chit {
    return $ChitCopyWith<$Res>(_self.chit, (value) {
      return _then(_self.copyWith(chit: value));
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $AudioEditCopyWith<$Res> get audio {
    return $AudioEditCopyWith<$Res>(_self.audio, (value) {
      return _then(_self.copyWith(audio: value));
    });
  }
}
