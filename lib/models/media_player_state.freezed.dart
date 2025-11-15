// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_player_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MediaPlayerState {

 int get index; List<Playable> get playables; double get rate; double get pitch; double get volume; bool get shuffle; Loop get loop; bool get exclusiveAudio; ReplayGain get replayGain; double get replayGainPreamp; Duration get crossfadeDuration; Duration get position; Duration get duration; bool get playing; bool get buffering; bool get completed; double get audioBitrate; AudioParams get audioParams;
/// Create a copy of MediaPlayerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaPlayerStateCopyWith<MediaPlayerState> get copyWith => _$MediaPlayerStateCopyWithImpl<MediaPlayerState>(this as MediaPlayerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaPlayerState&&(identical(other.index, index) || other.index == index)&&const DeepCollectionEquality().equals(other.playables, playables)&&(identical(other.rate, rate) || other.rate == rate)&&(identical(other.pitch, pitch) || other.pitch == pitch)&&(identical(other.volume, volume) || other.volume == volume)&&(identical(other.shuffle, shuffle) || other.shuffle == shuffle)&&(identical(other.loop, loop) || other.loop == loop)&&(identical(other.exclusiveAudio, exclusiveAudio) || other.exclusiveAudio == exclusiveAudio)&&(identical(other.replayGain, replayGain) || other.replayGain == replayGain)&&(identical(other.replayGainPreamp, replayGainPreamp) || other.replayGainPreamp == replayGainPreamp)&&(identical(other.crossfadeDuration, crossfadeDuration) || other.crossfadeDuration == crossfadeDuration)&&(identical(other.position, position) || other.position == position)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.playing, playing) || other.playing == playing)&&(identical(other.buffering, buffering) || other.buffering == buffering)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.audioBitrate, audioBitrate) || other.audioBitrate == audioBitrate)&&(identical(other.audioParams, audioParams) || other.audioParams == audioParams));
}


@override
int get hashCode => Object.hash(runtimeType,index,const DeepCollectionEquality().hash(playables),rate,pitch,volume,shuffle,loop,exclusiveAudio,replayGain,replayGainPreamp,crossfadeDuration,position,duration,playing,buffering,completed,audioBitrate,audioParams);

@override
String toString() {
  return 'MediaPlayerState(index: $index, playables: $playables, rate: $rate, pitch: $pitch, volume: $volume, shuffle: $shuffle, loop: $loop, exclusiveAudio: $exclusiveAudio, replayGain: $replayGain, replayGainPreamp: $replayGainPreamp, crossfadeDuration: $crossfadeDuration, position: $position, duration: $duration, playing: $playing, buffering: $buffering, completed: $completed, audioBitrate: $audioBitrate, audioParams: $audioParams)';
}


}

/// @nodoc
abstract mixin class $MediaPlayerStateCopyWith<$Res>  {
  factory $MediaPlayerStateCopyWith(MediaPlayerState value, $Res Function(MediaPlayerState) _then) = _$MediaPlayerStateCopyWithImpl;
@useResult
$Res call({
 int index, List<Playable> playables, double rate, double pitch, double volume, bool shuffle, Loop loop, bool exclusiveAudio, ReplayGain replayGain, double replayGainPreamp, Duration crossfadeDuration, Duration position, Duration duration, bool playing, bool buffering, bool completed, double audioBitrate, AudioParams audioParams
});




}
/// @nodoc
class _$MediaPlayerStateCopyWithImpl<$Res>
    implements $MediaPlayerStateCopyWith<$Res> {
  _$MediaPlayerStateCopyWithImpl(this._self, this._then);

  final MediaPlayerState _self;
  final $Res Function(MediaPlayerState) _then;

/// Create a copy of MediaPlayerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? index = null,Object? playables = null,Object? rate = null,Object? pitch = null,Object? volume = null,Object? shuffle = null,Object? loop = null,Object? exclusiveAudio = null,Object? replayGain = null,Object? replayGainPreamp = null,Object? crossfadeDuration = null,Object? position = null,Object? duration = null,Object? playing = null,Object? buffering = null,Object? completed = null,Object? audioBitrate = null,Object? audioParams = null,}) {
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
as ReplayGain,replayGainPreamp: null == replayGainPreamp ? _self.replayGainPreamp : replayGainPreamp // ignore: cast_nullable_to_non_nullable
as double,crossfadeDuration: null == crossfadeDuration ? _self.crossfadeDuration : crossfadeDuration // ignore: cast_nullable_to_non_nullable
as Duration,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,playing: null == playing ? _self.playing : playing // ignore: cast_nullable_to_non_nullable
as bool,buffering: null == buffering ? _self.buffering : buffering // ignore: cast_nullable_to_non_nullable
as bool,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,audioBitrate: null == audioBitrate ? _self.audioBitrate : audioBitrate // ignore: cast_nullable_to_non_nullable
as double,audioParams: null == audioParams ? _self.audioParams : audioParams // ignore: cast_nullable_to_non_nullable
as AudioParams,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaPlayerState].
extension MediaPlayerStatePatterns on MediaPlayerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaPlayerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaPlayerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaPlayerState value)  $default,){
final _that = this;
switch (_that) {
case _MediaPlayerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaPlayerState value)?  $default,){
final _that = this;
switch (_that) {
case _MediaPlayerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int index,  List<Playable> playables,  double rate,  double pitch,  double volume,  bool shuffle,  Loop loop,  bool exclusiveAudio,  ReplayGain replayGain,  double replayGainPreamp,  Duration crossfadeDuration,  Duration position,  Duration duration,  bool playing,  bool buffering,  bool completed,  double audioBitrate,  AudioParams audioParams)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaPlayerState() when $default != null:
return $default(_that.index,_that.playables,_that.rate,_that.pitch,_that.volume,_that.shuffle,_that.loop,_that.exclusiveAudio,_that.replayGain,_that.replayGainPreamp,_that.crossfadeDuration,_that.position,_that.duration,_that.playing,_that.buffering,_that.completed,_that.audioBitrate,_that.audioParams);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int index,  List<Playable> playables,  double rate,  double pitch,  double volume,  bool shuffle,  Loop loop,  bool exclusiveAudio,  ReplayGain replayGain,  double replayGainPreamp,  Duration crossfadeDuration,  Duration position,  Duration duration,  bool playing,  bool buffering,  bool completed,  double audioBitrate,  AudioParams audioParams)  $default,) {final _that = this;
switch (_that) {
case _MediaPlayerState():
return $default(_that.index,_that.playables,_that.rate,_that.pitch,_that.volume,_that.shuffle,_that.loop,_that.exclusiveAudio,_that.replayGain,_that.replayGainPreamp,_that.crossfadeDuration,_that.position,_that.duration,_that.playing,_that.buffering,_that.completed,_that.audioBitrate,_that.audioParams);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int index,  List<Playable> playables,  double rate,  double pitch,  double volume,  bool shuffle,  Loop loop,  bool exclusiveAudio,  ReplayGain replayGain,  double replayGainPreamp,  Duration crossfadeDuration,  Duration position,  Duration duration,  bool playing,  bool buffering,  bool completed,  double audioBitrate,  AudioParams audioParams)?  $default,) {final _that = this;
switch (_that) {
case _MediaPlayerState() when $default != null:
return $default(_that.index,_that.playables,_that.rate,_that.pitch,_that.volume,_that.shuffle,_that.loop,_that.exclusiveAudio,_that.replayGain,_that.replayGainPreamp,_that.crossfadeDuration,_that.position,_that.duration,_that.playing,_that.buffering,_that.completed,_that.audioBitrate,_that.audioParams);case _:
  return null;

}
}

}

/// @nodoc


class _MediaPlayerState implements MediaPlayerState {
  const _MediaPlayerState({required this.index, required final  List<Playable> playables, required this.rate, required this.pitch, required this.volume, required this.shuffle, required this.loop, required this.exclusiveAudio, required this.replayGain, required this.replayGainPreamp, required this.crossfadeDuration, required this.position, required this.duration, required this.playing, required this.buffering, required this.completed, required this.audioBitrate, required this.audioParams}): _playables = playables;
  

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
@override final  double replayGainPreamp;
@override final  Duration crossfadeDuration;
@override final  Duration position;
@override final  Duration duration;
@override final  bool playing;
@override final  bool buffering;
@override final  bool completed;
@override final  double audioBitrate;
@override final  AudioParams audioParams;

/// Create a copy of MediaPlayerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaPlayerStateCopyWith<_MediaPlayerState> get copyWith => __$MediaPlayerStateCopyWithImpl<_MediaPlayerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaPlayerState&&(identical(other.index, index) || other.index == index)&&const DeepCollectionEquality().equals(other._playables, _playables)&&(identical(other.rate, rate) || other.rate == rate)&&(identical(other.pitch, pitch) || other.pitch == pitch)&&(identical(other.volume, volume) || other.volume == volume)&&(identical(other.shuffle, shuffle) || other.shuffle == shuffle)&&(identical(other.loop, loop) || other.loop == loop)&&(identical(other.exclusiveAudio, exclusiveAudio) || other.exclusiveAudio == exclusiveAudio)&&(identical(other.replayGain, replayGain) || other.replayGain == replayGain)&&(identical(other.replayGainPreamp, replayGainPreamp) || other.replayGainPreamp == replayGainPreamp)&&(identical(other.crossfadeDuration, crossfadeDuration) || other.crossfadeDuration == crossfadeDuration)&&(identical(other.position, position) || other.position == position)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.playing, playing) || other.playing == playing)&&(identical(other.buffering, buffering) || other.buffering == buffering)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.audioBitrate, audioBitrate) || other.audioBitrate == audioBitrate)&&(identical(other.audioParams, audioParams) || other.audioParams == audioParams));
}


@override
int get hashCode => Object.hash(runtimeType,index,const DeepCollectionEquality().hash(_playables),rate,pitch,volume,shuffle,loop,exclusiveAudio,replayGain,replayGainPreamp,crossfadeDuration,position,duration,playing,buffering,completed,audioBitrate,audioParams);

@override
String toString() {
  return 'MediaPlayerState(index: $index, playables: $playables, rate: $rate, pitch: $pitch, volume: $volume, shuffle: $shuffle, loop: $loop, exclusiveAudio: $exclusiveAudio, replayGain: $replayGain, replayGainPreamp: $replayGainPreamp, crossfadeDuration: $crossfadeDuration, position: $position, duration: $duration, playing: $playing, buffering: $buffering, completed: $completed, audioBitrate: $audioBitrate, audioParams: $audioParams)';
}


}

/// @nodoc
abstract mixin class _$MediaPlayerStateCopyWith<$Res> implements $MediaPlayerStateCopyWith<$Res> {
  factory _$MediaPlayerStateCopyWith(_MediaPlayerState value, $Res Function(_MediaPlayerState) _then) = __$MediaPlayerStateCopyWithImpl;
@override @useResult
$Res call({
 int index, List<Playable> playables, double rate, double pitch, double volume, bool shuffle, Loop loop, bool exclusiveAudio, ReplayGain replayGain, double replayGainPreamp, Duration crossfadeDuration, Duration position, Duration duration, bool playing, bool buffering, bool completed, double audioBitrate, AudioParams audioParams
});




}
/// @nodoc
class __$MediaPlayerStateCopyWithImpl<$Res>
    implements _$MediaPlayerStateCopyWith<$Res> {
  __$MediaPlayerStateCopyWithImpl(this._self, this._then);

  final _MediaPlayerState _self;
  final $Res Function(_MediaPlayerState) _then;

/// Create a copy of MediaPlayerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? index = null,Object? playables = null,Object? rate = null,Object? pitch = null,Object? volume = null,Object? shuffle = null,Object? loop = null,Object? exclusiveAudio = null,Object? replayGain = null,Object? replayGainPreamp = null,Object? crossfadeDuration = null,Object? position = null,Object? duration = null,Object? playing = null,Object? buffering = null,Object? completed = null,Object? audioBitrate = null,Object? audioParams = null,}) {
  return _then(_MediaPlayerState(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,playables: null == playables ? _self._playables : playables // ignore: cast_nullable_to_non_nullable
as List<Playable>,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as double,pitch: null == pitch ? _self.pitch : pitch // ignore: cast_nullable_to_non_nullable
as double,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as double,shuffle: null == shuffle ? _self.shuffle : shuffle // ignore: cast_nullable_to_non_nullable
as bool,loop: null == loop ? _self.loop : loop // ignore: cast_nullable_to_non_nullable
as Loop,exclusiveAudio: null == exclusiveAudio ? _self.exclusiveAudio : exclusiveAudio // ignore: cast_nullable_to_non_nullable
as bool,replayGain: null == replayGain ? _self.replayGain : replayGain // ignore: cast_nullable_to_non_nullable
as ReplayGain,replayGainPreamp: null == replayGainPreamp ? _self.replayGainPreamp : replayGainPreamp // ignore: cast_nullable_to_non_nullable
as double,crossfadeDuration: null == crossfadeDuration ? _self.crossfadeDuration : crossfadeDuration // ignore: cast_nullable_to_non_nullable
as Duration,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,playing: null == playing ? _self.playing : playing // ignore: cast_nullable_to_non_nullable
as bool,buffering: null == buffering ? _self.buffering : buffering // ignore: cast_nullable_to_non_nullable
as bool,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,audioBitrate: null == audioBitrate ? _self.audioBitrate : audioBitrate // ignore: cast_nullable_to_non_nullable
as double,audioParams: null == audioParams ? _self.audioParams : audioParams // ignore: cast_nullable_to_non_nullable
as AudioParams,
  ));
}


}

// dart format on
