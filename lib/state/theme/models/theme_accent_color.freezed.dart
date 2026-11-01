// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'theme_accent_color.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ThemeAccentColor {

 int get light; int get dark;
/// Create a copy of ThemeAccentColor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThemeAccentColorCopyWith<ThemeAccentColor> get copyWith => _$ThemeAccentColorCopyWithImpl<ThemeAccentColor>(this as ThemeAccentColor, _$identity);

  /// Serializes this ThemeAccentColor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThemeAccentColor&&(identical(other.light, light) || other.light == light)&&(identical(other.dark, dark) || other.dark == dark));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,light,dark);

@override
String toString() {
  return 'ThemeAccentColor(light: $light, dark: $dark)';
}


}

/// @nodoc
abstract mixin class $ThemeAccentColorCopyWith<$Res>  {
  factory $ThemeAccentColorCopyWith(ThemeAccentColor value, $Res Function(ThemeAccentColor) _then) = _$ThemeAccentColorCopyWithImpl;
@useResult
$Res call({
 int light, int dark
});




}
/// @nodoc
class _$ThemeAccentColorCopyWithImpl<$Res>
    implements $ThemeAccentColorCopyWith<$Res> {
  _$ThemeAccentColorCopyWithImpl(this._self, this._then);

  final ThemeAccentColor _self;
  final $Res Function(ThemeAccentColor) _then;

/// Create a copy of ThemeAccentColor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? light = null,Object? dark = null,}) {
  return _then(_self.copyWith(
light: null == light ? _self.light : light // ignore: cast_nullable_to_non_nullable
as int,dark: null == dark ? _self.dark : dark // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ThemeAccentColor].
extension ThemeAccentColorPatterns on ThemeAccentColor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThemeAccentColor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThemeAccentColor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThemeAccentColor value)  $default,){
final _that = this;
switch (_that) {
case _ThemeAccentColor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThemeAccentColor value)?  $default,){
final _that = this;
switch (_that) {
case _ThemeAccentColor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int light,  int dark)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThemeAccentColor() when $default != null:
return $default(_that.light,_that.dark);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int light,  int dark)  $default,) {final _that = this;
switch (_that) {
case _ThemeAccentColor():
return $default(_that.light,_that.dark);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int light,  int dark)?  $default,) {final _that = this;
switch (_that) {
case _ThemeAccentColor() when $default != null:
return $default(_that.light,_that.dark);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThemeAccentColor implements ThemeAccentColor {
  const _ThemeAccentColor({required this.light, required this.dark});
  factory _ThemeAccentColor.fromJson(Map<String, dynamic> json) => _$ThemeAccentColorFromJson(json);

@override final  int light;
@override final  int dark;

/// Create a copy of ThemeAccentColor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThemeAccentColorCopyWith<_ThemeAccentColor> get copyWith => __$ThemeAccentColorCopyWithImpl<_ThemeAccentColor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThemeAccentColorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThemeAccentColor&&(identical(other.light, light) || other.light == light)&&(identical(other.dark, dark) || other.dark == dark));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,light,dark);

@override
String toString() {
  return 'ThemeAccentColor(light: $light, dark: $dark)';
}


}

/// @nodoc
abstract mixin class _$ThemeAccentColorCopyWith<$Res> implements $ThemeAccentColorCopyWith<$Res> {
  factory _$ThemeAccentColorCopyWith(_ThemeAccentColor value, $Res Function(_ThemeAccentColor) _then) = __$ThemeAccentColorCopyWithImpl;
@override @useResult
$Res call({
 int light, int dark
});




}
/// @nodoc
class __$ThemeAccentColorCopyWithImpl<$Res>
    implements _$ThemeAccentColorCopyWith<$Res> {
  __$ThemeAccentColorCopyWithImpl(this._self, this._then);

  final _ThemeAccentColor _self;
  final $Res Function(_ThemeAccentColor) _then;

/// Create a copy of ThemeAccentColor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? light = null,Object? dark = null,}) {
  return _then(_ThemeAccentColor(
light: null == light ? _self.light : light // ignore: cast_nullable_to_non_nullable
as int,dark: null == dark ? _self.dark : dark // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
