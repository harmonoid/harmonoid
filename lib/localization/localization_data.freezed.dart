// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'localization_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LocalizationData {

 String get code; String get name; String get country;
/// Create a copy of LocalizationData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocalizationDataCopyWith<LocalizationData> get copyWith => _$LocalizationDataCopyWithImpl<LocalizationData>(this as LocalizationData, _$identity);

  /// Serializes this LocalizationData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalizationData&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.country, country) || other.country == country));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,name,country);

@override
String toString() {
  return 'LocalizationData(code: $code, name: $name, country: $country)';
}


}

/// @nodoc
abstract mixin class $LocalizationDataCopyWith<$Res>  {
  factory $LocalizationDataCopyWith(LocalizationData value, $Res Function(LocalizationData) _then) = _$LocalizationDataCopyWithImpl;
@useResult
$Res call({
 String code, String name, String country
});




}
/// @nodoc
class _$LocalizationDataCopyWithImpl<$Res>
    implements $LocalizationDataCopyWith<$Res> {
  _$LocalizationDataCopyWithImpl(this._self, this._then);

  final LocalizationData _self;
  final $Res Function(LocalizationData) _then;

/// Create a copy of LocalizationData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? name = null,Object? country = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LocalizationData].
extension LocalizationDataPatterns on LocalizationData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocalizationData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocalizationData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocalizationData value)  $default,){
final _that = this;
switch (_that) {
case _LocalizationData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocalizationData value)?  $default,){
final _that = this;
switch (_that) {
case _LocalizationData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String name,  String country)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocalizationData() when $default != null:
return $default(_that.code,_that.name,_that.country);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String name,  String country)  $default,) {final _that = this;
switch (_that) {
case _LocalizationData():
return $default(_that.code,_that.name,_that.country);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String name,  String country)?  $default,) {final _that = this;
switch (_that) {
case _LocalizationData() when $default != null:
return $default(_that.code,_that.name,_that.country);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LocalizationData implements LocalizationData {
  const _LocalizationData({required this.code, required this.name, required this.country});
  factory _LocalizationData.fromJson(Map<String, dynamic> json) => _$LocalizationDataFromJson(json);

@override final  String code;
@override final  String name;
@override final  String country;

/// Create a copy of LocalizationData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocalizationDataCopyWith<_LocalizationData> get copyWith => __$LocalizationDataCopyWithImpl<_LocalizationData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocalizationDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocalizationData&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.country, country) || other.country == country));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,name,country);

@override
String toString() {
  return 'LocalizationData(code: $code, name: $name, country: $country)';
}


}

/// @nodoc
abstract mixin class _$LocalizationDataCopyWith<$Res> implements $LocalizationDataCopyWith<$Res> {
  factory _$LocalizationDataCopyWith(_LocalizationData value, $Res Function(_LocalizationData) _then) = __$LocalizationDataCopyWithImpl;
@override @useResult
$Res call({
 String code, String name, String country
});




}
/// @nodoc
class __$LocalizationDataCopyWithImpl<$Res>
    implements _$LocalizationDataCopyWith<$Res> {
  __$LocalizationDataCopyWithImpl(this._self, this._then);

  final _LocalizationData _self;
  final $Res Function(_LocalizationData) _then;

/// Create a copy of LocalizationData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? name = null,Object? country = null,}) {
  return _then(_LocalizationData(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
