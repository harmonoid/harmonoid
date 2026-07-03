// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lyrics_translation_key.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LyricsTranslationKey {

 String get track; String get artist; int get duration; String get language;
/// Create a copy of LyricsTranslationKey
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LyricsTranslationKeyCopyWith<LyricsTranslationKey> get copyWith => _$LyricsTranslationKeyCopyWithImpl<LyricsTranslationKey>(this as LyricsTranslationKey, _$identity);

  /// Serializes this LyricsTranslationKey to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LyricsTranslationKey&&(identical(other.track, track) || other.track == track)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.language, language) || other.language == language));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,track,artist,duration,language);

@override
String toString() {
  return 'LyricsTranslationKey(track: $track, artist: $artist, duration: $duration, language: $language)';
}


}

/// @nodoc
abstract mixin class $LyricsTranslationKeyCopyWith<$Res>  {
  factory $LyricsTranslationKeyCopyWith(LyricsTranslationKey value, $Res Function(LyricsTranslationKey) _then) = _$LyricsTranslationKeyCopyWithImpl;
@useResult
$Res call({
 String track, String artist, int duration, String language
});




}
/// @nodoc
class _$LyricsTranslationKeyCopyWithImpl<$Res>
    implements $LyricsTranslationKeyCopyWith<$Res> {
  _$LyricsTranslationKeyCopyWithImpl(this._self, this._then);

  final LyricsTranslationKey _self;
  final $Res Function(LyricsTranslationKey) _then;

/// Create a copy of LyricsTranslationKey
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? track = null,Object? artist = null,Object? duration = null,Object? language = null,}) {
  return _then(_self.copyWith(
track: null == track ? _self.track : track // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LyricsTranslationKey].
extension LyricsTranslationKeyPatterns on LyricsTranslationKey {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LyricsTranslationKey value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LyricsTranslationKey() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LyricsTranslationKey value)  $default,){
final _that = this;
switch (_that) {
case _LyricsTranslationKey():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LyricsTranslationKey value)?  $default,){
final _that = this;
switch (_that) {
case _LyricsTranslationKey() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String track,  String artist,  int duration,  String language)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LyricsTranslationKey() when $default != null:
return $default(_that.track,_that.artist,_that.duration,_that.language);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String track,  String artist,  int duration,  String language)  $default,) {final _that = this;
switch (_that) {
case _LyricsTranslationKey():
return $default(_that.track,_that.artist,_that.duration,_that.language);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String track,  String artist,  int duration,  String language)?  $default,) {final _that = this;
switch (_that) {
case _LyricsTranslationKey() when $default != null:
return $default(_that.track,_that.artist,_that.duration,_that.language);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LyricsTranslationKey implements LyricsTranslationKey {
  const _LyricsTranslationKey({required this.track, required this.artist, required this.duration, required this.language});
  factory _LyricsTranslationKey.fromJson(Map<String, dynamic> json) => _$LyricsTranslationKeyFromJson(json);

@override final  String track;
@override final  String artist;
@override final  int duration;
@override final  String language;

/// Create a copy of LyricsTranslationKey
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LyricsTranslationKeyCopyWith<_LyricsTranslationKey> get copyWith => __$LyricsTranslationKeyCopyWithImpl<_LyricsTranslationKey>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LyricsTranslationKeyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LyricsTranslationKey&&(identical(other.track, track) || other.track == track)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.language, language) || other.language == language));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,track,artist,duration,language);

@override
String toString() {
  return 'LyricsTranslationKey(track: $track, artist: $artist, duration: $duration, language: $language)';
}


}

/// @nodoc
abstract mixin class _$LyricsTranslationKeyCopyWith<$Res> implements $LyricsTranslationKeyCopyWith<$Res> {
  factory _$LyricsTranslationKeyCopyWith(_LyricsTranslationKey value, $Res Function(_LyricsTranslationKey) _then) = __$LyricsTranslationKeyCopyWithImpl;
@override @useResult
$Res call({
 String track, String artist, int duration, String language
});




}
/// @nodoc
class __$LyricsTranslationKeyCopyWithImpl<$Res>
    implements _$LyricsTranslationKeyCopyWith<$Res> {
  __$LyricsTranslationKeyCopyWithImpl(this._self, this._then);

  final _LyricsTranslationKey _self;
  final $Res Function(_LyricsTranslationKey) _then;

/// Create a copy of LyricsTranslationKey
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? track = null,Object? artist = null,Object? duration = null,Object? language = null,}) {
  return _then(_LyricsTranslationKey(
track: null == track ? _self.track : track // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
