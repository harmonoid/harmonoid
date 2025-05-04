// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playback_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PlaybackState _$PlaybackStateFromJson(Map<String, dynamic> json) {
  return _PlaybackState.fromJson(json);
}

/// @nodoc
mixin _$PlaybackState {
  int get index => throw _privateConstructorUsedError;
  List<Playable> get playables => throw _privateConstructorUsedError;
  double get rate => throw _privateConstructorUsedError;
  double get pitch => throw _privateConstructorUsedError;
  double get volume => throw _privateConstructorUsedError;
  bool get shuffle => throw _privateConstructorUsedError;
  Loop get loop => throw _privateConstructorUsedError;
  bool get exclusiveAudio => throw _privateConstructorUsedError;

  /// Serializes this PlaybackState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlaybackState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlaybackStateCopyWith<PlaybackState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaybackStateCopyWith<$Res> {
  factory $PlaybackStateCopyWith(
          PlaybackState value, $Res Function(PlaybackState) then) =
      _$PlaybackStateCopyWithImpl<$Res, PlaybackState>;
  @useResult
  $Res call(
      {int index,
      List<Playable> playables,
      double rate,
      double pitch,
      double volume,
      bool shuffle,
      Loop loop,
      bool exclusiveAudio});
}

/// @nodoc
class _$PlaybackStateCopyWithImpl<$Res, $Val extends PlaybackState>
    implements $PlaybackStateCopyWith<$Res> {
  _$PlaybackStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlaybackState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
    Object? playables = null,
    Object? rate = null,
    Object? pitch = null,
    Object? volume = null,
    Object? shuffle = null,
    Object? loop = null,
    Object? exclusiveAudio = null,
  }) {
    return _then(_value.copyWith(
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      playables: null == playables
          ? _value.playables
          : playables // ignore: cast_nullable_to_non_nullable
              as List<Playable>,
      rate: null == rate
          ? _value.rate
          : rate // ignore: cast_nullable_to_non_nullable
              as double,
      pitch: null == pitch
          ? _value.pitch
          : pitch // ignore: cast_nullable_to_non_nullable
              as double,
      volume: null == volume
          ? _value.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as double,
      shuffle: null == shuffle
          ? _value.shuffle
          : shuffle // ignore: cast_nullable_to_non_nullable
              as bool,
      loop: null == loop
          ? _value.loop
          : loop // ignore: cast_nullable_to_non_nullable
              as Loop,
      exclusiveAudio: null == exclusiveAudio
          ? _value.exclusiveAudio
          : exclusiveAudio // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlaybackStateImplCopyWith<$Res>
    implements $PlaybackStateCopyWith<$Res> {
  factory _$$PlaybackStateImplCopyWith(
          _$PlaybackStateImpl value, $Res Function(_$PlaybackStateImpl) then) =
      __$$PlaybackStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int index,
      List<Playable> playables,
      double rate,
      double pitch,
      double volume,
      bool shuffle,
      Loop loop,
      bool exclusiveAudio});
}

/// @nodoc
class __$$PlaybackStateImplCopyWithImpl<$Res>
    extends _$PlaybackStateCopyWithImpl<$Res, _$PlaybackStateImpl>
    implements _$$PlaybackStateImplCopyWith<$Res> {
  __$$PlaybackStateImplCopyWithImpl(
      _$PlaybackStateImpl _value, $Res Function(_$PlaybackStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlaybackState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
    Object? playables = null,
    Object? rate = null,
    Object? pitch = null,
    Object? volume = null,
    Object? shuffle = null,
    Object? loop = null,
    Object? exclusiveAudio = null,
  }) {
    return _then(_$PlaybackStateImpl(
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      playables: null == playables
          ? _value._playables
          : playables // ignore: cast_nullable_to_non_nullable
              as List<Playable>,
      rate: null == rate
          ? _value.rate
          : rate // ignore: cast_nullable_to_non_nullable
              as double,
      pitch: null == pitch
          ? _value.pitch
          : pitch // ignore: cast_nullable_to_non_nullable
              as double,
      volume: null == volume
          ? _value.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as double,
      shuffle: null == shuffle
          ? _value.shuffle
          : shuffle // ignore: cast_nullable_to_non_nullable
              as bool,
      loop: null == loop
          ? _value.loop
          : loop // ignore: cast_nullable_to_non_nullable
              as Loop,
      exclusiveAudio: null == exclusiveAudio
          ? _value.exclusiveAudio
          : exclusiveAudio // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlaybackStateImpl implements _PlaybackState {
  const _$PlaybackStateImpl(
      {required this.index,
      required final List<Playable> playables,
      required this.rate,
      required this.pitch,
      required this.volume,
      required this.shuffle,
      required this.loop,
      required this.exclusiveAudio})
      : _playables = playables;

  factory _$PlaybackStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaybackStateImplFromJson(json);

  @override
  final int index;
  final List<Playable> _playables;
  @override
  List<Playable> get playables {
    if (_playables is EqualUnmodifiableListView) return _playables;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_playables);
  }

  @override
  final double rate;
  @override
  final double pitch;
  @override
  final double volume;
  @override
  final bool shuffle;
  @override
  final Loop loop;
  @override
  final bool exclusiveAudio;

  @override
  String toString() {
    return 'PlaybackState(index: $index, playables: $playables, rate: $rate, pitch: $pitch, volume: $volume, shuffle: $shuffle, loop: $loop, exclusiveAudio: $exclusiveAudio)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaybackStateImpl &&
            (identical(other.index, index) || other.index == index) &&
            const DeepCollectionEquality()
                .equals(other._playables, _playables) &&
            (identical(other.rate, rate) || other.rate == rate) &&
            (identical(other.pitch, pitch) || other.pitch == pitch) &&
            (identical(other.volume, volume) || other.volume == volume) &&
            (identical(other.shuffle, shuffle) || other.shuffle == shuffle) &&
            (identical(other.loop, loop) || other.loop == loop) &&
            (identical(other.exclusiveAudio, exclusiveAudio) ||
                other.exclusiveAudio == exclusiveAudio));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      index,
      const DeepCollectionEquality().hash(_playables),
      rate,
      pitch,
      volume,
      shuffle,
      loop,
      exclusiveAudio);

  /// Create a copy of PlaybackState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaybackStateImplCopyWith<_$PlaybackStateImpl> get copyWith =>
      __$$PlaybackStateImplCopyWithImpl<_$PlaybackStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlaybackStateImplToJson(
      this,
    );
  }
}

abstract class _PlaybackState implements PlaybackState {
  const factory _PlaybackState(
      {required final int index,
      required final List<Playable> playables,
      required final double rate,
      required final double pitch,
      required final double volume,
      required final bool shuffle,
      required final Loop loop,
      required final bool exclusiveAudio}) = _$PlaybackStateImpl;

  factory _PlaybackState.fromJson(Map<String, dynamic> json) =
      _$PlaybackStateImpl.fromJson;

  @override
  int get index;
  @override
  List<Playable> get playables;
  @override
  double get rate;
  @override
  double get pitch;
  @override
  double get volume;
  @override
  bool get shuffle;
  @override
  Loop get loop;
  @override
  bool get exclusiveAudio;

  /// Create a copy of PlaybackState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlaybackStateImplCopyWith<_$PlaybackStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
