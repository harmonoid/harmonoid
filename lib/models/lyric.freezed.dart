// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lyric.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Lyric {

 int get timestamp; String get text;
/// Create a copy of Lyric
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LyricCopyWith<Lyric> get copyWith => _$LyricCopyWithImpl<Lyric>(this as Lyric, _$identity);

  /// Serializes this Lyric to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Lyric&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,timestamp,text);

@override
String toString() {
  return 'Lyric(timestamp: $timestamp, text: $text)';
}


}

/// @nodoc
abstract mixin class $LyricCopyWith<$Res>  {
  factory $LyricCopyWith(Lyric value, $Res Function(Lyric) _then) = _$LyricCopyWithImpl;
@useResult
$Res call({
 int timestamp, String text
});




}
/// @nodoc
class _$LyricCopyWithImpl<$Res>
    implements $LyricCopyWith<$Res> {
  _$LyricCopyWithImpl(this._self, this._then);

  final Lyric _self;
  final $Res Function(Lyric) _then;

/// Create a copy of Lyric
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? timestamp = null,Object? text = null,}) {
  return _then(_self.copyWith(
timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Lyric].
extension LyricPatterns on Lyric {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Lyric value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Lyric() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Lyric value)  $default,){
final _that = this;
switch (_that) {
case _Lyric():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Lyric value)?  $default,){
final _that = this;
switch (_that) {
case _Lyric() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int timestamp,  String text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Lyric() when $default != null:
return $default(_that.timestamp,_that.text);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int timestamp,  String text)  $default,) {final _that = this;
switch (_that) {
case _Lyric():
return $default(_that.timestamp,_that.text);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int timestamp,  String text)?  $default,) {final _that = this;
switch (_that) {
case _Lyric() when $default != null:
return $default(_that.timestamp,_that.text);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Lyric implements Lyric {
  const _Lyric({required this.timestamp, required this.text});
  factory _Lyric.fromJson(Map<String, dynamic> json) => _$LyricFromJson(json);

@override final  int timestamp;
@override final  String text;

/// Create a copy of Lyric
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LyricCopyWith<_Lyric> get copyWith => __$LyricCopyWithImpl<_Lyric>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LyricToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Lyric&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,timestamp,text);

@override
String toString() {
  return 'Lyric(timestamp: $timestamp, text: $text)';
}


}

/// @nodoc
abstract mixin class _$LyricCopyWith<$Res> implements $LyricCopyWith<$Res> {
  factory _$LyricCopyWith(_Lyric value, $Res Function(_Lyric) _then) = __$LyricCopyWithImpl;
@override @useResult
$Res call({
 int timestamp, String text
});




}
/// @nodoc
class __$LyricCopyWithImpl<$Res>
    implements _$LyricCopyWith<$Res> {
  __$LyricCopyWithImpl(this._self, this._then);

  final _Lyric _self;
  final $Res Function(_Lyric) _then;

/// Create a copy of Lyric
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? timestamp = null,Object? text = null,}) {
  return _then(_Lyric(
timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
