// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'splash_image.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SplashImage {

 String get url; String get fit; String get alignment; String? get backgroundColor;
/// Create a copy of SplashImage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SplashImageCopyWith<SplashImage> get copyWith => _$SplashImageCopyWithImpl<SplashImage>(this as SplashImage, _$identity);

  /// Serializes this SplashImage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SplashImage&&(identical(other.url, url) || other.url == url)&&(identical(other.fit, fit) || other.fit == fit)&&(identical(other.alignment, alignment) || other.alignment == alignment)&&(identical(other.backgroundColor, backgroundColor) || other.backgroundColor == backgroundColor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,fit,alignment,backgroundColor);

@override
String toString() {
  return 'SplashImage(url: $url, fit: $fit, alignment: $alignment, backgroundColor: $backgroundColor)';
}


}

/// @nodoc
abstract mixin class $SplashImageCopyWith<$Res>  {
  factory $SplashImageCopyWith(SplashImage value, $Res Function(SplashImage) _then) = _$SplashImageCopyWithImpl;
@useResult
$Res call({
 String url, String fit, String alignment, String? backgroundColor
});




}
/// @nodoc
class _$SplashImageCopyWithImpl<$Res>
    implements $SplashImageCopyWith<$Res> {
  _$SplashImageCopyWithImpl(this._self, this._then);

  final SplashImage _self;
  final $Res Function(SplashImage) _then;

/// Create a copy of SplashImage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? fit = null,Object? alignment = null,Object? backgroundColor = freezed,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,fit: null == fit ? _self.fit : fit // ignore: cast_nullable_to_non_nullable
as String,alignment: null == alignment ? _self.alignment : alignment // ignore: cast_nullable_to_non_nullable
as String,backgroundColor: freezed == backgroundColor ? _self.backgroundColor : backgroundColor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SplashImage].
extension SplashImagePatterns on SplashImage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SplashImage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SplashImage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SplashImage value)  $default,){
final _that = this;
switch (_that) {
case _SplashImage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SplashImage value)?  $default,){
final _that = this;
switch (_that) {
case _SplashImage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  String fit,  String alignment,  String? backgroundColor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SplashImage() when $default != null:
return $default(_that.url,_that.fit,_that.alignment,_that.backgroundColor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  String fit,  String alignment,  String? backgroundColor)  $default,) {final _that = this;
switch (_that) {
case _SplashImage():
return $default(_that.url,_that.fit,_that.alignment,_that.backgroundColor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  String fit,  String alignment,  String? backgroundColor)?  $default,) {final _that = this;
switch (_that) {
case _SplashImage() when $default != null:
return $default(_that.url,_that.fit,_that.alignment,_that.backgroundColor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SplashImage implements SplashImage {
  const _SplashImage({required this.url, required this.fit, required this.alignment, this.backgroundColor});
  factory _SplashImage.fromJson(Map<String, dynamic> json) => _$SplashImageFromJson(json);

@override final  String url;
@override final  String fit;
@override final  String alignment;
@override final  String? backgroundColor;

/// Create a copy of SplashImage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SplashImageCopyWith<_SplashImage> get copyWith => __$SplashImageCopyWithImpl<_SplashImage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SplashImageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SplashImage&&(identical(other.url, url) || other.url == url)&&(identical(other.fit, fit) || other.fit == fit)&&(identical(other.alignment, alignment) || other.alignment == alignment)&&(identical(other.backgroundColor, backgroundColor) || other.backgroundColor == backgroundColor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,fit,alignment,backgroundColor);

@override
String toString() {
  return 'SplashImage(url: $url, fit: $fit, alignment: $alignment, backgroundColor: $backgroundColor)';
}


}

/// @nodoc
abstract mixin class _$SplashImageCopyWith<$Res> implements $SplashImageCopyWith<$Res> {
  factory _$SplashImageCopyWith(_SplashImage value, $Res Function(_SplashImage) _then) = __$SplashImageCopyWithImpl;
@override @useResult
$Res call({
 String url, String fit, String alignment, String? backgroundColor
});




}
/// @nodoc
class __$SplashImageCopyWithImpl<$Res>
    implements _$SplashImageCopyWith<$Res> {
  __$SplashImageCopyWithImpl(this._self, this._then);

  final _SplashImage _self;
  final $Res Function(_SplashImage) _then;

/// Create a copy of SplashImage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? fit = null,Object? alignment = null,Object? backgroundColor = freezed,}) {
  return _then(_SplashImage(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,fit: null == fit ? _self.fit : fit // ignore: cast_nullable_to_non_nullable
as String,alignment: null == alignment ? _self.alignment : alignment // ignore: cast_nullable_to_non_nullable
as String,backgroundColor: freezed == backgroundColor ? _self.backgroundColor : backgroundColor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
