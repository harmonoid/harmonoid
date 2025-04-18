// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playable.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Playable _$PlayableFromJson(Map<String, dynamic> json) {
  return _Playable.fromJson(json);
}

/// @nodoc
mixin _$Playable {
  String get uri => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  List<String> get subtitle => throw _privateConstructorUsedError;
  List<String> get description => throw _privateConstructorUsedError;

  /// Serializes this Playable to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Playable
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlayableCopyWith<Playable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayableCopyWith<$Res> {
  factory $PlayableCopyWith(Playable value, $Res Function(Playable) then) =
      _$PlayableCopyWithImpl<$Res, Playable>;
  @useResult
  $Res call(
      {String uri,
      String title,
      List<String> subtitle,
      List<String> description});
}

/// @nodoc
class _$PlayableCopyWithImpl<$Res, $Val extends Playable>
    implements $PlayableCopyWith<$Res> {
  _$PlayableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Playable
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? title = null,
    Object? subtitle = null,
    Object? description = null,
  }) {
    return _then(_value.copyWith(
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      subtitle: null == subtitle
          ? _value.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as List<String>,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlayableImplCopyWith<$Res>
    implements $PlayableCopyWith<$Res> {
  factory _$$PlayableImplCopyWith(
          _$PlayableImpl value, $Res Function(_$PlayableImpl) then) =
      __$$PlayableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String uri,
      String title,
      List<String> subtitle,
      List<String> description});
}

/// @nodoc
class __$$PlayableImplCopyWithImpl<$Res>
    extends _$PlayableCopyWithImpl<$Res, _$PlayableImpl>
    implements _$$PlayableImplCopyWith<$Res> {
  __$$PlayableImplCopyWithImpl(
      _$PlayableImpl _value, $Res Function(_$PlayableImpl) _then)
      : super(_value, _then);

  /// Create a copy of Playable
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? title = null,
    Object? subtitle = null,
    Object? description = null,
  }) {
    return _then(_$PlayableImpl(
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      subtitle: null == subtitle
          ? _value._subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as List<String>,
      description: null == description
          ? _value._description
          : description // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlayableImpl implements _Playable {
  const _$PlayableImpl(
      {required this.uri,
      required this.title,
      required final List<String> subtitle,
      required final List<String> description})
      : _subtitle = subtitle,
        _description = description;

  factory _$PlayableImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayableImplFromJson(json);

  @override
  final String uri;
  @override
  final String title;
  final List<String> _subtitle;
  @override
  List<String> get subtitle {
    if (_subtitle is EqualUnmodifiableListView) return _subtitle;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subtitle);
  }

  final List<String> _description;
  @override
  List<String> get description {
    if (_description is EqualUnmodifiableListView) return _description;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_description);
  }

  @override
  String toString() {
    return 'Playable(uri: $uri, title: $title, subtitle: $subtitle, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayableImpl &&
            (identical(other.uri, uri) || other.uri == uri) &&
            (identical(other.title, title) || other.title == title) &&
            const DeepCollectionEquality().equals(other._subtitle, _subtitle) &&
            const DeepCollectionEquality()
                .equals(other._description, _description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      uri,
      title,
      const DeepCollectionEquality().hash(_subtitle),
      const DeepCollectionEquality().hash(_description));

  /// Create a copy of Playable
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayableImplCopyWith<_$PlayableImpl> get copyWith =>
      __$$PlayableImplCopyWithImpl<_$PlayableImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayableImplToJson(
      this,
    );
  }
}

abstract class _Playable implements Playable {
  const factory _Playable(
      {required final String uri,
      required final String title,
      required final List<String> subtitle,
      required final List<String> description}) = _$PlayableImpl;

  factory _Playable.fromJson(Map<String, dynamic> json) =
      _$PlayableImpl.fromJson;

  @override
  String get uri;
  @override
  String get title;
  @override
  List<String> get subtitle;
  @override
  List<String> get description;

  /// Create a copy of Playable
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlayableImplCopyWith<_$PlayableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
