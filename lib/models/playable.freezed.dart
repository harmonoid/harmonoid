// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playable.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Playable {

 String get uri; String get title; List<String> get subtitle; List<String> get description;
/// Create a copy of Playable
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayableCopyWith<Playable> get copyWith => _$PlayableCopyWithImpl<Playable>(this as Playable, _$identity);

  /// Serializes this Playable to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Playable&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.subtitle, subtitle)&&const DeepCollectionEquality().equals(other.description, description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uri,title,const DeepCollectionEquality().hash(subtitle),const DeepCollectionEquality().hash(description));

@override
String toString() {
  return 'Playable(uri: $uri, title: $title, subtitle: $subtitle, description: $description)';
}


}

/// @nodoc
abstract mixin class $PlayableCopyWith<$Res>  {
  factory $PlayableCopyWith(Playable value, $Res Function(Playable) _then) = _$PlayableCopyWithImpl;
@useResult
$Res call({
 String uri, String title, List<String> subtitle, List<String> description
});




}
/// @nodoc
class _$PlayableCopyWithImpl<$Res>
    implements $PlayableCopyWith<$Res> {
  _$PlayableCopyWithImpl(this._self, this._then);

  final Playable _self;
  final $Res Function(Playable) _then;

/// Create a copy of Playable
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uri = null,Object? title = null,Object? subtitle = null,Object? description = null,}) {
  return _then(_self.copyWith(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as List<String>,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [Playable].
extension PlayablePatterns on Playable {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Playable value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Playable() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Playable value)  $default,){
final _that = this;
switch (_that) {
case _Playable():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Playable value)?  $default,){
final _that = this;
switch (_that) {
case _Playable() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uri,  String title,  List<String> subtitle,  List<String> description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Playable() when $default != null:
return $default(_that.uri,_that.title,_that.subtitle,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uri,  String title,  List<String> subtitle,  List<String> description)  $default,) {final _that = this;
switch (_that) {
case _Playable():
return $default(_that.uri,_that.title,_that.subtitle,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uri,  String title,  List<String> subtitle,  List<String> description)?  $default,) {final _that = this;
switch (_that) {
case _Playable() when $default != null:
return $default(_that.uri,_that.title,_that.subtitle,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Playable implements Playable {
  const _Playable({required this.uri, required this.title, required final  List<String> subtitle, required final  List<String> description}): _subtitle = subtitle,_description = description;
  factory _Playable.fromJson(Map<String, dynamic> json) => _$PlayableFromJson(json);

@override final  String uri;
@override final  String title;
 final  List<String> _subtitle;
@override List<String> get subtitle {
  if (_subtitle is EqualUnmodifiableListView) return _subtitle;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subtitle);
}

 final  List<String> _description;
@override List<String> get description {
  if (_description is EqualUnmodifiableListView) return _description;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_description);
}


/// Create a copy of Playable
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayableCopyWith<_Playable> get copyWith => __$PlayableCopyWithImpl<_Playable>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayableToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Playable&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._subtitle, _subtitle)&&const DeepCollectionEquality().equals(other._description, _description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uri,title,const DeepCollectionEquality().hash(_subtitle),const DeepCollectionEquality().hash(_description));

@override
String toString() {
  return 'Playable(uri: $uri, title: $title, subtitle: $subtitle, description: $description)';
}


}

/// @nodoc
abstract mixin class _$PlayableCopyWith<$Res> implements $PlayableCopyWith<$Res> {
  factory _$PlayableCopyWith(_Playable value, $Res Function(_Playable) _then) = __$PlayableCopyWithImpl;
@override @useResult
$Res call({
 String uri, String title, List<String> subtitle, List<String> description
});




}
/// @nodoc
class __$PlayableCopyWithImpl<$Res>
    implements _$PlayableCopyWith<$Res> {
  __$PlayableCopyWithImpl(this._self, this._then);

  final _Playable _self;
  final $Res Function(_Playable) _then;

/// Create a copy of Playable
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uri = null,Object? title = null,Object? subtitle = null,Object? description = null,}) {
  return _then(_Playable(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self._subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as List<String>,description: null == description ? _self._description : description // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
