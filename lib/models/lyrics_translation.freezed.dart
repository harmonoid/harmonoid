// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lyrics_translation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LyricsTranslation {

 bool get same; Lyrics? get lyrics;
/// Create a copy of LyricsTranslation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LyricsTranslationCopyWith<LyricsTranslation> get copyWith => _$LyricsTranslationCopyWithImpl<LyricsTranslation>(this as LyricsTranslation, _$identity);

  /// Serializes this LyricsTranslation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LyricsTranslation&&(identical(other.same, same) || other.same == same)&&const DeepCollectionEquality().equals(other.lyrics, lyrics));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,same,const DeepCollectionEquality().hash(lyrics));

@override
String toString() {
  return 'LyricsTranslation(same: $same, lyrics: $lyrics)';
}


}

/// @nodoc
abstract mixin class $LyricsTranslationCopyWith<$Res>  {
  factory $LyricsTranslationCopyWith(LyricsTranslation value, $Res Function(LyricsTranslation) _then) = _$LyricsTranslationCopyWithImpl;
@useResult
$Res call({
 bool same, Lyrics? lyrics
});




}
/// @nodoc
class _$LyricsTranslationCopyWithImpl<$Res>
    implements $LyricsTranslationCopyWith<$Res> {
  _$LyricsTranslationCopyWithImpl(this._self, this._then);

  final LyricsTranslation _self;
  final $Res Function(LyricsTranslation) _then;

/// Create a copy of LyricsTranslation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? same = null,Object? lyrics = freezed,}) {
  return _then(_self.copyWith(
same: null == same ? _self.same : same // ignore: cast_nullable_to_non_nullable
as bool,lyrics: freezed == lyrics ? _self.lyrics : lyrics // ignore: cast_nullable_to_non_nullable
as Lyrics?,
  ));
}

}


/// Adds pattern-matching-related methods to [LyricsTranslation].
extension LyricsTranslationPatterns on LyricsTranslation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LyricsTranslation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LyricsTranslation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LyricsTranslation value)  $default,){
final _that = this;
switch (_that) {
case _LyricsTranslation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LyricsTranslation value)?  $default,){
final _that = this;
switch (_that) {
case _LyricsTranslation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool same,  Lyrics? lyrics)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LyricsTranslation() when $default != null:
return $default(_that.same,_that.lyrics);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool same,  Lyrics? lyrics)  $default,) {final _that = this;
switch (_that) {
case _LyricsTranslation():
return $default(_that.same,_that.lyrics);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool same,  Lyrics? lyrics)?  $default,) {final _that = this;
switch (_that) {
case _LyricsTranslation() when $default != null:
return $default(_that.same,_that.lyrics);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LyricsTranslation implements LyricsTranslation {
  const _LyricsTranslation({required this.same, required final  Lyrics? lyrics}): _lyrics = lyrics;
  factory _LyricsTranslation.fromJson(Map<String, dynamic> json) => _$LyricsTranslationFromJson(json);

@override final  bool same;
 final  Lyrics? _lyrics;
@override Lyrics? get lyrics {
  final value = _lyrics;
  if (value == null) return null;
  if (_lyrics is EqualUnmodifiableListView) return _lyrics;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of LyricsTranslation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LyricsTranslationCopyWith<_LyricsTranslation> get copyWith => __$LyricsTranslationCopyWithImpl<_LyricsTranslation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LyricsTranslationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LyricsTranslation&&(identical(other.same, same) || other.same == same)&&const DeepCollectionEquality().equals(other._lyrics, _lyrics));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,same,const DeepCollectionEquality().hash(_lyrics));

@override
String toString() {
  return 'LyricsTranslation(same: $same, lyrics: $lyrics)';
}


}

/// @nodoc
abstract mixin class _$LyricsTranslationCopyWith<$Res> implements $LyricsTranslationCopyWith<$Res> {
  factory _$LyricsTranslationCopyWith(_LyricsTranslation value, $Res Function(_LyricsTranslation) _then) = __$LyricsTranslationCopyWithImpl;
@override @useResult
$Res call({
 bool same, Lyrics? lyrics
});




}
/// @nodoc
class __$LyricsTranslationCopyWithImpl<$Res>
    implements _$LyricsTranslationCopyWith<$Res> {
  __$LyricsTranslationCopyWithImpl(this._self, this._then);

  final _LyricsTranslation _self;
  final $Res Function(_LyricsTranslation) _then;

/// Create a copy of LyricsTranslation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? same = null,Object? lyrics = freezed,}) {
  return _then(_LyricsTranslation(
same: null == same ? _self.same : same // ignore: cast_nullable_to_non_nullable
as bool,lyrics: freezed == lyrics ? _self._lyrics : lyrics // ignore: cast_nullable_to_non_nullable
as Lyrics?,
  ));
}


}

// dart format on
