// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playback_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlaybackState {

 int get index; List<Playable> get playables; double get rate; double get pitch; double get volume; bool get shuffle; Loop get loop; bool get exclusiveAudio; ReplayGain get replayGain;
/// Create a copy of PlaybackState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaybackStateCopyWith<PlaybackState> get copyWith => _$PlaybackStateCopyWithImpl<PlaybackState>(this as PlaybackState, _$identity);

  /// Serializes this PlaybackState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaybackState&&(identical(other.index, index) || other.index == index)&&const DeepCollectionEquality().equals(other.playables, playables)&&(identical(other.rate, rate) || other.rate == rate)&&(identical(other.pitch, pitch) || other.pitch == pitch)&&(identical(other.volume, volume) || other.volume == volume)&&(identical(other.shuffle, shuffle) || other.shuffle == shuffle)&&(identical(other.loop, loop) || other.loop == loop)&&(identical(other.exclusiveAudio, exclusiveAudio) || other.exclusiveAudio == exclusiveAudio)&&(identical(other.replayGain, replayGain) || other.replayGain == replayGain));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,index,const DeepCollectionEquality().hash(playables),rate,pitch,volume,shuffle,loop,exclusiveAudio,replayGain);

@override
String toString() {
  return 'PlaybackState(index: $index, playables: $playables, rate: $rate, pitch: $pitch, volume: $volume, shuffle: $shuffle, loop: $loop, exclusiveAudio: $exclusiveAudio, replayGain: $replayGain)';
}


}

/// @nodoc
abstract mixin class $PlaybackStateCopyWith<$Res>  {
  factory $PlaybackStateCopyWith(PlaybackState value, $Res Function(PlaybackState) _then) = _$PlaybackStateCopyWithImpl;
@useResult
$Res call({
 int index, List<Playable> playables, double rate, double pitch, double volume, bool shuffle, Loop loop, bool exclusiveAudio, ReplayGain replayGain
});




}
/// @nodoc
class _$PlaybackStateCopyWithImpl<$Res>
    implements $PlaybackStateCopyWith<$Res> {
  _$PlaybackStateCopyWithImpl(this._self, this._then);

  final PlaybackState _self;
  final $Res Function(PlaybackState) _then;

/// Create a copy of PlaybackState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? index = null,Object? playables = null,Object? rate = null,Object? pitch = null,Object? volume = null,Object? shuffle = null,Object? loop = null,Object? exclusiveAudio = null,Object? replayGain = null,}) {
  return _then(_self.copyWith(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,playables: null == playables ? _self.playables : playables // ignore: cast_nullable_to_non_nullable
as List<Playable>,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as double,pitch: null == pitch ? _self.pitch : pitch // ignore: cast_nullable_to_non_nullable
as double,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as double,shuffle: null == shuffle ? _self.shuffle : shuffle // ignore: cast_nullable_to_non_nullable
as bool,loop: null == loop ? _self.loop : loop // ignore: cast_nullable_to_non_nullable
as Loop,exclusiveAudio: null == exclusiveAudio ? _self.exclusiveAudio : exclusiveAudio // ignore: cast_nullable_to_non_nullable
as bool,replayGain: null == replayGain ? _self.replayGain : replayGain // ignore: cast_nullable_to_non_nullable
as ReplayGain,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaybackState].
extension PlaybackStatePatterns on PlaybackState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaybackState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaybackState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaybackState value)  $default,){
final _that = this;
switch (_that) {
case _PlaybackState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaybackState value)?  $default,){
final _that = this;
switch (_that) {
case _PlaybackState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int index,  List<Playable> playables,  double rate,  double pitch,  double volume,  bool shuffle,  Loop loop,  bool exclusiveAudio,  ReplayGain replayGain)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaybackState() when $default != null:
return $default(_that.index,_that.playables,_that.rate,_that.pitch,_that.volume,_that.shuffle,_that.loop,_that.exclusiveAudio,_that.replayGain);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int index,  List<Playable> playables,  double rate,  double pitch,  double volume,  bool shuffle,  Loop loop,  bool exclusiveAudio,  ReplayGain replayGain)  $default,) {final _that = this;
switch (_that) {
case _PlaybackState():
return $default(_that.index,_that.playables,_that.rate,_that.pitch,_that.volume,_that.shuffle,_that.loop,_that.exclusiveAudio,_that.replayGain);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int index,  List<Playable> playables,  double rate,  double pitch,  double volume,  bool shuffle,  Loop loop,  bool exclusiveAudio,  ReplayGain replayGain)?  $default,) {final _that = this;
switch (_that) {
case _PlaybackState() when $default != null:
return $default(_that.index,_that.playables,_that.rate,_that.pitch,_that.volume,_that.shuffle,_that.loop,_that.exclusiveAudio,_that.replayGain);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlaybackState implements PlaybackState {
  const _PlaybackState({required this.index, required final  List<Playable> playables, required this.rate, required this.pitch, required this.volume, required this.shuffle, required this.loop, required this.exclusiveAudio, required this.replayGain}): _playables = playables;
  factory _PlaybackState.fromJson(Map<String, dynamic> json) => _$PlaybackStateFromJson(json);

@override final  int index;
 final  List<Playable> _playables;
@override List<Playable> get playables {
  if (_playables is EqualUnmodifiableListView) return _playables;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_playables);
}

@override final  double rate;
@override final  double pitch;
@override final  double volume;
@override final  bool shuffle;
@override final  Loop loop;
@override final  bool exclusiveAudio;
@override final  ReplayGain replayGain;

/// Create a copy of PlaybackState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaybackStateCopyWith<_PlaybackState> get copyWith => __$PlaybackStateCopyWithImpl<_PlaybackState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaybackStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaybackState&&(identical(other.index, index) || other.index == index)&&const DeepCollectionEquality().equals(other._playables, _playables)&&(identical(other.rate, rate) || other.rate == rate)&&(identical(other.pitch, pitch) || other.pitch == pitch)&&(identical(other.volume, volume) || other.volume == volume)&&(identical(other.shuffle, shuffle) || other.shuffle == shuffle)&&(identical(other.loop, loop) || other.loop == loop)&&(identical(other.exclusiveAudio, exclusiveAudio) || other.exclusiveAudio == exclusiveAudio)&&(identical(other.replayGain, replayGain) || other.replayGain == replayGain));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,index,const DeepCollectionEquality().hash(_playables),rate,pitch,volume,shuffle,loop,exclusiveAudio,replayGain);

@override
String toString() {
  return 'PlaybackState(index: $index, playables: $playables, rate: $rate, pitch: $pitch, volume: $volume, shuffle: $shuffle, loop: $loop, exclusiveAudio: $exclusiveAudio, replayGain: $replayGain)';
}


}

/// @nodoc
abstract mixin class _$PlaybackStateCopyWith<$Res> implements $PlaybackStateCopyWith<$Res> {
  factory _$PlaybackStateCopyWith(_PlaybackState value, $Res Function(_PlaybackState) _then) = __$PlaybackStateCopyWithImpl;
@override @useResult
$Res call({
 int index, List<Playable> playables, double rate, double pitch, double volume, bool shuffle, Loop loop, bool exclusiveAudio, ReplayGain replayGain
});




}
/// @nodoc
class __$PlaybackStateCopyWithImpl<$Res>
    implements _$PlaybackStateCopyWith<$Res> {
  __$PlaybackStateCopyWithImpl(this._self, this._then);

  final _PlaybackState _self;
  final $Res Function(_PlaybackState) _then;

/// Create a copy of PlaybackState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? index = null,Object? playables = null,Object? rate = null,Object? pitch = null,Object? volume = null,Object? shuffle = null,Object? loop = null,Object? exclusiveAudio = null,Object? replayGain = null,}) {
  return _then(_PlaybackState(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,playables: null == playables ? _self._playables : playables // ignore: cast_nullable_to_non_nullable
as List<Playable>,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as double,pitch: null == pitch ? _self.pitch : pitch // ignore: cast_nullable_to_non_nullable
as double,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as double,shuffle: null == shuffle ? _self.shuffle : shuffle // ignore: cast_nullable_to_non_nullable
as bool,loop: null == loop ? _self.loop : loop // ignore: cast_nullable_to_non_nullable
as Loop,exclusiveAudio: null == exclusiveAudio ? _self.exclusiveAudio : exclusiveAudio // ignore: cast_nullable_to_non_nullable
as bool,replayGain: null == replayGain ? _self.replayGain : replayGain // ignore: cast_nullable_to_non_nullable
as ReplayGain,
  ));
}


}

// dart format on
