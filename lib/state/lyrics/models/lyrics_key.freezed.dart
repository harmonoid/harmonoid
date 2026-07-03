// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lyrics_key.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LyricsKey {

 String get track; String get artist; int get duration;
/// Create a copy of LyricsKey
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LyricsKeyCopyWith<LyricsKey> get copyWith => _$LyricsKeyCopyWithImpl<LyricsKey>(this as LyricsKey, _$identity);

  /// Serializes this LyricsKey to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LyricsKey&&(identical(other.track, track) || other.track == track)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.duration, duration) || other.duration == duration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,track,artist,duration);

@override
String toString() {
  return 'LyricsKey(track: $track, artist: $artist, duration: $duration)';
}


}

/// @nodoc
abstract mixin class $LyricsKeyCopyWith<$Res>  {
  factory $LyricsKeyCopyWith(LyricsKey value, $Res Function(LyricsKey) _then) = _$LyricsKeyCopyWithImpl;
@useResult
$Res call({
 String track, String artist, int duration
});




}
/// @nodoc
class _$LyricsKeyCopyWithImpl<$Res>
    implements $LyricsKeyCopyWith<$Res> {
  _$LyricsKeyCopyWithImpl(this._self, this._then);

  final LyricsKey _self;
  final $Res Function(LyricsKey) _then;

/// Create a copy of LyricsKey
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? track = null,Object? artist = null,Object? duration = null,}) {
  return _then(_self.copyWith(
track: null == track ? _self.track : track // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LyricsKey].
extension LyricsKeyPatterns on LyricsKey {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LyricsKey value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LyricsKey() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LyricsKey value)  $default,){
final _that = this;
switch (_that) {
case _LyricsKey():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LyricsKey value)?  $default,){
final _that = this;
switch (_that) {
case _LyricsKey() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String track,  String artist,  int duration)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LyricsKey() when $default != null:
return $default(_that.track,_that.artist,_that.duration);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String track,  String artist,  int duration)  $default,) {final _that = this;
switch (_that) {
case _LyricsKey():
return $default(_that.track,_that.artist,_that.duration);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String track,  String artist,  int duration)?  $default,) {final _that = this;
switch (_that) {
case _LyricsKey() when $default != null:
return $default(_that.track,_that.artist,_that.duration);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LyricsKey implements LyricsKey {
  const _LyricsKey({required this.track, required this.artist, required this.duration});
  factory _LyricsKey.fromJson(Map<String, dynamic> json) => _$LyricsKeyFromJson(json);

@override final  String track;
@override final  String artist;
@override final  int duration;

/// Create a copy of LyricsKey
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LyricsKeyCopyWith<_LyricsKey> get copyWith => __$LyricsKeyCopyWithImpl<_LyricsKey>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LyricsKeyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LyricsKey&&(identical(other.track, track) || other.track == track)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.duration, duration) || other.duration == duration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,track,artist,duration);

@override
String toString() {
  return 'LyricsKey(track: $track, artist: $artist, duration: $duration)';
}


}

/// @nodoc
abstract mixin class _$LyricsKeyCopyWith<$Res> implements $LyricsKeyCopyWith<$Res> {
  factory _$LyricsKeyCopyWith(_LyricsKey value, $Res Function(_LyricsKey) _then) = __$LyricsKeyCopyWithImpl;
@override @useResult
$Res call({
 String track, String artist, int duration
});




}
/// @nodoc
class __$LyricsKeyCopyWithImpl<$Res>
    implements _$LyricsKeyCopyWith<$Res> {
  __$LyricsKeyCopyWithImpl(this._self, this._then);

  final _LyricsKey _self;
  final $Res Function(_LyricsKey) _then;

/// Create a copy of LyricsKey
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? track = null,Object? artist = null,Object? duration = null,}) {
  return _then(_LyricsKey(
track: null == track ? _self.track : track // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
