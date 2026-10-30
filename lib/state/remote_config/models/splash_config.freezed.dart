// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'splash_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SplashConfig {

 String get url; String get fit; String get alignment; int get delay; String? get backgroundColor;
/// Create a copy of SplashConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SplashConfigCopyWith<SplashConfig> get copyWith => _$SplashConfigCopyWithImpl<SplashConfig>(this as SplashConfig, _$identity);

  /// Serializes this SplashConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SplashConfig&&(identical(other.url, url) || other.url == url)&&(identical(other.fit, fit) || other.fit == fit)&&(identical(other.alignment, alignment) || other.alignment == alignment)&&(identical(other.delay, delay) || other.delay == delay)&&(identical(other.backgroundColor, backgroundColor) || other.backgroundColor == backgroundColor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,fit,alignment,delay,backgroundColor);

@override
String toString() {
  return 'SplashConfig(url: $url, fit: $fit, alignment: $alignment, delay: $delay, backgroundColor: $backgroundColor)';
}


}

/// @nodoc
abstract mixin class $SplashConfigCopyWith<$Res>  {
  factory $SplashConfigCopyWith(SplashConfig value, $Res Function(SplashConfig) _then) = _$SplashConfigCopyWithImpl;
@useResult
$Res call({
 String url, String fit, String alignment, int delay, String? backgroundColor
});




}
/// @nodoc
class _$SplashConfigCopyWithImpl<$Res>
    implements $SplashConfigCopyWith<$Res> {
  _$SplashConfigCopyWithImpl(this._self, this._then);

  final SplashConfig _self;
  final $Res Function(SplashConfig) _then;

/// Create a copy of SplashConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? fit = null,Object? alignment = null,Object? delay = null,Object? backgroundColor = freezed,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,fit: null == fit ? _self.fit : fit // ignore: cast_nullable_to_non_nullable
as String,alignment: null == alignment ? _self.alignment : alignment // ignore: cast_nullable_to_non_nullable
as String,delay: null == delay ? _self.delay : delay // ignore: cast_nullable_to_non_nullable
as int,backgroundColor: freezed == backgroundColor ? _self.backgroundColor : backgroundColor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SplashConfig].
extension SplashConfigPatterns on SplashConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SplashConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SplashConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SplashConfig value)  $default,){
final _that = this;
switch (_that) {
case _SplashConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SplashConfig value)?  $default,){
final _that = this;
switch (_that) {
case _SplashConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  String fit,  String alignment,  int delay,  String? backgroundColor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SplashConfig() when $default != null:
return $default(_that.url,_that.fit,_that.alignment,_that.delay,_that.backgroundColor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  String fit,  String alignment,  int delay,  String? backgroundColor)  $default,) {final _that = this;
switch (_that) {
case _SplashConfig():
return $default(_that.url,_that.fit,_that.alignment,_that.delay,_that.backgroundColor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  String fit,  String alignment,  int delay,  String? backgroundColor)?  $default,) {final _that = this;
switch (_that) {
case _SplashConfig() when $default != null:
return $default(_that.url,_that.fit,_that.alignment,_that.delay,_that.backgroundColor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SplashConfig implements SplashConfig {
  const _SplashConfig({required this.url, required this.fit, required this.alignment, required this.delay, this.backgroundColor});
  factory _SplashConfig.fromJson(Map<String, dynamic> json) => _$SplashConfigFromJson(json);

@override final  String url;
@override final  String fit;
@override final  String alignment;
@override final  int delay;
@override final  String? backgroundColor;

/// Create a copy of SplashConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SplashConfigCopyWith<_SplashConfig> get copyWith => __$SplashConfigCopyWithImpl<_SplashConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SplashConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SplashConfig&&(identical(other.url, url) || other.url == url)&&(identical(other.fit, fit) || other.fit == fit)&&(identical(other.alignment, alignment) || other.alignment == alignment)&&(identical(other.delay, delay) || other.delay == delay)&&(identical(other.backgroundColor, backgroundColor) || other.backgroundColor == backgroundColor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,fit,alignment,delay,backgroundColor);

@override
String toString() {
  return 'SplashConfig(url: $url, fit: $fit, alignment: $alignment, delay: $delay, backgroundColor: $backgroundColor)';
}


}

/// @nodoc
abstract mixin class _$SplashConfigCopyWith<$Res> implements $SplashConfigCopyWith<$Res> {
  factory _$SplashConfigCopyWith(_SplashConfig value, $Res Function(_SplashConfig) _then) = __$SplashConfigCopyWithImpl;
@override @useResult
$Res call({
 String url, String fit, String alignment, int delay, String? backgroundColor
});




}
/// @nodoc
class __$SplashConfigCopyWithImpl<$Res>
    implements _$SplashConfigCopyWith<$Res> {
  __$SplashConfigCopyWithImpl(this._self, this._then);

  final _SplashConfig _self;
  final $Res Function(_SplashConfig) _then;

/// Create a copy of SplashConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? fit = null,Object? alignment = null,Object? delay = null,Object? backgroundColor = freezed,}) {
  return _then(_SplashConfig(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,fit: null == fit ? _self.fit : fit // ignore: cast_nullable_to_non_nullable
as String,alignment: null == alignment ? _self.alignment : alignment // ignore: cast_nullable_to_non_nullable
as String,delay: null == delay ? _self.delay : delay // ignore: cast_nullable_to_non_nullable
as int,backgroundColor: freezed == backgroundColor ? _self.backgroundColor : backgroundColor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
