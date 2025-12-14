// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'github_release.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GithubRelease {

 String get tagName; String get name; String get body;
/// Create a copy of GithubRelease
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GithubReleaseCopyWith<GithubRelease> get copyWith => _$GithubReleaseCopyWithImpl<GithubRelease>(this as GithubRelease, _$identity);

  /// Serializes this GithubRelease to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GithubRelease&&(identical(other.tagName, tagName) || other.tagName == tagName)&&(identical(other.name, name) || other.name == name)&&(identical(other.body, body) || other.body == body));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tagName,name,body);

@override
String toString() {
  return 'GithubRelease(tagName: $tagName, name: $name, body: $body)';
}


}

/// @nodoc
abstract mixin class $GithubReleaseCopyWith<$Res>  {
  factory $GithubReleaseCopyWith(GithubRelease value, $Res Function(GithubRelease) _then) = _$GithubReleaseCopyWithImpl;
@useResult
$Res call({
 String tagName, String name, String body
});




}
/// @nodoc
class _$GithubReleaseCopyWithImpl<$Res>
    implements $GithubReleaseCopyWith<$Res> {
  _$GithubReleaseCopyWithImpl(this._self, this._then);

  final GithubRelease _self;
  final $Res Function(GithubRelease) _then;

/// Create a copy of GithubRelease
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tagName = null,Object? name = null,Object? body = null,}) {
  return _then(_self.copyWith(
tagName: null == tagName ? _self.tagName : tagName // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GithubRelease].
extension GithubReleasePatterns on GithubRelease {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GithubRelease value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GithubRelease() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GithubRelease value)  $default,){
final _that = this;
switch (_that) {
case _GithubRelease():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GithubRelease value)?  $default,){
final _that = this;
switch (_that) {
case _GithubRelease() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tagName,  String name,  String body)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GithubRelease() when $default != null:
return $default(_that.tagName,_that.name,_that.body);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tagName,  String name,  String body)  $default,) {final _that = this;
switch (_that) {
case _GithubRelease():
return $default(_that.tagName,_that.name,_that.body);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tagName,  String name,  String body)?  $default,) {final _that = this;
switch (_that) {
case _GithubRelease() when $default != null:
return $default(_that.tagName,_that.name,_that.body);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GithubRelease implements GithubRelease {
  const _GithubRelease({required this.tagName, required this.name, required this.body});
  factory _GithubRelease.fromJson(Map<String, dynamic> json) => _$GithubReleaseFromJson(json);

@override final  String tagName;
@override final  String name;
@override final  String body;

/// Create a copy of GithubRelease
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GithubReleaseCopyWith<_GithubRelease> get copyWith => __$GithubReleaseCopyWithImpl<_GithubRelease>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GithubReleaseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GithubRelease&&(identical(other.tagName, tagName) || other.tagName == tagName)&&(identical(other.name, name) || other.name == name)&&(identical(other.body, body) || other.body == body));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tagName,name,body);

@override
String toString() {
  return 'GithubRelease(tagName: $tagName, name: $name, body: $body)';
}


}

/// @nodoc
abstract mixin class _$GithubReleaseCopyWith<$Res> implements $GithubReleaseCopyWith<$Res> {
  factory _$GithubReleaseCopyWith(_GithubRelease value, $Res Function(_GithubRelease) _then) = __$GithubReleaseCopyWithImpl;
@override @useResult
$Res call({
 String tagName, String name, String body
});




}
/// @nodoc
class __$GithubReleaseCopyWithImpl<$Res>
    implements _$GithubReleaseCopyWith<$Res> {
  __$GithubReleaseCopyWithImpl(this._self, this._then);

  final _GithubRelease _self;
  final $Res Function(_GithubRelease) _then;

/// Create a copy of GithubRelease
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tagName = null,Object? name = null,Object? body = null,}) {
  return _then(_GithubRelease(
tagName: null == tagName ? _self.tagName : tagName // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
